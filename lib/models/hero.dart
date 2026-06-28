import 'enums.dart';
import 'stats.dart';
import 'weapon.dart';
import 'armor.dart';
import 'ability.dart';
import '../data/weapons_data.dart';
import '../data/armor_data.dart';

// ─── ITEM MODIFIER TOTALS ────────────────────────────────────────────────────
// Pre-computed aggregate of all ItemModifier bonuses from equipped instanced
// items. Recomputed by the notifier whenever equipment changes so the combat
// engine can read it without needing access to the inventory.

class ItemModifierTotals {
  final int    bonusDamageFlat;
  final int    armorPenFlat;
  final double critChanceBonus;      // fraction: 0.10 = +10% crit chance
  final double critDamageBonus;      // fraction added to 2.0× base crit mult
  final int    lifestealFlat;
  final double spellPowerBonus;      // fraction: 0.15 = +15% spell damage
  final int    bonusDefenseFlat;
  final int    bonusHpFlat;
  final double dodgeBonus;           // fraction: 0.08 = 8% chance to evade
  final double damageReductionBonus; // fraction: 0.05 = 5% less damage taken
  final int    thornsDamageFlat;

  const ItemModifierTotals({
    this.bonusDamageFlat      = 0,
    this.armorPenFlat         = 0,
    this.critChanceBonus      = 0.0,
    this.critDamageBonus      = 0.0,
    this.lifestealFlat        = 0,
    this.spellPowerBonus      = 0.0,
    this.bonusDefenseFlat     = 0,
    this.bonusHpFlat          = 0,
    this.dodgeBonus           = 0.0,
    this.damageReductionBonus = 0.0,
    this.thornsDamageFlat     = 0,
  });

  static const zero = ItemModifierTotals();

  Map<String, dynamic> toJson() => {
    'bonusDamageFlat':      bonusDamageFlat,
    'armorPenFlat':         armorPenFlat,
    'critChanceBonus':      critChanceBonus,
    'critDamageBonus':      critDamageBonus,
    'lifestealFlat':        lifestealFlat,
    'spellPowerBonus':      spellPowerBonus,
    'bonusDefenseFlat':     bonusDefenseFlat,
    'bonusHpFlat':          bonusHpFlat,
    'dodgeBonus':           dodgeBonus,
    'damageReductionBonus': damageReductionBonus,
    'thornsDamageFlat':     thornsDamageFlat,
  };

  factory ItemModifierTotals.fromJson(Map<String, dynamic> j) =>
      ItemModifierTotals(
        bonusDamageFlat:      (j['bonusDamageFlat']      as num? ?? 0).toInt(),
        armorPenFlat:         (j['armorPenFlat']         as num? ?? 0).toInt(),
        critChanceBonus:      (j['critChanceBonus']      as num? ?? 0.0).toDouble(),
        critDamageBonus:      (j['critDamageBonus']      as num? ?? 0.0).toDouble(),
        lifestealFlat:        (j['lifestealFlat']        as num? ?? 0).toInt(),
        spellPowerBonus:      (j['spellPowerBonus']      as num? ?? 0.0).toDouble(),
        bonusDefenseFlat:     (j['bonusDefenseFlat']     as num? ?? 0).toInt(),
        bonusHpFlat:          (j['bonusHpFlat']          as num? ?? 0).toInt(),
        dodgeBonus:           (j['dodgeBonus']           as num? ?? 0.0).toDouble(),
        damageReductionBonus: (j['damageReductionBonus'] as num? ?? 0.0).toDouble(),
        thornsDamageFlat:     (j['thornsDamageFlat']     as num? ?? 0).toInt(),
      );
}

// ─── EQUIPMENT ───────────────────────────────────────────────────────────────
// Stores item IDs and resolves them to live objects from the master data lists.
// This keeps saves small and ensures items always reflect their canonical stats.

class HeroEquipment {
  final String? mainHandId;
  final String? offHandId;
  final String? headId;
  final String? bodyId;
  final String? handsId;
  final String? legsId;
  final String? feetId;
  final String? shieldId;
  // Maps slot name → instanceId when the equipped item came from a trader (has modifiers).
  // Slots: 'mainHand','offHand','head','body','hands','legs','feet','shield'
  final Map<String, String> slotInstanceIds;
  final ItemModifierTotals modifierTotals;

