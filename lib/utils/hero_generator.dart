import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/hero.dart';
import '../models/enums.dart';
import '../models/stats.dart';

const Map<HeroClass, List<String>> _startingSpells = {
  HeroClass.mage:        ['arcane_missile', 'frost_bolt'],
  HeroClass.warlock:     ['shadow_bolt', 'drain_life'],
  HeroClass.necromancer: ['death_bolt', 'bone_shard'],
  HeroClass.priest:      ['smite', 'sacred_word'],
};

int _initialMana(HeroClass heroClass, HeroStats stats) {
  if (!heroClass.isCaster) return 0;
  // Mirrors Hero.maxMana at level 1 with no equipment bonus
  return 10 + (stats.intelligence * 2) + 2;
}

const _uuid = Uuid();
final _rng = Random();

const _maleNames = [
  'Aldric','Bram','Cedric','Dorin','Edmund','Fenwick','Godwin','Harald',
  'Ingvar','Jorin','Kaelin','Leofric','Magnus','Nolan','Osbert','Percival',
  'Ragnar','Sigurd','Theron','Ulrich','Valdric','Wulfric','Yorick','Zaran',
];
const _femaleNames = [
  'Aelith','Brynn','Celeste','Dagmar','Edith','Freya','Gunnhild','Hilde',
  'Isolde','Jora','Kessa','Leofwyn','Maren','Nessa','Oswyn','Petra',
  'Ragnhild','Sigrid','Thyra','Ursa','Valdis','Wilda','Ysolde','Zara',
];
const _surnames = [
  'Ashwood','Blackthorn','Coldwater','Dunmore','Embervale','Frostmantle',
  'Greystone','Halloway','Ironfield','Kettleburn','Lochridge','Mournwall',
  'Nighthollow','Oakenshield','Pale','Queensmere','Ravenscroft','Stormgate',
  'Thornwall','Underhill','Vantablack','Whitmore','Yellowmere','Zephyrholt',
];

const Map<HeroClass, HeroStats> _classBaseStats = {
  HeroClass.knight:     HeroStats(strength:8,dexterity:4,endurance:9,intelligence:2,faith:4,luck:3),
  HeroClass.ranger:     HeroStats(strength:4,dexterity:9,endurance:6,intelligence:3,faith:2,luck:6),
  HeroClass.priest:     HeroStats(strength:3,dexterity:3,endurance:5,intelligence:5,faith:10,luck:4),
  HeroClass.mage:       HeroStats(strength:2,dexterity:4,endurance:3,intelligence:11,faith:3,luck:7),
  HeroClass.rogue:      HeroStats(strength:4,dexterity:10,endurance:4,intelligence:4,faith:1,luck:7),
  HeroClass.necromancer:HeroStats(strength:2,dexterity:3,endurance:4,intelligence:10,faith:7,luck:4),
  HeroClass.warlock:    HeroStats(strength:3,dexterity:4,endurance:4,intelligence:9,faith:8,luck:2),
};

const Map<HeroClass, List<FaithType>> _classFaithAffinities = {
  HeroClass.knight:      [FaithType.luminantChurch, FaithType.oldWays],
  HeroClass.ranger:      [FaithType.oldWays, FaithType.compactOfSaints],
  HeroClass.priest:      [FaithType.luminantChurch, FaithType.compactOfSaints, FaithType.paleCourt],
  HeroClass.mage:        [FaithType.compactOfSaints, FaithType.ashenRite],
  HeroClass.rogue:       [FaithType.compactOfSaints, FaithType.ashenRite],
  HeroClass.necromancer: [FaithType.paleCourt, FaithType.ashenRite],
  HeroClass.warlock:     [FaithType.ashenRite, FaithType.paleCourt],
};

/// Build the player character with chosen name, class, faith, and gender.
/// Gets +1 on every stat roll to reflect being the protagonist.
Hero createPlayerHero(
  String name,
  HeroClass heroClass,
  FaithType faith, {
  bool isFemale = false,
}) {
  final base = _classBaseStats[heroClass]!;
  final stats = HeroStats(
    strength:     base.strength     + _rng.nextInt(3) + 1,
    dexterity:    base.dexterity    + _rng.nextInt(3) + 1,
    endurance:    base.endurance    + _rng.nextInt(3) + 1,
    intelligence: base.intelligence + _rng.nextInt(3) + 1,
    faith:        base.faith        + _rng.nextInt(3) + 1,
    luck:         base.luck         + _rng.nextInt(3) + 1,
  );
  final spells = _startingSpells[heroClass] ?? [];
  return Hero(
    id: _uuid.v4(),
    name: name,
    age: 22 + _rng.nextInt(12),
    heroClass: heroClass,
    baseStats: stats,
    faith: faith,
    devotion: 10,
    currentHealth: stats.maxHealth,
    currentMana: _initialMana(heroClass, stats),
    knownSpells: spells,
    equippedSpells: spells,
    isPlayerCharacter: true,
    isFemale: isFemale,
  );
}

Hero generateHero({bool isPlayer = false}) {
  final isFemale = _rng.nextBool();
  final firstName = isFemale
      ? _femaleNames[_rng.nextInt(_femaleNames.length)]
      : _maleNames[_rng.nextInt(_maleNames.length)];
  final surname = _surnames[_rng.nextInt(_surnames.length)];
  final name = '$firstName $surname';

  final heroClass =
      HeroClass.values[_rng.nextInt(HeroClass.values.length)];
  final baseStats = _classBaseStats[heroClass]!;

  // Add small random variation so heroes feel individual
  final stats = HeroStats(
    strength:     baseStats.strength     + _rng.nextInt(3),
    dexterity:    baseStats.dexterity    + _rng.nextInt(3),
    endurance:    baseStats.endurance    + _rng.nextInt(3),
    intelligence: baseStats.intelligence + _rng.nextInt(3),
    faith:        baseStats.faith        + _rng.nextInt(3),
    luck:         baseStats.luck         + _rng.nextInt(3),
  );

  final affinities = _classFaithAffinities[heroClass]!;
  final faith = _rng.nextDouble() < 0.85
      ? affinities[_rng.nextInt(affinities.length)]
      : FaithType.values[_rng.nextInt(FaithType.values.length)];

  final spells = _startingSpells[heroClass] ?? [];
  return Hero(
    id: _uuid.v4(),
    name: name,
    age: 18 + _rng.nextInt(22),
    heroClass: heroClass,
    baseStats: stats,
    faith: faith,
    devotion: _rng.nextDouble() * 15,
    currentHealth: stats.maxHealth,
    currentMana: _initialMana(heroClass, stats),
    knownSpells: spells,
    equippedSpells: spells,
    isPlayerCharacter: isPlayer,
    isFemale: isFemale,
  );
}
