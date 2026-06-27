import 'dart:math';
import '../models/enums.dart';

final _rng = Random();

const _dungeonPrefixes = [
  'The Sunken','The Drowned','The Forgotten','The Ashen','The Pale',
  'The Black','The Hollow','The Rotting','The Iron','The Salt',
];
const _dungeonSuffixes = [
  'Vault','Crypt','Barrow','Keep','Warren','Pit','Maw','Cellar','Hold','Tomb',
];
const _castlePrefixes = [
  'Ironwall','Ashkeep','Greymoor','Coldstone','Thornwall','Blackspire',
  'Duskhold','Emberfell','Grimhaven','Saltkeep',
];
const _townPrefixes = [
  'Millhaven','Ashwick','Dunford','Greywater','Embervale','Coldmere',
  'Thornfield','Halloway','Ironbridge','Salthaven',
];
const _wildernessNames = [
  'The Ashwood','The Pale Moors','The Thornfeld','The Greymarch',
  'The Salted Wastes','The Duskwood','The Ironfen','The Coldmere',
  'The Black Fells','The Rotting Mere',
];
const _ruinsNames = [
  'The Old Watchtower','The Broken Abbey','The Drowned Village',
  'The Shattered Rampart','The Collapsed Mineshaft','The Ruined Gatehouse',
  'The Charred Cathedral','The Sunken Granary',
];
const _monasteryNames = [
  'The Monastery of Pale Flame','The Abbey of the Three Saints',
  'The Priory of Ash','The Hermitage of the Void','The Chapter House of Iron',
  'The Shrine of the Old Ways','The Sanctuary of Last Rites',
];
const _cemeteryNames = [
  'The Barrow Field','The Weeping Ground','The Unmarked Hollow',
  'The Crooked Hill','The Plague Yard','The Salt Graves','The Long Mound',
  'The Warden\'s Rest','The Unmourned Ground','The Cold Garden',
];
const _libraryNames = [
  'The Sealed Archive','The Wayfarers\' Record','The Grey Repository',
  'The Pale Court\'s Index','The Road Compendium','The Ash Library',
  'The Chronicler\'s Annex','The Forbidden Catalogue','The Dusty Keep',
];
const _forgeNames = [
  'The Cold Hearth','The Iron Works','The Ashen Foundry',
  'The Black Anvil','The Deepfire Works','The Salt Forge',
  'The Broken Crucible','The Unlit Furnace','The Warm Pit',
];
const _churchNames = [
  'The Chapel of the Road','The Church of the Pale Flame','The Sanctuary of the Sun-Wheel',
  'The Wayside Altar','The Iron Bell Chapel','The Church of the Faithful Dead',
  'The Saint\'s Crossing','The Candlelit Nave','The Traveller\'s Chapel',
];
const _shrineNames = [
  'The Standing Stone','The Old Way Marker','The Thornwood Shrine',
  'The Weathered Circle','The Moonpool Shrine','The Ash Grove Altar',
  'The Cairn of the Elder Road','The Root Stone','The Way of the Fern',
];
const _cultSiteNames = [
  'The Hidden Altar','The Night Fold','The Sunken Circle',
  'The Ashen Rite Hollow','The Ritual Clearing','The Black Congregation',
  'The Void Fold','The Marked Ground','The Below-Path',
];

class GeneratedLocation {
  final String name;
  final LocationType type;
  final int durationSeconds;    // how long the expedition takes
  final String description;
  final int recommendedLevel;

  const GeneratedLocation({
    required this.name,
    required this.type,
    required this.durationSeconds,
    required this.description,
    required this.recommendedLevel,
  });
}

GeneratedLocation generateLocation(LocationType type) {
  return switch (type) {
    LocationType.dungeon   => _genDungeon(),
    LocationType.castle    => _genCastle(),
    LocationType.town      => _genTown(),
    LocationType.wilderness=> _genWilderness(),
    LocationType.ruins     => _genRuins(),
    LocationType.monastery => _genMonastery(),
    LocationType.cemetery  => _genCemetery(),
    LocationType.library   => _genLibrary(),
    LocationType.forge     => _genForge(),
    LocationType.church    => _genChurch(),
    LocationType.shrine    => _genShrine(),
    LocationType.cultSite  => _genCultSite(),
  };
}

List<GeneratedLocation> generateLocationChoices() {
  final types = LocationType.values.toList()..shuffle(_rng);
  return types.take(4).map(generateLocation).toList();
}

GeneratedLocation _genDungeon() {
  final name =
      '${_dungeonPrefixes[_rng.nextInt(_dungeonPrefixes.length)]} '
      '${_dungeonSuffixes[_rng.nextInt(_dungeonSuffixes.length)]}';
  final depth = 1 + _rng.nextInt(5);
  return GeneratedLocation(
    name: name,
    type: LocationType.dungeon,
    durationSeconds: depth * 120,
    description: 'A dark underground complex. ${depth > 3 ? "Danger lurks deep within." : "Manageable for a capable party."}',
    recommendedLevel: depth,
  );
}

