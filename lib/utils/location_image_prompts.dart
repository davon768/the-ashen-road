import '../models/world_location.dart';
import '../models/enums.dart';

String buildLocationImagePrompt(WorldLocation loc) {
  final scene = _sceneDescription(loc.type, loc.depth);
  return 'Dark medieval fantasy landscape painting. $scene '
      'Dramatic atmospheric lighting, detailed oil painting style, '
      'gritty realism, wide establishing shot, cinematic composition. '
      'No text, no watermarks, no people in foreground.';
}

String buildWorldMapPrompt(List<WorldLocation> locations) {
  // Derive feature counts per region to inform terrain hints.
  final west    = locations.where((l) => l.depth <= 2).toList();
  final central = locations.where((l) => l.depth == 3).toList();
  final east    = locations.where((l) => l.depth >= 4).toList();

  bool _has(List<WorldLocation> locs, LocationType t) =>
      locs.any((l) => l.type == t);

  String _features(List<WorldLocation> locs) {
    final parts = <String>[];
    if (_has(locs, LocationType.town))       parts.add('stone villages and market towns');
    if (_has(locs, LocationType.castle))     parts.add('stone fortresses and keeps');
    if (_has(locs, LocationType.monastery))  parts.add('monastery cloisters');
    if (_has(locs, LocationType.ruins))      parts.add('crumbling ruins and broken arches');
    if (_has(locs, LocationType.dungeon))    parts.add('cave entrances and dungeon mouths');
    if (_has(locs, LocationType.wilderness)) parts.add('open wilderness');
    return parts.join(', ');
  }

  final westFeatures    = _features(west);
  final centralFeatures = _features(central);
  final eastFeatures    = _features(east);

  // The AI cannot place named locations at specific pixel positions, so we
  // describe terrain character and feature types per region instead.
  return
      // Art style — parchment map style produces far more accurate spatial layout
      // than aerial painting, and AI handles it reliably.
      'Fantasy world map in the style of a medieval parchment cartographic illustration. '
      'Aged yellowed paper texture. Pen-and-ink line-work with muted watercolor washes. '
      'Tolkien-style hand-drawn map art. Wide landscape aspect ratio (16:9). '

      // The road — stated first and most prominently because it is the game's core visual.
      'THE SINGLE MOST IMPORTANT FEATURE: a dirt road runs as a double-line track '
      'horizontally through the center of the map from the left edge to the right edge. '
      'This is THE ASHEN ROAD. It is the dominant axis of the whole composition. '

      // West region
      'LEFT SIDE (western region, living land): muted grey-green moorland with cross-hatch '
      'hill shading, dark illustrated trees for forests, black pools and bogs, '
      'small stone village symbols with tower icons, cave mouth illustrations, '
      'standing stone circles on hilltops. '
      'Features illustrated: $westFeatures. '
      'Ink wash colors: soft grey-green, pale brown earth, dark forest ink. '

      // Central region
      'CENTRE (transitional zone, darker): a large walled city with towers and gates '
      'illustrated in detailed cartographic style, a crumbling abbey on a hilltop shown '
      'as broken arches, a winding black river south of the road, dead leafless forest '
      'with bare branch symbols, a castle keep on a ridge. '
      'Features illustrated: $centralFeatures. '
      'Ink wash colors: grey stone, shadow brown, dark river black. '

      // East region — must be visually distinct
      'RIGHT SIDE (eastern blight, dying land): pale ash-grey wash blankets all terrain, '
      'stippled ash-dust ground with no vegetation, a ruined cathedral shown as collapsed '
      'spire and broken nave, iron keeps on bare dead rock, a salt lake with dotted texture '
      'fading to white, at the far-right edge a MASSIVE BLACK FORTRESS with thick dark ink '
      'and a void-darkness haze surrounding it — the road ends here. '
      'Features illustrated: $eastFeatures. '
      'Ink wash colors: near-monochrome, ash white to deep black, no green anywhere. '

      // Atmosphere and transition
      'Ash drifts visually from right to left — heavier stippling on the right, '
      'fading to clear moorland on the left. The sky at the right edge is black void. '
      'The sky at the left edge is pale overcast grey. '

      // Style constraints
      'Decorative parchment border around the edges. Compass rose in one corner. '
      'The only text permitted anywhere on the image is the road label: THE ASHEN ROAD. '
      'No other words, letters, numbers, or writing of any kind. '
      'Style: hand-illustrated cartographic art, NOT photorealistic, NOT aerial photograph.';
}

