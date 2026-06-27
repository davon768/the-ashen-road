import 'package:flutter/material.dart' hide Hero;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/town_visit.dart';
import '../models/enums.dart';
import '../models/quest.dart';
import '../state/providers.dart';
import '../state/game_state.dart';
import '../theme/colors.dart';
import '../theme/parchment_widgets.dart';
import '../screens/trader_screen.dart';
import '../state/game_notifier.dart';
import '../models/hero.dart';

class TownVisitPanel extends ConsumerStatefulWidget {
  final TownVisit visit;
  const TownVisitPanel({super.key, required this.visit});

  @override
  ConsumerState<TownVisitPanel> createState() => _TownVisitPanelState();
}

class _TownVisitPanelState extends ConsumerState<TownVisitPanel> {
  // Track which NPC's dialogue is expanded.
  String? _expandedNpcId;

  @override
  Widget build(BuildContext context) {
    // Always read from provider so we react to state changes.
    final visit = ref.watch(townVisitProvider) ?? widget.visit;
    final gold = ref.watch(goldProvider);
    final partySize = ref.watch(partyProvider).length;
    final maxPartySize = ref.watch(maxPartySizeProvider);
    final notifier = ref.read(gameProvider.notifier);
    final isMonastery = visit.visitType == TownVisitType.monastery;
    final isFaithSite = visit.visitType == TownVisitType.faithSite;

    // ── Faith site panel ─────────────────────────────────────────────────────
    if (isFaithSite) {
      return ParchmentPanel(
        accentColor: const Color(0xFF8A5FB0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('✦', style: TextStyle(fontSize: 20, color: Color(0xFF8A5FB0))),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(visit.locationName.toUpperCase(), style: AshenText.heading),
                ),
                _LeaveButton(onLeave: notifier.leaveTown, label: 'DEPART'),
              ],
            ),
            const SizedBox(height: 14),
            _SectionLabel('DEVOTION GAINED'),
            const SizedBox(height: 8),
            ...visit.faithMessages.map((msg) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(msg, style: AshenText.body),
            )),
            const SizedBox(height: 8),
            Text(
              'Visit the Party screen to spend devotion on blessings.',
              style: AshenText.dim.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            _SectionLabel('TITHE'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8A5FB0),
                  side: const BorderSide(color: Color(0xFF8A5FB0)),
                  shape: const RoundedRectangleBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(fontSize: 11, letterSpacing: 2),
                ),
                onPressed: gold >= 100 ? () => notifier.donateFaith() : null,
                child: const Text('DONATE 100 GOLD  →  +25 DEVOTION'),
              ),
            ),
          ],
        ),
      );
    }

    final totalInnCost = visit.innCostPerHero * visit.heroIds.length;
    final canAffordInn = gold >= totalInnCost;

    final hiresAvailable = visit.availableRecruits.isNotEmpty;

    return ParchmentPanel(
      accentColor: AshenColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Row(
            children: [
              Text(
                isMonastery ? '⛪' : '🏘',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  visit.locationName.toUpperCase(),
                  style: AshenText.heading,
                ),
              ),
              _LeaveButton(onLeave: notifier.leaveTown),
            ],
          ),
          const SizedBox(height: 14),

          // ── Inn ────────────────────────────────────────────────────────────
          _SectionLabel(isMonastery ? 'THE MONASTERY' : 'THE INN'),
          const SizedBox(height: 8),
          _InnRow(
            visit: visit,
            totalCost: totalInnCost,
            canAfford: canAffordInn,
            onUse: notifier.useInn,
          ),

          // ── Trader (towns only) ───────────────────────────────────────────
          if (!isMonastery && visit.traderStock.isNotEmpty) ...[
            const InkRule(),
            _SectionLabel('THE TRADER'),
            const SizedBox(height: 8),
            _OpenTraderButton(visit: visit),
            const SizedBox(height: 4),
          ],

          // ── Wanderers for Hire (towns only) ───────────────────────────────
          if (!isMonastery && hiresAvailable) ...[
            const InkRule(),
            _SectionLabel('WANDERERS FOR HIRE'),
            const SizedBox(height: 8),
            if (partySize >= maxPartySize)
              Text(
                'Your party is full. Dismiss a hero to make room.',
                style: AshenText.dim.copyWith(fontStyle: FontStyle.italic),
              )
            else
              ...visit.availableRecruits.map((recruit) => _HireRow(
                    recruit: recruit,
                    gold: gold,
                    partyFull: partySize >= maxPartySize,
                    onHire: () => notifier.hireHeroFromTown(recruit.recruitId),
                  )),
            const SizedBox(height: 4),
          ],

          // ── Notice Board (towns only) ─────────────────────────────────────
          if (!isMonastery && visit.questOffers.isNotEmpty) ...[
            const InkRule(),
            _SectionLabel('NOTICE BOARD'),
            const SizedBox(height: 8),
            ...visit.questOffers.map((q) => _QuestOfferRow(quest: q)),
            const SizedBox(height: 4),
          ],

          // ── Training contracts ────────────────────────────────────────────
          if (isMonastery) ...[
            const InkRule(),
            _SectionLabel('TRAINING CONTRACTS'),
            const SizedBox(height: 8),
            _TrainingSection(visit: visit, gold: gold, notifier: notifier),
            const SizedBox(height: 4),
          ],

          // ── Townsfolk / Monks ─────────────────────────────────────────────
          const InkRule(),
          _SectionLabel(isMonastery ? 'THE BROTHERS' : 'TOWNSFOLK'),
          const SizedBox(height: 8),
          ...visit.npcs.map((npc) => _NpcRow(
                npc: npc,
                isExpanded: _expandedNpcId == npc.id,
                onTap: () {
                  notifier.talkToNpc(npc.id);
                  setState(() {
                    _expandedNpcId =
                        _expandedNpcId == npc.id ? null : npc.id;
                  });
                },
              )),
        ],
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AshenText.dim.copyWith(
          letterSpacing: 2,
          fontSize: 10,
          color: AshenColors.copper,
        ),
      );
}