  const HeroEquipment({
    this.mainHandId,
    this.offHandId,
    this.headId,
    this.bodyId,
    this.handsId,
    this.legsId,
    this.feetId,
    this.shieldId,
    this.slotInstanceIds = const {},
    this.modifierTotals = ItemModifierTotals.zero,
  });

  // Resolved lookups
  Weapon? get mainHand => _weapon(mainHandId);
  Weapon? get offHand  => _weapon(offHandId);
  Armor?  get head     => _armor(headId);
  Armor?  get body     => _armor(bodyId);
  Armor?  get hands    => _armor(handsId);
  Armor?  get legs     => _armor(legsId);
  Armor?  get feet     => _armor(feetId);
  Armor?  get shield   => _armor(shieldId);

  static Weapon? _weapon(String? id) =>
      id == null ? null : allWeapons.where((w) => w.id == id).firstOrNull;

  static Armor? _armor(String? id) =>
      id == null ? null : allArmor.where((a) => a.id == id).firstOrNull;

  int get totalDefense =>
      (head?.defense   ?? 0) +
      (body?.defense   ?? 0) +
      (hands?.defense  ?? 0) +
      (legs?.defense   ?? 0) +
      (feet?.defense   ?? 0) +
      (shield?.defense ?? 0);

  int get totalWeight =>
      (head?.weight   ?? 0) +
      (body?.weight   ?? 0) +
      (hands?.weight  ?? 0) +
      (legs?.weight   ?? 0) +
      (feet?.weight   ?? 0) +
      (shield?.weight ?? 0);

  HeroEquipment copyWith({
    Object? mainHandId  = _sentinel,
    Object? offHandId   = _sentinel,
    Object? headId      = _sentinel,
    Object? bodyId      = _sentinel,
    Object? handsId     = _sentinel,
    Object? legsId      = _sentinel,
    Object? feetId      = _sentinel,
    Object? shieldId    = _sentinel,
    Map<String, String>? slotInstanceIds,
    ItemModifierTotals? modifierTotals,
  }) {
    return HeroEquipment(
      mainHandId: mainHandId  == _sentinel ? this.mainHandId  : mainHandId  as String?,
      offHandId:  offHandId   == _sentinel ? this.offHandId   : offHandId   as String?,
      headId:     headId      == _sentinel ? this.headId      : headId      as String?,
      bodyId:     bodyId      == _sentinel ? this.bodyId      : bodyId      as String?,
      handsId:    handsId     == _sentinel ? this.handsId     : handsId     as String?,
      legsId:     legsId      == _sentinel ? this.legsId      : legsId      as String?,
      feetId:     feetId      == _sentinel ? this.feetId      : feetId      as String?,
      shieldId:   shieldId    == _sentinel ? this.shieldId    : shieldId    as String?,
      slotInstanceIds: slotInstanceIds ?? this.slotInstanceIds,
      modifierTotals:  modifierTotals  ?? this.modifierTotals,
    );
  }

  Map<String, dynamic> toJson() => {
        'mainHandId': mainHandId,
        'offHandId':  offHandId,
        'headId':     headId,
        'bodyId':     bodyId,
        'handsId':    handsId,
        'legsId':     legsId,
        'feetId':     feetId,
        'shieldId':   shieldId,
        'slotInstanceIds': slotInstanceIds,
        'modifierTotals':  modifierTotals.toJson(),
      };

  factory HeroEquipment.fromJson(Map<String, dynamic> j) => HeroEquipment(
        mainHandId: j['mainHandId'] as String?,
        offHandId:  j['offHandId']  as String?,
        headId:     j['headId']     as String?,
        bodyId:     j['bodyId']     as String?,
        handsId:    j['handsId']    as String?,
        legsId:     j['legsId']     as String?,
        feetId:     j['feetId']     as String?,
        shieldId:   j['shieldId']   as String?,
        slotInstanceIds: Map<String, String>.from(
            j['slotInstanceIds'] as Map? ?? {}),
        modifierTotals: j['modifierTotals'] != null
            ? ItemModifierTotals.fromJson(
                j['modifierTotals'] as Map<String, dynamic>)
            : ItemModifierTotals.zero,
      );
}

