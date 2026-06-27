import 'package:flutter/material.dart' hide Hero;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../theme/colors.dart';

// ─── CODEX SCREEN ─────────────────────────────────────────────────────────────

class CodexScreen extends ConsumerStatefulWidget {
  const CodexScreen({super.key});

  @override
  ConsumerState<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends ConsumerState<CodexScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AshenColors.background,
      appBar: AppBar(
        backgroundColor: AshenColors.background,
        foregroundColor: AshenColors.parchment,
        title: const Text(
          'THE ASHEN CODEX',
          style: TextStyle(
            color: AshenColors.copper,
            fontSize: 13,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          labelColor: AshenColors.copper,
          unselectedLabelColor: AshenColors.ashGrey,
          indicatorColor: AshenColors.copper,
          labelStyle: const TextStyle(fontSize: 10, letterSpacing: 2),
          tabs: const [
            Tab(text: 'LOCATIONS'),
            Tab(text: 'FAITHS'),
            Tab(text: 'FIGURES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _LocationsTab(),
          _FaithsTab(),
          _FiguresTab(),
        ],
      ),
    );
  }
}

// ─── LOCATIONS TAB ────────────────────────────────────────────────────────────

class _LocationsTab extends ConsumerWidget {
  const _LocationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worldMap = ref.watch(gameProvider).worldMap;
    final named = worldMap.where((l) => l.lore != null).toList()
      ..sort((a, b) {
        final depthCmp = a.depth.compareTo(b.depth);
        return depthCmp != 0 ? depthCmp : a.name.compareTo(b.name);
      });

    if (named.isEmpty) {
      return const Center(
        child: Text('No named locations discovered yet.',
            style: AshenText.dim),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: named.length,
      separatorBuilder: (_, idx) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final loc = named[i];
        final discovered = loc.discovered;
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: discovered ? AshenColors.border : AshenColors.border.withAlpha(60),
            ),
            color: discovered ? AshenColors.surface : const Color(0xFF0E0C0A),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.name,
                        style: AshenText.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: discovered
                              ? AshenColors.parchment
                              : AshenColors.ashGrey,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: discovered ? AshenColors.border : AshenColors.border.withAlpha(40),
                        ),
                      ),
                      child: Text(
                        'DEPTH ${loc.depth}',
                        style: TextStyle(
                          color: discovered ? AshenColors.ashGrey : AshenColors.ashGrey.withAlpha(80),
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  loc.typeLabel.toUpperCase(),
                  style: TextStyle(
                    color: discovered ? AshenColors.copper : AshenColors.ashGrey.withAlpha(80),
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
                if (discovered && loc.lore != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    loc.lore!,
                    style: AshenText.dim.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ] else if (!discovered) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Undiscovered — venture deeper to learn more.',
                    style: AshenText.dim.copyWith(
                      color: AshenColors.ashGrey.withAlpha(100),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── FAITHS TAB ───────────────────────────────────────────────────────────────

class _FaithsTab extends StatelessWidget {
  const _FaithsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _faithEntries.map((f) => _FaithEntry(entry: f)).toList(),
    );
  }
}

class _FaithEntry extends StatefulWidget {
  final ({String name, String subtitle, String body, Color color}) entry;
  const _FaithEntry({required this.entry});

  @override
  State<_FaithEntry> createState() => _FaithEntryState();
}

class _FaithEntryState extends State<_FaithEntry> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.entry;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _open = !_open),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: f.color, width: 3)),
            color: AshenColors.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.name,
                              style: AshenText.body.copyWith(
                                color: f.color,
                                fontWeight: FontWeight.bold,
                              )),
                          Text(f.subtitle,
                              style: AshenText.dim.copyWith(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              )),
                        ],
                      ),
                    ),
                    Icon(
                      _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AshenColors.ashGrey,
                      size: 16,
                    ),
                  ],
                ),
                if (_open) ...[
                  const SizedBox(height: 10),
                  Text(f.body, style: AshenText.dim.copyWith(fontSize: 12)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final _faithEntries = [
  (
    name: 'Luminant Church',
    subtitle: 'The Church of the Eternal Flame',
    color: Color(0xFFC8A820),
    body:
        'The dominant faith of the west, built on the Eternal Flame — a divine fire said to have spoken to the First Patriarch in a high mountain pass three centuries ago. The Church crusaded east along the Ashen Road ~250 years ago, burning Old Ways shrines as they went. The road\'s name comes from the ash of those fires.\n\n'
        'The Church organized a crusade under High Inquisitor Verdane forty years ago in response to The Opening, intending to seal whatever had cracked the eastern sky. Fourteen thousand soldiers reached Grimhaven. None returned as themselves.',
  ),
  (
    name: 'The Old Ways',
    subtitle: 'The faith before the flame',
    color: Color(0xFF5A8A3A),
    body:
        'The original faith of the land, organized around three gods who once walked among men: the Sky-Father, the Stone-Mother, and the Sea-King. Death was tended by the Three-Faced Queen — a goddess of the harvest cycle, encompassing both dying and rebirth.\n\n'
        'The Church\'s crusade suppressed the Old Ways across two generations. Shrines were burned, priests driven out or converted. What remains is scattered: way-shrines on old roads, village rites that look like harvest customs, and rangers who pray to a sky their faith no longer names.',
  ),
  (
    name: 'The Compact of Saints',
    subtitle: 'The Church that answered when the Church did not',
    color: Color(0xFF6888C0),
    body:
        'Founded roughly 200 years ago during a great plague, when the Luminant Church\'s prayers went unanswered but spontaneous prayers to the recently dead began producing results. The Compact venerates individual saints — human figures who performed extraordinary acts of mercy, sacrifice, or will.\n\n'
        'The most petitioned is Saint Aldric, a reformed bandit-king who walked the Ashen Road nine times in penance and founded Greywater as a free city. The Compact has no great cathedrals; it operates through wayfarers, shrines at crossroads, and the prayers of travelers.',
  ),
  (
    name: 'The Pale Court',
    subtitle: 'Those who serve the Three-Faced Queen',
    color: Color(0xFF9090C0),
    body:
        'An institution that formalized around the Old Ways death-goddess after her rebirth aspect was severed by the Church\'s suppression. The Three-Faced Queen was once a complete cycle — death AND return. Now she holds only death. The Pale Court\'s theology reflects this: ancestor veneration, careful records of the departed, and the belief that the dead persist in a court that mirrors the living world.\n\n'
        'Rielle — called the Pale Mother — was Abbess of the Priory of Ash. She wrote "The Accounting," a text that predicted The Opening thirty years before it occurred with specific accuracy. The later entries are not prophecy; they are instruction.',
  ),
  (
    name: 'The Ashen Rite',
    subtitle: 'Those who bargain with what came through',
    color: Color(0xFF9050A0),
    body:
        'The newest and least understood faith, born in the decades since The Opening. Where other faiths interpret the Void as evil or enemy, the Ashen Rite regards it as ABSENCE — the negation of all things, not a force of malice. The ash spreading westward is void-touch made material.\n\n'
        'Practitioners believe the Void can be bargained with because it wants to experience existence through proxies. Whether this is theology or delusion is unclear. What is clear: the Rite\'s rituals work on something — and the price is paid later.',
  ),
];

// ─── FIGURES TAB ─────────────────────────────────────────────────────────────

class _FiguresTab extends StatelessWidget {
  const _FiguresTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _figureEntries.map((f) => _FigureEntry(entry: f)).toList(),
    );
  }
}

