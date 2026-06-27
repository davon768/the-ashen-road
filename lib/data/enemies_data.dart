import 'dart:math';
import '../models/enemy.dart';
import '../models/enums.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
final _rng = Random();

// ─── ENEMY TEMPLATES ────────────────────────────────────────────────────────
// Each template is a function that returns a fresh Enemy instance.
// Scaled by a difficulty multiplier so deeper dungeons spawn tougher versions.

typedef EnemyTemplate = Enemy Function(double scale);

const _humanNames = [
  'Bandit', 'Cutthroat', 'Deserter', 'Sellsword', 'Poacher',
  'Brigand', 'Raider', 'Outlaw', 'Hedge Knight', 'Footpad',
];
const _undeadNames = [
  'Skeleton Warrior', 'Drowned Man', 'Risen Soldier', 'Wight',
  'Revenant', 'Grave Walker', 'Hollow Knight', 'Barrow Guard',
];
const _beastNames = [
  'Gaunt Wolf', 'Black Boar', 'Cave Bear', 'Plague Rat Swarm',
  'Dire Hound', 'Giant Adder', 'Rabid Dog',
];
const _supernaturalNames = [
  'Shade', 'Wraith', 'Void-Touched Spirit', 'Haunting',
  'Blood Spectre', 'Gibbering Horror', 'Ashen Apparition',
];
const _eliteNames = [
  'Captain of the Guard', 'Knight-Errant', 'Warlord',
  'High Priest of the Pale Court', 'Void-Sworn Champion',
  'Death Knight', 'Veteran Man-at-Arms', 'Dungeon Boss',
];

const _bossNamesByType = {
  'dungeon':    ['The Pale Warden', 'Lord of the Hollow Warren', 'The Ashen King',
                 'Arch-Revenant', 'The Bonethrone Guardian', 'Voice of the Pit'],
  'castle':     ['Baron of the Sunken Keep', 'The Iron Warlord', 'Castellan of Blood',
                 'The Forgotten Lord', 'Knight-Commander Ashwick', 'The Blackspire Tyrant'],
  'ruins':      ['The Drowned Sentinel', 'Keeper of the Broken Gate', 'The Last Warden',
                 'Ruinfather', 'The Charred Abbot', 'Spirit of the Old King'],
  'monastery':  ['The Corrupted Prior', 'He Who Rang the Bell Last', 'The Pale Abbot',
                 'The Cursed Sexton', 'The Void-Touched High Priest', 'Brother Ashenwrath'],
  'castle_alt': ['The Void-Sworn Champion', 'The Iron Marshal', 'Grimhaven\'s Heir'],
  'wilderness': ['The Beast-King', 'The Hunger', 'Lord of the Black Fells',
                 'The Gaunt Alpha', 'Ashwood\'s Dread'],
  'town':       ['The Crime Lord', 'The Poisoned Mayor', 'The Taxmaster\'s Shadow'],
  'cemetery':   ['The Graveswarden', 'Lord of the Unmourned', 'The Pale Walker',
                 'The Lich of the Long Barrow', 'The Mourning King'],
  'library':    ['The Forbidden Archivist', 'Keeper of the Void Codex', 'The Locked Chapter',
                 'The Pale Court\'s Voice', 'The Last Cataloguer'],
  'forge':      ['The Infernal Smeltwright', 'The Iron Exile', 'Master of the Deepfire',
                 'The Undying Forgemaster', 'The Black Iron Warden'],
};

Enemy _makeHuman(double scale) => Enemy(
      id: _uuid.v4(),
      name: _humanNames[_rng.nextInt(_humanNames.length)],
      type: EnemyType.human,
      maxHp: (25 * scale).round(),
      minDamage: (4 * scale).round(),
      maxDamage: (9 * scale).round(),
      armor: (2 * scale).round(),
      xpValue: (10 * scale).round(),
      goldValue: (3 * scale).round() + _rng.nextInt(8),
      traits: {EnemyTrait.fleeOnLowHp},
    );

Enemy _makeUndead(double scale) => Enemy(
      id: _uuid.v4(),
      name: _undeadNames[_rng.nextInt(_undeadNames.length)],
      type: EnemyType.undead,
      maxHp: (30 * scale).round(),
      minDamage: (5 * scale).round(),
      maxDamage: (11 * scale).round(),
      armor: (3 * scale).round(),
      xpValue: (14 * scale).round(),
      goldValue: _rng.nextInt(5),
      traits: scale >= 1.5
          ? {EnemyTrait.critImmune, EnemyTrait.selfRegen}
          : {EnemyTrait.critImmune},
    );

Enemy _makeBeast(double scale) => Enemy(
      id: _uuid.v4(),
      name: _beastNames[_rng.nextInt(_beastNames.length)],
      type: EnemyType.beast,
      maxHp: (20 * scale).round(),
      minDamage: (6 * scale).round(),
      maxDamage: (12 * scale).round(),
      armor: 0,
      critChance: 0.12,
      xpValue: (8 * scale).round(),
      goldValue: 0,
      traits: {EnemyTrait.armorPiercing},
    );

Enemy _makeSupernatural(double scale) => Enemy(
      id: _uuid.v4(),
      name: _supernaturalNames[_rng.nextInt(_supernaturalNames.length)],
      type: EnemyType.supernatural,
      maxHp: (18 * scale).round(),
      minDamage: (8 * scale).round(),
      maxDamage: (16 * scale).round(),
      armor: 0,
      critChance: 0.2,
      xpValue: (20 * scale).round(),
      goldValue: _rng.nextInt(12),
      traits: scale >= 1.5
          ? {EnemyTrait.phaseOnCrit, EnemyTrait.partyDamage}
          : {EnemyTrait.phaseOnCrit},
    );