class _LeaveButton extends StatelessWidget {
  final VoidCallback onLeave;
  final String label;
  const _LeaveButton({required this.onLeave, this.label = 'LEAVE TOWN'});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AshenColors.parchmentDim,
          side: const BorderSide(color: AshenColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: Size.zero,
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(fontSize: 11, letterSpacing: 1),
        ),
        onPressed: onLeave,
        child: Text(label),
      );
}

class _InnRow extends StatelessWidget {
  final TownVisit visit;
  final int totalCost;
  final bool canAfford;
  final VoidCallback onUse;
  const _InnRow({
    required this.visit,
    required this.totalCost,
    required this.canAfford,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    if (visit.innUsed) {
      return Row(children: [
        const Icon(Icons.hotel, size: 14, color: AshenColors.parchmentDim),
        const SizedBox(width: 8),
        Text(
          visit.visitType == TownVisitType.monastery
              ? 'You rested in the brothers\' care. All wounds are healed.'
              : 'Your party has rested. All wounds are healed.',
          style: AshenText.dim.copyWith(fontStyle: FontStyle.italic),
        ),
      ]);
    }

    return Row(
      children: [
        const Icon(Icons.hotel, size: 14, color: AshenColors.parchmentDim),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            visit.visitType == TownVisitType.monastery
                ? 'Rest under the monastery\'s roof. Heals all heroes fully.'
                : 'A bed and a meal. Heals all heroes to full.',
            style: AshenText.dim,
          ),
        ),
        const SizedBox(width: 8),
        _ActionButton(
          label: canAfford ? 'REST  ($totalCost g)' : 'NEED $totalCost g',
          enabled: canAfford,
          onPressed: onUse,
          color: canAfford ? AshenColors.copper : AshenColors.parchmentDim,
        ),
      ],
    );
  }
}

class _OpenTraderButton extends StatelessWidget {
  final TownVisit visit;
  const _OpenTraderButton({required this.visit});

  @override
  Widget build(BuildContext context) {
    final soldCount = visit.traderStock.where((o) => o.purchased).length;
    final total = visit.traderStock.length;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AshenColors.copper,
          side: const BorderSide(color: AshenColors.copper),
          shape: const RoundedRectangleBorder(),
          padding: const EdgeInsets.symmetric(vertical: 10),
          textStyle: const TextStyle(fontSize: 11, letterSpacing: 2),
        ),
        icon: const Icon(Icons.storefront, size: 14),
        label: Text(soldCount < total
            ? 'BROWSE WARES  ($soldCount/$total sold)'
            : 'VIEW WARES  (all sold)'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TraderScreen(visit: visit)),
        ),
      ),
    );
  }
}

class _NpcRow extends StatelessWidget {
  final TownNpc npc;
  final bool isExpanded;
  final VoidCallback onTap;
  const _NpcRow({required this.npc, required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: npc.talked
                      ? AshenColors.parchmentDim
                      : AshenColors.copper,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: npc.name,
                          style: AshenText.body.copyWith(
                            fontSize: 13,
                            color: npc.talked
                                ? AshenColors.parchmentDim
                                : AshenColors.parchment,
                          ),
                        ),
                        TextSpan(
                          text: '  ${npc.role}',
                          style: AshenText.dim.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 14,
                  color: AshenColors.parchmentDim,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${npc.greeting}"',
                      style: AshenText.dim.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: AshenColors.parchment.withValues(alpha: 0.8),
                      ),
                    ),
                    if (npc.questHint != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AshenColors.parchmentWarm,
                          border: const Border(
                            left: BorderSide(
                              color: AshenColors.copper,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📜 ',
                              style: TextStyle(fontSize: 11),
                            ),
                            Expanded(
                              child: Text(
                                npc.questHint!,
                                style: AshenText.dim.copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final Color color;
  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: enabled ? color : AshenColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(fontSize: 10, letterSpacing: 1),
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(label),
      );
}

class _HireRow extends StatelessWidget {
  final HeroRecruit recruit;
  final int gold;
  final bool partyFull;
  final VoidCallback onHire;

  const _HireRow({
    required this.recruit,
    required this.gold,
    required this.partyFull,
    required this.onHire,
  });

  @override
  Widget build(BuildContext context) {
    final hired = recruit.hired;
    final canAfford = gold >= recruit.hireCost && !hired && !partyFull;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.person_outline,
              size: 14,
              color: hired ? AshenColors.border : AshenColors.parchmentDim),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recruit.hero.name,
                  style: AshenText.body.copyWith(
                    fontSize: 13,
                    color: hired ? AshenColors.ashGrey : AshenColors.parchment,
                    decoration: hired ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${_className(recruit.hero.heroClass)}  ·  Lv ${recruit.hero.level}',
                  style: AshenText.dim.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          if (hired)
            Text('HIRED', style: AshenText.dim.copyWith(fontSize: 10, color: AshenColors.border))
          else
            _ActionButton(
              label: canAfford
                  ? 'HIRE  ${recruit.hireCost} g'
                  : gold < recruit.hireCost
                      ? 'NEED ${recruit.hireCost} g'
                      : 'PARTY FULL',
              enabled: canAfford,
              onPressed: onHire,
              color: canAfford ? AshenColors.copper : AshenColors.parchmentDim,
            ),
        ],
      ),
    );
  }

