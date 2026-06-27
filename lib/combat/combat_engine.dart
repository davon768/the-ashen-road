import 'dart:math';
import '../models/hero.dart' as model show Hero;
import '../models/enums.dart';
import '../models/enemy.dart';
import '../models/spell.dart';
import '../data/enemies_data.dart';
import '../data/spells_data.dart';
import 'combat_result.dart';

final _rng = Random();

// ─── NARRATIVE HELPERS ──────────────────────────────────────────────────────

const _attackVerbs = [
  'strikes', 'slashes at', 'drives a blow into', 'cuts into',
  'hammers', 'thrusts at', 'lunges at', 'smashes',
];
const _critPhrases = [
  'A devastating blow!', 'A telling strike!', 'Strikes a vital point!',
  'A savage hit!', 'Finds a gap in the armor!',
];
const _enemyAttackVerbs = [
  'attacks', 'lunges at', 'claws at', 'slashes', 'bites', 'strikes',
];
const _killPhrases = [
  'falls to the ground.', 'collapses with a groan.', 'crumples and is still.',
  'is cut down.', 'drops dead.', 'is slain.',
];
const _downPhrases = [
  'takes a grievous wound and staggers back.',
  'is badly hurt and cannot continue.',
  'falls, too wounded to fight on.',
  'collapses, breathing but broken.',
];

String _pickVerb() => _attackVerbs[_rng.nextInt(_attackVerbs.length)];
String _pickKill() => _killPhrases[_rng.nextInt(_killPhrases.length)];
String _pickDown() => _downPhrases[_rng.nextInt(_downPhrases.length)];
String _pickCrit() => _critPhrases[_rng.nextInt(_critPhrases.length)];

// ─── FAITH BONUSES ──────────────────────────────────────────────────────────

double _faithDamageBonus(model.Hero hero, EnemyType enemyType) {
  final faith   = hero.faith;
  final devotion = hero.devotion;
  if (faith == null || devotion < 30) return 1.0;
  return switch (faith) {
    FaithType.luminantChurch =>
      (enemyType == EnemyType.undead || enemyType == EnemyType.supernatural)
          ? (devotion >= 70 ? 1.3 : 1.15) : 1.0,
    FaithType.oldWays        => devotion >= 70 ? 1.3 : 1.15,
    FaithType.paleCourt      => enemyType == EnemyType.undead ? 0.8 : 1.15,
    FaithType.compactOfSaints=> 1.0,
    FaithType.ashenRite      => devotion >= 70 ? 1.4 : 1.2,
  };
}

// ─── SUBCLASS ABILITIES ─────────────────────────────────────────────────────

double _subclassDamageMultiplier(
  model.Hero hero,
  Enemy enemy,
  int heroCurrentHp,
  bool isFirstRound,
) {
  final sub = hero.subclass;
  if (sub == null) return 1.0;
  return switch (sub) {
    Subclass.berserker    => heroCurrentHp < hero.maxHealth ~/ 2 ? 1.5 : 1.0,
    Subclass.crusader     => (enemy.type == EnemyType.undead || enemy.type == EnemyType.supernatural) ? 1.3 : 1.0,
    Subclass.inquisitor   => (enemy.type == EnemyType.undead || enemy.type == EnemyType.supernatural) ? 1.4 : 1.0,
    Subclass.zealot       => 1.15,
    Subclass.elementalist => _rng.nextDouble() < 0.30 ? 1.9 : 1.0,
    Subclass.assassin     => isFirstRound ? 1.5 : 1.15,
    Subclass.shadowblade  => 1.2,
    Subclass.hexblade     => 1.25,
    Subclass.occultist    => _rng.nextDouble() < 0.20 ? 2.0 : 1.0,
    _                     => 1.0,
  };
}

int _subclassDefenseBonus(model.Hero hero) {
  final sub = hero.subclass;
  if (sub == null) return 0;
  return switch (sub) {
    Subclass.sentinel    => 6,
    Subclass.deathKnight => 4,
    Subclass.hospitaller => 2,
    Subclass.lich        => -2,
    _                    => 0,
  };
}

bool _subclassForceCrit(model.Hero hero, bool isFirstRound) {
  final sub = hero.subclass;
  if (sub == null) return false;
  return switch (sub) {
    Subclass.huntsman => isFirstRound,
    Subclass.assassin => isFirstRound,
    _                 => false,
  };
}

String? _abilityNarrative(model.Hero hero, Enemy enemy, bool isFirstRound, bool isCrit, double mul) {
  final sub = hero.subclass;
  if (sub == null) return null;
  return switch (sub) {
    Subclass.berserker    => hero.currentHealth < hero.maxHealth ~/ 2
        ? '[Blood Rage] ${hero.name} fights with reckless fury!'
        : null,
    Subclass.crusader     => (enemy.type == EnemyType.undead || enemy.type == EnemyType.supernatural)
        ? '[Sacred Strike] ${hero.name}\'s blow burns with holy purpose!'
        : null,
    Subclass.inquisitor   => (enemy.type == EnemyType.undead || enemy.type == EnemyType.supernatural)
        ? '[Brand of Heresy] ${hero.name} marks the creature for judgment!'
        : null,
    Subclass.elementalist => mul > 1.5
        ? '[Elemental Burst] ${hero.name}\'s spell surges with raw elemental power!'
        : null,
    Subclass.assassin     => isFirstRound
        ? '[Backstab] ${hero.name} strikes from the shadows!'
        : null,
    Subclass.huntsman     => isFirstRound
        ? '[Headshot] ${hero.name} takes careful aim...'
        : null,
    Subclass.occultist    => mul > 1.5
        ? '[Dark Ritual] ${hero.name} invokes the forbidden name!'
        : null,
    _                     => null,
  };
}

// ─── CLASS ROLE HELPERS ──────────────────────────────────────────────────────

bool _partyHasActiveClass(
  HeroClass cls,
  List<model.Hero> heroes,
  Map<String, int> heroHpMap,
) =>
    heroes.any((h) => h.heroClass == cls && (heroHpMap[h.id] ?? 0) > 0);

// Returns true when a living priest is above 50% HP (Holy Ward condition).
bool _holyWardActive(List<model.Hero> heroes, Map<String, int> heroHpMap) =>
    heroes.any((h) =>
        h.heroClass == HeroClass.priest &&
        (heroHpMap[h.id] ?? 0) > (h.maxHealth * 0.5).round());

// 35% chance for a living necromancer to raise a slain enemy as a skeleton (2 rounds).
void _deathHarvestCheck(
  List<model.Hero> heroes,
  Map<String, int> heroHpMap,
  List<_ActiveSummon> activeSummons,
  List<CombatEvent> events,
) {
  if (!_partyHasActiveClass(HeroClass.necromancer, heroes, heroHpMap)) return;
  if (_rng.nextDouble() >= 0.35) return;
  activeSummons.add(_ActiveSummon(
    damagePerRound: 8,
    casterName: 'Death Harvest',
    spellName: 'Risen Skeleton',
    roundsLeft: 2,
  ));
  events.add(CombatEvent(
    '[Death Harvest] A slain foe stirs and rises to serve the necromancer!',
    CombatEventType.ability,
  ));
}

