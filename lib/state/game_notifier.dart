import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'game_state.dart';
import 'save_service.dart';
import 'providers.dart';
import '../models/hero.dart';
import '../models/enums.dart';
import '../models/expedition.dart';
import '../models/property.dart';
import '../models/inventory.dart';
import '../data/weapons_data.dart';
import '../data/armor_data.dart';
import '../data/loot_tables.dart';
import '../data/classes_data.dart';
import '../data/road_events_data.dart';
import '../data/travel_events_data.dart';
import '../data/spells_data.dart';
import '../data/consumables_data.dart';
import '../utils/portrait_prompts.dart';
import '../utils/location_image_prompts.dart';
import '../utils/world_generator.dart';
import '../models/world_location.dart';
import '../utils/hero_generator.dart';
import '../combat/combat_engine.dart';
import '../combat/combat_result.dart';
import '../models/town_visit.dart';
import '../models/item_instance.dart';
import '../models/property_event.dart';
import '../data/town_data.dart';
import '../data/item_modifiers_data.dart';
import '../data/property_addons_data.dart';
import '../data/property_events_data.dart';
import '../data/devotion_perks_data.dart';
import '../models/devotion_perk.dart';
import '../models/quest.dart';
import '../data/quest_data.dart';

const int _maxOfflineSeconds = 8 * 60 * 60;
const int _inGameDaySeconds = 600;
const int _autoSaveEverySeconds = 60;
const _uuid = Uuid();

class GameNotifier extends Notifier<GameState> {
  Timer? _tickTimer;
  int _secondsSinceLastSave  = 0;
  int _eventRollCooldown     = 300;
  // Prevents the same road event firing twice in a row.
  String? _lastEventId;
  final _rng = Random();

  SaveService get _save => ref.read(saveServiceProvider);

  // ─── PROPERTY HELPERS ──────────────────────────────────────────────────────

  bool _hasProperty(PropertyType type) =>
      state.properties.any((p) => p.type == type);

  bool _propertyHasAddon(PropertyType type, String addonId) {
    final p = state.properties.where((p) => p.type == type).firstOrNull;
    return p?.unlockedAddonIds.contains(addonId) ?? false;
  }

  int get _maxPartySize =>
      _hasProperty(PropertyType.castle) ? 6 : 5;

  // Stables travel-time multiplier (1.0 = no reduction)
  double get _stablesSpeedMultiplier {
    if (!_hasProperty(PropertyType.stables)) return 1.0;
    if (_propertyHasAddon(PropertyType.stables, 'stables_training')) return 0.55;
    if (_propertyHasAddon(PropertyType.stables, 'stables_farrier'))  return 0.65;
    if (_propertyHasAddon(PropertyType.stables, 'stables_paddock'))  return 0.70;
    if (_propertyHasAddon(PropertyType.stables, 'stables_haybarn'))  return 0.75;
    return 0.80;
  }

  // Apothecary recovery-speed multiplier
  int get _recoverySpeedMultiplier {
    if (!_hasProperty(PropertyType.apothecary)) return 1;
    if (_propertyHasAddon(PropertyType.apothecary, 'apothecary_alchemical')) return 16;
    if (_propertyHasAddon(PropertyType.apothecary, 'apothecary_surgery'))    return 8;
    if (_propertyHasAddon(PropertyType.apothecary, 'apothecary_distillery')) return 4;
    if (_propertyHasAddon(PropertyType.apothecary, 'apothecary_garden'))     return 3;
    return 2;
  }

  // General store extra loot items per expedition
  int get _storeBonusLoot {
    if (!_hasProperty(PropertyType.generalStore)) return 0;
    int bonus = 1;
    if (_propertyHasAddon(PropertyType.generalStore, 'store_warehouse')) bonus++;
    if (_propertyHasAddon(PropertyType.generalStore, 'store_license'))   bonus++;
    return bonus;
  }

  // Blacksmith weapon damage bonus (0.0 = none)
  double get _blacksmithDamageBonus {
    if (!_hasProperty(PropertyType.blacksmith)) return 0.0;
    if (_propertyHasAddon(PropertyType.blacksmith, 'blacksmith_masterforge'))  return 0.20;
    if (_propertyHasAddon(PropertyType.blacksmith, 'blacksmith_sharpening'))   return 0.15;
    return 0.10;
  }

  // Maximum rarity tier visible in the Iron Hearth shop
  Rarity get _blacksmithShopMaxRarity {
    if (!_hasProperty(PropertyType.blacksmith)) return Rarity.uncommon;
    if (_propertyHasAddon(PropertyType.blacksmith, 'blacksmith_armory'))      return Rarity.legendary;
    if (_propertyHasAddon(PropertyType.blacksmith, 'blacksmith_apprentice'))  return Rarity.rare;
    return Rarity.uncommon;
  }

  // Flat bonus fraction added to expedition gold from retired heroes (+3% each)
  double get _retirementGoldBonus =>
      state.retirementPerks.where((p) => p == 'gold_legacy').length * 0.03;

  // Flat bonus fraction added to expedition XP from retired heroes (+3% each)
  double get _retirementXpBonus =>
      state.retirementPerks.where((p) => p == 'xp_legacy').length * 0.03;

  @override
  GameState build() => GameState.newGame();