// Sentinel to distinguish "not passed" from "explicitly null" in copyWith
const _sentinel = Object();

// ─── HERO ────────────────────────────────────────────────────────────────────

class Hero {
  final String id;
  final String name;
  final int age;
  final HeroClass heroClass;
  final Subclass? subclass;
  final int level;
  final int experience;
  final HeroStats baseStats;
  final FaithType? faith;
  final double devotion;
  final int currentHealth;
  final int currentMana;
  final List<String> knownSpells;    // all spell IDs this hero has learned
  final List<String> equippedSpells; // spell IDs assigned to active slots
  final HeroEquipment equipment;
  final List<Ability> abilities;
  final HeroStatus status;
  final int recoverySecondsRemaining;
  final String? imageUrl;
  final String? localImagePath;
  final bool isPlayerCharacter;
  final bool permadeathEnabled;
  final bool isFemale;
  final List<String> devotionPerkIds; // chosen perk IDs, one per unlocked tier
  final HeroStats perkStatBonus;      // summed stat bonus from chosen perks

  const Hero({
    required this.id,
    required this.name,
    required this.age,
    required this.heroClass,
    this.subclass,
    this.level = 1,
    this.experience = 0,
    required this.baseStats,
    this.faith,
    this.devotion = 0.0,
    required this.currentHealth,
    this.currentMana = 0,
    this.knownSpells = const [],
    this.equippedSpells = const [],
    this.equipment = const HeroEquipment(),
    this.abilities = const [],
    this.status = HeroStatus.active,
    this.recoverySecondsRemaining = 0,
    this.imageUrl,
    this.localImagePath,
    this.isPlayerCharacter = false,
    this.permadeathEnabled = false,
    this.isFemale = false,
    this.devotionPerkIds = const [],
    this.perkStatBonus = const HeroStats(
        strength: 0, dexterity: 0, endurance: 0,
        intelligence: 0, faith: 0, luck: 0),
  });

  int get maxHealth => baseStats.maxHealth + (level - 1) * 8 + equipment.modifierTotals.bonusHpFlat;
  bool get isAlive    => status != HeroStatus.dead;
  bool get isAvailable=> status == HeroStatus.active;
  int  get experienceToNextLevel => level * 100;

  int get maxMana {
    if (!heroClass.isCaster) return 0;
    return 10 + (effectiveStats.intelligence * 3) + (level * 3);
  }

  int get maxSpellSlots {
    if (!heroClass.isCaster) return 0;
    if (level >= 20) return 6;
    if (level >= 15) return 5;
    if (level >= 10) return 4;
    if (level >= 5)  return 3;
    return 2;
  }

  HeroStats get effectiveStats {
    var bonus = perkStatBonus; // start with perk bonuses

    void add(HeroStats? s) { if (s != null) bonus = bonus + s; }

    add(equipment.mainHand?.statBonus);
    add(equipment.offHand?.statBonus);
    add(equipment.head?.statBonus);
    add(equipment.body?.statBonus);
    add(equipment.hands?.statBonus);
    add(equipment.legs?.statBonus);
    add(equipment.feet?.statBonus);
    add(equipment.shield?.statBonus);

    return baseStats + bonus;
  }

