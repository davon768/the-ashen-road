import 'enums.dart';

const _sentinel = Object();

class WorldLocation {
  final String id;
  final String name;
  final LocationType type;
  final int depth;          // 1-5 difficulty
  final double x;           // position on 1400×1000 canvas
  final double y;
  final bool discovered;
  final List<String> connectedIds;
  final String? imageUrl;

  const WorldLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.depth,
    required this.x,
    required this.y,
    this.discovered = false,
    this.connectedIds = const [],
    this.imageUrl,
  });

  /// Minimum average party level required to send an expedition here.
  /// 0 means no requirement.
  int get minPartyLevel => switch (depth) {
    1 || 2 => 0,
    3 => 5,
    4 => 10,
    5 => 14,
    6 => 18,
    _ => 22,
  };

  int get durationSeconds => switch (type) {
        LocationType.town       => depth * 90,
        LocationType.wilderness => depth * 120,
        LocationType.ruins      => depth * 130,
        LocationType.monastery  => depth * 120,
        LocationType.dungeon    => depth * 150,
        LocationType.castle     => depth * 180,
        LocationType.cemetery   => depth * 130,
        LocationType.library    => depth * 110,
        LocationType.forge      => depth * 145,
        LocationType.church     => 60 + depth * 30,
        LocationType.shrine     => 60 + depth * 30,
        LocationType.cultSite   => 60 + depth * 40,
      };

  // Lore blurb for named locations; null for procedural ones.
  String? get lore => switch (id) {
    'ashenvale'         => 'The westernmost settlement on the Road proper. Its name predates the Church — in the Old Ways tongue, ashen meant a liminal place, between states. The Church renamed it ironically. The tavern has stood for two hundred years. The well has been dry for three.',
    'hollow_warren'     => 'A tunnel complex the Church\'s surveyors mapped during the Second Crusade. Their margin notes are still legible on the stones: "Bones of pre-Church origin — do not disturb." Someone disturbed them.',
    'pale_moors'        => 'Open moorland belonging to no lord and no god. Old Ways practitioners held their rites here when the First Crusade burned their lowland shrines. The ground still bears fire-circle marks beneath the heather, if you know where to look.',
    'millhaven'         => 'A mill-town on a slow black river. The mill is still running. The family that built it left during the Retreat when the ash began falling in earnest. Whoever runs it now does not give their name.',
    'old_watchtower'    => 'A Church watchtower built to watch the northern highlands for Old Ways activity. Staffed for forty years, then the garrison was withdrawn — not by order, but because no replacement soldiers ever arrived. What became of the originals was never recorded.',
    'rotting_mere'      => 'A lake that was clear and cold in older maps. Thirty years ago it began to turn. The water is not quite black — more a deep green that does not reflect light correctly. Fish still swim in it. They should not be eaten.',
    'ashen_crypt'       => 'The crypt predates the Church by five centuries. The Church sealed its entrance with a prayer-stone and declared the occupants anathema. The prayer-stone fell inward during The Opening. The entrance is no longer sealed.',
    'dunford'           => 'A ford-town on the River Ash, which the Church renamed from its Old Ways name. The ford has stood since before memory. Dunford taxes every crossing and has grown quietly rich doing so. They will tax you regardless of which direction you\'re heading.',
    'drowned_village'   => 'A village that flooded a century ago when the dam upstream was sabotaged — the culprit was never found. The houses are intact beneath the water. Sometimes lantern light is seen moving in the submerged windows.',
    'shrine_old'        => 'Not a monastery in the Church sense — a grove of standing stones tended by three practitioners of the Old Ways who have been here, by various accounts, for between forty and two hundred years. The Church has sent three parties to close it. All three reported finding nothing to close.',
    'ashwood'           => 'Where practitioners of the Old Ways fled when the First Crusade burned their lowland shrines. The forest is named for them, or for the ash they carried, or for the road that ran through it before the road was the Ashen Road. The bark is grey. The wood does not burn.',
    'forgotten_barrow'  => 'A barrow so old that Church historians could not date it. Their excavation notes describe a chamber at the lowest level "opened from within." The expedition\'s return party was three people fewer than those who entered. No explanation was recorded.',
    'priory_ash'        => 'Where the Pale Mother lived and died. She spent forty years writing the Accounting — a record of every soul she believed had passed into the Three-Faced Queen\'s keeping. The final chapter predicted The Opening with specific accuracy. The brothers read from it every morning and call it a comfort.',
    'greymoor'          => 'A castle with no clear lord of record. Every occupant across three centuries has eventually abandoned it — or vanished from it. The stonework shows no weathering. The castle seems to maintain itself.',
    'black_maw'         => 'The largest cave system in the Reaches, by every measure taken. The Church surveyed it four times and reached different conclusions about its depth each time. The Ashen Rite considers it sacred. The Old Ways call it the mouth of Stone-Mother. The Pale Court sends its unclaimed dead here.',
    'drowned_vault'     => 'Once a treasury for a lord whose name was erased from all records — the Church notes the erasure but not the reason. The vault is now underwater to its second level. What is in the deeper sections has not been catalogued since the erasure, which some sources call a mercy.',
    'broken_abbey'      => 'The Church\'s oldest structure in the region, broken during what the records call a doctrinal dispute — which other sources attribute to a monk who opened something he should not have. His name is the first entry on the Ashen Rite\'s list of honored dead.',
    'greywater'         => 'Named for the river by Saint Aldric, who built it. Aldric was a bandit for twenty years and a penitent for thirty, and the city reflects both careers: open markets, twelve almshouses, and a quiet understanding that you cannot be arrested here for anything you confess to having done elsewhere.',
    'ironwall'          => 'The last garrisoned Church fortification on the road. The garrison\'s records show forty-seven requests for reinforcement in twenty years. They received supplies eleven times, soldiers twice. The commander has not sent a personal letter home in six years.',
    'sunken_hold'       => 'Originally built as a water cistern for a fortress above. The fortress has been gone for a century; the cistern survives, extending into chambers that were not part of the original construction. The water in the lower levels is not water.',
    'black_fells'       => 'Where the ash falls heaviest outside the east. The ground is covered in fine grey powder that does not blow away and does not mix with rain. The Ashen Rite makes pilgrimage here to hear the Void breathe. Those of the Old Ways will not enter the Fells at all.',
    'chapter_iron'      => 'A Church military order\'s headquarters. The Iron Chapter\'s last Grand Master died fourteen years ago and the order has not elected a replacement. The brothers live by the old routine — prayers, training, patrol — with no orders to follow and no one to fight for. The most disciplined army in the Reaches with no cause.',
    'coldstone'         => 'A keep on a granite shelf so cold that snow never fully melts from its battlements. The current occupant — recorded only as the Pale Margrave in nearby tax ledgers — has held it for an indeterminate number of years. Visitors describe the interior as warm. They describe the Margrave inconsistently.',
    'iron_pit'          => 'An iron mine that collapsed seventy years ago, killing its entire workforce. The Church declared it cursed. Someone unsealed it thirty years ago. Iron is now being extracted of a quality no known forge process can replicate, sold through channels the Church cannot trace. Buyers report it is warm to the touch even in winter.',
    'charred_cathedral' => 'The Church\'s greatest construction in the Reaches, built over two generations and destroyed in a single night thirty-two years ago. The night of The Opening. What was inside at the time is officially undisclosed. The High Patriarch was present. His body was never recovered. The ash that fell that night is the same ash that falls in the east today.',
    'salthaven'         => 'A port town on a salt lake whose underground channels to the sea closed during The Opening. The lake has been slowly concentrating since. Salthaven\'s people have developed their own dialect, their own saints, and their own rites that borrow from all five faiths and belong to none.',
    'duskhold'          => 'The last structure built before The Opening, completed in the same year as the catastrophe. The architect did not survive to see it finished. Duskhold was taken as a forward base for the Church\'s crusade and abandoned after Grimhaven. It has not been empty since the soldiers left.',
    'forgotten_tomb'    => 'The Pale Court holds this is the burial place of the first person who ever died — the origin of all subsequent death. They do not mean this as metaphor. If it is what they say, it is also the oldest structure in the Reaches by approximately the age of the world.',
    'hermitage_void'    => 'A single stone building on a plain of ash. The practitioner who lives there belongs to no faith, or claims to belong to all of them. Travelers report the practitioner answers questions before they are asked. They do not report this as pleasant.',
    'salt_maw'          => 'Where Salthaven\'s underground channels used to open into the sea. They do not open into the sea anymore. The Ashen Rite has been studying this transition point for thirty years. Their findings are written in a script they invented specifically to describe things with no words in any living language.',
    'grimhaven'         => 'The site of the Church\'s great failure. High Inquisitor Verdane led fourteen thousand soldiers here to push back The Opening. The battle lasted six hours. None of Verdane\'s soldiers died — they simply became something else. They are still in Grimhaven. Verdane leads them. He has not spoken since.',

    // ── CEMETERY LOCATIONS ──────────────────────────────────────────────────
    'chalk_barrows'     => 'The oldest burial ground on record in the western Reaches. Church surveyors counted eighty-seven distinct mounds during the second land survey. Their record shows ninety-four. They do not note the discrepancy.',
    'plague_hill'       => 'Named plainly and accurately. Three thousand, two hundred, and eleven recorded interments during the ash-plague of the Age of the Flame. The Church counted the dead for forty years before the numbers stopped changing. They then found eleven more. The marker at the hill\'s crown reads: HERE ENDS THE COUNT.',
    'gallows_moor'      => 'Six hundred years of legal executions carried out on the moor, which was chosen for its remoteness. The Church deconsecrated it during the reforms. The Old Ways quietly reconsecrated it — their tradition holds that the violently-killed dead need more tending, not less. Practitioners still come. The Church has chosen not to notice.',
    'the_unmourned'     => 'The burial ground for soldiers who did not return from the Grimhaven Crusade — not those who died there, but those who simply stopped existing between the last muster and the first count. Fourteen thousand soldiers entered Grimhaven. The Church\'s record shows twelve thousand, four hundred and seven survivors. The mathematics is irreconcilable. The Unmourned marks the space where the accounting fails.',
    'garden_fallen'     => 'Where they buried what could be buried after Grimhaven. The rest — the greater proportion — could not be buried, for reasons the Church\'s record documents obliquely with the phrase "physical discontinuity." The Garden holds the identifiable remains. A second section was begun and then stopped. A third section was begun, and the workers stopped returning. The Church has declared the Garden complete. The groundskeepers report the boundary markers have been moved inward again.',

    // ── LIBRARY LOCATIONS ───────────────────────────────────────────────────
    'wayfarers_archive' => 'An inn whose keeper collected road journals from passing travelers over forty years. The inn burned. The journals survived in the root cellar, sealed in waxed cloth. Whoever collected them into the current structure built shelves before walls. The archive has no roof. It has never lost a book to rain.',
    'chroniclers_keep'  => 'Built by a Church historian who declined a church appointment in favor of a private commission: to write the complete history of the Ashen Road. He wrote for sixty years and did not finish. His estate sealed the keep upon his death and the keys passed through four owners, none of whom visited. The current owners do not know they own it.',
    'pale_court_archive' => 'The central repository of the Pale Court\'s records of the dead. Maintained for three centuries. The index alone fills twenty-seven volumes. It is, by some counts, the most complete census of mortality in the Reaches. The librarians say they are waiting for the missing categories to fill. They do not say for what.',
    'void_codex'        => 'Not a building. A structure that resembles a building but predates all local construction traditions. The texts inside are written in a script that predates every other script found in the region. The Pale Court has been translating for sixty years. They have translated three pages. The library has, by their count, four hundred and twelve pages. They have not explained why the number does not decrease.',

    // ── FORGE LOCATIONS ─────────────────────────────────────────────────────
    'tallow_works'      => 'A tallow-rendering works repurposed as a small forge by a smith who needed the heat. The tallow smell never fully left. The smith left too, eventually — though his tools remained lit in the furnace when he was found gone.',
    'iron_hearth_old'   => 'The first forge on the eastern stretch of the Ashen Road, built by a smith named Orvyn who followed the road-builders and repaired their tools. He is listed in road construction records as a "necessary annoyance." After his death, the forge was run by someone who signed their work differently. The marking has never been attributed.',
    'ashblood_forge'    => 'A working forge in the literal sense: someone is working here. The ore it uses is the warm iron pulled from the Iron Pit, and the products it makes do not match any pattern in the Church\'s smithing registers. The smith has not given a name. The goods move through Greywater under false provenance. The Church suspects. The Church has not sent anyone to investigate twice.',
    'deepfire_pit'      => 'Where the warm iron originates. A natural heat shaft used as a forge floor since before the Church\'s calendar. The current operators have modified the original structure past recognition. No one who visits the Pit speaks afterward — not out of compulsion, but out of what recovery accounts describe as "understanding what some things cost."',
    'undying_forge'     => 'The oldest forge in the Reaches, possibly the oldest in the world. The heat source has never been identified. The structure has been used continuously for longer than any other recorded site of manufacture. Each group of operators has believed themselves to be the first to find it. The evidence inside suggests otherwise. The evidence has been added to a growing archive, behind a door that requires no key.',

    // ── FAITH SITE LOCATIONS ────────────────────────────────────────────────
    'saint_crossing'    => 'Built at the site where Saint Aldric is said to have refused the road tax and given his coat to a beggar instead. The chapel that stands here is the third version — the first two were burned during different purges of different kinds. The third was built by villagers who did not care which side was burning.',
    'pale_chapel'       => 'A roadside chapel that collapsed the night of The Opening. The Church rebuilt similar chapels up and down the road. Not this one. The ecclesiastical record notes only "conditions at site unsuitable for reconsecration." It does not elaborate.',
    'thornwood_shrine'  => 'A standing stone that the Church attempted to demolish three times. The first demolition crew returned unable to explain why they had not demolished it. The second was found sitting in a circle around it, unwilling to move. The third was not found at all. The Church\'s current position is that the stone is not a shrine and thus does not require suppression.',
    'moonpool_shrine'   => 'A natural depression in the rock that fills with water that does not reflect the moon correctly. Practitioners of the Old Ways call it the Pool of the Watcher — a window, not a mirror. The Church has not interfered with it. No one who has interfered with it has been available to report on their experience.',
    'night_fold'        => 'A natural hollow used by the Ashen Rite for at least two centuries. The Church has known about it for approximately that long and has taken no action, which those familiar with Church practice describe as more alarming than persecution.',
    'root_fold'         => 'Where the road passes between two massive roots of a tree that is not visible from the road. Practitioners of the Old Ways consider the passage a threshold — crossing it means something different depending on which direction you go. They do not agree on which direction means what.',
    'iron_bell_chapel'  => 'Named for the iron bell in its tower, which rings without being struck. The Church sent investigators twice. They concluded the bell rings due to harmonics in the stone — a conclusion they filed and did not revisit. The bell rings most often at night, and never at services.',
    'sunwheel_hall'     => 'A hall of the Luminant Church built in the old style, before the reforms simplified the architecture. The sun-wheel carvings on every surface represent a theology the current Church hierarchy has officially classified as "pre-reform enthusiasm." The hall is still consecrated. They have not explained why.',
    'ashen_hollow'      => 'A depression in the eastern wastes where ash accumulates and does not blow out. The Ashen Rite consider it the deepest listening place on the Road — the ear of something larger. The Pale Court says the ash here contains the residue of people. Both groups have requested the other leave. Neither has.',
    'cathedral_ash'     => 'A vast cathedral that the Church records show was never built — the site records no construction, no consecration, no occupants. It has been on the eastern road for as long as living memory. The architecture matches no tradition. The ash has not touched the stonework. Services are held here by persons in robes of no identifiable faith.',
    'void_rite_circle'  => 'The oldest Ashen Rite site recorded. The Rite\'s own historians say it predates the Rite — that the circle is where the Rite found what it practices, not where it began. This distinction is important to them. They have not explained why.',

    // ── OTHER NEW LOCATIONS ─────────────────────────────────────────────────
    'mill_ruin'         => 'Where the road crosses a mill-race that has been dry for thirty years. The mill still turns, sometimes, when there is no wind and the wheel is above water level. The miller\'s accounts — still legible on a board inside — show production records up to three days after his death.',
    'the_long_house'    => 'A pre-Church communal hall converted into a burial complex by whoever used it last. The floor is lower than the foundation level, the internal walls do not match the external ones, and the original roof structure shows evidence of deliberate fire damage from inside. Whatever was sealed in was sealed in deliberately.',
    'vale_of_lament'    => 'A narrow valley that channels wind in a way that produces a low, sustained sound described variously as singing, breathing, and grinding. The Church declared it a natural phenomenon. Practitioners of the Old Ways call it the voice of something that used to be there. Neither explanation satisfies anyone who has camped in the valley at night.',
    'the_long_barrow'   => 'A burial structure longer than any other on record in the Reaches: one hundred and eighteen paces, measured externally. Church archaeologists measured the internal length at forty-three paces and reported no discrepancy. They were asked to measure again. They produced the same result and resigned the commission without explanation.',

    // ── DEPTH 6 — BEYOND GRIMHAVEN ─────────────────────────────────────────────
    'ash_breach'        => 'The fortified position that remained when the survivors of Grimhaven retreated west. The Church named it formally; the soldiers who held it called it the Holding. That name did not make it into any record. The record keepers were among those who did not return from the second watch.',
    'shattered_manse'   => 'A noble estate the Church purchased for a field hospital before The Opening. The patients were moved east. Their conditions did not improve in the eastern air. The manse\'s admission records are complete; the discharge records show destinations that no longer appear on any current map.',
    'carrion_flats'     => 'Where the ash settles into a crust that does not crack underfoot but sounds hollow. The hollow space is occupied by something that does not register on naturalist instruments as a living thing. It registers as something else.',
    'the_great_crypt'   => 'The largest structure of its type on the eastern road. Its entrance hall is catalogued; the lower levels are referenced in older Church documents as "the section we have chosen not to count." Current estimates put the total chamber count at between forty and four hundred, depending on which estimate you trust.',
    'grey_asylum'       => 'A place of retreat for those whose faith collapsed on contact with the eastern road. The records of its founding show three hundred admitted in its first year. The records of its operation after the fifth year show no admissions and no discharges. The building is occupied. The occupants have not been formally identified.',
    'forge_of_regret'   => 'Where the Iron Chapter\'s smith worked during the Grimhaven Crusade. The smith\'s final commission — armaments for the Crusade — was completed and delivered on schedule. His journal, found later, describes this commission as the thing he most regretted. He does not say why.',
    'the_long_dead'     => 'The burial site for those who died on the road east before Grimhaven, over two centuries of travel. The headstones here are still being added to. Nobody has admitted to adding them.',
    'white_archive'     => 'The repository of the Church\'s final eastern survey, conducted six months before Grimhaven. The twelve-person survey team\'s reports are detailed, meticulous, and contradictory in ways that a group observed together should not be. One copy has a margin annotation: "we did not all see the same thing." The handwriting matches no team member on record.',
    'ash_trench'        => 'A natural depression in the ash waste that runs for several miles. The Church\'s engineers say it was made by water. The Ashen Rite says it was made by something breathing. Both groups agree it was not here thirty years ago.',
    'howling_vault'     => 'A structure built as a granary — its original purpose is the only thing documented with certainty. What it stores now has been described variously by the three expeditions that reached its lower level. All three descriptions are different. All three use the word "sound" where other accounts would use "thing."',
    'iron_cathedral'    => 'A cathedral the Iron Chapter constructed for their Crusade. Services were held here until the battle. The chapel records show the last service, the names of those who attended, and the date. After that entry, the record continues — same handwriting, same format — but the names no longer correspond to any known individual.',

    // ── DEPTH 7 — THE FAR WASTE ────────────────────────────────────────────────
    'void_spire'        => 'The structure at the edge of the ash waste that does not appear in any survey conducted before The Opening. Its height has been measured at different numbers on different days. The Ashen Rite says it is a finger pointing at something. They will not say at what.',
    'ash_heart'         => 'At the center of the ash waste there is a place where the ash is warm underfoot. The Ashen Rite has been attempting to reach it for two decades. Each expedition ends at a different point, having run out of usable ground to stand on. The center appears to recede as you approach. They have not stopped trying.',
    'lords_of_nothing'  => 'A fortification in Church maps as a checkpoint with a garrison of sixty. The garrison was last in contact forty years ago. The fortification remains on current maps. The update noting it is occupied by something other than the original garrison was filed by someone since reassigned to a posting that does not appear in any current roster.',
    'wasting_plain'     => 'Where the Crusade marched. Fourteen thousand soldiers walked east across it. The plain\'s ground today shows, in certain lights, the impression of fourteen thousand footprints going east. No prints coming back.',
    'the_final_barrow'  => 'Who buried here first is not known. The barrow predates every living tradition in the Reaches. What is known: it is not full. It has never been full, regardless of how many are added. The Pale Court considers this a theological problem. Everyone else considers it an argument for distance.',
    'opening_scar'      => 'The place where The Opening happened — or the strongest candidate for it. No one agrees. The Rite, the Pale Court, and the Church\'s Historical Commission all name different sites. They agree only that somewhere in the far waste the ground looks as though it was turned inside out, and that the air in that place smells of something that has no name.',
    'the_last_prayer'   => 'A hermitage at the road\'s far end, where the last monk to travel east before Grimhaven built a small chapel and did not return. The chapel is still standing. A lamp is still lit. There is no record of anyone maintaining it. The lamp has been burning for thirty-two years.',
    'the_ashen_deep'    => 'A cave system the Ashen Rite considers their holiest site. They do not explain why. Their founding texts describe entering it and hearing something that cannot be heard above ground — a frequency below human perception that the body translates as certainty. Certainty of what, the texts do not specify.',
    'forge_absolute'    => 'There is no record of who built this or why. There is no record of when it was last used. There is heat inside. There are tools laid out as if work is about to continue. There is no smith. There has not been a smith here in any documented account. The work laid out on the bench has never been identified.',

    _                   => null,
  };

  String get description => switch (type) {
        LocationType.town =>
          depth <= 2
              ? 'A settlement on the road. Trade and rumour in equal measure.'
              : 'A fortified town that has seen better days. Danger lurks nearby.',
        LocationType.dungeon =>
          depth <= 2
              ? 'A dark underground complex. Manageable for a capable party.'
              : depth <= 4
                  ? 'A treacherous network of tunnels and chambers. Many do not return.'
                  : 'A pit of ancient evil. Only the strongest dare enter.',
        LocationType.castle =>
          depth <= 2
              ? 'A stronghold with a skeleton garrison. Ripe for plunder.'
              : 'A fortified citadel whose walls have repelled many sieges.',
        LocationType.wilderness =>
          depth <= 2
              ? 'Open country with no roads. Bandits and beasts roam freely.'
              : 'Wild, hostile country. The land itself seems to resist you.',
        LocationType.ruins =>
          depth <= 2
              ? 'The remnants of something older. What was left behind may still be dangerous.'
              : 'Ancient ruins steeped in dark history and forgotten power.',
        LocationType.monastery =>
          depth <= 2
              ? 'A place of faith — or what once was. The brothers are welcoming.'
              : 'A monastery consumed by something. Faith can curdle into worse things.',
        LocationType.cemetery =>
          depth <= 2
              ? 'An old burial ground. The dead here are restless.'
              : depth <= 4
                  ? 'A haunted necropolis. The boundary between death and something else is thin.'
                  : 'A cursed ground where death itself has broken down. What walks here is not what was buried.',
        LocationType.library =>
          depth <= 2
              ? 'A collection of road-worn knowledge. Useful, if you survive the custodians.'
              : depth <= 4
                  ? 'A sealed archive whose guardians have outlasted their mandate.'
                  : 'A repository of forbidden text. The knowledge here costs more than coin.',
        LocationType.forge =>
          depth <= 2
              ? 'A working forge, or what remains of one. The heat never quite leaves.'
              : depth <= 4
                  ? 'A dangerous industrial complex producing things no Church smith would claim.'
                  : 'A mythic place of making, predating the Road and possibly the world.',
        LocationType.church =>
          'A sanctioned house of worship. Prayer here deepens devotion for the Luminant Church and the Compact of Saints.',
        LocationType.shrine =>
          'An old way marker of the ancient faiths. Those who follow the Old Ways or Pale Court find purpose here.',
        LocationType.cultSite =>
          'A hidden place of the Ashen Rite. Only those of the Rite will find true meaning here — others merely find shadows.',
      };

  String get typeLabel => switch (type) {
        LocationType.town       => 'Town',
        LocationType.dungeon    => 'Dungeon',
        LocationType.castle     => 'Castle',
        LocationType.wilderness => 'Wilderness',
        LocationType.ruins      => 'Ruins',
        LocationType.monastery  => 'Monastery',
        LocationType.cemetery   => 'Cemetery',
        LocationType.library    => 'Library',
        LocationType.forge      => 'Forge',
        LocationType.church     => 'Church',
        LocationType.shrine     => 'Shrine',
        LocationType.cultSite   => 'Cult Site',
      };

  WorldLocation copyWith({
    bool? discovered,
    List<String>? connectedIds,
    Object? imageUrl = _sentinel,
  }) =>
      WorldLocation(
        id: id,
        name: name,
        type: type,
        depth: depth,
        x: x,
        y: y,
        discovered: discovered ?? this.discovered,
        connectedIds: connectedIds ?? this.connectedIds,
        imageUrl: imageUrl == _sentinel ? this.imageUrl : imageUrl as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'depth': depth,
        'x': x,
        'y': y,
        'discovered': discovered,
        'connectedIds': connectedIds,
        'imageUrl': imageUrl,
      };

  factory WorldLocation.fromJson(Map<String, dynamic> j) => WorldLocation(
        id: j['id'],
        name: j['name'],
        type: LocationType.values.byName(j['type']),
        depth: j['depth'],
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        discovered: j['discovered'] ?? false,
        connectedIds: List<String>.from(j['connectedIds'] ?? []),
        imageUrl: j['imageUrl'] as String?,
      );
}