class _FigureEntry extends StatefulWidget {
  final ({String name, String epithet, String era, String body, String? items}) entry;
  const _FigureEntry({required this.entry});

  @override
  State<_FigureEntry> createState() => _FigureEntryState();
}

class _FigureEntryState extends State<_FigureEntry> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.entry;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _open = !_open),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AshenColors.border),
            color: AshenColors.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.name,
                              style: AshenText.body.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                          Text(
                            '"${f.epithet}"  ·  ${f.era}',
                            style: AshenText.dim.copyWith(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AshenColors.ashGrey,
                      size: 16,
                    ),
                  ],
                ),
                if (_open) ...[
                  const SizedBox(height: 10),
                  Text(f.body, style: AshenText.dim.copyWith(fontSize: 12)),
                  if (f.items != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AshenColors.copper, width: 2),
                        ),
                        color: AshenColors.parchmentWarm,
                      ),
                      child: Text(
                        'Known relics: ${f.items!}',
                        style: AshenText.dim.copyWith(
                          fontSize: 11,
                          color: AshenColors.copper,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final _figureEntries = [
  (
    name: 'High Inquisitor Verdane',
    epithet: 'He who led the last crusade',
    era: 'The Ashen Age',
    body:
        'Verdane organized and led the Church\'s crusade against the eastern darkness forty years ago. Fourteen thousand soldiers marched with him to Grimhaven. Before the final charge, he removed his helm so he could address his soldiers face to face.\n\n'
        'Those soldiers did not die at Grimhaven. They became something else. Verdane himself now leads them. He speaks no human language. He does not seem to require his helm.',
    items: "Verdane's Mandate (estoc), Verdane's Helm (great helm)",
  ),
  (
    name: 'Rielle, the Pale Mother',
    epithet: 'She who wrote what was not yet done',
    era: 'The Ashen Age',
    body:
        'Abbess of the Priory of Ash and the most significant theological voice of the Pale Court in a generation. She wrote "The Accounting" — a record of the dead and the patterns she observed in their passing. Midway through, her writing changed. She began describing The Opening thirty years before it occurred, with specific accuracy.\n\n'
        'The entries after the prediction are not prophecy. They are instruction. What they instruct — and for whom — is a matter of considerable debate among the Court\'s scholars.',
    items: "The Accounting (tome), The Pale Mother's Veil (head armor)",
  ),
  (
    name: 'Saint Aldric',
    epithet: 'The penitent bandit-king',
    era: 'Age of the Flame',
    body:
        'Aldric was a bandit-king for twenty years before a Compact wayfarder found him at a crossroads, sitting next to a man he had just robbed and killed. He turned himself in, was not executed, and spent thirty years in penance — most of it walking.\n\n'
        'He walked the Ashen Road nine times in total. He founded Greywater as a free city with no tithe to the Church. He was on an Inquisitor\'s list that was never acted on. The Compact petitions him more than any other saint. He was petitioned, someone once said, because he answered.',
    items: "The Honest Axe (axe), Aldric's Road-Boots (feet armor)",
  ),
  (
    name: 'The Pale Margrave',
    epithet: 'Holder of Coldstone Keep',
    era: 'Unknown',
    body:
        'The Pale Margrave appears on tax records but is described inconsistently by those who have visited Coldstone Keep. Some describe a woman; some a man; some an old figure; some a young one. The keep has been held for an indeterminate number of years.\n\n'
        'Departing guests are sometimes given a gift — a sword, or a cloak. These items subsequently reappear in later inventories without explanation. Whether the Margrave is a single person, a title, or something else is not known. The keep\'s staff, if there is staff, does not speak of it.',
    items: "The Margrave's Greeting (longsword), The Margrave's Cloak (body armor)",
  ),
  (
    name: 'Bryndis the Unbowed',
    epithet: 'Old Ways ranger, first of the road',
    era: 'The Old Age',
    body:
        'Bryndis walked the land before the Church came, before the road was built, before the land had the name it has now. She was a ranger of the Old Ways — a wanderer who served the Sky-Father by knowing the lay of every track and crossing.\n\n'
        'Her bow was made from a tree with no modern name: ash-pale wood that no longer grows anywhere on the road. It was found in an Old Ways wayshrine, wrapped in cloth that had not rotted despite centuries of exposure. The bow still holds its draw.',
    items: "Bryndis's Eye (longbow), Road-Warden's Tabard (body armor)",
  ),
  (
    name: 'Iron Marshal Halvast',
    epithet: 'He who held without word or reinforcement',
    era: 'Age of the Flame',
    body:
        'Halvast held Ironwall for a full campaign season with no supply line, no reinforcement, and no reply to any of the dispatches he sent. He never learned whether the dispatches were received.\n\n'
        'His soldiers, following his example, stripped iron from Ironwall\'s own buildings for armor repair. They named his war hammer "The Unanswered Letter" — his own orders for what to call it were one of the dispatches that was not replied to.',
    items: "The Unanswered Letter (war hammer), Halvast's Warplate (body armor)",
  ),
  (
    name: 'Mira of the Flooded Road',
    epithet: 'A Saint of the Compact',
    era: 'Age of the Flame',
    body:
        'Mira died guiding a column of refugees across a submerged causeway during a flash flood. She was at the rear when the water rose. Her staff reportedly glowed during the crossing — not with the Eternal Flame, not with Church blessing, but with something older and quieter.\n\n'
        'The Compact says Mira held no particular faith. Only will. They petition her in floods, in dark roads, and in the moment before a difficult decision.',
    items: "Mira's Lantern (staff)",
  ),
  (
    name: 'The Ashen Architect',
    epithet: 'Builder beneath the builders',
    era: 'Unknown — pre-Church',
    body:
        'Whoever built the Ashen Road left markings in the foundation stones that pre-date the Church\'s own marks by an unknown span of years. These marks are in a script that Church scholars have not been able to fully translate.\n\n'
        'The final inscription, on a stone near the road\'s eastern terminus, translates approximately as: "The Ashwood. My road leads home." What the Ashwood is, and whether the road still leads there, is not recorded.',
    items: "The Architect's Rod (wand)",
  ),
];
