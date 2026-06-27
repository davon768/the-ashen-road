import 'package:flutter/material.dart' hide Hero;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../theme/colors.dart';
import '../theme/parchment_widgets.dart';
import '../models/hero.dart';
import '../models/enums.dart';
import '../models/devotion_perk.dart';
import '../data/devotion_perks_data.dart';

// ─── DEVOTION TREE SCREEN ─────────────────────────────────────────────────────

class DevotionScreen extends ConsumerWidget {
  final String heroId;
  const DevotionScreen({super.key, required this.heroId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final party = ref.watch(partyProvider);
    final hero = party.where((h) => h.id == heroId).firstOrNull;

    if (hero == null || hero.faith == null) {
      return const Scaffold(
        backgroundColor: AshenColors.background,
        body: Center(child: Text('Hero not found or has no faith.', style: AshenText.dim)),
      );
    }

    final perks = perksForFaith(hero.faith!);
    final tierUnlocked = devotionTierUnlocked(hero.devotion);

    return Scaffold(
      backgroundColor: AshenColors.background,
      appBar: AppBar(
        backgroundColor: AshenColors.background,
        foregroundColor: AshenColors.parchment,
        title: Text(
          '${hero.name.toUpperCase()} — ${_faithLabel(hero.faith!)}',
          style: AshenText.heading.copyWith(fontSize: 13),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Devotion progress
            _DevotionHeader(hero: hero, tierUnlocked: tierUnlocked),
            const SizedBox(height: 20),

            // Tier rows
            for (int tier = 1; tier <= 4; tier++) ...[
              _TierRow(
                tier: tier,
                hero: hero,
                perks: perks.where((p) => p.tier == tier).toList(),
                unlocked: tier <= tierUnlocked,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  static String _faithLabel(FaithType faith) => switch (faith) {
    FaithType.luminantChurch  => 'Luminant Church',
    FaithType.oldWays         => 'The Old Ways',
    FaithType.paleCourt       => 'The Pale Court',
    FaithType.compactOfSaints => 'Compact of Saints',
    FaithType.ashenRite       => 'The Ashen Rite',
  };
}

// ─── DEVOTION HEADER ─────────────────────────────────────────────────────────

class _DevotionHeader extends StatelessWidget {
  final Hero hero;
  final int tierUnlocked;

  const _DevotionHeader({required this.hero, required this.tierUnlocked});

  @override
  Widget build(BuildContext context) {
    return ParchmentPanel(
      accentColor: _tierColor(tierUnlocked),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Devotion: ${hero.devotion.toStringAsFixed(0)} / 100',
                  style: AshenText.body,
                ),
              ),
              Text(
                tierUnlocked >= 4
                    ? 'ALL TIERS UNLOCKED'
                    : 'Next tier at ${devotionTierThresholds[tierUnlocked].toStringAsFixed(0)}',
                style: AshenText.dim.copyWith(fontSize: 10, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar with tier markers
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              LinearProgressIndicator(
                value: hero.devotion / 100,
                minHeight: 10,
                backgroundColor: AshenColors.border,
                valueColor: AlwaysStoppedAnimation(_tierColor(tierUnlocked)),
              ),
              // Tier marker lines
              for (final threshold in devotionTierThresholds)
                Positioned(
                  left: (threshold / 100) *
                      (MediaQuery.of(context).size.width - 64),
                  child: Container(width: 2, height: 14, color: AshenColors.background),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Chosen perk stat bonuses summary
          if (hero.devotionPerkIds.isNotEmpty) ...[
            Text(
              'Active blessings: ${hero.devotionPerkIds.length}',
              style: AshenText.dim.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              _perkBonusSummary(hero),
              style: AshenText.dim.copyWith(fontSize: 10, color: AshenColors.copper),
            ),
          ],
        ],
      ),
    );
  }

  String _perkBonusSummary(Hero hero) {
    final parts = <String>[];
    final s = hero.perkStatBonus;
    if (s.strength > 0)     parts.add('+${s.strength} STR');
    if (s.dexterity > 0)    parts.add('+${s.dexterity} DEX');
    if (s.endurance > 0)    parts.add('+${s.endurance} END');
    if (s.intelligence > 0) parts.add('+${s.intelligence} INT');
    if (s.faith > 0)        parts.add('+${s.faith} FAI');
    if (s.luck > 0)         parts.add('+${s.luck} LCK');
    final gold = computeGoldBonus(hero.devotionPerkIds);
    if (gold > 0) parts.add('+${(gold * 100).round()}% gold');
    final xp = computeXpBonus(hero.devotionPerkIds);
    if (xp > 0) parts.add('+${(xp * 100).round()}% XP');
    final heal = computeHealBonus(hero.devotionPerkIds);
    if (heal > 0) parts.add('+${(heal * 100).round()}% heal');
    return parts.join('  ·  ');
  }

  Color _tierColor(int tier) => switch (tier) {
    0 => AshenColors.ashGrey,
    1 => const Color(0xFF7A9060),
    2 => AshenColors.copper,
    3 => const Color(0xFFB08050),
    _ => AshenColors.gold,
  };
}

// ─── TIER ROW ────────────────────────────────────────────────────────────────

class _TierRow extends ConsumerWidget {
  final int tier;
  final Hero hero;
  final List<DevotionPerk> perks;
  final bool unlocked;

  const _TierRow({
    required this.tier,
    required this.hero,
    required this.perks,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threshold = devotionTierThresholds[tier - 1];
    final chosenId = hero.devotionPerkIds
        .where((id) => perks.any((p) => p.id == id))
        .firstOrNull;
    final hasPending = ref.watch(pendingDevotionChoicesProvider).contains(hero.id);
    final canChoose = unlocked && chosenId == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: unlocked ? AshenColors.copper : AshenColors.border),
                color: unlocked ? const Color(0xFF2A1800) : const Color(0xFF181410),
              ),
              child: Text(
                'TIER $tier  —  ${threshold.toStringAsFixed(0)} devotion',
                style: AshenText.dim.copyWith(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: unlocked ? AshenColors.copper : AshenColors.ashGrey,
                ),
              ),
            ),
            if (canChoose && hasPending) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: const Color(0xFF6A3000),
                child: Text(
                  'CHOOSE A BLESSING',
                  style: AshenText.dim.copyWith(
                    fontSize: 9, letterSpacing: 1, color: AshenColors.gold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: perks.map((perk) {
            final isChosen = chosenId == perk.id;
            final otherChosen = chosenId != null && chosenId != perk.id;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _PerkCard(
                  perk: perk,
                  isChosen: isChosen,
                  isLocked: !unlocked || otherChosen,
                  canChoose: canChoose,
                  onChoose: canChoose
                      ? () => ref
                          .read(gameProvider.notifier)
                          .selectDevotionPerk(hero.id, perk.id)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── PERK CARD ────────────────────────────────────────────────────────────────

class _PerkCard extends StatelessWidget {
  final DevotionPerk perk;
  final bool isChosen;
  final bool isLocked;
  final bool canChoose;
  final VoidCallback? onChoose;

  const _PerkCard({
    required this.perk,
    required this.isChosen,
    required this.isLocked,
    required this.canChoose,
    this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isChosen
        ? AshenColors.gold
        : isLocked
            ? AshenColors.border.withOpacity(0.4)
            : AshenColors.border;

    final bgColor = isChosen
        ? const Color(0xFF2A1E00)
        : isLocked
            ? const Color(0xFF0E0C0A)
            : const Color(0xFF181410);

    return GestureDetector(
      onTap: canChoose ? onChoose : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: isChosen ? 1.5 : 1.0),
          color: bgColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    perk.name,
                    style: AshenText.body.copyWith(
                      color: isChosen
                          ? AshenColors.gold
                          : isLocked
                              ? AshenColors.ashGrey
                              : AshenColors.parchment,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (isChosen)
                  const Text('✓', style: TextStyle(color: AshenColors.gold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              perk.description,
              style: AshenText.dim.copyWith(
                fontSize: 10,
                color: isLocked ? AshenColors.ashGrey.withOpacity(0.6) : AshenColors.copper,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              perk.flavorText,
              style: AshenText.dim.copyWith(
                fontSize: 9,
                fontStyle: FontStyle.italic,
                color: isLocked
                    ? AshenColors.ashGrey.withOpacity(0.4)
                    : AshenColors.parchmentDim,
              ),
            ),
            if (canChoose && !isChosen && !isLocked) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: AshenColors.copper),
                  ),
                  child: Text(
                    'CHOOSE',
                    style: AshenText.dim.copyWith(
                      fontSize: 9, letterSpacing: 2, color: AshenColors.copper,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
