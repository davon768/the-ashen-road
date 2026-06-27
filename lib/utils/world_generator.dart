import 'dart:math';
import '../models/world_location.dart';
import '../models/enums.dart';

// Named locations (id, name, type, depth).
// Five "spine" locations are placed at fixed Y≈500 positions along the Ashen Road.
// All others are scattered above/below at their depth band.
const _locations = [
  // ── SPINE TOWNS (the Ashen Road) ───────────────────────────────────────────
  ('ashenvale',         'Ashenvale',                   LocationType.town,       1),
  ('dunford',           'Dunford',                     LocationType.town,       2),
  ('greywater',         'Greywater',                   LocationType.town,       3),
  ('ironwall',          'Ironwall',                    LocationType.castle,     4),
  ('grimhaven',         'Grimhaven',                   LocationType.castle,     5),
  ('ash_breach',        'The Ash Breach',              LocationType.castle,     6),
  ('void_spire',        'The Void Spire',              LocationType.castle,     7),

  // ── DEPTH 1 ────────────────────────────────────────────────────────────────
  ('hollow_warren',     'The Hollow Warren',           LocationType.dungeon,    1),
  ('pale_moors',        'The Pale Moors',              LocationType.wilderness, 1),
  ('millhaven',         'Millhaven',                   LocationType.town,       1),
  ('chalk_barrows',     'The Chalk Barrows',           LocationType.cemetery,   1),
  ('tallow_works',      'The Tallow Works',            LocationType.forge,      1),
  ('pale_chapel',       'The Pale Chapel',             LocationType.ruins,      1),
  ('saint_crossing',    "Saint's Crossing Chapel",     LocationType.church,     1),
  ('thornwood_shrine',  'The Thornwood Shrine',        LocationType.shrine,     1),

  // ── DEPTH 2 ────────────────────────────────────────────────────────────────
  ('old_watchtower',    'The Old Watchtower',          LocationType.ruins,      2),
  ('rotting_mere',      'The Rotting Mere',            LocationType.wilderness, 2),
  ('ashen_crypt',       'The Ashen Crypt',             LocationType.dungeon,    2),
  ('drowned_village',   'The Drowned Village',         LocationType.ruins,      2),
  ('shrine_old',        'The Shrine of the Old Ways',  LocationType.monastery,  2),
  ('ashwood',           'The Ashwood',                 LocationType.wilderness, 2),
  ('iron_hearth_old',   'The Old Iron Hearth',         LocationType.forge,      2),
  ('wayfarers_archive', "The Wayfarer's Archive",       LocationType.library,    2),
  ('plague_hill',       'Plague Hill',                 LocationType.cemetery,   2),
  ('mill_ruin',         'The Broken Mill',             LocationType.ruins,      2),
  ('moonpool_shrine',   'The Moonpool Shrine',         LocationType.shrine,     2),
  ('night_fold',        'The Night Fold',              LocationType.cultSite,   2),

  // ── DEPTH 3 ────────────────────────────────────────────────────────────────
  ('thornwall',         'Thornwall Castle',            LocationType.castle,     3),
  ('forgotten_barrow',  'The Forgotten Barrow',        LocationType.dungeon,    3),
  ('priory_ash',        'The Priory of Ash',           LocationType.monastery,  3),
  ('greymoor',          'Greymoor',                    LocationType.castle,     3),
  ('black_maw',         'The Black Maw',               LocationType.dungeon,    3),
  ('drowned_vault',     'The Drowned Vault',           LocationType.dungeon,    3),
  ('broken_abbey',      'The Broken Abbey',            LocationType.ruins,      3),
  ('chroniclers_keep',  "The Chronicler's Keep",        LocationType.library,    3),
  ('ashblood_forge',    'The Ashblood Forge',          LocationType.forge,      3),
  ('gallows_moor',      'The Gallows Moor',            LocationType.cemetery,   3),
  ('the_long_house',    'The Long House',              LocationType.dungeon,    3),
  ('vale_of_lament',    'The Vale of Lament',          LocationType.wilderness, 3),
  ('iron_bell_chapel',  'The Iron Bell Chapel',        LocationType.church,     3),
  ('root_fold',         'The Root Fold',               LocationType.cultSite,   3),

  // ── DEPTH 4 ────────────────────────────────────────────────────────────────
  ('sunken_hold',       'The Sunken Hold',             LocationType.dungeon,    4),
  ('black_fells',       'The Black Fells',             LocationType.wilderness, 4),
  ('chapter_iron',      'The Chapter House of Iron',   LocationType.monastery,  4),
  ('coldstone',         'Coldstone Keep',              LocationType.castle,     4),
  ('iron_pit',          'The Iron Pit',                LocationType.dungeon,    4),
  ('charred_cathedral', 'The Charred Cathedral',       LocationType.ruins,      4),
  ('salthaven',         'Salthaven',                   LocationType.town,       4),
  ('pale_court_archive', "The Pale Court's Archive",    LocationType.library,    4),
  ('deepfire_pit',      'The Deepfire Pit',            LocationType.forge,      4),
  ('the_unmourned',     'The Unmourned',               LocationType.cemetery,   4),
  ('the_long_barrow',   'The Long Barrow',             LocationType.dungeon,    4),
  ('sunwheel_hall',     'The Sun-Wheel Congregation',  LocationType.church,     4),
  ('ashen_hollow',      'The Ashen Hollow',            LocationType.cultSite,   4),

  // ── DEPTH 5 ────────────────────────────────────────────────────────────────
  ('duskhold',          'Duskhold',                    LocationType.castle,     5),
  ('forgotten_tomb',    'The Forgotten Tomb',          LocationType.dungeon,    5),
  ('hermitage_void',    'The Hermitage of the Void',   LocationType.monastery,  5),
  ('salt_maw',          'The Salt Maw',                LocationType.dungeon,    5),
  ('void_codex',        'The Void Codex',              LocationType.library,    5),
  ('undying_forge',     'The Undying Forge',           LocationType.forge,      5),
  ('garden_fallen',     'The Garden of the Fallen',    LocationType.cemetery,   5),
  ('cathedral_ash',     'The Cathedral of Ash',        LocationType.church,     5),
  ('void_rite_circle',  'The Void Rite Circle',        LocationType.cultSite,   5),

  // ── DEPTH 6 — Beyond Grimhaven ─────────────────────────────────────────────
  ('shattered_manse',   'The Shattered Manse',         LocationType.ruins,      6),
  ('carrion_flats',     'The Carrion Flats',            LocationType.wilderness, 6),
  ('the_great_crypt',   'The Great Crypt',              LocationType.dungeon,    6),
  ('grey_asylum',       'The Grey Asylum',              LocationType.monastery,  6),
  ('forge_of_regret',   'The Forge of Regret',          LocationType.forge,      6),
  ('the_long_dead',     'The Long Dead',                LocationType.cemetery,   6),
  ('white_archive',     'The White Archive',            LocationType.library,    6),
  ('ash_trench',        'The Ash Trench',               LocationType.wilderness, 6),
  ('howling_vault',     'The Howling Vault',            LocationType.dungeon,    6),
  ('iron_cathedral',    'The Iron Cathedral',           LocationType.church,     6),

  // ── DEPTH 7 — The Far Waste ────────────────────────────────────────────────
  ('ash_heart',         'The Ash Heart',                LocationType.dungeon,    7),
  ('lords_of_nothing',  'The Lords of Nothing',         LocationType.castle,     7),
  ('wasting_plain',     'The Wasting Plain',            LocationType.wilderness, 7),
  ('the_final_barrow',  'The Final Barrow',             LocationType.cemetery,   7),
  ('opening_scar',      'The Opening Scar',             LocationType.ruins,      7),
  ('the_last_prayer',   'The Last Prayer',              LocationType.monastery,  7),
  ('the_ashen_deep',    'The Ashen Deep',               LocationType.dungeon,    7),
  ('forge_absolute',    'The Absolute Forge',           LocationType.forge,      7),
];