// 50% chance for a living priest to revive a fallen ally at 25% HP (once per hero per encounter).
bool _tryLayOnHands(
  model.Hero fallen,
  List<model.Hero> heroes,
  Map<String, int> heroHpMap,
  Set<String> revivedIds,
  List<CombatEvent> events,
) {
  if (revivedIds.contains(fallen.id)) return false;
  final priest = heroes
      .where((h) =>
          h.heroClass == HeroClass.priest &&
          (heroHpMap[h.id] ?? 0) > 0 &&
          h.id != fallen.id)
      .firstOrNull;
  if (priest == null) return false;
  if (_rng.nextDouble() >= 0.40) return false;

  final reviveHp = (fallen.maxHealth * 0.25).round().clamp(1, fallen.maxHealth);
  heroHpMap[fallen.id] = reviveHp;
  revivedIds.add(fallen.id);
  events.add(CombatEvent(
    '[Lay on Hands] ${priest.name} reaches through the chaos and pulls ${fallen.name} back! '
    '($reviveHp/${fallen.maxHealth} HP)',
    CombatEventType.ability,
  ));
  return true;
}

// ─── HERO ATTACK ────────────────────────────────────────────────────────────

int _heroAttackDamage(
  model.Hero hero,
  Enemy enemy,
  int heroCurrentHp,
  bool isFirstRound,
) {
  final stats  = hero.effectiveStats;
  final weapon = hero.equipment.mainHand;

  int min, max;
  if (weapon != null) {
    // Ranged weapons scale with dexterity; magic implements scale with intelligence.
    // Everything else (swords, axes, polearms, blunt, daggers) scales with strength.
    final statBonus = switch (weapon.type) {
      WeaponType.bow || WeaponType.crossbow                    => stats.dexterity   ~/ 3,
      WeaponType.staff || WeaponType.wand || WeaponType.tome   => stats.intelligence ~/ 3,
      _                                                        => stats.strength     ~/ 3,
    };
    min = weapon.minDamage + statBonus;
    max = weapon.maxDamage + statBonus;
  } else {
    min = stats.meleeDamage ~/ 2;
    max = stats.meleeDamage;
  }

  // Physical damage grows with level so non-casters stay relevant at higher depths.
  final levelBonus = (hero.level - 1) ~/ 2;
  min += levelBonus;
  max += levelBonus;

  final modTotals = hero.equipment.modifierTotals;
  final raw      = min + _rng.nextInt((max - min + 1).clamp(1, 999)) + modTotals.bonusDamageFlat;
  final faithMul = _faithDamageBonus(hero, enemy.type);
  final subMul   = _subclassDamageMultiplier(hero, enemy, heroCurrentHp, isFirstRound);
  final afterMul = (raw * faithMul * subMul).round();
  final effectiveArmor = (enemy.armor - modTotals.armorPenFlat).clamp(0, 9999);
  return (afterMul - effectiveArmor).clamp(1, 9999);
}

bool _isHeroCrit(model.Hero hero, bool isFirstRound) =>
    _subclassForceCrit(hero, isFirstRound) ||
    _rng.nextDouble() < hero.effectiveStats.critChance + hero.equipment.modifierTotals.critChanceBonus;

// ─── ENEMY ATTACK ────────────────────────────────────────────────────────────

int _enemyAttackDamage(
  Enemy enemy,
  model.Hero hero, {
  bool ignoreArmor = false,
  int extraDefense = 0,
}) {
  final raw     = enemy.minDamage + _rng.nextInt((enemy.maxDamage - enemy.minDamage + 1).clamp(1, 999));
  final instDef = ignoreArmor ? 0 : hero.equipment.modifierTotals.bonusDefenseFlat;
  final defense = ignoreArmor ? 0 : (hero.equipment.totalDefense + _subclassDefenseBonus(hero) + extraDefense + instDef);
  final dexMit  = ignoreArmor ? 0 : (hero.effectiveStats.dexterity ~/ 5);
  return (raw - defense - dexMit).clamp(1, 9999);
}

bool _isEnemyCrit(Enemy enemy) => _rng.nextDouble() < enemy.critChance;

// ─── FAITH MIRACLE CHECK ────────────────────────────────────────────────────

CombatEvent? _checkMiracle(model.Hero hero) {
  if (hero.faith == null || hero.devotion < 70) return null;
  if (_rng.nextDouble() > 0.08) return null;

  final text = switch (hero.faith!) {
    FaithType.luminantChurch =>
      '${hero.name}: The Eternal Flame answers! A burst of holy fire scorches the enemy.',
    FaithType.oldWays        =>
      '${hero.name}: The Old Gods bellow through ${hero.name}\'s blade. A godborn strike!',
    FaithType.paleCourt      =>
      '${hero.name}: The dead stir at ${hero.name}\'s call. Skeletal hands drag at the enemy.',
    FaithType.compactOfSaints=>
      '${hero.name}: A saint intervenes. The blow that should have connected misses entirely.',
    FaithType.ashenRite      =>
      '${hero.name}: The Void speaks through ${hero.name}. Ashen energy consumes the foe.',
  };
  return CombatEvent(text, CombatEventType.faithMiracle);
}

// ─── SPELL CASTING ──────────────────────────────────────────────────────────

class _ActiveDoT {
  final String? targetId; // null = all enemies
  final int damagePerRound;
  final String casterName;
  final String spellName;
  int roundsLeft;

  _ActiveDoT({
    required this.targetId,
    required this.damagePerRound,
    required this.casterName,
    required this.spellName,
    required this.roundsLeft,
  });
}

class _ActiveSummon {
  final int damagePerRound;
  final String casterName;
  final String spellName;
  int roundsLeft;

  _ActiveSummon({
    required this.damagePerRound,
    required this.casterName,
    required this.spellName,
    required this.roundsLeft,
  });
}