  // ─── INIT ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    final saved = await _save.load();
    if (saved != null) {
      final offlineSeconds = DateTime.now()
          .difference(saved.lastOnlineTime)
          .inSeconds
          .clamp(0, _maxOfflineSeconds);
      state = saved;

      // Map migration: add any named locations introduced since this save was created.
      final savedIds = state.worldMap.map((l) => l.id).toSet();
      final canonical = generateWorldMap();
      final missing = canonical.where((l) => !savedIds.contains(l.id)).toList();
      if (missing.isNotEmpty) {
        state = state.copyWith(worldMap: [...state.worldMap, ...missing]);
      }

      if (offlineSeconds > 10) _applyOfflineProgress(offlineSeconds);
      // Regenerate any portrait that didn't make it to disk in a previous session.
      for (final hero in state.party) {
        if (hero.imageUrl == null) _generatePortrait(hero);
      }
    }
    _startTickTimer();
  }

  void _startTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  // ─── CHARACTER CREATION ────────────────────────────────────────────────────

  void createPlayerCharacter(
    String name,
    HeroClass heroClass,
    FaithType faith, {
    bool hardcore = false,
    bool isFemale = false,
    String? appearanceHint,
  }) {
    final hero = createPlayerHero(name, heroClass, faith, isFemale: isFemale);
    state = state.copyWith(party: [hero], permadeathEnabled: hardcore);
    _save.save(state);
    _generatePortrait(hero, appearanceHint: appearanceHint);
  }

  Future<void> hardReset() async {
    _tickTimer?.cancel();
    await _save.deleteSave();
    state = GameState.newGame();
    _startTickTimer();
  }

  void generateLocationImage(String locationId) {
    if (state.worldMap.any((l) => l.id == locationId && l.imageUrl != null)) return;
    _generateLocationImageAsync(locationId);
  }

  Future<void> _generateLocationImageAsync(String locationId) async {
    try {
      final loc = state.worldMap.where((l) => l.id == locationId).firstOrNull;
      if (loc == null || loc.imageUrl != null) return;
      final replicate = ref.read(replicateServiceProvider);
      final url = await replicate.generateImage(
          buildLocationImagePrompt(loc), aspectRatio: '16:9');
      if (url == null) return;
      // Re-read in case another call beat us here.
      if (state.worldMap.any((l) => l.id == locationId && l.imageUrl != null)) return;
      final updated = state.worldMap
          .map((l) => l.id == locationId ? l.copyWith(imageUrl: url) : l)
          .toList();
      state = state.copyWith(worldMap: updated);
      _save.save(state);
    } catch (_) {}
  }

  // ─── TICK ENGINE ───────────────────────────────────────────────────────────

  void _tick() {
    _applyOneTick();
    _secondsSinceLastSave++;
    if (_secondsSinceLastSave >= _autoSaveEverySeconds) {
      _secondsSinceLastSave = 0;
      _save.save(state);
    }
    _eventRollCooldown--;
    if (_eventRollCooldown <= 0) {
      _eventRollCooldown = 300;
      _maybeFireRoadEvent();
    }
  }

  void _applyOneTick() {
    final s = state;
    final devMode = ref.read(devModeProvider);
    final tickSeconds = devMode ? 30 : 1;
    final earnedInt = (s.goldPerSecond * tickSeconds).floor();

    final recoveryTick = tickSeconds * _recoverySpeedMultiplier;
    final recoveredParty = s.party.map((hero) {
      if (hero.status == HeroStatus.recovering &&
          hero.recoverySecondsRemaining > 0) {
        final newTime = (hero.recoverySecondsRemaining - recoveryTick).clamp(0, 999999);
        return hero.copyWith(
          recoverySecondsRemaining: newTime,
          status: newTime <= 0 ? HeroStatus.active : HeroStatus.recovering,
        );
      }
      return hero;
    }).toList();

    Expedition? expedition = s.activeExpedition;
    bool expeditionCompleted = false;
    String? newPendingTravelEventId;

    if (expedition != null && !expedition.isComplete) {
      // Don't advance time while the player resolves a travel event.
      if (s.pendingTravelEventId == null) {
        expedition = expedition.copyWith(
          elapsedSeconds: min(expedition.elapsedSeconds + tickSeconds, expedition.durationSeconds),
        );
      }

      if (expedition.isTraveling && s.pendingTravelEventId == null) {
        var mask = expedition.travelEventMask;
        // Standard travel event at 50%
        if (mask & 1 == 0 && expedition.travelProgress >= 0.50) {
          if (_rng.nextDouble() < 0.65) {
            final pool = travelEventsFor(expedition.locationType);
            newPendingTravelEventId = pool[_rng.nextInt(pool.length)].id;
          }
          mask |= 1;
          expedition = expedition.copyWith(travelEventMask: mask);
        }
        // Campfire event on long expeditions (> 720s total) at 50% travel
        if (!expedition.campfireFired &&
            expedition.durationSeconds > 720 &&
            expedition.travelProgress >= 0.50 &&
            newPendingTravelEventId == null) {
          final cf = campfireEvents[_rng.nextInt(campfireEvents.length)];
          newPendingTravelEventId = cf.id;
          expedition = expedition.copyWith(campfireFired: true);
        }
      }

      // Healing kit fires at 50% at-location progress (bit 0 of suppliesFlags = bought)
      // Bit 2 of travelEventMask tracks whether the kit already fired
      if (!expedition.isTraveling &&
          s.pendingTravelEventId == null &&
          expedition.suppliesFlags & 1 != 0 &&
          expedition.travelEventMask & 4 == 0 &&
          expedition.atLocationProgress >= 0.50) {
        final currentParty = recoveredParty;
        final healed = currentParty.map((h) {
          if (!expedition!.heroIds.contains(h.id)) return h;
          return h.copyWith(
            currentHealth: (h.currentHealth + 40).clamp(0, h.maxHealth),
          );
        }).toList();
        expedition = expedition.copyWith(
          travelEventMask: expedition.travelEventMask | 4,
        );
        state = s.copyWith(
          party: healed,
          eventLog: [
            'The healing kit is opened on the road. Each hero recovers 40 HP.',
            ...s.eventLog,
          ].take(50).toList(),
        );
      }

      if (expedition.isComplete) {
        if (isFriendlyLocation(expedition.locationType)) {
          _resolveTownArrival(expedition, recoveredParty);
        } else {
          _resolveExpedition(expedition, recoveredParty, s.eventLog);
        }
        expeditionCompleted = true;
      }
    }

    // Tick down the party return animation (marker moving back to Ashenvale).
    // Pause while a return event is pending.
    PartyReturn? updatedPartyReturn = s.partyReturn;
    String? newPendingReturnEventId = s.pendingReturnEventId;
    if (s.partyReturn != null && s.pendingReturnEventId == null) {
      final pr = s.partyReturn!;
      final newRemaining = (pr.secondsRemaining - tickSeconds).clamp(0, pr.totalSeconds);
      // Fire return encounter at 50% of the return journey (once)
      if (!pr.eventFired && pr.returnProgress <= 0.5) {
        final pool = travelEventsFor(
          s.activeExpedition?.locationType ?? LocationType.wilderness);
        newPendingReturnEventId = pool[_rng.nextInt(pool.length)].id;
        updatedPartyReturn = newRemaining <= 0
            ? null
            : pr.copyWith(secondsRemaining: newRemaining, eventFired: true);
      } else {
        updatedPartyReturn =
            newRemaining <= 0 ? null : pr.copyWith(secondsRemaining: newRemaining);
      }
    }

    final newPlaytime = s.totalPlaytimeSeconds + tickSeconds;
    final newDay = newPlaytime ~/ _inGameDaySeconds + 1;

    // Spawn traveling merchant when the day crosses nextMerchantDay
    if (newDay >= s.nextMerchantDay && !s.merchantActive && newDay != s.inGameDay) {
      final stock = _generateMerchantStock();
      final nextDay = newDay + 4 + _rng.nextInt(4); // reappears in 4–7 days
      state = s.copyWith(
        merchantActive: true,
        merchantStock: stock,
        nextMerchantDay: nextDay,
        gold: s.gold + earnedInt,
        party: recoveredParty,
        activeExpedition: expedition,
        totalPlaytimeSeconds: newPlaytime,
        inGameDay: newDay,
        lastOnlineTime: DateTime.now(),
        partyReturn: updatedPartyReturn,
        pendingReturnEventId: newPendingReturnEventId,
        eventLog: [
          'A traveling merchant has arrived on the road! Their wares are rare — and priced to match.',
          ...s.eventLog,
        ].take(50).toList(),
      );
      if (newPendingTravelEventId != null) {
        state = state.copyWith(pendingTravelEventId: newPendingTravelEventId);
      }
      _maybeGeneratePropertyEvent();
      return;
    }

    if (expeditionCompleted) {
      state = state.copyWith(
        gold: state.gold + earnedInt,
        totalPlaytimeSeconds: newPlaytime,
        inGameDay: newDay,
        lastOnlineTime: DateTime.now(),
      );
    } else {
      state = s.copyWith(
        gold: s.gold + earnedInt,
        party: recoveredParty,
        activeExpedition: expedition,
        totalPlaytimeSeconds: newPlaytime,
        inGameDay: newDay,
        lastOnlineTime: DateTime.now(),
        partyReturn: updatedPartyReturn,
        pendingReturnEventId: newPendingReturnEventId,
      );
      if (newPendingTravelEventId != null) {
        state = state.copyWith(pendingTravelEventId: newPendingTravelEventId);
      }
    }

    _maybeGeneratePropertyEvent();
  }

  // Roughly 1 event per 4 minutes per property (1/240 chance per second).
  void _maybeGeneratePropertyEvent() {
    if (state.properties.isEmpty) return;
    final pending = state.pendingPropertyEvents;
    final pendingIds = {for (final e in pending) e.propertyId};

    final newEvents = <PendingPropertyEvent>[];
    for (final prop in state.properties) {
      if (pendingIds.contains(prop.id)) continue;
      if (_rng.nextDouble() >= 1 / 240) continue;

      final pool = eventsForType(prop.type);
      if (pool.isEmpty) continue;
      final def = pool[_rng.nextInt(pool.length)];
      newEvents.add(PendingPropertyEvent(propertyId: prop.id, defId: def.id));
    }

    if (newEvents.isNotEmpty) {
      state = state.copyWith(
        pendingPropertyEvents: [...state.pendingPropertyEvents, ...newEvents],
      );
    }
  }

  void _applyOfflineProgress(int seconds) {
    final s = state;
    final earnedInt = (s.goldPerSecond * seconds).floor();

    final recoveredParty = s.party.map((hero) {
      if (hero.status == HeroStatus.recovering) {
        final remaining =
            (hero.recoverySecondsRemaining - seconds).clamp(0, 999999);
        return hero.copyWith(
          recoverySecondsRemaining: remaining,
          status: remaining <= 0 ? HeroStatus.active : HeroStatus.recovering,
        );
      }
      return hero;
    }).toList();

    Expedition? expedition = s.activeExpedition;
    bool expeditionCompleted = false;

    if (expedition != null && !expedition.isComplete) {
      expedition = expedition.copyWith(
        elapsedSeconds:
            min(expedition.elapsedSeconds + seconds, expedition.durationSeconds),
      );
      if (expedition.isComplete) {
        if (isFriendlyLocation(expedition.locationType)) {
          _resolveTownArrival(expedition, recoveredParty);
        } else {
          _resolveExpedition(expedition, recoveredParty, s.eventLog);
        }
        expeditionCompleted = true;
      }
    }

    final offlineMinutes = seconds ~/ 60;

    if (expeditionCompleted) {
      // _resolveExpedition already updated state fully; layer offline gold + message on top
      state = state.copyWith(
        gold: state.gold + earnedInt,
        eventLog: [
          'You were away for $offlineMinutes minutes. Your road did not wait.',
          ...state.eventLog,
        ].take(50).toList(),
      );
      // Party stays at destination on the map — no return animation needed.
    } else {
      state = s.copyWith(
        gold: s.gold + earnedInt,
        party: recoveredParty,
        activeExpedition: expedition,
        eventLog: [
          'You were away for $offlineMinutes minutes. Your road did not wait.',
          ...s.eventLog,
        ].take(50).toList(),
      );
    }
  }

  // ─── EXPEDITION RESOLUTION ─────────────────────────────────────────────────

  // Updates state directly (gold, inventory, party, expedition, worldMap, eventLog).
  // Callers must re-read state after this returns to see the changes.
  void _resolveExpedition(
    Expedition expedition,
    List<Hero> party,
    List<String> previousLog,
  ) {
    final expeditionParty = expedition.heroIds
        .map((id) {
          try {
            return party.firstWhere((h) => h.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<Hero>()
        .toList();

    if (expeditionParty.isEmpty) return;

    final depth = expedition.depth > 0 ? expedition.depth : 1;

    // Use pre-computed combat summary when available (pre-computed at expedition start
    // so the live combat log and the final resolution are always consistent).
    final stored = _tryExtractStoredSummary(expedition.combatReportJson);
    final int totalGold;
    final int totalXp;
    final List<String> injuredHeroIds;
    final List<String> deadHeroIds;
    final CombatOutcome finalOutcome;
    String resolvedReportJson;

    if (stored != null) {
      totalGold          = stored.totalGold;
      totalXp            = stored.totalXp;
      injuredHeroIds     = stored.injuredHeroIds;
      deadHeroIds        = stored.deadHeroIds;
      finalOutcome       = stored.finalOutcome;
      resolvedReportJson = expedition.combatReportJson!;
    } else {
      // Fallback: run fresh simulation (old save files or missing pre-computation).
      final combatResult = resolveExpedition(expeditionParty, expedition.locationType, depth);
      totalGold          = combatResult.totalGold;
      totalXp            = combatResult.totalXp;
      injuredHeroIds     = combatResult.injuredHeroIds;
      deadHeroIds        = combatResult.deadHeroIds;
      finalOutcome       = combatResult.finalOutcome;
      resolvedReportJson = jsonEncode(_serializeCombatResult(combatResult));
    }

    // Ration penalty — party takes 20 HP damage if they left without food
    if (expedition.suppliesFlags & 4 != 0 && finalOutcome != CombatOutcome.partyWiped) {
      final damageMsg = 'The party suffered from hunger on the road. Each hero loses 20 HP.';
      final hungryParty = party.map((h) {
        if (!expedition.heroIds.contains(h.id)) return h;
        return h.copyWith(currentHealth: (h.currentHealth - 20).clamp(1, h.maxHealth));
      }).toList();
      state = state.copyWith(
        party: hungryParty,
        eventLog: [damageMsg, ...state.eventLog].take(50).toList(),
      );
    }

    // Apply gold from combat — scale by party gold bonuses + retirement legacy
    final partyGoldBonus = expeditionParty.fold(0.0,
        (sum, h) => sum + computeGoldBonus(h.devotionPerkIds)) /
        expeditionParty.length.clamp(1, 99);

    // Location reputation: 5+ visits → +25% gold
    final locId = expedition.worldLocationId ?? '';
    final visitCount = state.locationVisitCounts[locId] ?? 0;
    final reputationGoldBonus = visitCount >= 5 ? 0.25 : 0.0;

    // Investment bonus: +50% gold if this location was invested in
    final investmentBonus = state.investedLocationIds.contains(locId) ? 0.50 : 0.0;

    // Hero bond bonus: +5% gold if any two heroes on this expedition have 5+ expeditions together
    double bondBonus = 0.0;
    if (expedition.heroIds.length >= 2) {
      final ids = [...expedition.heroIds]..sort();
      outer:
      for (int i = 0; i < ids.length; i++) {
        for (int j = i + 1; j < ids.length; j++) {
          final key = '${ids[i]}:${ids[j]}';
          if ((state.heroBonds[key] ?? 0) >= 5) {
            bondBonus = 0.05;
            break outer;
          }
        }
      }
    }

    final scaledGold = (totalGold * (1.0 + partyGoldBonus + _retirementGoldBonus + reputationGoldBonus + investmentBonus + bondBonus)).round();
    state = state.copyWith(gold: state.gold + scaledGold);

    // Clear the investment for this location now that it's been used
    if (investmentBonus > 0) {
      state = state.copyWith(
        investedLocationIds: state.investedLocationIds.where((id) => id != locId).toList(),
        eventLog: [
          'Your prior investment in ${expedition.locationName} paid off. +${(investmentBonus * 100).round()}% gold.',
          ...state.eventLog,
        ].take(50).toList(),
      );
    }

    // Reputation note at 3+ visits
    if (visitCount == 2 && finalOutcome != CombatOutcome.partyWiped) {
      state = state.copyWith(
        eventLog: [
          'The enemies at ${expedition.locationName} grow wary of your party. Expect greater resistance.',
          ...state.eventLog,
        ].take(50).toList(),
      );
    }

    // Award item loot to inventory (general store grants bonus rolls)
    Inventory inv = state.inventory;
    ItemLoot itemLoot;
    final hasGuildBoost = _propertyHasAddon(PropertyType.generalStore, 'store_guild');
    if (finalOutcome == CombatOutcome.partyWiped) {
      itemLoot = ItemLoot(weaponIds: [], armorIds: []);
    } else {
      itemLoot = generateItemLoot(expedition.locationType, depth, guildBoost: hasGuildBoost);
      // General store perk: extra loot rolls
      final bonusRolls = _storeBonusLoot;
      for (int i = 0; i < bonusRolls; i++) {
        final bonus = generateItemLoot(expedition.locationType, depth, guildBoost: hasGuildBoost);
        itemLoot = ItemLoot(
          weaponIds: [...itemLoot.weaponIds, ...bonus.weaponIds],
          armorIds: [...itemLoot.armorIds, ...bonus.armorIds],
          consumableIds: [...itemLoot.consumableIds, ...bonus.consumableIds],
        );
      }
    }
    for (final id in itemLoot.weaponIds) {
      inv = inv.addWeapon(id);
    }
    for (final id in itemLoot.armorIds) {
      inv = inv.addArmor(id);
    }
    for (final id in itemLoot.consumableIds) {
      inv = inv.addConsumable(id);
    }
    state = state.copyWith(inventory: inv);

    // Resolve real item names and patch the report JSON so the victory screen
    // shows what was actually found instead of fake flavor text.
    final lootNames = [
      ...itemLoot.weaponIds.map(
          (id) => allWeapons.where((w) => w.id == id).firstOrNull?.name ?? id),
      ...itemLoot.armorIds.map(
          (id) => allArmor.where((a) => a.id == id).firstOrNull?.name ?? id),
      ...itemLoot.consumableIds.map((id) {
        if (isSpellTome(id)) {
          final sid = tomeSpellId(id);
          final name = sid != null ? spellById(sid)?.name : null;
          return name != null ? 'Tome: $name' : id;
        }
        return consumableById(id)?.name ?? id;
      }),
    ];
    final reportMap = jsonDecode(resolvedReportJson) as Map<String, dynamic>;
    reportMap['loot'] = lootNames;
    resolvedReportJson = jsonEncode(reportMap);

    // Extract final mana for event log
    final finalManaMap = reportMap.containsKey('heroFinalMana')
        ? Map<String, int>.from((reportMap['heroFinalMana'] as Map)
            .map((k, v) => MapEntry(k as String, v as int)))
        : <String, int>{};

    // XP diminishing returns: overleveled parties earn less from shallow content.
    final expHeroes = party.where((h) => expedition.heroIds.contains(h.id));
    final avgHeroLevel = expHeroes.isEmpty
        ? 1.0
        : expHeroes.map((h) => h.level).reduce((a, b) => a + b) /
            expHeroes.length;
    final depthSurplus = avgHeroLevel - expedition.depth * 3.0;
    final xpMultiplier = depthSurplus > 8 ? 0.25
        : depthSurplus > 4 ? 0.5
        : 1.0;
    final effectiveTotalXp = (totalXp * xpMultiplier).round();

    // Apply XP to heroes — each hero earns the full expedition total.
    // Splitting by party size made larger parties level far too slowly.
    var updatedParty = party.map((h) {
      if (!expedition.heroIds.contains(h.id)) return h;
      final xpBonus = computeXpBonus(h.devotionPerkIds) + _retirementXpBonus;
      final xpShare = (effectiveTotalXp * (1.0 + xpBonus)).round();
      final oldLevel = h.level;
      final newXp    = h.experience + xpShare;
      final newLevel = _levelFromXp(newXp);
      var updated    = h.copyWith(experience: newXp, level: newLevel);

      // Grant a new spell on level-up for casters
      if (newLevel > oldLevel && h.heroClass.isCaster) {
        final classSpells = spellsForClass(h.heroClass);
        final unknown     = classSpells.where((s) => !updated.knownSpells.contains(s.id)).toList();
        if (unknown.isNotEmpty) {
          // Prefer tier appropriate to level
          final tier    = newLevel >= 15 ? 3 : (newLevel >= 5 ? 2 : 1);
          final tiered  = unknown.where((s) => s.tier == tier).toList();
          final pick    = tiered.isNotEmpty
              ? tiered[_rng.nextInt(tiered.length)]
              : unknown[_rng.nextInt(unknown.length)];
          updated = updated.copyWith(knownSpells: [...updated.knownSpells, pick.id]);
          state = state.copyWith(
            eventLog: [
              '${updated.name} learned ${pick.name}!',
              ...state.eventLog,
            ].take(50).toList(),
          );
        }
      }
      return updated;
    }).toList();

    // Apply final mana states from combat
    if (stored != null && stored.heroFinalMana.isNotEmpty) {
      updatedParty = updatedParty.map((h) {
        if (!expedition.heroIds.contains(h.id)) return h;
        final finalMana = stored.heroFinalMana[h.id];
        return finalMana != null ? h.copyWith(currentMana: finalMana) : h;
      }).toList();
    }

    // Notify level-10 crossings (subclass unlock)
    for (final id in expedition.heroIds) {
      final before = party.firstWhere((h) => h.id == id, orElse: () => party.first);
      final after  = updatedParty.firstWhere((h) => h.id == id,
          orElse: () => updatedParty.first);
      if (before.level < 10 && after.level >= 10 && after.subclass == null) {
        state = state.copyWith(
          eventLog: [
            '${after.name} has reached Level 10! Choose a specialization in the Party screen.',
            ...state.eventLog,
          ].take(50).toList(),
        );
      }
    }

    // Apply injuries / deaths
    final rng = Random();
    for (final heroId in injuredHeroIds) {
      updatedParty = updatedParty.map((h) {
        if (h.id != heroId) return h;
        final recovery = 120 + rng.nextInt(360);
        return h.copyWith(
          status: HeroStatus.recovering,
          recoverySecondsRemaining: recovery,
          currentHealth: h.maxHealth ~/ 4,
        );
      }).toList();
    }
    for (final heroId in deadHeroIds) {
      updatedParty = updatedParty.map((h) {
        if (h.id != heroId) return h;
        return h.copyWith(status: HeroStatus.dead);
      }).toList();
    }

    // Award devotion
    final newDevotionChoices = <String>[...state.pendingDevotionChoices];
    if (finalOutcome != CombatOutcome.partyWiped) {
      var devParty = updatedParty;
      for (final hero in expeditionParty) {
        final gain = _devotionGain(hero, expedition.locationType, finalOutcome);
        if (gain <= 0) continue;
        devParty = devParty.map((h) {
          if (h.id != hero.id) return h;
          final prev = h.devotion;
          final next = (prev + gain).clamp(0.0, 100.0);
          // Check if a new devotion tier was crossed
          final prevTier = devotionTierUnlocked(prev);
          final nextTier = devotionTierUnlocked(next);
          if (nextTier > prevTier && !newDevotionChoices.contains(h.id)) {
            newDevotionChoices.add(h.id);
            state = state.copyWith(
              eventLog: ['${h.name}\'s faith has grown — a new blessing awaits!', ...state.eventLog]
                  .take(50)
                  .toList(),
            );
          } else if (prev < 30 && next >= 30) {
            state = state.copyWith(
              eventLog: ['${h.name}\'s devotion deepens on the road.', ...state.eventLog]
                  .take(50)
                  .toList(),
            );
          } else if (prev < 70 && next >= 70) {
            state = state.copyWith(
              eventLog: ['${h.name}\'s faith burns with true power!', ...state.eventLog]
                  .take(50)
                  .toList(),
            );
          }
          return h.copyWith(devotion: next);
        }).toList();
      }
      // Merge devotion changes into updatedParty
      updatedParty = updatedParty.map((h) {
        final devHero = devParty.where((d) => d.id == h.id).firstOrNull;
        return devHero != null ? h.copyWith(devotion: devHero.devotion) : h;
      }).toList();
    }
    if (newDevotionChoices != state.pendingDevotionChoices) {
      state = state.copyWith(pendingDevotionChoices: newDevotionChoices);
    }

    state = state.copyWith(party: updatedParty);

    // Store combat report on the expedition AND in top-level state fields so it
    // survives after the player sends a new expedition (activeExpedition is replaced).
    state = state.copyWith(
      activeExpedition: expedition.copyWith(
        completed: true,
        combatReportJson: resolvedReportJson,
      ),
      lastCombatReportJson: resolvedReportJson,
      lastCombatLocationName: expedition.locationName,
      lastCompletedLocationId: expedition.worldLocationId,
    );

    // Reveal nearby map locations
    if (expedition.worldLocationId != null) {
      final updatedMap =
          discoverNearby(state.worldMap, expedition.worldLocationId!);
      state = state.copyWith(worldMap: updatedMap);
    }

    // 12% chance a wanderer joins the party after a victory
    if (finalOutcome == CombatOutcome.victory && state.party.length < _maxPartySize) {
      if (rng.nextDouble() < 0.12) {
        final recruit = generateHero();
        state = state.copyWith(
          party: [...state.party, recruit],
          eventLog: [
            '${recruit.name} crossed your path on the road back. They have asked to join your company.',
            ...state.eventLog,
          ].take(50).toList(),
        );
        _generatePortrait(recruit);
      }
    }

    // Boss instanced loot — depth >= 4 victory drops a guaranteed high-rarity item
    if (depth >= 4 && finalOutcome == CombatOutcome.victory) {
      final bossRarity = depth >= 6 ? Rarity.legendary : Rarity.epic;
      final useWeapon = rng.nextBool();
      String? bossItemId;
      bool bossIsWeapon = useWeapon;
      if (useWeapon) {
        final pool = allWeapons.where((w) => w.rarity == bossRarity).toList();
        if (pool.isEmpty) {
          final fallback = allWeapons.where((w) => w.rarity == Rarity.epic).toList();
          if (fallback.isNotEmpty) { bossItemId = fallback[rng.nextInt(fallback.length)].id; }
        } else {
          bossItemId = pool[rng.nextInt(pool.length)].id;
        }
      } else {
        final pool = allArmor.where((a) => a.rarity == bossRarity).toList();
        if (pool.isEmpty) {
          final fallback = allArmor.where((a) => a.rarity == Rarity.epic).toList();
          if (fallback.isNotEmpty) { bossItemId = fallback[rng.nextInt(fallback.length)].id; bossIsWeapon = false; }
        } else {
          bossItemId = pool[rng.nextInt(pool.length)].id;
        }
      }
      if (bossItemId != null) {
        final mods = generateModifiers(_rng, bossRarity, bossIsWeapon);
        final inst = ItemInstance(
          instanceId: _uuid.v4(),
          baseItemId: bossItemId,
          isWeapon: bossIsWeapon,
          rarity: bossRarity,
          modifiers: mods,
        );
        inv = inv.addItemInstance(inst);
        state = state.copyWith(inventory: inv);
        final rarityLabel = bossRarity == Rarity.legendary ? 'legendary' : 'epic';
        state = state.copyWith(
          eventLog: [
            'A great enemy fell at ${expedition.locationName}. A $rarityLabel trophy was claimed.',
            ...state.eventLog,
          ].take(50).toList(),
        );
      }
    }

    // Quest progress — update active quests against this expedition
    if (finalOutcome != CombatOutcome.partyWiped) {
      var updatedQuests = state.activeQuests.toList();
      var completedTitles = [...state.completedQuestTitles];
      bool questStateChanged = false;

      for (int qi = 0; qi < updatedQuests.length; qi++) {
        final q = updatedQuests[qi];
        if (q.completed) continue;

        bool advanced = false;
        if (q.type == QuestType.expeditionCount) {
          if (q.targetLocationType == null || q.targetLocationType == expedition.locationType) {
            updatedQuests[qi] = q.copyWith(progress: q.progress + 1);
            advanced = true;
          }
        } else if (q.type == QuestType.depthReach) {
          if (depth >= q.targetValue) {
            updatedQuests[qi] = q.copyWith(progress: q.targetValue);
            advanced = true;
          }
        }

        if (advanced && updatedQuests[qi].progress >= q.targetValue) {
          updatedQuests[qi] = updatedQuests[qi].copyWith(completed: true);
          completedTitles = [...completedTitles, q.title];
          state = state.copyWith(
            gold: state.gold + q.rewardGold,
            eventLog: [
              'Quest complete: "${q.title}". ${q.questGiverName} rewards you with ${q.rewardGold} gold.',
              ...state.eventLog,
            ].take(50).toList(),
          );
          questStateChanged = true;
        } else if (advanced) {
          questStateChanged = true;
        }
      }

      if (questStateChanged) {
        state = state.copyWith(
          activeQuests: updatedQuests,
          completedQuestTitles: completedTitles,
        );
      }
    }

    // Track location visit count (only for non-friendly combat locations)
    if (locId.isNotEmpty && finalOutcome != CombatOutcome.partyWiped) {
      final updatedVisits = Map<String, int>.from(state.locationVisitCounts);
      updatedVisits[locId] = (updatedVisits[locId] ?? 0) + 1;
      state = state.copyWith(locationVisitCounts: updatedVisits);
    }

    // Track hero bonds — increment count for each pair of heroes on this expedition
    if (expedition.heroIds.length >= 2 && finalOutcome != CombatOutcome.partyWiped) {
      final ids = [...expedition.heroIds]..sort();
      final updatedBonds = Map<String, int>.from(state.heroBonds);
      for (int i = 0; i < ids.length; i++) {
        for (int j = i + 1; j < ids.length; j++) {
          final key = '${ids[i]}:${ids[j]}';
          final prev = updatedBonds[key] ?? 0;
          updatedBonds[key] = prev + 1;
          if (prev < 5 && updatedBonds[key]! >= 5) {
            // Announce the bond milestone
            final hA = state.party.where((h) => h.id == ids[i]).firstOrNull;
            final hB = state.party.where((h) => h.id == ids[j]).firstOrNull;
            if (hA != null && hB != null) {
              state = state.copyWith(
                eventLog: [
                  '${hA.name} and ${hB.name} have forged a bond on the road. Their partnership brings +5% gold on shared expeditions.',
                  ...state.eventLog,
                ].take(50).toList(),
              );
            }
          }
        }
      }
      state = state.copyWith(heroBonds: updatedBonds);
    }

    // Build and append the expedition result log entry
    final heroNames = expeditionParty.map((h) => h.name).join(', ');
    final outcomeText = switch (finalOutcome) {
      CombatOutcome.victory    => 'returned victorious',
      CombatOutcome.retreat    => 'retreated with wounds',
      CombatOutcome.partyWiped => 'were overwhelmed',
    };
    final lootText = lootNames.isEmpty ? '' : ' Found: ${lootNames.join(', ')}.';

    final casterManaEntries = expeditionParty
        .where((h) => h.heroClass.isCaster)
        .map((h) {
          final mana = finalManaMap[h.id];
          if (mana == null) return null;
          return '${h.name}: $mana/${h.maxMana} MP';
        })
        .whereType<String>()
        .toList();

    state = state.copyWith(
      eventLog: [
        '$heroNames $outcomeText from ${expedition.locationName}. '
            '+$totalGold gold, +$effectiveTotalXp XP${xpMultiplier < 1.0 ? " (reduced — content below level)" : ""}.$lootText Tap to view combat report.',
        if (casterManaEntries.isNotEmpty)
          'Mana remaining — ${casterManaEntries.join('  ·  ')}',
        // Preserve all log entries added during resolution (level-ups, devotion etc.)
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  // ─── TOWN ARRIVAL & ACTIONS ────────────────────────────────────────────────

  void _resolveTownArrival(Expedition expedition, List<Hero> party) {
    final isFaithSiteType = expedition.locationType == LocationType.church ||
        expedition.locationType == LocationType.shrine ||
        expedition.locationType == LocationType.cultSite;
    if (isFaithSiteType) {
      _resolveFaithSiteArrival(expedition, party);
      return;
    }
    final isMonastery = expedition.locationType == LocationType.monastery;
    final rng = Random();

    // Small travel XP for the journey.
    const travelXp = 15;
    final updatedParty = party.map((h) {
      if (!expedition.heroIds.contains(h.id)) return h;
      final newXp = h.experience + travelXp;
      return h.copyWith(experience: newXp, level: _levelFromXp(newXp));
    }).toList();

    // Discover nearby locations.
    var updatedMap = state.worldMap;
    if (expedition.worldLocationId != null) {
      updatedMap = discoverNearby(updatedMap, expedition.worldLocationId!);
    }

    final npcs = generateTownNpcs(rng, isMonastery, count: isMonastery ? 2 : 3);
    final knownSpellIds = state.party.expand((h) => h.knownSpells).toSet().toList();
    final stock = isMonastery
        ? <TraderOffer>[]
        : generateTraderStock(rng, expedition.depth, knownSpellIds: knownSpellIds);
    final innCost = innCostForDepth(expedition.depth);

    // Generate wanderers for hire (towns only, not monasteries)
    final hasStage = _propertyHasAddon(PropertyType.tavern, 'tavern_stage');
    final recruits = <HeroRecruit>[];
    if (!isMonastery) {
      final playerLevel = state.party
          .where((h) => h.isPlayerCharacter)
          .firstOrNull?.level ?? 1;
      // Level band for this zone: depth 1-2 → [1,6], depth 3 → [5,10], etc.
      final zoneBase = switch (expedition.depth) {
        1 || 2 => 1,
        3      => 5,
        4      => 10,
        5      => 14,
        6      => 18,
        _      => 22,
      };
      final recruitCount = 1 + rng.nextInt(2); // 1 or 2 wanderers
      final hireCost = 50 + expedition.depth * 25;
      for (var i = 0; i < recruitCount; i++) {
        var hero = generateHero();
        final levelMin = zoneBase.clamp(1, playerLevel);
        final levelMax = (zoneBase + 5).clamp(levelMin, playerLevel);
        var heroLevel = levelMin + (levelMax > levelMin ? rng.nextInt(levelMax - levelMin + 1) : 0);
        // Bard's Stage: one extra level on top
        if (hasStage) heroLevel = (heroLevel + 1).clamp(1, playerLevel);
        final heroXp = 50 * heroLevel * (heroLevel - 1);
        hero = hero.copyWith(level: heroLevel, experience: heroXp);
        hero = hero.copyWith(currentHealth: hero.maxHealth);
        recruits.add(HeroRecruit(recruitId: _uuid.v4(), hero: hero, hireCost: hireCost));
      }
    }

    // Brewery: monasteries get a small trader stock when owned
    var finalStock = stock;
    if (isMonastery && _propertyHasAddon(PropertyType.tavern, 'tavern_brewery')) {
      finalStock = generateTraderStock(rng, expedition.depth, knownSpellIds: knownSpellIds);
    }
    // Supply Contacts: add one extra trader item to town visits
    if (!isMonastery && _propertyHasAddon(PropertyType.generalStore, 'store_contacts')) {
      final extra = generateTraderStock(rng, expedition.depth, knownSpellIds: knownSpellIds);
      if (extra.isNotEmpty) finalStock = [...finalStock, extra.first];
    }

    // Quest offers for the notice board (towns only, not monasteries)
    final questOffers = isMonastery
        ? <Quest>[]
        : generateQuestOffers(
            rng,
            expedition.depth,
            state.activeQuests.map((q) => q.title).toList(),
            state.completedQuestTitles,
          );

    final visit = TownVisit(
      locationId: expedition.worldLocationId ?? expedition.locationName,
      locationName: expedition.locationName,
      depth: expedition.depth,
      visitType: isMonastery ? TownVisitType.monastery : TownVisitType.town,
      heroIds: expedition.heroIds,
      npcs: npcs,
      traderStock: finalStock,
      innCostPerHero: innCost,
      availableRecruits: recruits,
      questOffers: questOffers,
    );

    final typeLabel = isMonastery ? 'monastery' : 'town';
    final heroNames =
        party.where((h) => expedition.heroIds.contains(h.id)).map((h) => h.name).join(', ');

    state = state.copyWith(
      party: updatedParty,
      worldMap: updatedMap,
      activeTownVisit: visit,
      activeExpedition: expedition.copyWith(completed: true),
      lastCompletedLocationId: expedition.worldLocationId,
      eventLog: [
        '$heroNames arrived at ${expedition.locationName}. The $typeLabel awaits.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  void _resolveFaithSiteArrival(Expedition expedition, List<Hero> party) {
    final rng = Random();
    final typeLabel = switch (expedition.locationType) {
      LocationType.church   => 'church',
      LocationType.shrine   => 'shrine',
      LocationType.cultSite => 'hidden cult',
      _                     => 'sacred site',
    };

    // Apply devotion gains to expedition heroes
    final newDevotionChoices = <String>[...state.pendingDevotionChoices];
    final faithMessages = <String>[];
    var updatedParty = party;
    for (final hero in party.where((h) => expedition.heroIds.contains(h.id))) {
      final gain = _devotionGain(hero, expedition.locationType, CombatOutcome.victory);
      if (gain <= 0) continue;
      final prev = hero.devotion;
      final next = (prev + gain).clamp(0.0, 100.0);
      final prevTier = devotionTierUnlocked(prev);
      final nextTier = devotionTierUnlocked(next);
      faithMessages.add('${hero.name} prays at the $typeLabel. +${gain.toStringAsFixed(0)} devotion.');
      if (nextTier > prevTier && !newDevotionChoices.contains(hero.id)) {
        newDevotionChoices.add(hero.id);
        faithMessages.add('${hero.name}\'s faith has grown — a new blessing awaits!');
      }
      updatedParty = updatedParty.map((h) {
        return h.id == hero.id ? h.copyWith(devotion: next) : h;
      }).toList();
    }

    // Discover nearby locations
    var updatedMap = state.worldMap;
    if (expedition.worldLocationId != null) {
      updatedMap = discoverNearby(updatedMap, expedition.worldLocationId!);
    }

    final visit = TownVisit(
      locationId: expedition.worldLocationId ?? expedition.locationName,
      locationName: expedition.locationName,
      depth: expedition.depth,
      visitType: TownVisitType.faithSite,
      heroIds: expedition.heroIds,
      npcs: [],
      traderStock: [],
      innCostPerHero: 0,
      faithMessages: faithMessages.isEmpty
          ? ['The ${expedition.locationName} stands silent. Your party finds no faithful here.']
          : faithMessages,
    );

    final heroNames = party
        .where((h) => expedition.heroIds.contains(h.id))
        .map((h) => h.name)
        .join(', ');

    state = state.copyWith(
      party: updatedParty,
      worldMap: updatedMap,
      activeTownVisit: visit,
      activeExpedition: expedition.copyWith(completed: true),
      lastCompletedLocationId: expedition.worldLocationId,
      pendingDevotionChoices: newDevotionChoices,
      eventLog: [
        '$heroNames arrived at ${expedition.locationName}. A place of faith on the Ashen Road.',
        ...state.eventLog,
      ].take(50).toList(),
    );

    // Small heal at sacred sites, scaled by each hero's heal bonus perks
    if (rng.nextDouble() < 0.40) {
      final healed = state.party.map((h) {
        if (!expedition.heroIds.contains(h.id)) return h;
        final healMul  = 1.0 + computeHealBonus(h.devotionPerkIds);
        final healAmt  = (h.maxHealth * 0.15 * healMul).round();
        return h.copyWith(
          currentHealth: (h.currentHealth + healAmt).clamp(0, h.maxHealth),
        );
      }).toList();
      state = state.copyWith(
        party: healed,
        eventLog: [
          'The sacred ground eases your wounds. (+15% HP)',
          ...state.eventLog,
        ].take(50).toList(),
      );
    }
  }

  /// Called when a hero picks a devotion perk after crossing a tier threshold.
  void selectDevotionPerk(String heroId, String perkId) {
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    final hero = state.party[heroIdx];
    if (hero.faith == null) return;

    final perk = devotionPerkById(perkId);
    if (perk == null) return;
    if (perk.faithType != hero.faith) return;
    if (hero.devotionPerkIds.contains(perkId)) return;

    // Verify the hero has enough devotion to unlock this tier
    final tierThreshold = devotionTierThresholds[perk.tier - 1];
    if (hero.devotion < tierThreshold) return;

    // Only one perk per tier allowed — check the hero hasn't already chosen one for this tier
    final alreadyHasTier = hero.devotionPerkIds.any((id) {
      final p = devotionPerkById(id);
      return p != null && p.tier == perk.tier;
    });
    if (alreadyHasTier) return;

    final newPerkIds = [...hero.devotionPerkIds, perkId];
    final newStatBonus = computePerkStatBonus(newPerkIds);

    final updatedHero = hero.copyWith(
      devotionPerkIds: newPerkIds,
      perkStatBonus: newStatBonus,
    );
    final updatedParty = [...state.party]..[heroIdx] = updatedHero;

    // Remove this hero from pending choices
    final updatedPending = state.pendingDevotionChoices
        .where((id) => id != heroId)
        .toList();

    state = state.copyWith(
      party: updatedParty,
      pendingDevotionChoices: updatedPending,
    );
    _log('${hero.name} chose the blessing: ${perk.name}.');
  }

  void talkToNpc(String npcId) {
    final visit = state.activeTownVisit;
    if (visit == null) return;
    final updated = visit.copyWith(
      npcs: visit.npcs.map((n) => n.id == npcId ? n.withTalked() : n).toList(),
    );
    state = state.copyWith(activeTownVisit: updated);
  }

  void buyTraderItem(String offerId) {
    final visit = state.activeTownVisit;
    if (visit == null) return;
    final offer = visit.traderStock.where((o) => o.offerId == offerId).firstOrNull;
    if (offer == null || offer.purchased) return;
    if (state.gold < offer.price) return;

    final updatedVisit = visit.copyWith(
      traderStock: visit.traderStock
          .map((o) => o.offerId == offerId ? o.withPurchased() : o)
          .toList(),
    );

    // Spell tome — add to consumables inventory, skip item-instance path
    if (offer.isTome) {
      final tomeId = 'tome_${offer.itemId}';
      state = state.copyWith(
        gold: state.gold - offer.price,
        inventory: state.inventory.addConsumable(tomeId),
        activeTownVisit: updatedVisit,
        eventLog: [
          'Purchased ${offer.displayName} for ${offer.price} gold.',
          ...state.eventLog,
        ].take(50).toList(),
      );
      return;
    }

    final rng = Random();
    final baseRarity = offer.isWeapon
        ? (allWeapons.where((w) => w.id == offer.itemId).firstOrNull?.rarity ?? Rarity.common)
        : (allArmor.where((a) => a.id == offer.itemId).firstOrNull?.rarity ?? Rarity.common);

    final modifiers = generateModifiers(rng, baseRarity, offer.isWeapon);
    final instance = ItemInstance(
      instanceId: 'inst_${DateTime.now().millisecondsSinceEpoch}_$offerId',
      baseItemId: offer.itemId,
      isWeapon: offer.isWeapon,
      rarity: baseRarity,
      modifiers: modifiers,
    );

    state = state.copyWith(
      gold: state.gold - offer.price,
      inventory: state.inventory.addItemInstance(instance),
      activeTownVisit: updatedVisit,
      eventLog: [
        'Purchased ${offer.displayName} for ${offer.price} gold.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  void sellItemInstance(String instanceId) {
    final instance = state.inventory.findInstance(instanceId);
    if (instance == null) return;

    final isEquipped = state.party.any(
      (h) => h.equipment.slotInstanceIds.values.contains(instanceId),
    );
    if (isEquipped) return;

    int baseValue = 0;
    String itemName = '';
    if (instance.isWeapon) {
      final w = allWeapons.where((w) => w.id == instance.baseItemId).firstOrNull;
      baseValue = w?.value ?? 0;
      itemName = w?.name ?? instance.baseItemId;
    } else {
      final a = allArmor.where((a) => a.id == instance.baseItemId).firstOrNull;
      baseValue = a?.value ?? 0;
      itemName = a?.name ?? instance.baseItemId;
    }

    final rarityMult = switch (instance.rarity) {
      Rarity.common    => 0.5,
      Rarity.uncommon  => 0.65,
      Rarity.rare      => 0.8,
      Rarity.epic      => 1.0,
      Rarity.legendary => 1.3,
    };

    final sellValue = (baseValue * rarityMult).round().clamp(1, 99999);
    final inv = state.inventory.removeItemInstance(instanceId);
    state = state.copyWith(gold: state.gold + sellValue, inventory: inv);
    _log('Sold $itemName for $sellValue gold.');
  }

  void equipItemInstance(String heroId, String instanceId) {
    final instance = state.inventory.findInstance(instanceId);
    if (instance == null) return;
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;

    final hero = state.party[heroIdx];
    var inv = state.inventory;

    if (instance.isWeapon) {
      // Return previous non-instanced weapon to inventory (instanced weapons stay in itemInstances)
      if (hero.equipment.slotInstanceIds['mainHand'] == null &&
          hero.equipment.mainHandId != null) {
        inv = inv.addWeapon(hero.equipment.mainHandId!);
      }
      final newSlots = Map<String, String>.from(hero.equipment.slotInstanceIds)
        ..['mainHand'] = instanceId;
      var newEq = hero.equipment.copyWith(
        mainHandId: instance.baseItemId,
        slotInstanceIds: newSlots,
      );
      newEq = newEq.copyWith(modifierTotals: _buildModifierTotals(newEq, inv));
      final updatedHero = hero.copyWith(equipment: newEq);
      final updatedParty = [...state.party]..[heroIdx] = updatedHero;
      state = state.copyWith(party: updatedParty, inventory: inv);
      final weaponName =
          allWeapons.where((w) => w.id == instance.baseItemId).firstOrNull?.name ?? '';
      _log('${hero.name} equipped $weaponName.');
    } else {
      final armor = allArmor.where((a) => a.id == instance.baseItemId).firstOrNull;
      if (armor == null) return;
      final slotName = _armorSlotName(armor.slot);

      if (hero.equipment.slotInstanceIds[slotName] == null) {
        final prevId = _armorIdForSlot(hero.equipment, armor.slot);
        if (prevId != null) inv = inv.addArmor(prevId);
      }

      final newSlots = Map<String, String>.from(hero.equipment.slotInstanceIds)
        ..[slotName] = instanceId;
      var newEq = _setArmorSlot(
          hero.equipment, armor.slot, instance.baseItemId, newSlots);
      newEq = newEq.copyWith(modifierTotals: _buildModifierTotals(newEq, inv));
      final updatedHero = hero.copyWith(equipment: newEq);
      final updatedParty = [...state.party]..[heroIdx] = updatedHero;
      state = state.copyWith(party: updatedParty, inventory: inv);
      _log('${hero.name} equipped ${armor.name}.');
    }
  }

  void useInn() {
    final visit = state.activeTownVisit;
    if (visit == null || visit.innUsed) return;
    final heroCount = visit.heroIds.length;
    final totalCost = visit.innCostPerHero * heroCount;
    if (state.gold < totalCost) return;

    final updatedParty = state.party.map((h) {
      if (!visit.heroIds.contains(h.id)) return h;
      return h.copyWith(
        currentHealth: h.maxHealth,
        currentMana: h.maxMana,
        status: HeroStatus.active,
        recoverySecondsRemaining: 0,
      );
    }).toList();

    state = state.copyWith(
      gold: state.gold - totalCost,
      party: updatedParty,
      activeTownVisit: visit.copyWith(innUsed: true),
      eventLog: [
        'Your party rested at the inn. All heroes fully restored. (–$totalCost gold)',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  void leaveTown() {
    if (state.activeTownVisit == null) return;
    final visit = state.activeTownVisit!;
    final name = visit.locationName;
    final locId = visit.locationId;

    // Track visit count for this town/faith site
    final updatedVisits = Map<String, int>.from(state.locationVisitCounts);
    updatedVisits[locId] = (updatedVisits[locId] ?? 0) + 1;

    // Start the return-journey map marker if the expedition had a travel phase.
    PartyReturn? returnJourney;
    final townExp = state.activeExpedition;
    if (townExp != null && townExp.travelSeconds > 0 && townExp.worldLocationId != null) {
      final loc = state.worldMap
          .where((l) => l.id == townExp.worldLocationId)
          .firstOrNull;
      if (loc != null) {
        returnJourney = PartyReturn(
          destX: loc.x,
          destY: loc.y,
          totalSeconds: townExp.travelSeconds,
          secondsRemaining: townExp.travelSeconds,
        );
      }
    }

    state = state.copyWith(
      activeTownVisit: null,
      clearExpedition: true,
      partyReturn: returnJourney,
      locationVisitCounts: updatedVisits,
      pendingReturnEventId: null,
      eventLog: [
        'Your party left $name and returned to the road.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  void hireHeroFromTown(String recruitId) {
    final visit = state.activeTownVisit;
    if (visit == null) return;
    if (state.party.length >= _maxPartySize) return;
    final recruit = visit.availableRecruits
        .where((r) => r.recruitId == recruitId && !r.hired)
        .firstOrNull;
    if (recruit == null) return;
    if (state.gold < recruit.hireCost) return;

    final updatedVisit = visit.copyWith(
      availableRecruits: visit.availableRecruits
          .map((r) => r.recruitId == recruitId ? r.withHired() : r)
          .toList(),
    );
    state = state.copyWith(
      gold: state.gold - recruit.hireCost,
      party: [...state.party, recruit.hero],
      activeTownVisit: updatedVisit,
      eventLog: [
        '${recruit.hero.name} has joined your company for ${recruit.hireCost} gold.',
        ...state.eventLog,
      ].take(50).toList(),
    );
    _generatePortrait(recruit.hero);
  }

  int _levelFromXp(int xp) {
    var level = 1;
    var threshold = 100;
    while (xp >= threshold && level < 50) {
      xp -= threshold;
      level++;
      threshold = level * 100;
    }
    return level;
  }

  Map<String, dynamic> _serializeCombatResult(ExpeditionCombatResult r) => {
        'totalGold': r.totalGold,
        'totalXp': r.totalXp,
        'finalOutcome': r.finalOutcome.name,
        'loot': r.lootDescriptions,
        'injuredHeroIds': r.injuredHeroIds,
        'deadHeroIds': r.deadHeroIds,
        'heroFinalMana': r.heroFinalMana,
        'encounters': r.encounters
            .map((e) => {
                  'enemyNames': e.enemyNames,
                  'outcome': e.outcome.name,
                  'goldFound': e.goldFound,
                  'xpGained': e.xpGained,
                  'events': e.events
                      .map((ev) => {
                            'text': ev.text,
                            'type': ev.type.name,
                          })
                      .toList(),
                })
            .toList(),
      };

  // Returns a pre-computed summary from stored JSON, or null if unavailable/stale.
  ({
    int totalGold,
    int totalXp,
    List<String> injuredHeroIds,
    List<String> deadHeroIds,
    CombatOutcome finalOutcome,
    List<String> lootDescriptions,
    Map<String, int> heroFinalMana,
  })? _tryExtractStoredSummary(String? json) {
    if (json == null) return null;
    try {
      final j = jsonDecode(json) as Map<String, dynamic>;
      if (!j.containsKey('injuredHeroIds')) return null; // old format
      return (
        totalGold: j['totalGold'] as int,
        totalXp: j['totalXp'] as int,
        injuredHeroIds: List<String>.from(j['injuredHeroIds']),
        deadHeroIds: List<String>.from(j['deadHeroIds']),
        finalOutcome: CombatOutcome.values.byName(j['finalOutcome'] as String),
        lootDescriptions: List<String>.from(j['loot']),
        heroFinalMana: j.containsKey('heroFinalMana')
            ? Map<String, int>.from(
                (j['heroFinalMana'] as Map).map((k, v) => MapEntry(k as String, v as int)))
            : <String, int>{},
      );
    } catch (_) {
      return null;
    }
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  static bool isFriendlyLocation(LocationType type) =>
      type == LocationType.town ||
      type == LocationType.monastery ||
      type == LocationType.church ||
      type == LocationType.shrine ||
      type == LocationType.cultSite;

  // ─── ACTIONS ───────────────────────────────────────────────────────────────

  static int rationCostForDuration(int seconds) {
    if (seconds < 300) return 1;   // < 5 min
    if (seconds < 1200) return 2;  // 5–20 min
    if (seconds < 3600) return 3;  // 20–60 min
    return 4;                      // > 60 min
  }

  void sendExpedition(
    List<String> heroIds,
    String locationName,
    LocationType type,
    int durationSeconds, {
    int depth = 1,
    String? worldLocationId,
    int supplyFlags = 0,
  }) {
    if (state.activeExpedition != null && !state.activeExpedition!.isComplete) return;
    if (state.activeTownVisit != null) return;
    if (worldLocationId != null && worldLocationId == state.lastCompletedLocationId) return;

    // Friendly locations have no combat — skip pre-computation.
    String? combatReportJson;
    List<String> liveCombatLog = [];
    if (!isFriendlyLocation(type)) {
      final expedParty = state.party.where((h) => heroIds.contains(h.id)).toList();
      if (expedParty.isNotEmpty) {
        final preComputed = resolveExpedition(expedParty, type, depth > 0 ? depth : 1);
        liveCombatLog = preComputed.encounters
            .expand((enc) => enc.events.map((e) => e.text))
            .toList();
        combatReportJson = jsonEncode(_serializeCombatResult(preComputed));
      }
    }

    final adjustedDuration = isFriendlyLocation(type)
        ? durationSeconds
        : (durationSeconds * _stablesSpeedMultiplier).round().clamp(10, 999999);

    final travelSecs = (adjustedDuration * 0.30).round().clamp(10, 150);

    // Deduct rations (or flag missing rations in suppliesFlags bit 2)
    final rationCost = rationCostForDuration(adjustedDuration);
    final hasRations = state.rations >= rationCost;
    final newRations = hasRations
        ? state.rations - rationCost
        : state.rations; // deduct what we have but flag missing
    int suppliesFlags = 0;
    if (!hasRations) suppliesFlags |= 4; // bit 2 = rations missing

    // Apply pre-purchased supplies from the departure sheet
    int supplyCost = 0;
    if (supplyFlags & 1 != 0 && state.gold >= 80) {
      suppliesFlags |= 1;
      supplyCost += 80;
    }
    if (supplyFlags & 2 != 0 && state.gold - supplyCost >= 60) {
      suppliesFlags |= 2;
      supplyCost += 60;
    }

    state = state.copyWith(
      activeExpedition: Expedition(
        id: _uuid.v4(),
        locationName: locationName,
        locationType: type,
        heroIds: heroIds,
        durationSeconds: adjustedDuration,
        depth: depth,
        worldLocationId: worldLocationId,
        liveCombatLog: liveCombatLog,
        combatReportJson: combatReportJson,
        travelSeconds: travelSecs,
        suppliesFlags: suppliesFlags,
      ),
      rations: newRations.clamp(0, 999),
      gold: state.gold - supplyCost,
      partyReturn: null,
      pendingTravelEventId: null,
      pendingReturnEventId: null,
    );

    if (!hasRations) {
      _log('Your party sets out with empty rations. They will suffer for it.');
    } else {
      _log('Your party ventures into $locationName.');
    }
  }

  void addHeroToParty(Hero hero) {
    if (state.party.length >= _maxPartySize) return;
    state = state.copyWith(party: [...state.party, hero]);
    _generatePortrait(hero);
  }

  /// Clears all hero portrait URLs and re-queues generation for every hero.
  /// Use from Settings when portraits are missing or the style was changed.
  void wipeAndRegeneratePortraits() {
    final wiped = state.party
        .map((h) => h.copyWith(imageUrl: null))
        .toList();
    state = state.copyWith(party: wiped);
    _save.save(state);
    for (final hero in state.party) {
      _generatePortrait(hero);
    }
  }

  void _generatePortrait(Hero hero, {String? appearanceHint}) {
    // Each portrait fires independently — the service semaphore handles throttling.
    _generatePortraitAsync(hero, appearanceHint: appearanceHint);
  }

  Future<void> _generatePortraitAsync(Hero hero, {String? appearanceHint}) async {
    // Skip if portrait already arrived (e.g., from a parallel call).
    if (state.party.any((h) => h.id == hero.id && h.imageUrl != null)) return;
    try {
      final replicate = ref.read(replicateServiceProvider);
      final prompt = buildPortraitPrompt(hero, appearanceHint: appearanceHint);
      final url = await replicate.generateImage(prompt, aspectRatio: '2:3');
      if (url == null) return;
      // Re-read state — it may have changed while the API call was running.
      final updated = state.party.map((h) {
        return h.id == hero.id ? h.copyWith(imageUrl: url) : h;
      }).toList();
      state = state.copyWith(party: updated);
      _save.save(state);
    } catch (_) {}
  }

  // ─── INVENTORY & EQUIPMENT ────────────────────────────────────────────────

  static ItemModifierTotals _buildModifierTotals(
    HeroEquipment eq,
    Inventory inv,
  ) {
    int bonusDamage = 0, armorPen = 0, lifesteal = 0,
        bonusDefense = 0, bonusHp = 0, thorns = 0;
    double critChance = 0, critDamage = 0, spellPower = 0,
        dodge = 0, damageReduction = 0;

    for (final instanceId in eq.slotInstanceIds.values) {
      final instance = inv.findInstance(instanceId);
      if (instance == null) continue;
      for (final mod in instance.modifiers) {
        switch (mod.statKey) {
          case 'bonusDamage':     bonusDamage    += mod.value.round();
          case 'armorPen':        armorPen       += mod.value.round();
          case 'lifesteal':       lifesteal      += mod.value.round();
          case 'bonusDefense':    bonusDefense   += mod.value.round();
          case 'bonusHp':         bonusHp        += mod.value.round();
          case 'thornsDamage':    thorns         += mod.value.round();
          case 'critChance':      critChance     += mod.value / 100.0;
          case 'critDamage':      critDamage     += mod.value / 100.0;
          case 'spellPower':      spellPower     += mod.value / 100.0;
          case 'dodge':           dodge          += mod.value / 100.0;
          case 'damageReduction': damageReduction += mod.value / 100.0;
        }
      }
    }

    return ItemModifierTotals(
      bonusDamageFlat:      bonusDamage,
      armorPenFlat:         armorPen,
      critChanceBonus:      critChance,
      critDamageBonus:      critDamage,
      lifestealFlat:        lifesteal,
      spellPowerBonus:      spellPower,
      bonusDefenseFlat:     bonusDefense,
      bonusHpFlat:          bonusHp,
      dodgeBonus:           dodge,
      damageReductionBonus: damageReduction,
      thornsDamageFlat:     thorns,
    );
  }

  void equipWeapon(String heroId, String weaponId) {
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    if (!state.inventory.hasWeapon(weaponId)) return;

    final hero = state.party[heroIdx];
    var inv = state.inventory.removeWeapon(weaponId);

    // If the slot had a non-instanced weapon, return it; instanced weapons stay in itemInstances
    if (hero.equipment.slotInstanceIds['mainHand'] == null &&
        hero.equipment.mainHandId != null) {
      inv = inv.addWeapon(hero.equipment.mainHandId!);
    }
    final newSlots = Map<String, String>.from(hero.equipment.slotInstanceIds)
      ..remove('mainHand');

    var newEq = hero.equipment.copyWith(mainHandId: weaponId, slotInstanceIds: newSlots);
    newEq = newEq.copyWith(modifierTotals: _buildModifierTotals(newEq, inv));
    final updatedHero = hero.copyWith(equipment: newEq);
    final updatedParty = [...state.party]..[heroIdx] = updatedHero;
    state = state.copyWith(party: updatedParty, inventory: inv);

    final weaponName =
        allWeapons.where((w) => w.id == weaponId).firstOrNull?.name ?? weaponId;
    _log('${hero.name} equipped $weaponName.');
  }

  void equipArmor(String heroId, String armorId) {
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    if (!state.inventory.hasArmor(armorId)) return;

    final armor = allArmor.where((a) => a.id == armorId).firstOrNull;
    if (armor == null) return;

    final hero = state.party[heroIdx];
    var inv = state.inventory.removeArmor(armorId);
    var eq = hero.equipment;

    final slotName = _armorSlotName(armor.slot);
    final newSlots = Map<String, String>.from(eq.slotInstanceIds)..remove(slotName);

    switch (armor.slot) {
      case ArmorSlot.head:
        if (eq.slotInstanceIds['head'] == null && eq.headId != null) {
          inv = inv.addArmor(eq.headId!);
        }
        eq = eq.copyWith(headId: armorId, slotInstanceIds: newSlots);
      case ArmorSlot.body:
        if (eq.slotInstanceIds['body'] == null && eq.bodyId != null) {
          inv = inv.addArmor(eq.bodyId!);
        }
        eq = eq.copyWith(bodyId: armorId, slotInstanceIds: newSlots);
      case ArmorSlot.hands:
        if (eq.slotInstanceIds['hands'] == null && eq.handsId != null) {
          inv = inv.addArmor(eq.handsId!);
        }
        eq = eq.copyWith(handsId: armorId, slotInstanceIds: newSlots);
      case ArmorSlot.legs:
        if (eq.slotInstanceIds['legs'] == null && eq.legsId != null) {
          inv = inv.addArmor(eq.legsId!);
        }
        eq = eq.copyWith(legsId: armorId, slotInstanceIds: newSlots);
      case ArmorSlot.feet:
        if (eq.slotInstanceIds['feet'] == null && eq.feetId != null) {
          inv = inv.addArmor(eq.feetId!);
        }
        eq = eq.copyWith(feetId: armorId, slotInstanceIds: newSlots);
      case ArmorSlot.shield:
        if (eq.slotInstanceIds['shield'] == null && eq.shieldId != null) {
          inv = inv.addArmor(eq.shieldId!);
        }
        eq = eq.copyWith(shieldId: armorId, slotInstanceIds: newSlots);
    }

    eq = eq.copyWith(modifierTotals: _buildModifierTotals(eq, inv));
    final updatedHero = hero.copyWith(equipment: eq);
    final updatedParty = [...state.party]..[heroIdx] = updatedHero;
    state = state.copyWith(party: updatedParty, inventory: inv);

    _log('${hero.name} equipped ${armor.name}.');
  }

  void unequipWeapon(String heroId) {
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    final hero = state.party[heroIdx];
    if (hero.equipment.mainHandId == null) return;

    var inv = state.inventory;
    // Only return to weapons map if it wasn't an instanced item (instanced stays in itemInstances)
    if (hero.equipment.slotInstanceIds['mainHand'] == null) {
      inv = inv.addWeapon(hero.equipment.mainHandId!);
    }
    final newSlots = Map<String, String>.from(hero.equipment.slotInstanceIds)
      ..remove('mainHand');
    var newEq = hero.equipment.copyWith(mainHandId: null, slotInstanceIds: newSlots);
    newEq = newEq.copyWith(modifierTotals: _buildModifierTotals(newEq, inv));
    final updatedHero = hero.copyWith(equipment: newEq);
    final updatedParty = [...state.party]..[heroIdx] = updatedHero;
    state = state.copyWith(party: updatedParty, inventory: inv);
  }

  void unequipArmor(String heroId, ArmorSlot slot) {
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    final hero = state.party[heroIdx];
    final eq = hero.equipment;

    final slotName = _armorSlotName(slot);
    final armorId = _armorIdForSlot(eq, slot);
    if (armorId == null) return;

    var inv = state.inventory;
    if (eq.slotInstanceIds[slotName] == null) {
      inv = inv.addArmor(armorId);
    }

    final newSlots = Map<String, String>.from(eq.slotInstanceIds)..remove(slotName);
    var newEq = _clearArmorSlot(eq, slot, newSlots);
    newEq = newEq.copyWith(modifierTotals: _buildModifierTotals(newEq, inv));
    final updatedHero = hero.copyWith(equipment: newEq);
    final updatedParty = [...state.party]..[heroIdx] = updatedHero;
    state = state.copyWith(party: updatedParty, inventory: inv);
  }

  void useConsumable(String heroId, String consumableId) {
    if (!state.inventory.hasConsumable(consumableId)) return;
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    final hero = state.party[heroIdx];
    if (!hero.heroClass.isCaster) return;
    final def = consumableById(consumableId);
    if (def == null || def.manaRestore <= 0) return;
    final newMana = (hero.currentMana + def.manaRestore).clamp(0, hero.maxMana);
    if (newMana == hero.currentMana) return;
    final updatedHero = hero.copyWith(currentMana: newMana);
    final updatedParty = [...state.party]..[heroIdx] = updatedHero;
    state = state.copyWith(
      party: updatedParty,
      inventory: state.inventory.removeConsumable(consumableId),
      eventLog: [
        '${hero.name} drank ${def.name}. +${def.manaRestore} mana. ($newMana/${hero.maxMana} MP)',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  void sellWeapon(String weaponId) {
    if (!state.inventory.hasWeapon(weaponId)) return;
    final value = weaponSellValue(weaponId);
    final inv = state.inventory.removeWeapon(weaponId);
    state = state.copyWith(gold: state.gold + value, inventory: inv);
    final name =
        allWeapons.where((w) => w.id == weaponId).firstOrNull?.name ?? weaponId;
    _log('Sold $name for $value gold.');
  }

  void sellArmor(String armorId) {
    if (!state.inventory.hasArmor(armorId)) return;
    final value = armorSellValue(armorId);
    final inv = state.inventory.removeArmor(armorId);
    state = state.copyWith(gold: state.gold + value, inventory: inv);
    final name =
        allArmor.where((a) => a.id == armorId).firstOrNull?.name ?? armorId;
    _log('Sold $name for $value gold.');
  }

  // ─── ARMOR SLOT HELPERS ──────────────────────────────────────────────────

  static String _armorSlotName(ArmorSlot slot) => switch (slot) {
    ArmorSlot.head   => 'head',
    ArmorSlot.body   => 'body',
    ArmorSlot.hands  => 'hands',
    ArmorSlot.legs   => 'legs',
    ArmorSlot.feet   => 'feet',
    ArmorSlot.shield => 'shield',
  };

  static String? _armorIdForSlot(HeroEquipment eq, ArmorSlot slot) => switch (slot) {
    ArmorSlot.head   => eq.headId,
    ArmorSlot.body   => eq.bodyId,
    ArmorSlot.hands  => eq.handsId,
    ArmorSlot.legs   => eq.legsId,
    ArmorSlot.feet   => eq.feetId,
    ArmorSlot.shield => eq.shieldId,
  };

  static HeroEquipment _setArmorSlot(
    HeroEquipment eq, ArmorSlot slot, String armorId, Map<String, String> newSlots) =>
    switch (slot) {
      ArmorSlot.head   => eq.copyWith(headId:   armorId, slotInstanceIds: newSlots),
      ArmorSlot.body   => eq.copyWith(bodyId:   armorId, slotInstanceIds: newSlots),
      ArmorSlot.hands  => eq.copyWith(handsId:  armorId, slotInstanceIds: newSlots),
      ArmorSlot.legs   => eq.copyWith(legsId:   armorId, slotInstanceIds: newSlots),
      ArmorSlot.feet   => eq.copyWith(feetId:   armorId, slotInstanceIds: newSlots),
      ArmorSlot.shield => eq.copyWith(shieldId: armorId, slotInstanceIds: newSlots),
    };

  static HeroEquipment _clearArmorSlot(
    HeroEquipment eq, ArmorSlot slot, Map<String, String> newSlots) =>
    switch (slot) {
      ArmorSlot.head   => eq.copyWith(headId:   null, slotInstanceIds: newSlots),
      ArmorSlot.body   => eq.copyWith(bodyId:   null, slotInstanceIds: newSlots),
      ArmorSlot.hands  => eq.copyWith(handsId:  null, slotInstanceIds: newSlots),
      ArmorSlot.legs   => eq.copyWith(legsId:   null, slotInstanceIds: newSlots),
      ArmorSlot.feet   => eq.copyWith(feetId:   null, slotInstanceIds: newSlots),
      ArmorSlot.shield => eq.copyWith(shieldId: null, slotInstanceIds: newSlots),
    };

  // ─── SUBCLASS ─────────────────────────────────────────────────────────────

  void chooseSubclass(String heroId, Subclass subclass) {
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    final hero = state.party[heroIdx];
    if (hero.subclass != null || hero.level < 10) return;

    final classDef = allClasses.firstWhere((c) => c.heroClass == hero.heroClass);
    final subDef = classDef.subclasses.firstWhere((s) => s.subclass == subclass);

    final updatedHero = hero.copyWith(
      subclass: subclass,
      baseStats: hero.baseStats + subDef.statBonus,
    );
    final updatedParty = [...state.party]..[heroIdx] = updatedHero;
    state = state.copyWith(party: updatedParty);
    _log('${hero.name} has become a ${subDef.name}! The road grows darker.');
  }

  // ─── DEVOTION HELPER ─────────────────────────────────────────────────────

  double _devotionGain(
    Hero hero,
    LocationType type,
    CombatOutcome outcome,
  ) {
    if (hero.faith == null) return 0;
    double gain = 0;

    switch (hero.faith!) {
      case FaithType.luminantChurch:
        if (type == LocationType.dungeon || type == LocationType.ruins) gain += 4;
        if (type == LocationType.monastery) gain += 8;
        if (type == LocationType.church) gain += 18;
      case FaithType.oldWays:
        gain += 3;
        if (type == LocationType.wilderness) gain += 4;
        if (type == LocationType.shrine) gain += 18;
      case FaithType.paleCourt:
        if (type == LocationType.dungeon ||
            type == LocationType.ruins ||
            type == LocationType.monastery) { gain += 5; }
        if (type == LocationType.church || type == LocationType.shrine) gain += 17;
      case FaithType.compactOfSaints:
        if (type == LocationType.town) gain += 7;
        if (outcome == CombatOutcome.victory) gain += 2;
        if (type == LocationType.church) gain += 18;
      case FaithType.ashenRite:
        gain += 3;
        if (type == LocationType.dungeon || type == LocationType.castle) gain += 3;
        if (type == LocationType.cultSite) gain += 20;
    }

    // Apply devotion gain bonus from chosen perks
    final gainBonus = computeDevotionGainBonus(hero.devotionPerkIds);
    if (gainBonus > 0) gain *= (1.0 + gainBonus);

    return gain;
  }

  // ─── ROAD EVENTS ─────────────────────────────────────────────────────────

  void _maybeFireRoadEvent() {
    if (state.pendingEventId != null) return;
    if (state.pendingTravelEventId != null) return;
    if (state.party.isEmpty) return;
    final rng = Random();
    if (rng.nextDouble() > 0.40) return;
    // Never fire the same event twice in a row.
    // Skip hero-join events if the party is already full.
    final partyFull = state.party.length >= _maxPartySize;
    final candidates = allRoadEvents
        .where((e) => e.id != _lastEventId)
        .where((e) => !partyFull || !e.choices.any((c) => c.effect.heroJoins))
        .toList();
    if (candidates.isEmpty) return;
    final event = candidates[rng.nextInt(candidates.length)];
    _lastEventId = event.id;
    state = state.copyWith(pendingEventId: event.id);
  }

  void resolveEventChoice(int choiceIndex) {
    final eventId = state.pendingEventId;
    if (eventId == null) return;
    final event = allRoadEvents.firstWhere(
      (e) => e.id == eventId,
      orElse: () => allRoadEvents.first,
    );
    if (choiceIndex >= event.choices.length) return;
    final choice = event.choices[choiceIndex];
    final effect = choice.effect;

    final newGold = (state.gold + effect.goldDelta).clamp(0, 999999999);

    final updatedParty = state.party.map((h) {
      var updated = h;
      if (effect.partyDamage > 0 && h.status == HeroStatus.active) {
        final newHp = (h.currentHealth - effect.partyDamage).clamp(1, h.maxHealth);
        updated = updated.copyWith(currentHealth: newHp);
      }
      if (effect.partyHeal > 0) {
        final newHp = (h.currentHealth + effect.partyHeal).clamp(0, h.maxHealth);
        updated = updated.copyWith(currentHealth: newHp);
      }
      final devotionMatches = effect.devotionDelta != 0 &&
          h.faith != null &&
          (effect.targetFaith == null || effect.targetFaith == h.faith);
      if (devotionMatches) {
        final newDevotion =
            (h.devotion + effect.devotionDelta).clamp(0.0, 100.0);
        updated = updated.copyWith(devotion: newDevotion);
      }
      return updated;
    }).toList();

    // Hero join from road event
    Hero? heroRecruit;
    if (effect.heroJoins && state.party.length < _maxPartySize) {
      heroRecruit = generateHero();
    }

    // Spell tome from road event
    Inventory updatedInventory = state.inventory;
    if (effect.spellTomeId != null) {
      updatedInventory = updatedInventory.addConsumable('tome_${effect.spellTomeId}');
    }

    // Weapon reward from road event
    if (effect.weaponRewardId != null) {
      updatedInventory = updatedInventory.addWeapon(effect.weaponRewardId!);
    }
    String? poolWeaponId;
    if (effect.weaponRewardPool.isNotEmpty) {
      poolWeaponId = effect.weaponRewardPool[Random().nextInt(effect.weaponRewardPool.length)];
      updatedInventory = updatedInventory.addWeapon(poolWeaponId);
    }

    state = state.copyWith(
      gold: newGold,
      party: heroRecruit != null ? [...updatedParty, heroRecruit] : updatedParty,
      inventory: updatedInventory,
      pendingEventId: null,
      pendingHeroJoinName: heroRecruit?.name,
    );
    _log('${event.title} — ${choice.outcome}');

    if (effect.spellTomeId != null) {
      final spell = spellById(effect.spellTomeId!);
      if (spell != null) _log('A tome of ${spell.name} has been added to your inventory.');
    }
    if (effect.weaponRewardId != null) {
      final weapon = allWeapons.where((w) => w.id == effect.weaponRewardId).firstOrNull;
      if (weapon != null) _log('${weapon.name} has been added to your inventory.');
    }
    if (poolWeaponId != null) {
      final weapon = allWeapons.where((w) => w.id == poolWeaponId).firstOrNull;
      if (weapon != null) _log('${weapon.name} has been added to your inventory.');
    }
    if (heroRecruit != null) {
      _generatePortrait(heroRecruit);
      _log('${heroRecruit.name} has joined your company.');
    }
  }

  void dismissHeroJoinNotification() {
    state = state.copyWith(pendingHeroJoinName: null);
  }

  void resolveReturnEventChoice(int choiceIndex) {
    final eventId = state.pendingReturnEventId;
    if (eventId == null) return;
    final event = travelEventById(eventId);
    if (event == null || choiceIndex >= event.choices.length) return;
    final choice = event.choices[choiceIndex];
    final effect = choice.effect;
    final newGold = (state.gold + effect.goldDelta).clamp(0, 999999999);
    final scaledDamage = (effect.partyDamage * 2.5).round();
    final scaledHeal   = (effect.partyHeal   * 2.5).round();
    final updatedParty = state.party.map((h) {
      var updated = h;
      if (scaledDamage > 0 && h.status == HeroStatus.active) {
        updated = updated.copyWith(currentHealth: (h.currentHealth - scaledDamage).clamp(1, h.maxHealth));
      }
      if (scaledHeal > 0) {
        updated = updated.copyWith(currentHealth: (h.currentHealth + scaledHeal).clamp(0, h.maxHealth));
      }
      return updated;
    }).toList();
    Inventory updatedInventory = state.inventory;
    if (effect.weaponRewardId != null) {
      updatedInventory = updatedInventory.addWeapon(effect.weaponRewardId!);
    }
    if (effect.spellTomeId != null) {
      updatedInventory = updatedInventory.addConsumable('tome_${effect.spellTomeId}');
    }
    state = state.copyWith(
      gold: newGold,
      party: updatedParty,
      inventory: updatedInventory,
      pendingReturnEventId: null,
    );
    _log('${event.title} — ${choice.outcome}');
  }

  void resolveTravelEventChoice(int choiceIndex) {
    final eventId = state.pendingTravelEventId;
    if (eventId == null) return;
    final event = travelEventById(eventId);
    if (event == null || choiceIndex >= event.choices.length) return;
    final choice = event.choices[choiceIndex];
    final effect = choice.effect;

    final newGold = (state.gold + effect.goldDelta).clamp(0, 999999999);

    // Scale HP effects so they register on a 80–150 HP hero.
    final scaledDamage = (effect.partyDamage * 2.5).round();
    final scaledHeal   = (effect.partyHeal   * 2.5).round();

    final updatedParty = state.party.map((h) {
      var updated = h;
      if (scaledDamage > 0 && h.status == HeroStatus.active) {
        final newHp = (h.currentHealth - scaledDamage).clamp(1, h.maxHealth);
        updated = updated.copyWith(currentHealth: newHp);
      }
      if (scaledHeal > 0) {
        final newHp = (h.currentHealth + scaledHeal).clamp(0, h.maxHealth);
        updated = updated.copyWith(currentHealth: newHp);
      }
      final devotionMatches = effect.devotionDelta != 0 &&
          h.faith != null &&
          (effect.targetFaith == null || effect.targetFaith == h.faith);
      if (devotionMatches) {
        final newDevotion = (h.devotion + effect.devotionDelta).clamp(0.0, 100.0);
        updated = updated.copyWith(devotion: newDevotion);
      }
      return updated;
    }).toList();

    // Hero recruit
    Hero? heroRecruit;
    if (effect.heroJoins && state.party.length < _maxPartySize) {
      heroRecruit = generateHero();
    }

    // Item rewards
    Inventory updatedInventory = state.inventory;
    if (effect.spellTomeId != null) {
      updatedInventory = updatedInventory.addConsumable('tome_${effect.spellTomeId}');
    }
    if (effect.weaponRewardId != null) {
      updatedInventory = updatedInventory.addWeapon(effect.weaponRewardId!);
    }
    String? poolWeaponId;
    if (effect.weaponRewardPool.isNotEmpty) {
      poolWeaponId = effect.weaponRewardPool[Random().nextInt(effect.weaponRewardPool.length)];
      updatedInventory = updatedInventory.addWeapon(poolWeaponId);
    }

    state = state.copyWith(
      gold: newGold,
      party: heroRecruit != null ? [...updatedParty, heroRecruit] : updatedParty,
      inventory: updatedInventory,
      pendingTravelEventId: null,
      pendingHeroJoinName: heroRecruit?.name,
    );
    _log('${event.title} — ${choice.outcome}');

    if (effect.spellTomeId != null) {
      final spell = spellById(effect.spellTomeId!);
      if (spell != null) _log('Found spell tome: ${spell.name}.');
    }
    if (effect.weaponRewardId != null) {
      final weapon = allWeapons.where((w) => w.id == effect.weaponRewardId).firstOrNull;
      if (weapon != null) _log('${weapon.name} has been added to your inventory.');
    }
    if (poolWeaponId != null) {
      final weapon = allWeapons.where((w) => w.id == poolWeaponId).firstOrNull;
      if (weapon != null) _log('${weapon.name} has been added to your inventory.');
    }
    if (heroRecruit != null) {
      _generatePortrait(heroRecruit);
      _log('${heroRecruit.name} has joined your company.');
    }
  }

  // ─── RATIONS & SUPPLIES ───────────────────────────────────────────────────

  void buyRations(int count) {
    const rationPrice = 15;
    final totalCost = rationPrice * count;
    if (state.gold < totalCost) return;
    state = state.copyWith(
      gold: state.gold - totalCost,
      rations: state.rations + count,
      eventLog: [
        'Purchased $count ration${count == 1 ? "" : "s"} for $totalCost gold.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  // supplyType: 'healing_kit' (80g, bit 0) or 'lantern' (60g, bit 1)
  void buyExpeditionSupply(String supplyType) {
    final expedition = state.activeExpedition;
    if (expedition == null || expedition.isComplete) return;
    int cost, bit;
    String label;
    switch (supplyType) {
      case 'healing_kit':
        cost = 80; bit = 1; label = 'Healing Kit';
      case 'lantern':
        cost = 60; bit = 2; label = 'Lantern';
      default: return;
    }
    if (expedition.suppliesFlags & bit != 0) return; // already bought
    if (state.gold < cost) return;
    final updated = expedition.copyWith(suppliesFlags: expedition.suppliesFlags | bit);
    state = state.copyWith(
      gold: state.gold - cost,
      activeExpedition: updated,
      eventLog: [
        '$label purchased for $cost gold.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  // ─── TRAVELING MERCHANT ───────────────────────────────────────────────────

  static const _merchantWeaponPool = [
    'war_axe', 'great_axe', 'mace', 'war_hammer', 'battle_axe',
    'katana', 'rapier', 'lance', 'scythe', 'great_sword',
    'crossbow', 'longbow', 'scepter', 'staff', 'wand',
  ];
  static const _merchantArmorPool = [
    'plate_chestplate', 'chain_hauberk', 'scale_breastplate',
    'great_helm', 'chain_coif', 'plate_gauntlets',
    'plate_greaves', 'leather_boots', 'tower_shield',
  ];

  List<MerchantItem> _generateMerchantStock() {
    final rng = Random();
    final items = <MerchantItem>[];
    final count = 4;
    for (int i = 0; i < count; i++) {
      final useWeapon = rng.nextBool();
      final pool = useWeapon ? _merchantWeaponPool : _merchantArmorPool;
      // Pick a valid id from data or fallback to pool entry
      final candidateId = pool[rng.nextInt(pool.length)];
      final isWeapon = useWeapon;
      int baseValue;
      if (isWeapon) {
        final w = allWeapons.where((w) => w.id == candidateId).firstOrNull;
        if (w == null) continue;
        baseValue = w.value;
      } else {
        final a = allArmor.where((a) => a.id == candidateId).firstOrNull;
        if (a == null) continue;
        baseValue = a.value;
      }
      final price = (baseValue * (2.0 + rng.nextDouble())).round().clamp(50, 9999);
      items.add(MerchantItem(id: candidateId, isArmor: !isWeapon, price: price));
    }
    return items;
  }

  void buyMerchantItem(int itemIndex) {
    if (!state.merchantActive) return;
    if (itemIndex < 0 || itemIndex >= state.merchantStock.length) return;
    final item = state.merchantStock[itemIndex];
    if (item.sold) return;
    if (state.gold < item.price) return;

    final rng = Random();
    Inventory updatedInv = state.inventory;
    if (!item.isArmor) {
      final w = allWeapons.where((w) => w.id == item.id).firstOrNull;
      if (w != null) {
        final mods = generateModifiers(rng, w.rarity, true);
        final inst = ItemInstance(
          instanceId: _uuid.v4(),
          baseItemId: item.id,
          isWeapon: true,
          rarity: w.rarity,
          modifiers: mods,
        );
        updatedInv = updatedInv.addItemInstance(inst);
      }
    } else {
      final a = allArmor.where((a) => a.id == item.id).firstOrNull;
      if (a != null) {
        final mods = generateModifiers(rng, a.rarity, false);
        final inst = ItemInstance(
          instanceId: _uuid.v4(),
          baseItemId: item.id,
          isWeapon: false,
          rarity: a.rarity,
          modifiers: mods,
        );
        updatedInv = updatedInv.addItemInstance(inst);
      }
    }

    final updatedStock = state.merchantStock.toList()..[itemIndex] = item.copyWith(sold: true);
    state = state.copyWith(
      gold: state.gold - item.price,
      inventory: updatedInv,
      merchantStock: updatedStock,
      eventLog: [
        'Purchased from the traveling merchant for ${item.price} gold.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  void dismissMerchant() {
    if (!state.merchantActive) return;
    state = state.copyWith(
      merchantActive: false,
      merchantStock: const [],
      eventLog: [
        'The traveling merchant packs up and moves on.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  // ─── FAITH DONATIONS ─────────────────────────────────────────────────────

  void donateFaith() {
    const cost = 100;
    const devotionGain = 25.0;
    final visit = state.activeTownVisit;
    if (visit == null) return;
    if (state.gold < cost) return;

    final updatedParty = state.party.map((h) {
      if (!visit.heroIds.contains(h.id) || h.faith == null) return h;
      final next = (h.devotion + devotionGain).clamp(0.0, 100.0);
      return h.copyWith(devotion: next);
    }).toList();

    state = state.copyWith(
      gold: state.gold - cost,
      party: updatedParty,
      eventLog: [
        'Your party donated $cost gold to ${visit.locationName}. +${devotionGain.round()} devotion to all faithful heroes.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  // ─── CARTOGRAPHER ─────────────────────────────────────────────────────────

  void cartographerReveal(String fromLocationId) {
    const cost = 250;
    if (state.gold < cost) return;
    // Find all undiscovered locations
    final undiscovered = state.worldMap.where((l) => !l.discovered).toList();
    if (undiscovered.isEmpty) return;
    // Pick the one closest to fromLocationId
    final from = state.worldMap.where((l) => l.id == fromLocationId).firstOrNull;
    WorldLocation target;
    if (from != null) {
      undiscovered.sort((a, b) {
        final da = (a.x - from.x) * (a.x - from.x) + (a.y - from.y) * (a.y - from.y);
        final db = (b.x - from.x) * (b.x - from.x) + (b.y - from.y) * (b.y - from.y);
        return da.compareTo(db);
      });
      target = undiscovered.first;
    } else {
      target = undiscovered[_rng.nextInt(undiscovered.length)];
    }
    final updatedMap = state.worldMap
        .map((l) => l.id == target.id ? l.copyWith(discovered: true) : l)
        .toList();
    state = state.copyWith(
      gold: state.gold - cost,
      worldMap: updatedMap,
      eventLog: [
        'A cartographer\'s map reveals ${target.name}.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  // ─── LOCATION INVESTMENT ─────────────────────────────────────────────────

  void investInLocation(String locationId) {
    const cost = 200;
    if (state.gold < cost) return;
    if (state.investedLocationIds.contains(locationId)) return;
    state = state.copyWith(
      gold: state.gold - cost,
      investedLocationIds: [...state.investedLocationIds, locationId],
      eventLog: [
        'You invested $cost gold in the next expedition here. Expect better returns.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  // ─── TRAINING CONTRACTS ───────────────────────────────────────────────────

  // locationId should be the active town visit's locationId.
  // Costs vary by location type (monastery 250g, forge 300g, castle 350g).
  void trainHero(String heroId, int xpGrant) {
    final visit = state.activeTownVisit;
    if (visit == null) return;
    final locId = visit.locationId;
    final already = state.trainingRecords[locId] ?? [];
    if (already.contains(heroId)) return;

    final cost = switch (visit.visitType) {
      TownVisitType.monastery => 250,
      _ => 300,
    };
    if (state.gold < cost) return;

    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    final hero = state.party[heroIdx];

    final newXp    = hero.experience + xpGrant;
    final newLevel = _levelFromXp(newXp);
    final updated  = hero.copyWith(experience: newXp, level: newLevel);
    final updatedParty = [...state.party]..[heroIdx] = updated;

    final updatedRecords = Map<String, List<String>>.from(state.trainingRecords);
    updatedRecords[locId] = [...already, heroId];

    state = state.copyWith(
      gold: state.gold - cost,
      party: updatedParty,
      trainingRecords: updatedRecords,
      eventLog: [
        '${hero.name} completed rigorous training for $cost gold. +$xpGrant XP.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  // ─── SHOP ─────────────────────────────────────────────────────────────────

  void buyWeapon(String weaponId) {
    final weapon = allWeapons.where((w) => w.id == weaponId).firstOrNull;
    if (weapon == null) return;
    if (state.gold < weapon.value) return;
    state = state.copyWith(
      gold: state.gold - weapon.value,
      inventory: state.inventory.addWeapon(weaponId),
    );
    _log('Purchased ${weapon.name} for ${weapon.value} gold.');
  }

  void buyArmor(String armorId) {
    final armor = allArmor.where((a) => a.id == armorId).firstOrNull;
    if (armor == null) return;
    if (state.gold < armor.value) return;
    state = state.copyWith(
      gold: state.gold - armor.value,
      inventory: state.inventory.addArmor(armorId),
    );
    _log('Purchased ${armor.name} for ${armor.value} gold.');
  }

  // ─── PROPERTIES ────────────────────────────────────────────────────────────

  void purchaseProperty(PropertyType type) {
    final cost = propertyCosts[type]!;
    if (state.gold < cost) return;
    if (state.properties.any((p) => p.type == type)) return;

    final property = OwnedProperty(
      id: _uuid.v4(),
      name: _propertyName(type),
      type: type,
      level: 1,
      goldPerMinute: baseIncomePerMinute[type]!,
      upgradeCost: cost * 2,
    );
    state = state.copyWith(
      gold: state.gold - cost,
      properties: [...state.properties, property],
    );
    _log('You now own ${property.name}.');
  }

  void upgradeProperty(String propertyId) {
    final idx = state.properties.indexWhere((p) => p.id == propertyId);
    if (idx == -1) return;
    final property = state.properties[idx];
    if (property.level >= 5 || state.gold < property.upgradeCost) return;

    final upgraded = property.copyWith(
      level: property.level + 1,
      goldPerMinute: (property.goldPerMinute * 1.5).round(),
      upgradeCost: property.upgradeCost * 2,
    );
    final updated = [...state.properties]..[idx] = upgraded;
    state = state.copyWith(
      gold: state.gold - property.upgradeCost,
      properties: updated,
    );
    _log('${property.name} upgraded to level ${upgraded.level}.');
  }

  void purchaseAddon(String propertyId, String addonId) {
    final idx = state.properties.indexWhere((p) => p.id == propertyId);
    if (idx == -1) return;
    final property = state.properties[idx];
    if (property.unlockedAddonIds.contains(addonId)) return;

    final def = addonById(addonId);
    if (def == null || state.gold < def.cost) return;

    final updated = property.copyWith(
      unlockedAddonIds: [...property.unlockedAddonIds, addonId],
      goldPerMinute: property.goldPerMinute + def.incomeBonus,
    );
    final props = [...state.properties]..[idx] = updated;
    state = state.copyWith(
      gold: state.gold - def.cost,
      properties: props,
    );
    _log('${def.name} added to ${property.name}.');

    // Watchtower immediately reveals all world locations
    if (addonId == 'castle_watchtower') {
      final allRevealed = state.worldMap
          .map((l) => l.copyWith(discovered: true))
          .toList();
      state = state.copyWith(worldMap: allRevealed);
      _log('The Watchtower\'s view reaches every corner of the known world.');
    }
  }

  // Tavern perk — free full rest, once per in-game day (twice with Private Rooms)
  void restAtTavern() {
    if (!_hasProperty(PropertyType.tavern)) return;
    final hasPrivateRooms = _propertyHasAddon(PropertyType.tavern, 'tavern_rooms');
    // Private Rooms: cooldown resets every 12 in-game hours (every day still = once per day
    // but we allow two rests by checking if day changed by 1)
    final restsAllowedPerDay = hasPrivateRooms ? 2 : 1;
    // We use tavernRestDay to store the last day * 10 + restCount within that day
    final storedDay = state.tavernRestDay ~/ 10;
    final restsToday = state.tavernRestDay % 10;
    final currentDay = state.inGameDay;
    final restCountToday = storedDay == currentDay ? restsToday : 0;
    if (restCountToday >= restsAllowedPerDay) return;

    final restoresMana = _propertyHasAddon(PropertyType.tavern, 'tavern_cookery');

    final healedParty = state.party.map((h) {
      if (h.status == HeroStatus.dead) return h;
      return h.copyWith(
        currentHealth: h.maxHealth,
        currentMana: restoresMana ? h.maxMana : h.currentMana,
        status: HeroStatus.active,
        recoverySecondsRemaining: 0,
      );
    }).toList();

    state = state.copyWith(
      party: healedParty,
      tavernRestDay: currentDay * 10 + (restCountToday + 1),
      eventLog: [
        'Your party rested at the tavern. All heroes fully restored${restoresMana ? " (mana included)" : ""}.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  void resolvePropertyEvent(String propertyId, int choiceIndex) {
    final eventIdx = state.pendingPropertyEvents
        .indexWhere((e) => e.propertyId == propertyId);
    if (eventIdx == -1) return;

    final pending = state.pendingPropertyEvents[eventIdx];
    final def = propertyEventById(pending.defId);
    if (def == null || choiceIndex >= def.choices.length) return;

    final choice = def.choices[choiceIndex];
    final newEvents = [...state.pendingPropertyEvents]..removeAt(eventIdx);

    state = state.copyWith(
      gold: (state.gold + choice.goldDelta).clamp(0, 9999999),
      pendingPropertyEvents: newEvents,
    );
    _log('${def.title}: ${choice.outcome}');
  }

  void setPermadeath(bool enabled) =>
      state = state.copyWith(permadeathEnabled: enabled);

  void dismissHero(String heroId) => state = state.copyWith(
        party: state.party.where((h) => h.id != heroId).toList(),
      );

  void retireHero(String heroId) {
    final hero = state.party.where((h) => h.id == heroId).firstOrNull;
    if (hero == null || hero.level < 20 || hero.isPlayerCharacter) return;
    if (hero.status == HeroStatus.dead) return;

    // Determine legacy perk by class archetype
    final perk = switch (hero.heroClass) {
      HeroClass.mage || HeroClass.necromancer || HeroClass.warlock => 'xp_legacy',
      _ => 'gold_legacy',
    };
    final label = perk == 'xp_legacy' ? '+3% XP' : '+3% gold';

    state = state.copyWith(
      party: state.party.where((h) => h.id != heroId).toList(),
      retirementPerks: [...state.retirementPerks, perk],
      eventLog: [
        '${hero.name} has retired after a distinguished career. Their legacy grants the company $label from all expeditions.',
        ...state.eventLog,
      ].take(50).toList(),
    );
    _save.save(state);
  }

  void acceptQuest(Quest quest) {
    if (state.activeQuests.any((q) => q.title == quest.title)) return;
    if (state.completedQuestTitles.contains(quest.title)) return;
    state = state.copyWith(
      activeQuests: [...state.activeQuests, quest],
      eventLog: [
        '${quest.questGiverName}: "${quest.title}" — quest accepted.',
        ...state.eventLog,
      ].take(50).toList(),
    );
  }

  // ─── MANA & SPELLS ────────────────────────────────────────────────────────

  void useManaPotion(String heroId, String consumableId) {
    if (!state.inventory.hasConsumable(consumableId)) return;
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    final hero = state.party[heroIdx];
    if (!hero.heroClass.isCaster) return;
    final restore = manaRestoreAmount(consumableId);
    if (restore <= 0) return;
    final before  = hero.currentMana;
    final newMana = (before + restore).clamp(0, hero.maxMana);
    final gained  = newMana - before;
    if (gained <= 0) return; // already full
    final updated = hero.copyWith(currentMana: newMana);
    final inv     = state.inventory.removeConsumable(consumableId);
    final name    = consumableById(consumableId)?.name ?? consumableId;
    final updatedParty = [...state.party]..[heroIdx] = updated;
    state = state.copyWith(party: updatedParty, inventory: inv);
    _log('${hero.name} drank a $name. +$gained mana. ($newMana/${hero.maxMana})');
  }

  void useSpellTome(String heroId, String tomeId) {
    if (!state.inventory.hasConsumable(tomeId)) return;
    if (!isSpellTome(tomeId)) return;
    final spellId = tomeSpellId(tomeId);
    if (spellId == null) return;
    final spell   = spellById(spellId);
    if (spell == null) return;
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    final hero = state.party[heroIdx];
    if (!spell.allowedClasses.contains(hero.heroClass)) return;
    if (hero.knownSpells.contains(spellId)) return;
    final updated = hero.copyWith(knownSpells: [...hero.knownSpells, spellId]);
    final inv     = state.inventory.removeConsumable(tomeId);
    final updatedParty = [...state.party]..[heroIdx] = updated;
    state = state.copyWith(party: updatedParty, inventory: inv);
    _log('${hero.name} learned ${spell.name} from a tome!');
  }

  void equipSpell(String heroId, String spellId) {
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    final hero = state.party[heroIdx];
    if (!hero.knownSpells.contains(spellId)) return;
    if (hero.equippedSpells.contains(spellId)) return;
    if (hero.equippedSpells.length >= hero.maxSpellSlots) return;
    final updated = hero.copyWith(equippedSpells: [...hero.equippedSpells, spellId]);
    final updatedParty = [...state.party]..[heroIdx] = updated;
    state = state.copyWith(party: updatedParty);
  }

  void unequipSpell(String heroId, String spellId) {
    final heroIdx = state.party.indexWhere((h) => h.id == heroId);
    if (heroIdx == -1) return;
    final hero = state.party[heroIdx];
    if (!hero.equippedSpells.contains(spellId)) return;
    final updated = hero.copyWith(
      equippedSpells: hero.equippedSpells.where((s) => s != spellId).toList(),
    );
    final updatedParty = [...state.party]..[heroIdx] = updated;
    state = state.copyWith(party: updatedParty);
  }

  void _log(String message) => state = state.copyWith(
        eventLog: [message, ...state.eventLog].take(50).toList(),
      );

  Future<void> save() => _save.save(state);

  Future<void> deleteSave() async {
    await _save.deleteSave();
    state = GameState.newGame();
  }

  void dispose() => _tickTimer?.cancel();

  String _propertyName(PropertyType type) => switch (type) {
        PropertyType.tavern       => 'The Ashen Tavern',
        PropertyType.blacksmith   => 'The Iron Hearth',
        PropertyType.apothecary  => 'The Pale Apothecary',
        PropertyType.generalStore => 'The Road Merchant',
        PropertyType.stables      => 'The Grey Stables',
        PropertyType.castle       => 'Ashkeep',
      };
}