Enemy _makeElite(double scale) => Enemy(
      id: _uuid.v4(),
      name: _eliteNames[_rng.nextInt(_eliteNames.length)],
      type: EnemyType.elite,
      maxHp: (70 * scale).round(),
      minDamage: (10 * scale).round(),
      maxDamage: (18 * scale).round(),
      armor: (6 * scale).round(),
      critChance: 0.1,
      xpValue: (50 * scale).round(),
      goldValue: (20 * scale).round() + _rng.nextInt(20),
      traits: {EnemyTrait.critImmune},
    );

// ─── ENCOUNTER SPAWNING ─────────────────────────────────────────────────────

/// Returns a list of enemies for one encounter based on location type and depth.
List<Enemy> spawnEncounter(LocationType locationType, int depth) {
  final scale = 1.0 + (depth - 1) * 0.25;
  final count = 1 + _rng.nextInt(3); // 1–3 enemies per encounter
  final isEliteEncounter = _rng.nextDouble() < 0.15;

  if (isEliteEncounter) return [_makeElite(scale)];

  return List.generate(count, (_) {
    return switch (locationType) {
      LocationType.dungeon    => _rng.nextDouble() < 0.5 ? _makeUndead(scale) : _makeHuman(scale),
      LocationType.castle     => _rng.nextDouble() < 0.7 ? _makeHuman(scale) : _makeElite(scale * 0.7),
      LocationType.town       => _makeHuman(scale * 0.8),
      LocationType.wilderness => _rng.nextDouble() < 0.6 ? _makeBeast(scale) : _makeHuman(scale),
      LocationType.ruins      => _rng.nextDouble() < 0.6 ? _makeUndead(scale) : _makeSupernatural(scale),
      LocationType.monastery  => _rng.nextDouble() < 0.5 ? _makeSupernatural(scale) : _makeUndead(scale),
      LocationType.cemetery   => _rng.nextDouble() < 0.7 ? _makeUndead(scale) : _makeSupernatural(scale),
      LocationType.library    => _rng.nextDouble() < 0.5 ? _makeSupernatural(scale) : _makeHuman(scale),
      LocationType.forge      => _rng.nextDouble() < 0.6 ? _makeHuman(scale) : _makeElite(scale * 0.8),
      // Faith sites are friendly — no combat encounters; these cases are unreachable
      LocationType.church || LocationType.shrine || LocationType.cultSite => _makeHuman(scale),
    };
  });
}

/// A named boss enemy for high-depth expeditions (depth >= 4).
Enemy spawnBoss(LocationType locationType, int depth) {
  final scale = 1.0 + (depth - 1) * 0.40;
  final typeKey = switch (locationType) {
    LocationType.dungeon    => 'dungeon',
    LocationType.castle     => 'castle',
    LocationType.ruins      => 'ruins',
    LocationType.monastery  => 'monastery',
    LocationType.wilderness => 'wilderness',
    LocationType.town       => 'town',
    LocationType.cemetery   => 'cemetery',
    LocationType.library    => 'library',
    LocationType.forge      => 'forge',
    LocationType.church || LocationType.shrine || LocationType.cultSite => 'dungeon',
  };
  final names = _bossNamesByType[typeKey]!;
  final name  = names[_rng.nextInt(names.length)];
  final bossType = switch (locationType) {
    LocationType.dungeon    => EnemyType.undead,
    LocationType.castle     => EnemyType.elite,
    LocationType.ruins      => EnemyType.supernatural,
    LocationType.monastery  => EnemyType.supernatural,
    LocationType.wilderness => EnemyType.beast,
    LocationType.town       => EnemyType.human,
    LocationType.cemetery   => EnemyType.undead,
    LocationType.library    => EnemyType.supernatural,
    LocationType.forge      => EnemyType.elite,
    LocationType.church || LocationType.shrine || LocationType.cultSite => EnemyType.human,
  };
  return Enemy(
    id: _uuid.v4(),
    name: name,
    type: bossType,
    maxHp: (200 * scale).round(),
    minDamage: (14 * scale).round(),
    maxDamage: (26 * scale).round(),
    armor: (6 * scale).round(),
    critChance: 0.18,
    xpValue: (200 * scale).round(),
    goldValue: (100 * scale).round() + _rng.nextInt(60),
    isBoss: true,
    traits: switch (bossType) {
      EnemyType.undead       => {EnemyTrait.critImmune, EnemyTrait.selfRegen},
      EnemyType.elite        => {EnemyTrait.critImmune},
      EnemyType.supernatural => {EnemyTrait.phaseOnCrit, EnemyTrait.partyDamage, EnemyTrait.drainOnHit},
      EnemyType.beast        => {EnemyTrait.armorPiercing},
      EnemyType.human        => {EnemyTrait.critImmune},
    },
  );
}

/// How many encounters happen in a full expedition.
int encounterCount(LocationType type, int depth) {
  final base = switch (type) {
    LocationType.dungeon    => 4,
    LocationType.castle     => 3,
    LocationType.town       => 1,
    LocationType.wilderness => 2,
    LocationType.ruins      => 3,
    LocationType.monastery  => 2,
    LocationType.cemetery   => 3,
    LocationType.library    => 2,
    LocationType.forge      => 3,
    LocationType.church || LocationType.shrine || LocationType.cultSite => 0,
  };
  return base + _rng.nextInt(3);
}