({int goldGained, int xpGained}) _castSpell(
  model.Hero caster,
  Spell spell,
  List<Enemy> aliveEnemies,
  List<model.Hero> heroes,
  Map<String, int> heroHpMap,
  Map<String, int> heroDefBonusMap,
  List<_ActiveDoT> activeDots,
  List<_ActiveSummon> activeSummons,
  List<CombatEvent> events,
) {
  int goldGained = 0;
  int xpGained   = 0;
  final mp = caster.effectiveStats.magicPower;

  events.add(CombatEvent(
    '[${spell.name}] ${caster.name} casts ${spell.name}.',
    CombatEventType.ability,
  ));

  final spBonus = 1.0 + caster.equipment.modifierTotals.spellPowerBonus;

  switch (spell.effectType) {
    case SpellEffectType.damage:
      if (aliveEnemies.isEmpty) break;
      final target = aliveEnemies[_rng.nextInt(aliveEnemies.length)];
      final dmg = (mp * spell.powerScale * spBonus).round().clamp(1, 9999);
      target.takeDamage(dmg);

      // Warlock: Soul Siphon — lifesteal on damage spells
      if (caster.heroClass == HeroClass.warlock) {
        final siphon = (dmg * 0.15).round().clamp(1, 50);
        final casterHp = heroHpMap[caster.id] ?? 0;
        if (casterHp > 0 && casterHp < caster.maxHealth) {
          heroHpMap[caster.id] = (casterHp + siphon).clamp(0, caster.maxHealth);
          events.add(CombatEvent(
            '[Soul Siphon] ${caster.name} feeds on the suffering. +$siphon HP.',
            CombatEventType.ability,
          ));
        }
      }

      if (target.isAlive) {
        events.add(CombatEvent(
          '${spell.name} strikes the ${target.name} for $dmg arcane damage. (${target.currentHp}/${target.maxHp} HP)',
          CombatEventType.heroAttack,
        ));
      } else {
        xpGained  += target.xpValue;
        goldGained += target.goldValue;
        aliveEnemies.remove(target);
        _deathHarvestCheck(heroes, heroHpMap, activeSummons, events);
        events.add(CombatEvent(
          '${spell.name} strikes the ${target.name} for $dmg arcane damage. The ${target.name} ${_pickKill()}',
          CombatEventType.heroKill,
        ));
      }

    case SpellEffectType.damageAll:
      if (aliveEnemies.isEmpty) break;
      final dmg = (mp * spell.powerScale * spBonus).round().clamp(1, 9999);
      events.add(CombatEvent(
        '${spell.name} hits all enemies for $dmg arcane damage!',
        CombatEventType.heroAttack,
      ));
      var totalDmgForSiphon = 0;
      for (final target in List<Enemy>.from(aliveEnemies)) {
        target.takeDamage(dmg);
        totalDmgForSiphon += dmg;
        if (!target.isAlive) {
          xpGained  += target.xpValue;
          goldGained += target.goldValue;
          aliveEnemies.remove(target);
          _deathHarvestCheck(heroes, heroHpMap, activeSummons, events);
          events.add(CombatEvent(
            'The ${target.name} ${_pickKill()}',
            CombatEventType.heroKill,
          ));
        } else {
          events.add(CombatEvent(
            'The ${target.name} takes $dmg damage. (${target.currentHp}/${target.maxHp} HP)',
            CombatEventType.heroAttack,
          ));
        }
      }
      // Warlock: Soul Siphon on AoE
      if (caster.heroClass == HeroClass.warlock && totalDmgForSiphon > 0) {
        final siphon = (totalDmgForSiphon * 0.10).round().clamp(1, 80);
        final casterHp = heroHpMap[caster.id] ?? 0;
        if (casterHp > 0 && casterHp < caster.maxHealth) {
          heroHpMap[caster.id] = (casterHp + siphon).clamp(0, caster.maxHealth);
          events.add(CombatEvent(
            '[Soul Siphon] ${caster.name} drinks deep from the carnage. +$siphon HP.',
            CombatEventType.ability,
          ));
        }
      }

    case SpellEffectType.dot:
      if (aliveEnemies.isEmpty) break;
      final target = aliveEnemies[_rng.nextInt(aliveEnemies.length)];
      final dmg = (mp * spell.powerScale).round().clamp(1, 9999);
      activeDots.add(_ActiveDoT(
        targetId: target.id,
        damagePerRound: dmg,
        casterName: caster.name,
        spellName: spell.name,
        roundsLeft: spell.duration,
      ));
      events.add(CombatEvent(
        '${spell.name} afflicts the ${target.name} — $dmg damage per round for ${spell.duration} rounds.',
        CombatEventType.ability,
      ));

    case SpellEffectType.dotAll:
      final dmg = (mp * spell.powerScale).round().clamp(1, 9999);
      activeDots.add(_ActiveDoT(
        targetId: null,
        damagePerRound: dmg,
        casterName: caster.name,
        spellName: spell.name,
        roundsLeft: spell.duration,
      ));
      events.add(CombatEvent(
        '${spell.name} sweeps across the field — all enemies suffer $dmg damage per round for ${spell.duration} rounds.',
        CombatEventType.ability,
      ));

    case SpellEffectType.heal:
      model.Hero? healTarget;
      double lowestRatio = 1.1;
      for (final h in heroes) {
        final hp = heroHpMap[h.id] ?? 0;
        if (hp <= 0) continue;
        final ratio = hp / h.maxHealth;
        if (ratio < lowestRatio) {
          lowestRatio = ratio;
          healTarget = h;
        }
      }
      if (healTarget == null) break;
      final healAmt = (mp * spell.powerScale).round().clamp(1, 9999);
      final prevHp  = heroHpMap[healTarget.id]!;
      heroHpMap[healTarget.id] = (prevHp + healAmt).clamp(0, healTarget.maxHealth);
      final gained = heroHpMap[healTarget.id]! - prevHp;
      events.add(CombatEvent(
        '${spell.name} restores $gained HP to ${healTarget.name}. (${heroHpMap[healTarget.id]}/${healTarget.maxHealth} HP)',
        CombatEventType.ability,
      ));

    case SpellEffectType.healAll:
      final healAmt = (mp * spell.powerScale).round().clamp(1, 9999);
      for (final h in heroes) {
        final hp = heroHpMap[h.id] ?? 0;
        if (hp <= 0) continue;
        final prevHp = hp;
        heroHpMap[h.id] = (hp + healAmt).clamp(0, h.maxHealth);
        final gained = heroHpMap[h.id]! - prevHp;
        events.add(CombatEvent(
          '${spell.name} restores $gained HP to ${h.name}. (${heroHpMap[h.id]}/${h.maxHealth} HP)',
          CombatEventType.ability,
        ));
      }

    case SpellEffectType.drain:
      if (aliveEnemies.isEmpty) break;
      final target  = aliveEnemies[_rng.nextInt(aliveEnemies.length)];
      final dmg     = (mp * spell.powerScale).round().clamp(1, 9999);
      final healAmt = (dmg * 0.5).round().clamp(1, 9999);
      target.takeDamage(dmg);
      final casterHp = heroHpMap[caster.id] ?? 0;
      if (casterHp > 0) {
        heroHpMap[caster.id] = (casterHp + healAmt).clamp(0, caster.maxHealth);
      }
      if (!target.isAlive) {
        xpGained  += target.xpValue;
        goldGained += target.goldValue;
        aliveEnemies.remove(target);
        _deathHarvestCheck(heroes, heroHpMap, activeSummons, events);
        events.add(CombatEvent(
          '${spell.name} drains $dmg life from the ${target.name}, healing ${caster.name} for $healAmt. The ${target.name} ${_pickKill()}',
          CombatEventType.heroKill,
        ));
      } else {
        events.add(CombatEvent(
          '${spell.name} drains $dmg life from the ${target.name} (${target.currentHp}/${target.maxHp} HP), healing ${caster.name} for $healAmt.',
          CombatEventType.heroAttack,
        ));
      }

    case SpellEffectType.buff:
      // Use max() so re-casting the same buff refreshes rather than stacks indefinitely.
      heroDefBonusMap[caster.id] = max(heroDefBonusMap[caster.id] ?? 0, spell.flatBonus);
      events.add(CombatEvent(
        '${spell.name} wraps ${caster.name} in protective energy. +${spell.flatBonus} defense.',
        CombatEventType.ability,
      ));

    case SpellEffectType.debuff:
      if (aliveEnemies.isEmpty) break;
      final target = aliveEnemies[_rng.nextInt(aliveEnemies.length)];
      target.armor = (target.armor - spell.flatBonus).clamp(0, 999);
      events.add(CombatEvent(
        '${spell.name} saps the ${target.name}\'s resilience. Their armor is reduced by ${spell.flatBonus}.',
        CombatEventType.ability,
      ));

    case SpellEffectType.dispel:
      if (aliveEnemies.isEmpty) break;
      final withTraits = aliveEnemies.where((e) => e.traits.isNotEmpty).toList();
      if (withTraits.isEmpty) {
        events.add(CombatEvent(
          '${spell.name} finds nothing to purge.',
          CombatEventType.ability,
        ));
        break;
      }
      final target = withTraits[_rng.nextInt(withTraits.length)];
      final removed = target.traits.first;
      target.traits.remove(removed);
      final traitLabel = switch (removed) {
        EnemyTrait.critImmune    => 'Critical Resistance',
        EnemyTrait.selfRegen     => 'Undead Regeneration',
        EnemyTrait.armorPiercing => 'Armor Piercing',
        EnemyTrait.phaseOnCrit   => 'Phase Shift',
        EnemyTrait.partyDamage   => 'Aura of Dread',
        EnemyTrait.drainOnHit    => 'Life Drain',
        EnemyTrait.fleeOnLowHp   => 'Cowardly Instinct',
      };
      events.add(CombatEvent(
        '${spell.name} tears the $traitLabel from the ${target.name}!',
        CombatEventType.ability,
      ));

    case SpellEffectType.summon:
      activeSummons.add(_ActiveSummon(
        damagePerRound: spell.flatBonus,
        casterName: caster.name,
        spellName: spell.name,
        roundsLeft: spell.duration,
      ));
      events.add(CombatEvent(
        '${caster.name}\'s ${spell.name} conjures an ally to fight alongside the party for ${spell.duration} rounds.',
        CombatEventType.ability,
      ));
  }

  return (goldGained: goldGained, xpGained: xpGained);
}