GeneratedLocation _genCastle() {
  final name = _castlePrefixes[_rng.nextInt(_castlePrefixes.length)];
  final level = 2 + _rng.nextInt(4);
  return GeneratedLocation(
    name: name,
    type: LocationType.castle,
    durationSeconds: level * 180,
    description: 'A fortified stronghold. The walls have seen sieges before.',
    recommendedLevel: level,
  );
}

GeneratedLocation _genTown() {
  final name = _townPrefixes[_rng.nextInt(_townPrefixes.length)];
  return GeneratedLocation(
    name: name,
    type: LocationType.town,
    durationSeconds: 90 + _rng.nextInt(90),
    description: 'A settlement on the road. Trade, rumours, and trouble in equal measure.',
    recommendedLevel: 1,
  );
}

GeneratedLocation _genWilderness() {
  final name = _wildernessNames[_rng.nextInt(_wildernessNames.length)];
  final level = 1 + _rng.nextInt(3);
  return GeneratedLocation(
    name: name,
    type: LocationType.wilderness,
    durationSeconds: level * 150,
    description: 'Open country with no roads. Bandits, beasts, and the occasional discovery.',
    recommendedLevel: level,
  );
}

GeneratedLocation _genRuins() {
  final name = _ruinsNames[_rng.nextInt(_ruinsNames.length)];
  final level = 1 + _rng.nextInt(4);
  return GeneratedLocation(
    name: name,
    type: LocationType.ruins,
    durationSeconds: level * 130,
    description: 'The remnants of something older. What was left behind may still be dangerous.',
    recommendedLevel: level,
  );
}

GeneratedLocation _genMonastery() {
  final name = _monasteryNames[_rng.nextInt(_monasteryNames.length)];
  final level = 1 + _rng.nextInt(3);
  return GeneratedLocation(
    name: name,
    type: LocationType.monastery,
    durationSeconds: level * 120,
    description: 'A place of faith — or what once was. Faith can curdle into something worse.',
    recommendedLevel: level,
  );
}

GeneratedLocation _genCemetery() {
  final name = _cemeteryNames[_rng.nextInt(_cemeteryNames.length)];
  final level = 1 + _rng.nextInt(4);
  return GeneratedLocation(
    name: name,
    type: LocationType.cemetery,
    durationSeconds: level * 130,
    description: 'A burial ground where the dead do not rest easily.',
    recommendedLevel: level,
  );
}

GeneratedLocation _genLibrary() {
  final name = _libraryNames[_rng.nextInt(_libraryNames.length)];
  final level = 1 + _rng.nextInt(4);
  return GeneratedLocation(
    name: name,
    type: LocationType.library,
    durationSeconds: level * 110,
    description: 'A sealed archive whose custodians have outlasted their mandate.',
    recommendedLevel: level,
  );
}

GeneratedLocation _genForge() {
  final name = _forgeNames[_rng.nextInt(_forgeNames.length)];
  final level = 1 + _rng.nextInt(5);
  return GeneratedLocation(
    name: name,
    type: LocationType.forge,
    durationSeconds: level * 145,
    description: 'A forge producing things no Church smith would claim.',
    recommendedLevel: level,
  );
}

GeneratedLocation _genChurch() {
  final name = _churchNames[_rng.nextInt(_churchNames.length)];
  final level = 1 + _rng.nextInt(3);
  return GeneratedLocation(
    name: name,
    type: LocationType.church,
    durationSeconds: 60 + level * 30,
    description: 'A place of sanctioned faith. Prayer here may deepen your devotion.',
    recommendedLevel: 1,
  );
}

GeneratedLocation _genShrine() {
  final name = _shrineNames[_rng.nextInt(_shrineNames.length)];
  final level = 1 + _rng.nextInt(3);
  return GeneratedLocation(
    name: name,
    type: LocationType.shrine,
    durationSeconds: 60 + level * 30,
    description: 'An old way marker of the ancient faiths. The earth remembers what men forget.',
    recommendedLevel: 1,
  );
}

GeneratedLocation _genCultSite() {
  final name = _cultSiteNames[_rng.nextInt(_cultSiteNames.length)];
  final level = 1 + _rng.nextInt(4);
  return GeneratedLocation(
    name: name,
    type: LocationType.cultSite,
    durationSeconds: 60 + level * 40,
    description: 'A hidden gathering of the forbidden. The Rite is observed here, out of sight.',
    recommendedLevel: level,
  );
}

String locationIcon(LocationType type) => switch (type) {
      LocationType.dungeon    => '⚔',
      LocationType.castle     => '🏰',
      LocationType.town       => '🏘',
      LocationType.wilderness => '🌲',
      LocationType.ruins      => '🏚',
      LocationType.monastery  => '⛪',
      LocationType.cemetery   => '✝',
      LocationType.library    => '📜',
      LocationType.forge      => '🔥',
      LocationType.church     => '⛪',
      LocationType.shrine     => '◎',
      LocationType.cultSite   => '✦',
    };

String formatDuration(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return s == 0 ? '${m}m' : '${m}m ${s}s';
}