// The five road-spine locations, placed at fixed Y≈500 positions.
// These form the guaranteed west→east chain: the Ashen Road itself.
// ironwall and grimhaven are now castles (they serve as the eastern spine).
const _spinePositions = {
  'ashenvale':  (150.0,  500.0),
  'dunford':    (370.0,  495.0),
  'greywater':  (590.0,  505.0),
  'ironwall':   (810.0,  500.0),
  'grimhaven':  (1040.0, 498.0),
  'ash_breach': (1280.0, 502.0),
  'void_spire': (1520.0, 498.0),
};
const _spineOrder = ['ashenvale', 'dunford', 'greywater', 'ironwall', 'grimhaven', 'ash_breach', 'void_spire'];

// X range [min, max] for non-spine locations at each depth level.
const _depthX = [
  (60.0,   290.0),  // depth 1
  (250.0,  500.0),  // depth 2
  (460.0,  720.0),  // depth 3
  (680.0,  940.0),  // depth 4
  (900.0, 1160.0),  // depth 5
  (1130.0,1410.0),  // depth 6
  (1380.0,1660.0),  // depth 7
];
const _yMin            = 60.0;
const _yMax            = 940.0;
const _minSpacing      = 75.0;
const _maxConnections  = 6;      // increased from 4 for a denser, less-linear web
const _connectionRadius = 380.0; // slightly larger for more cross-links