String _sceneDescription(LocationType type, int depth) => switch (type) {
      LocationType.town => depth <= 2
          ? 'Small medieval village with timber-framed buildings, muddy market square, '
              'smoke rising from chimneys, lantern light on cobblestones, merchants and travellers.'
          : 'Fortified medieval town with high stone walls and watchtowers, '
              'crowded dark streets, armed guards at the gate, gallows in the square, ravens overhead.',
      LocationType.dungeon => depth <= 2
          ? 'Dark cave entrance carved into a hillside, stone steps descending into blackness, '
              'rusted torch sconces on mossy walls, bones scattered at the threshold, cobwebs.'
          : depth <= 4
              ? 'Ancient underground dungeon, long stone corridor with iron portcullis, '
                  'skeletal remains in alcoves, green slime dripping from walls, torchlit chamber ahead.'
              : 'Vast nightmare dungeon, black basalt walls engraved with demonic runes, '
                  'enormous altar of skulls, rivers of shadow flowing through carved channels, '
                  'ancient evil radiating from the depths.',
      LocationType.castle => depth <= 2
          ? 'Medieval stone castle on a rocky hill, grey battlements against a stormy sky, '
              'drawbridge over a dark moat, ravens circling the keep, banners torn by wind.'
          : 'Massive dark fortress of black stone, dragon skulls mounted on battlements, '
              'siege weapons on the walls, dead trees in the courtyard, cursed banners flying.',
      LocationType.wilderness => depth <= 2
          ? 'Open rolling moorland under grey skies, lone twisted oak on a ridge, '
              'distant mountains in fog, a muddy track winding through heather and bracken.'
          : 'Hostile corrupted wilderness, forest of black-bark trees with no leaves, '
              'toxic purple fog drifting between trunks, dead earth, oppressive dark canopy overhead.',
      LocationType.ruins => depth <= 2
          ? 'Crumbling stone ruins of a forgotten settlement, broken arches and collapsed walls, '
              'overgrown with ivy and moss, eerie silence, faint light through cloud cover.'
          : 'Ancient ruins of a dark civilisation, massive collapsed columns, '
              'occult symbols carved deep in black stone, scorched earth, crows perched on rubble.',
      LocationType.monastery => depth <= 2
          ? 'Austere stone monastery on a hilltop, candlelit narrow windows, '
              'monks in grey robes crossing a quiet courtyard, stone bell tower, iron cross.'
          : 'Corrupted monastery consumed by shadow, cracked bell tower leaning, '
              'robed cultists gathered around a forbidden altar, dark ritual fire, void symbols on walls.',
      LocationType.cemetery => depth <= 2
          ? 'Old graveyard on a grey hillside, rows of weathered headstones in morning mist, '
              'iron gate hanging open, crows on the fence-posts, wilted flowers at unmarked graves.'
          : depth <= 4
              ? 'Sprawling ancient cemetery, overgrown with dark thorns, massive mausoleums cracked '
                  'open, bone-white grave markers leaning at wrong angles, pale lanterns among the tombs.'
              : 'Vast necromantic burial ground, obsidian obelisks carved with death-rites, '
                  'pale mist rising from the earth, undead figures shambling between enormous tombs, '
                  'a sunless sky the colour of ash.',
      LocationType.library => depth <= 2
          ? 'Stone archive building with tall arched windows, shelves of manuscripts visible inside, '
              'a robed scholar at the entrance, dust motes in pale light, parchment scrolls stacked on tables.'
          : depth <= 4
              ? 'Grand but decaying library hall, vaulted ceiling with cracked frescoes, '
                  'overflowing shelves floor to ceiling, forbidden tomes chained to lecterns, '
                  'grey-robed archivists moving silently between the stacks.'
              : 'Vast subterranean archive, walls of black stone inscribed with void formulae, '
                  'floating manuscript pages, spectral librarians, a great central tome open on an altar '
                  'radiating eldritch light, darkness pressing at the edges.',
      LocationType.forge => depth <= 2
          ? 'Stone smithy with open-air hearth, anvil glowing orange in the shadows, '
              'tools hanging from iron hooks, sparks drifting, a blacksmith\'s silhouette against the fire.'
          : depth <= 4
              ? 'Ancient forge complex carved from rock, massive bellows, cauldrons of molten iron, '
                  'weapons cooling on racks, sweating smiths working cursed metal by torchlight.'
              : 'Volcanic forge deep underground, rivers of lava channelled through stone troughs, '
                  'titanic black anvils, demonic iron constructs taking shape on the casting floor, '
                  'hellish heat and poisonous smoke, chains and chains of cooling dark metal.',
      LocationType.church => depth <= 2
          ? 'Small stone chapel on a quiet road, candlelight in arched windows, iron bell tower, '
              'a carved stone cross in the courtyard, white flowers at the threshold, peaceful grey sky.'
          : depth <= 4
              ? 'Weathered stone church with cracked stained-glass windows, candles burning at a worn altar, '
                  'religious murals faded but intact, robed figure praying in a shadowed pew, incense smoke.'
              : 'Grand cathedral half-consumed by shadow, golden altarpiece still gleaming, '
                  'holy symbols etched into crumbling walls, pale priests performing desperate rites, '
                  'divine light cutting through darkness from above.',
      LocationType.shrine => depth <= 2
          ? 'Ancient stone shrine on a mossy hilltop, carved faces worn smooth by centuries, '
              'offerings of flowers and carved wood at its base, candles in clay cups, morning mist.'
          : depth <= 4
              ? 'Old Way shrine deep in the wood, standing stones arranged around a sacred pool, '
                  'carved runes on bark and rock, ritual offerings hanging from branches, dim filtered light.'
              : 'Primordial standing stone circle on a blasted ridge, massive monoliths carved with '
                  'spiralling runes, a dark pool at the centre reflecting starless sky, '
                  'earth glowing faintly beneath, a presence older than memory.',
      LocationType.cultSite => depth <= 2
          ? 'A hidden gathering place beneath a ruined barn, crude symbols chalked on walls, '
              'low torches, a circle of hooded figures facing a carved stone idol, '
              'scattered parchment and strange offerings on the floor.'
          : depth <= 4
              ? 'Underground cult chamber with vaulted ceilings, obsidian altar at the centre, '
                  'robed devotees kneeling in concentric rings, forbidden symbols on every surface, '
                  'red candlelight, the smell of incense and old blood.'
              : 'Vast subterranean cult cathedral, enormous idol of a forgotten god carved from void-stone, '
                  'hundreds of masked faithful in ritual formation, fires in iron braziers, '
                  'a rift in the ceiling where stars are visible in full daylight.',
    };