  Hero copyWith({
    String? id,
    String? name,
    int? age,
    HeroClass? heroClass,
    // Use _sentinel so callers can explicitly pass null to clear these fields.
    Object? subclass  = _sentinel,
    int? level,
    int? experience,
    HeroStats? baseStats,
    Object? faith     = _sentinel,
    double? devotion,
    int? currentHealth,
    int? currentMana,
    List<String>? knownSpells,
    List<String>? equippedSpells,
    HeroEquipment? equipment,
    List<Ability>? abilities,
    HeroStatus? status,
    int? recoverySecondsRemaining,
    Object? imageUrl       = _sentinel,
    Object? localImagePath = _sentinel,
    bool? isPlayerCharacter,
    bool? permadeathEnabled,
    bool? isFemale,
    List<String>? devotionPerkIds,
    HeroStats? perkStatBonus,
  }) {
    return Hero(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      heroClass: heroClass ?? this.heroClass,
      subclass:  subclass  == _sentinel ? this.subclass  : subclass  as Subclass?,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      baseStats: baseStats ?? this.baseStats,
      faith:     faith     == _sentinel ? this.faith     : faith     as FaithType?,
      devotion: devotion ?? this.devotion,
      currentHealth: currentHealth ?? this.currentHealth,
      currentMana: currentMana ?? this.currentMana,
      knownSpells: knownSpells ?? this.knownSpells,
      equippedSpells: equippedSpells ?? this.equippedSpells,
      equipment: equipment ?? this.equipment,
      abilities: abilities ?? this.abilities,
      status: status ?? this.status,
      recoverySecondsRemaining:
          recoverySecondsRemaining ?? this.recoverySecondsRemaining,
      imageUrl:       imageUrl       == _sentinel ? this.imageUrl       : imageUrl       as String?,
      localImagePath: localImagePath == _sentinel ? this.localImagePath : localImagePath as String?,
      isPlayerCharacter: isPlayerCharacter ?? this.isPlayerCharacter,
      permadeathEnabled: permadeathEnabled ?? this.permadeathEnabled,
      isFemale: isFemale ?? this.isFemale,
      devotionPerkIds: devotionPerkIds ?? this.devotionPerkIds,
      perkStatBonus: perkStatBonus ?? this.perkStatBonus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'heroClass': heroClass.name,
        'subclass': subclass?.name,
        'level': level,
        'experience': experience,
        'baseStats': baseStats.toJson(),
        'faith': faith?.name,
        'devotion': devotion,
        'currentHealth': currentHealth,
        'currentMana': currentMana,
        'knownSpells': knownSpells,
        'equippedSpells': equippedSpells,
        'equipment': equipment.toJson(),
        'status': status.name,
        'recoverySecondsRemaining': recoverySecondsRemaining,
        'imageUrl': imageUrl,
        'localImagePath': localImagePath,
        'isPlayerCharacter': isPlayerCharacter,
        'permadeathEnabled': permadeathEnabled,
        'isFemale': isFemale,
        'devotionPerkIds': devotionPerkIds,
        'perkStatBonus': perkStatBonus.toJson(),
      };

  factory Hero.fromJson(Map<String, dynamic> json) => Hero(
        id: json['id'],
        name: json['name'],
        age: json['age'],
        heroClass: HeroClass.values.byName(json['heroClass']),
        subclass: json['subclass'] != null
            ? Subclass.values.byName(json['subclass'])
            : null,
        level: json['level'] ?? 1,
        experience: json['experience'] ?? 0,
        baseStats: HeroStats.fromJson(json['baseStats']),
        faith: json['faith'] != null
            ? FaithType.values.byName(json['faith'])
            : null,
        devotion: (json['devotion'] ?? 0.0).toDouble(),
        currentHealth: json['currentHealth'],
        currentMana: json['currentMana'] as int? ?? 0,
        knownSpells: List<String>.from(json['knownSpells'] as List? ?? []),
        equippedSpells: List<String>.from(json['equippedSpells'] as List? ?? []),
        equipment: json['equipment'] != null
            ? HeroEquipment.fromJson(json['equipment'])
            : const HeroEquipment(),
        status: HeroStatus.values.byName(json['status'] ?? 'active'),
        recoverySecondsRemaining: json['recoverySecondsRemaining'] ?? 0,
        imageUrl: json['imageUrl'],
        localImagePath: json['localImagePath'] as String?,
        isPlayerCharacter: json['isPlayerCharacter'] ?? false,
        permadeathEnabled: json['permadeathEnabled'] ?? false,
        isFemale: json['isFemale'] ?? false,
        devotionPerkIds: List<String>.from(json['devotionPerkIds'] as List? ?? []),
        perkStatBonus: json['perkStatBonus'] != null
            ? HeroStats.fromJson(json['perkStatBonus'])
            : const HeroStats(strength: 0, dexterity: 0, endurance: 0,
                intelligence: 0, faith: 0, luck: 0),
      );
}