List<WorldLocation> generateWorldMap() {
  final rng = Random();

  // Pre-place all spine locations.
  final placed = <(String, double, double)>[];
  for (final id in _spineOrder) {
    final (x, y) = _spinePositions[id]!;
    placed.add((id, x, y));
  }

  (double, double) randomOffSpine(String id, int depth) {
    final (xMin, xMax) = _depthX[depth - 1];
    for (var attempt = 0; attempt < 150; attempt++) {
      final x = xMin + rng.nextDouble() * (xMax - xMin);
      // Bias strongly toward upper/lower thirds so road corridor stays clear.
      final double yBand;
      final band = attempt % 3;
      if (band == 0) {
        yBand = _yMin + rng.nextDouble() * 240;          // upper band
      } else if (band == 1) {
        yBand = (_yMax - 240) + rng.nextDouble() * 240;  // lower band
      } else {
        yBand = _yMin + rng.nextDouble() * (_yMax - _yMin); // anywhere
      }
      final tooClose = placed.any((p) {
        final dx = p.$2 - x;
        final dy = p.$3 - yBand;
        return sqrt(dx * dx + dy * dy) < _minSpacing;
      });
      if (!tooClose) {
        placed.add((id, x, yBand));
        return (x, yBand);
      }
    }
    final x = xMin + rng.nextDouble() * (xMax - xMin);
    final y = _yMin + rng.nextDouble() * (_yMax - _yMin);
    placed.add((id, x, y));
    return (x, y);
  }

  var locations = _locations.map((r) {
    final (id, name, type, depth) = r;
    if (_spinePositions.containsKey(id)) {
      final (x, y) = _spinePositions[id]!;
      return WorldLocation(id: id, name: name, type: type, depth: depth, x: x, y: y);
    }
    final (x, y) = randomOffSpine(id, depth);
    return WorldLocation(id: id, name: name, type: type, depth: depth, x: x, y: y);
  }).toList();

  // Build connection map, seeding the spine chain first.
  final connections = <String, List<String>>{
    for (final l in locations) l.id: [],
  };

  // Guaranteed spine chain: each spine node connects to the next.
  for (var i = 0; i < _spineOrder.length - 1; i++) {
    final a = _spineOrder[i];
    final b = _spineOrder[i + 1];
    connections[a]!.add(b);
    connections[b]!.add(a);
  }

  // Proximity-based connections for remaining capacity.
  for (var i = 0; i < locations.length; i++) {
    final a = locations[i];
    if ((connections[a.id]?.length ?? 0) >= _maxConnections) continue;

    final candidates = locations.sublist(i + 1)
      ..sort((b, c) => _dist(a, b).compareTo(_dist(a, c)));

    for (final b in candidates) {
      if ((connections[a.id]?.length ?? 0) >= _maxConnections) break;
      if ((connections[b.id]?.length ?? 0) >= _maxConnections) continue;
      if (_dist(a, b) > _connectionRadius) break;
      if (connections[a.id]!.contains(b.id)) continue;
      connections[a.id]!.add(b.id);
      connections[b.id]!.add(a.id);
    }
  }

  // Ensure every non-spine location has at least one connection (no orphans).
  for (final loc in locations) {
    if (_spinePositions.containsKey(loc.id)) continue;
    if ((connections[loc.id]?.length ?? 0) > 0) continue;
    // Find the nearest location that isn't already maxed.
    final nearest = locations
        .where((o) => o.id != loc.id)
        .where((o) => (connections[o.id]?.length ?? 0) < _maxConnections)
        .toList()
      ..sort((a, b) => _dist(loc, a).compareTo(_dist(loc, b)));
    if (nearest.isNotEmpty) {
      final n = nearest.first;
      connections[loc.id]!.add(n.id);
      connections[n.id]!.add(loc.id);
    }
  }

  // Apply connections.
  locations = locations.map((l) {
    return l.copyWith(connectedIds: connections[l.id] ?? []);
  }).toList();

  // Discover starting town and its immediate neighbours.
  final startConnections = connections['ashenvale'] ?? [];
  locations = locations.map((l) {
    if (l.id == 'ashenvale' || startConnections.contains(l.id)) {
      return l.copyWith(discovered: true);
    }
    return l;
  }).toList();

  return locations;
}

double _dist(WorldLocation a, WorldLocation b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  return sqrt(dx * dx + dy * dy);
}

/// After visiting a location, reveal nearby undiscovered locations.
List<WorldLocation> discoverNearby(
  List<WorldLocation> worldMap,
  String visitedId,
) {
  final visited = worldMap.firstWhere(
    (l) => l.id == visitedId,
    orElse: () => worldMap.first,
  );
  const revealRadius = 420.0;

  return worldMap.map((l) {
    if (l.discovered) return l;
    if (_dist(visited, l) <= revealRadius) {
      return l.copyWith(discovered: true);
    }
    return l;
  }).toList();
}