// ─── SINGLE ENCOUNTER ────────────────────────────────────────────────────────

EncounterResult resolveEncounter(
  List<model.Hero> heroes,
  List<Enemy> enemies,
  Map<String, int> heroHpMap,
  Map<String, int> heroManaMap,
) {
  final events        = <CombatEvent>[];
  final activeDots    = <_ActiveDoT>[];
  final activeSummons = <_ActiveSummon>[];
  // Per-encounter defense bonuses from buff spells (reset each encounter)
  final heroDefBonusMap = <String, int>{for (final h in heroes) h.id: 0};
  // Heroes revived by Lay on Hands this encounter (once per hero)
  final revivedHeroIds  = <String>{};

  int goldFound = 0;
  int xpGained  = 0;

  // Opening narrative
  final enemyList = enemies.map((e) => e.name).join(', ');
  final openText  = enemies.length == 1
      ? (enemies.first.isBoss
          ? '★ BOSS: ${enemies.first.name} rises before you! ★'
          : 'A ${enemies.first.name} bars the way.')
      : 'The party faces: $enemyList.';
  events.add(CombatEvent(openText, CombatEventType.narrative));

  // ── Warlock: Demon Familiar — bound demon attacks at start of each encounter ──
  for (final h in heroes) {
    if (h.heroClass == HeroClass.warlock && (heroHpMap[h.id] ?? 0) > 0) {
      final aliveEne = enemies.where((e) => e.isAlive).toList();
      if (aliveEne.isNotEmpty) {
        final demonTarget = aliveEne[_rng.nextInt(aliveEne.length)];
        final demonDmg    = 10 + (h.level * 2);
        demonTarget.takeDamage(demonDmg);
        if (!demonTarget.isAlive) {
          xpGained  += demonTarget.xpValue;
          goldFound += demonTarget.goldValue;
          _deathHarvestCheck(heroes, heroHpMap, activeSummons, events);
          events.add(CombatEvent(
            '[Demon Familiar] ${h.name}\'s bound demon tears into the ${demonTarget.name} for $demonDmg damage. '
            'The ${demonTarget.name} ${_pickKill()}',
            CombatEventType.ability,
          ));
        } else {
          events.add(CombatEvent(
            '[Demon Familiar] ${h.name}\'s bound demon strikes the ${demonTarget.name} for $demonDmg damage. '
            '(${demonTarget.currentHp}/${demonTarget.maxHp} HP)',
            CombatEventType.ability,
          ));
        }
      }
    }
  }

  final maxRounds = enemies.any((e) => e.isBoss) ? 30 : 20;

  for (var round = 0; round < maxRounds; round++) {
    final aliveHeroes  = heroes.where((h) => (heroHpMap[h.id] ?? 0) > 0).toList();
    final aliveEnemies = enemies.where((e) => e.isAlive).toList();
    if (aliveHeroes.isEmpty || aliveEnemies.isEmpty) break;

    final isFirstRound = round == 0;

    // ── Heroes attack ──────────────────────────────────────────────────
    for (final hero in aliveHeroes) {
      if (aliveEnemies.isEmpty) break;

      // Casters: try to cast an equipped spell
      if (hero.heroClass.isCaster && hero.equippedSpells.isNotEmpty) {
        final mana = heroManaMap[hero.id] ?? 0;
        final partyNeedsHealing = heroes.any(
          (h) => (heroHpMap[h.id] ?? 0) > 0 && (heroHpMap[h.id] ?? 0) < h.maxHealth,
        );
        final affordable = hero.equippedSpells
            .map((id) => spellById(id))
            .whereType<Spell>()
            .where((s) => s.manaCost <= mana)
            // Don't waste mana on heals when the whole party is already at full HP.
            .where((s) =>
                (s.effectType != SpellEffectType.heal &&
                 s.effectType != SpellEffectType.healAll) ||
                partyNeedsHealing)
            .toList();

        if (affordable.isNotEmpty) {
          final miracle = _checkMiracle(hero);
          if (miracle != null) events.add(miracle);

          final spell = affordable[_rng.nextInt(affordable.length)];
          heroManaMap[hero.id] = mana - spell.manaCost;

          final result = _castSpell(
            hero, spell, aliveEnemies, heroes, heroHpMap,
            heroDefBonusMap, activeDots, activeSummons, events,
          );
          xpGained  += result.xpGained;
          goldFound += result.goldGained;

          // Mage: Arcane Echo — 25% chance to cast the same spell again for free
          if (hero.heroClass == HeroClass.mage &&
              _rng.nextDouble() < 0.25 &&
              aliveEnemies.isNotEmpty) {
            events.add(CombatEvent(
              '[Arcane Echo] The spell resonates — ${hero.name}\'s magic surges again!',
              CombatEventType.ability,
            ));
            final echoResult = _castSpell(
              hero, spell, aliveEnemies, heroes, heroHpMap,
              heroDefBonusMap, activeDots, activeSummons, events,
            );
            xpGained  += echoResult.xpGained;
            goldFound += echoResult.goldGained;
          }

          continue; // skip physical attack this turn
        }
        // Out of mana — fall through to physical attack
      }

      // Physical attack (non-casters or out-of-mana casters)
      var target = aliveEnemies[_rng.nextInt(aliveEnemies.length)];

      // Rogue: Shadow Strike — 25% chance to strike from shadow for 2× before main attack
      if (hero.heroClass == HeroClass.rogue && _rng.nextDouble() < 0.25) {
        final shadowDmg = (_heroAttackDamage(hero, target, heroHpMap[hero.id] ?? 0, isFirstRound) * 2.0).round();
        target.takeDamage(shadowDmg);
        if (!target.isAlive) {
          xpGained  += target.xpValue;
          goldFound += target.goldValue;
          _deathHarvestCheck(heroes, heroHpMap, activeSummons, events);
          events.add(CombatEvent(
            '[Shadow Strike] ${hero.name} steps from shadow and slays the ${target.name} for $shadowDmg damage!',
            CombatEventType.heroKill,
          ));
          aliveEnemies.remove(target);
          if (aliveEnemies.isEmpty) continue;
          target = aliveEnemies[_rng.nextInt(aliveEnemies.length)];
        } else {
          events.add(CombatEvent(
            '[Shadow Strike] ${hero.name} materializes from shadow, striking the ${target.name} for $shadowDmg damage. '
            '(${target.currentHp}/${target.maxHp} HP)',
            CombatEventType.ability,
          ));
        }
      }

      final miracle = _checkMiracle(hero);
      if (miracle != null) events.add(miracle);

      final currentHp = heroHpMap[hero.id] ?? 0;
      final mul       = _subclassDamageMultiplier(hero, target, currentHp, isFirstRound);
      final abilityText = _abilityNarrative(hero, target, isFirstRound, false, mul);
      if (abilityText != null) {
        events.add(CombatEvent(abilityText, CombatEventType.ability));
      }

      final isCrit = _isHeroCrit(hero, isFirstRound);
      var dmg = _heroAttackDamage(hero, target, currentHp, isFirstRound);
      final critMul = 2.0 + hero.equipment.modifierTotals.critDamageBonus;
      if (isCrit) {
        if (target.traits.contains(EnemyTrait.critImmune)) {
          events.add(CombatEvent(
            '[Critical Resistance] The ${target.name} has no vital points. Normal damage.',
            CombatEventType.ability,
          ));
        } else if (target.traits.contains(EnemyTrait.phaseOnCrit)) {
          dmg = (dmg * 1.3).round();
          events.add(CombatEvent(
            '[Phase Shift] The spirit partially disperses — the blow passes through.',
            CombatEventType.ability,
          ));
        } else {
          dmg = (dmg * critMul).round();
          events.add(CombatEvent(_pickCrit(), CombatEventType.crit));
        }
      }

      // Ranger: Eagle Eye — first attack of the encounter deals 1.5× damage
      if (hero.heroClass == HeroClass.ranger && isFirstRound) {
        dmg = (dmg * 1.5).round();
        events.add(CombatEvent(
          '[Eagle Eye] ${hero.name} draws a careful bead — a precise, devastating shot!',
          CombatEventType.ability,
        ));
      }

      target.takeDamage(dmg);

      // Lifesteal from enchanted weapon
      final lifesteal = hero.equipment.modifierTotals.lifestealFlat;
      if (lifesteal > 0 && (heroHpMap[hero.id] ?? 0) > 0) {
        final prevHp = heroHpMap[hero.id]!;
        if (prevHp < hero.maxHealth) {
          heroHpMap[hero.id] = (prevHp + lifesteal).clamp(0, hero.maxHealth);
          events.add(CombatEvent(
            '[Lifesteal] ${hero.name}\'s blade drinks from the wound. +$lifesteal HP.',
            CombatEventType.ability,
          ));
        }
      }

      if (target.isAlive) {
        events.add(CombatEvent(
          '${hero.name} ${_pickVerb()} the ${target.name} for $dmg damage. '
          '(${target.currentHp}/${target.maxHp} HP)',
          CombatEventType.heroAttack,
        ));

        // Rogue: Poison Blade — 30% chance on hit to poison target (DoT 4/round, 3 rounds)
        if (hero.heroClass == HeroClass.rogue && _rng.nextDouble() < 0.30) {
          activeDots.add(_ActiveDoT(
            targetId: target.id,
            damagePerRound: 4,
            casterName: hero.name,
            spellName: 'Poison',
            roundsLeft: 3,
          ));
          events.add(CombatEvent(
            '[Poison Blade] ${hero.name}\'s blade is coated — the ${target.name} is poisoned!',
            CombatEventType.ability,
          ));
        }
      } else {
        xpGained  += target.xpValue;
        goldFound += target.goldValue;
        _deathHarvestCheck(heroes, heroHpMap, activeSummons, events);
        events.add(CombatEvent(
          '${hero.name} ${_pickVerb()} the ${target.name} for $dmg damage. '
          'The ${target.name} ${_pickKill()}',
          CombatEventType.heroKill,
        ));
        aliveEnemies.remove(target);

        // Lich drain on kill
        if (hero.subclass == Subclass.lich) {
          const drain = 10;
          heroHpMap[hero.id] = ((heroHpMap[hero.id] ?? 0) + drain).clamp(0, hero.maxHealth);
          events.add(CombatEvent(
            '[Phylactery Bond] ${hero.name} drains life from the fallen. +$drain HP.',
            CombatEventType.ability,
          ));
        }
      }

      // Ranger: Rapid Shot — 30% chance to attack again this round
      if (hero.heroClass == HeroClass.ranger &&
          aliveEnemies.isNotEmpty &&
          _rng.nextDouble() < 0.30) {
        final rapidTarget = aliveEnemies[_rng.nextInt(aliveEnemies.length)];
        final rapidDmg    = _heroAttackDamage(hero, rapidTarget, heroHpMap[hero.id] ?? 0, false);
        rapidTarget.takeDamage(rapidDmg);
        if (!rapidTarget.isAlive) {
          xpGained  += rapidTarget.xpValue;
          goldFound += rapidTarget.goldValue;
          _deathHarvestCheck(heroes, heroHpMap, activeSummons, events);
          events.add(CombatEvent(
            '[Rapid Shot] ${hero.name} looses another arrow! The ${rapidTarget.name} ${_pickKill()}',
            CombatEventType.heroKill,
          ));
          aliveEnemies.remove(rapidTarget);
        } else {
          events.add(CombatEvent(
            '[Rapid Shot] ${hero.name} fires again for $rapidDmg damage. '
            '(${rapidTarget.currentHp}/${rapidTarget.maxHp} HP)',
            CombatEventType.ability,
          ));
        }
      }
    }

    // ── Enemies attack ─────────────────────────────────────────────────
    final stillAliveEnemies = enemies.where((e) => e.isAlive).toList();
    for (final enemy in stillAliveEnemies) {
      final aliveTargets = heroes.where((h) => (heroHpMap[h.id] ?? 0) > 0).toList();
      if (aliveTargets.isEmpty) break;

      // Flee check
      if (enemy.traits.contains(EnemyTrait.fleeOnLowHp) &&
          enemy.currentHp < enemy.maxHp * 0.3 &&
          _rng.nextDouble() < 0.35) {
        final coinDrop = (enemy.goldValue * 0.5).round();
        goldFound += coinDrop;
        xpGained  += (enemy.xpValue * 0.5).round();
        enemy.currentHp = 0;
        events.add(CombatEvent(
          'The ${enemy.name} breaks and flees, dropping coin as they run!'
          '${coinDrop > 0 ? ' +$coinDrop gold.' : ''}',
          CombatEventType.narrative,
        ));
        continue;
      }

      // Party-wide aura attack
      if (enemy.traits.contains(EnemyTrait.partyDamage)) {
        events.add(CombatEvent(
          '[Aura of Dread] The ${enemy.name} unleashes a wave of dark force across the party!',
          CombatEventType.ability,
        ));
        var totalDmgDealt = 0;
        final wardActive  = _holyWardActive(heroes, heroHpMap);
        for (final auraTarget in aliveTargets) {
          // Pathfinder dodge
          if (auraTarget.subclass == Subclass.pathfinder && _rng.nextDouble() < 0.20) {
            events.add(CombatEvent('[Fade] ${auraTarget.name} sidesteps the wave.', CombatEventType.ability));
            continue;
          }
          // Rogue: Smoke Bomb dodge
          if (auraTarget.heroClass == HeroClass.rogue && _rng.nextDouble() < 0.30) {
            events.add(CombatEvent('[Smoke Bomb] ${auraTarget.name} vanishes in smoke — the wave passes through empty air!', CombatEventType.ability));
            continue;
          }
          // Item modifier: dodge
          final auraDodge = auraTarget.equipment.modifierTotals.dodgeBonus;
          if (auraDodge > 0 && _rng.nextDouble() < auraDodge) {
            events.add(CombatEvent('[Quick Reflexes] ${auraTarget.name} sidesteps the wave!', CombatEventType.ability));
            continue;
          }
          final boneArmor = auraTarget.heroClass == HeroClass.necromancer ? 6 : 0;
          final defBonus  = (heroDefBonusMap[auraTarget.id] ?? 0) + boneArmor;
          var dmg = (_enemyAttackDamage(enemy, auraTarget, extraDefense: defBonus) * 0.55).round().clamp(1, 9999);
          if (_isEnemyCrit(enemy)) dmg = (dmg * 1.5).round();
          if (wardActive) dmg = (dmg * 0.90).round().clamp(1, 9999);
          // Knight: Shield Block
          if (auraTarget.heroClass == HeroClass.knight && _rng.nextDouble() < 0.20) {
            dmg = (dmg * 0.5).round().clamp(1, 9999);
            events.add(CombatEvent('[Shield Block] ${auraTarget.name} raises their shield!', CombatEventType.ability));
          }
          // Item modifier: damage reduction
          final auraDr = auraTarget.equipment.modifierTotals.damageReductionBonus;
          if (auraDr > 0) dmg = (dmg * (1.0 - auraDr)).round().clamp(1, 9999);
          totalDmgDealt += dmg;
          final currentHp = heroHpMap[auraTarget.id]!;
          final newHp     = (currentHp - dmg).clamp(0, auraTarget.maxHealth);
          heroHpMap[auraTarget.id] = newHp;
          if (newHp > 0) {
            events.add(CombatEvent(
              '${auraTarget.name} takes $dmg from the wave. ($newHp/${auraTarget.maxHealth} HP)',
              CombatEventType.enemyAttack,
            ));
          } else {
            final revived = _tryLayOnHands(auraTarget, heroes, heroHpMap, revivedHeroIds, events);
            if (!revived) {
              events.add(CombatEvent('${auraTarget.name} ${_pickDown()}', CombatEventType.heroDown));
            }
          }
          // Item modifier: thorns
          final auraThorns = auraTarget.equipment.modifierTotals.thornsDamageFlat;
          if (auraThorns > 0 && enemy.isAlive) {
            enemy.takeDamage(auraThorns);
          }
        }
        if (enemy.traits.contains(EnemyTrait.drainOnHit) && totalDmgDealt > 0) {
          final drainHeal = (totalDmgDealt * 0.35).round().clamp(1, 30);
          enemy.currentHp = (enemy.currentHp + drainHeal).clamp(0, enemy.maxHp);
          events.add(CombatEvent(
            '[Life Drain] The spirit feeds on the suffering it caused. +$drainHeal HP.',
            CombatEventType.ability,
          ));
        }
        continue;
      }

      // Standard single-target attack — Knight Taunt adjusts target selection
      model.Hero target;
      final knights = aliveTargets.where((h) => h.heroClass == HeroClass.knight).toList();
      if (knights.isNotEmpty && _rng.nextDouble() < 0.65) {
        target = knights[_rng.nextInt(knights.length)];
        // Narrate taunt when it redirects from non-knight targets (avoid spam)
        if (aliveTargets.length > knights.length && _rng.nextDouble() < 0.40) {
          events.add(CombatEvent(
            '[Iron Taunt] ${target.name} steps forward and draws the ${enemy.name}\'s wrath!',
            CombatEventType.ability,
          ));
        }
      } else {
        target = aliveTargets[_rng.nextInt(aliveTargets.length)];
      }

      // Pathfinder: Fade dodge
      if (target.subclass == Subclass.pathfinder && _rng.nextDouble() < 0.20) {
        events.add(CombatEvent(
          '[Fade] ${target.name} sidesteps the blow entirely.',
          CombatEventType.ability,
        ));
        continue;
      }

      // Rogue: Smoke Bomb dodge
      if (target.heroClass == HeroClass.rogue && _rng.nextDouble() < 0.30) {
        events.add(CombatEvent(
          '[Smoke Bomb] ${target.name} vanishes in a cloud of smoke — the attack misses!',
          CombatEventType.ability,
        ));
        continue;
      }

      // Item modifier: dodge chance
      final itemDodge = target.equipment.modifierTotals.dodgeBonus;
      if (itemDodge > 0 && _rng.nextDouble() < itemDodge) {
        events.add(CombatEvent(
          '[Quick Reflexes] ${target.name} sidesteps the blow!',
          CombatEventType.ability,
        ));
        continue;
      }

      final ignoreArmor = enemy.traits.contains(EnemyTrait.armorPiercing);
      if (ignoreArmor) {
        events.add(CombatEvent(
          '[Armor-Piercing] The ${enemy.name} tears through ${target.name}\'s defenses!',
          CombatEventType.ability,
        ));
      }

      final boneArmor = target.heroClass == HeroClass.necromancer ? 6 : 0;
      final defBonus  = ignoreArmor ? 0 : ((heroDefBonusMap[target.id] ?? 0) + boneArmor);
      final isCrit    = _isEnemyCrit(enemy);
      var dmg = _enemyAttackDamage(enemy, target, ignoreArmor: ignoreArmor, extraDefense: defBonus);
      if (isCrit) dmg = (dmg * 1.5).round();

      // Priest: Holy Ward — 10% damage reduction while a healthy priest is alive
      if (_holyWardActive(heroes, heroHpMap)) {
        dmg = (dmg * 0.90).round().clamp(1, 9999);
      }

      // Knight: Shield Block — 20% chance to halve incoming damage
      if (target.heroClass == HeroClass.knight && _rng.nextDouble() < 0.20) {
        dmg = (dmg * 0.5).round().clamp(1, 9999);
        events.add(CombatEvent(
          '[Shield Block] ${target.name} raises their shield and absorbs the blow!',
          CombatEventType.ability,
        ));
      }

      // Item modifier: damage reduction from enchanted armor
      final dr = ignoreArmor ? 0.0 : target.equipment.modifierTotals.damageReductionBonus;
      if (dr > 0) dmg = (dmg * (1.0 - dr)).round().clamp(1, 9999);

      final currentHp = heroHpMap[target.id]!;
      final newHp     = (currentHp - dmg).clamp(0, target.maxHealth);
      heroHpMap[target.id] = newHp;

      if (newHp > 0) {
        events.add(CombatEvent(
          'The ${enemy.name} ${_enemyAttackVerbs[_rng.nextInt(_enemyAttackVerbs.length)]} '
          '${target.name} for $dmg damage. ($newHp/${target.maxHealth} HP)',
          CombatEventType.enemyAttack,
        ));
      } else {
        final revived = _tryLayOnHands(target, heroes, heroHpMap, revivedHeroIds, events);
        if (!revived) {
          events.add(CombatEvent(
            'The ${enemy.name} strikes ${target.name} for $dmg damage. '
            '${target.name} ${_pickDown()}',
            CombatEventType.heroDown,
          ));
        } else {
          events.add(CombatEvent(
            'The ${enemy.name} strikes ${target.name} for $dmg damage — a near fatal blow!',
            CombatEventType.enemyAttack,
          ));
        }
      }

      // Item modifier: thorns — reflect damage to attacker
      final thorns = target.equipment.modifierTotals.thornsDamageFlat;
      if (thorns > 0 && enemy.isAlive) {
        enemy.takeDamage(thorns);
        events.add(CombatEvent(
          '[Thorns] ${target.name}\'s armor retaliates — $thorns damage to ${enemy.name}.',
          CombatEventType.ability,
        ));
      }

      if (enemy.traits.contains(EnemyTrait.drainOnHit)) {
        final drainHeal = (dmg * 0.35).round().clamp(1, 20);
        enemy.currentHp = (enemy.currentHp + drainHeal).clamp(0, enemy.maxHp);
        events.add(CombatEvent(
          '[Life Drain] The spirit feeds on the wound. +$drainHeal HP. (${enemy.currentHp}/${enemy.maxHp})',
          CombatEventType.ability,
        ));
      }
    }

    // ── Per-round effects ─────────────────────────────────────────────

    // Active DoTs
    final expiredDots = <_ActiveDoT>[];
    for (final dot in activeDots) {
      if (dot.targetId == null) {
        // AoE DoT
        for (final e in List<Enemy>.from(enemies.where((e) => e.isAlive))) {
          e.takeDamage(dot.damagePerRound);
          if (!e.isAlive) {
            xpGained  += e.xpValue;
            goldFound += e.goldValue;
            _deathHarvestCheck(heroes, heroHpMap, activeSummons, events);
          }
          events.add(CombatEvent(
            '[${dot.spellName}] The ${e.name} suffers ${dot.damagePerRound} damage. (${e.currentHp}/${e.maxHp} HP)',
            CombatEventType.ability,
          ));
        }
      } else {
        final t = enemies.where((e) => e.id == dot.targetId && e.isAlive).firstOrNull;
        if (t != null) {
          t.takeDamage(dot.damagePerRound);
          if (!t.isAlive) {
            xpGained  += t.xpValue;
            goldFound += t.goldValue;
            _deathHarvestCheck(heroes, heroHpMap, activeSummons, events);
          }
          events.add(CombatEvent(
            '[${dot.spellName}] The ${t.name} suffers ${dot.damagePerRound} damage. (${t.currentHp}/${t.maxHp} HP)',
            CombatEventType.ability,
          ));
        }
      }
      dot.roundsLeft--;
      if (dot.roundsLeft <= 0) expiredDots.add(dot);
    }
    activeDots.removeWhere(expiredDots.contains);

    // Active summons
    final expiredSummons = <_ActiveSummon>[];
    for (final summon in activeSummons) {
      final aliveEne = enemies.where((e) => e.isAlive).toList();
      if (aliveEne.isNotEmpty) {
        final t = aliveEne[_rng.nextInt(aliveEne.length)];
        t.takeDamage(summon.damagePerRound);
        if (!t.isAlive) {
          xpGained  += t.xpValue;
          goldFound += t.goldValue;
          _deathHarvestCheck(heroes, heroHpMap, activeSummons, events);
        }
        events.add(CombatEvent(
          '[${summon.spellName}] ${summon.casterName}\'s summoned creature attacks the ${t.name} for ${summon.damagePerRound} damage. (${t.currentHp}/${t.maxHp} HP)',
          CombatEventType.ability,
        ));
      }
      summon.roundsLeft--;
      if (summon.roundsLeft <= 0) expiredSummons.add(summon);
    }
    activeSummons.removeWhere(expiredSummons.contains);

    // Hospitaller end-of-round heal
    final survivors = heroes.where((h) => (heroHpMap[h.id] ?? 0) > 0).toList();
    for (final hero in survivors) {
      if (hero.subclass == Subclass.hospitaller) {
        final hp = heroHpMap[hero.id] ?? 0;
        if (hp > 0 && hp < hero.maxHealth ~/ 2) {
          final heal = (hero.maxHealth * 0.08).round().clamp(1, 40);
          heroHpMap[hero.id] = (hp + heal).clamp(0, hero.maxHealth);
          events.add(CombatEvent(
            '[Field Surgery] ${hero.name}\'s prayer restores $heal HP.',
            CombatEventType.ability,
          ));
        }
      }
    }

    // Enemy self-regen
    for (final enemy in enemies.where((e) => e.isAlive)) {
      if (enemy.traits.contains(EnemyTrait.selfRegen)) {
        final healAmt = (enemy.maxHp * 0.05).round().clamp(1, 25);
        enemy.currentHp = (enemy.currentHp + healAmt).clamp(0, enemy.maxHp);
        events.add(CombatEvent(
          '[Undead Regeneration] The ${enemy.name} knits itself back together. '
          '+$healAmt HP. (${enemy.currentHp}/${enemy.maxHp})',
          CombatEventType.ability,
        ));
      }
    }
  }

  // Determine outcome
  final heroesStanding  = heroes.where((h) => (heroHpMap[h.id] ?? 0) > 0).length;
  final enemiesStanding = enemies.where((e) => e.isAlive).length;

  CombatOutcome outcome;
  if (enemiesStanding == 0) {
    outcome = CombatOutcome.victory;
    events.add(CombatEvent(
      'The party is victorious. +$xpGained XP, +$goldFound gold.',
      CombatEventType.loot,
    ));
  } else if (heroesStanding == 0) {
    outcome = CombatOutcome.partyWiped;
    events.add(CombatEvent('The party is overwhelmed.', CombatEventType.narrative));
  } else {
    outcome = CombatOutcome.retreat;
    events.add(CombatEvent('The party retreats to fight another day.', CombatEventType.narrative));
  }

  return EncounterResult(
    enemyNames: enemyList,
    events: events,
    outcome: outcome,
    goldFound: goldFound,
    xpGained: xpGained,
  );
}