  String _className(HeroClass c) => switch (c) {
        HeroClass.knight      => 'Knight',
        HeroClass.ranger      => 'Ranger',
        HeroClass.priest      => 'Priest',
        HeroClass.mage        => 'Mage',
        HeroClass.rogue       => 'Rogue',
        HeroClass.necromancer => 'Necromancer',
        HeroClass.warlock     => 'Warlock',
      };
}

// ─── QUEST OFFER ROW ─────────────────────────────────────────────────────────

class _QuestOfferRow extends ConsumerWidget {
  final Quest quest;
  const _QuestOfferRow({required this.quest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeQuests = ref.watch(gameProvider.select((s) => s.activeQuests));
    final completedTitles = ref.watch(gameProvider.select((s) => s.completedQuestTitles));
    final isActive    = activeQuests.any((q) => q.title == quest.title);
    final isCompleted = completedTitles.contains(quest.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AshenColors.parchmentWarm,
        border: Border(
          left: BorderSide(
            color: isCompleted
                ? AshenColors.gold
                : isActive
                    ? AshenColors.copper
                    : AshenColors.border,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  quest.title,
                  style: AshenText.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? AshenColors.gold
                        : AshenColors.parchment,
                  ),
                ),
              ),
              Text(
                '${quest.rewardGold}g',
                style: AshenText.gold.copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(quest.description, style: AshenText.dim.copyWith(fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            '— ${quest.questGiverName}',
            style: AshenText.dim.copyWith(
                fontSize: 10, fontStyle: FontStyle.italic, color: AshenColors.copper),
          ),
          const SizedBox(height: 8),
          if (isCompleted)
            Text('COMPLETED', style: AshenText.dim.copyWith(color: AshenColors.gold, fontSize: 10, letterSpacing: 1.5))
          else if (isActive)
            Row(children: [
              const Icon(Icons.check_circle_outline, size: 12, color: AshenColors.copper),
              const SizedBox(width: 4),
              Text('QUEST ACCEPTED', style: AshenText.dim.copyWith(color: AshenColors.copper, fontSize: 10, letterSpacing: 1.5)),
            ])
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AshenColors.copper,
                  side: const BorderSide(color: AshenColors.copper),
                  shape: const RoundedRectangleBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  textStyle: const TextStyle(fontSize: 10, letterSpacing: 1.5),
                ),
                onPressed: () => ref.read(gameProvider.notifier).acceptQuest(quest),
                child: const Text('ACCEPT'),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── TRAINING SECTION ─────────────────────────────────────────────────────────

class _TrainingSection extends ConsumerWidget {
  final TownVisit visit;
  final int gold;
  final GameNotifier notifier;

  const _TrainingSection({
    required this.visit,
    required this.gold,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final party = ref.watch(partyProvider);
    final trainingRecords = ref.watch(gameProvider.select((s) => s.trainingRecords));
    final expedHeroes = party.where((h) => visit.heroIds.contains(h.id)).toList();
    const cost = 250;
    const xpGrant = 400;

    if (expedHeroes.isEmpty) {
      return Text('No heroes available for training.', style: AshenText.dim);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pay ${cost}g per hero for intensive training (+$xpGrant XP). Once per visit.',
          style: AshenText.dim.copyWith(fontSize: 11, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        ...expedHeroes.map((hero) {
          final trained = (trainingRecords[visit.locationId] ?? []).contains(hero.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(hero.name,
                      style: AshenText.body.copyWith(fontSize: 12)),
                ),
                if (trained)
                  Text('TRAINED',
                      style: AshenText.dim.copyWith(
                          fontSize: 10,
                          color: AshenColors.copper,
                          letterSpacing: 1))
                else
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AshenColors.copper,
                      side: const BorderSide(color: AshenColors.copper),
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 10, letterSpacing: 1),
                    ),
                    onPressed: gold >= cost
                        ? () => notifier.trainHero(hero.id, xpGrant)
                        : null,
                    child: Text('${cost}g'),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