// ─── FULL EXPEDITION ─────────────────────────────────────────────────────────

ExpeditionCombatResult resolveExpedition(
  List<model.Hero> party,
  LocationType locationType,
  int depth,
) {
  final heroHpMap   = {for (final h in party) h.id: h.currentHealth};
  final heroManaMap = {for (final h in party) h.id: h.currentMana};
  final encounters  = <EncounterResult>[];
  var totalGold     = 0;
  var totalXp       = 0;

  final numEncounters = encounterCount(locationType, depth);

  for (var i = 0; i < numEncounters; i++) {
    if (party.every((h) => (heroHpMap[h.id] ?? 0) <= 0)) break;

    // Mage: Mana Flow — recover 20% max mana between encounters (not on the first)
    if (i > 0) {
      for (final h in party) {
        if (h.heroClass == HeroClass.mage && (heroHpMap[h.id] ?? 0) > 0) {
          final recovery = (h.maxMana * 0.20).round();
          if (recovery > 0) {
            heroManaMap[h.id] = ((heroManaMap[h.id] ?? 0) + recovery).clamp(0, h.maxMana);
          }
        }
      }
    }

    final enemies = spawnEncounter(locationType, depth);
    final result  = resolveEncounter(party, enemies, heroHpMap, heroManaMap);
    encounters.add(result);
    totalGold += result.goldFound;
    totalXp   += result.xpGained;

    if (result.outcome == CombatOutcome.partyWiped) break;
  }

  // Boss encounter for depth >= 4
  if (depth >= 4 &&
      encounters.isNotEmpty &&
      encounters.last.outcome != CombatOutcome.partyWiped) {
    final livingHeroes = party.where((h) => (heroHpMap[h.id] ?? 0) > 0).toList();
    if (livingHeroes.isNotEmpty) {
      final boss       = spawnBoss(locationType, depth);
      final bossResult = resolveEncounter(party, [boss], heroHpMap, heroManaMap);
      encounters.add(bossResult);
      totalGold += bossResult.goldFound;
      totalXp   += bossResult.xpGained;
    }
  }

  // Injury / death
  final injured = <String>[];
  final dead    = <String>[];
  final rng     = Random();
  for (final hero in party) {
    final hp = heroHpMap[hero.id] ?? 0;
    if (hp <= 0) {
      if (hero.permadeathEnabled && rng.nextDouble() < 0.1) {
        dead.add(hero.id);
      } else {
        injured.add(hero.id);
      }
    }
  }

  final finalOutcome = dead.length == party.length
      ? CombatOutcome.partyWiped
      : encounters.last.outcome;

  final loot = _generateLoot(totalGold, locationType);

  return ExpeditionCombatResult(
    encounters: encounters,
    totalGold: totalGold,
    totalXp: totalXp,
    injuredHeroIds: injured,
    deadHeroIds: dead,
    finalOutcome: finalOutcome,
    lootDescriptions: loot,
    heroFinalMana: Map<String, int>.from(heroManaMap),
  );
}

// ─── LOOT DESCRIPTIONS ──────────────────────────────────────────────────────

const _lootPrefixes = [
  'A battered', 'A worn', 'A blood-stained', 'A fine', 'A rusted',
  'A cracked', 'A serviceable', 'An ornate',
];
const _lootItems = [
  'arming sword', 'iron mace', 'leather satchel', 'crossbow bolt bundle',
  'dagger', 'shield boss', 'gauntlet', 'helmet', 'purse of coin',
  'iron key', 'vial of poison', 'healing poultice', 'war axe head',
  'torn banner', 'silver ring', 'boot knife',
];

List<String> _generateLoot(int gold, LocationType locationType) {
  final items     = <String>[];
  final itemCount = _rng.nextInt(3);
  for (var i = 0; i < itemCount; i++) {
    final prefix = _lootPrefixes[_rng.nextInt(_lootPrefixes.length)];
    final item   = _lootItems[_rng.nextInt(_lootItems.length)];
    items.add('$prefix $item');
  }
  if (gold > 0) items.add('$gold gold coins');
  return items;
}
