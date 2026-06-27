import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../theme/colors.dart';
import '../theme/parchment_widgets.dart';
import '../utils/location_generator.dart';
import '../data/road_events_data.dart';
import '../data/travel_events_data.dart';
import '../data/weapons_data.dart';
import '../data/armor_data.dart';
import '../models/expedition.dart';
import '../widgets/town_visit_panel.dart';
import 'combat_report_screen.dart';
import 'devotion_screen.dart';
import 'codex_screen.dart';

class RoadScreen extends ConsumerWidget {
  const RoadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gold           = ref.watch(goldProvider);
    final rations        = ref.watch(gameProvider.select((s) => s.rations));
    final day            = ref.watch(inGameDayProvider);
    final log            = ref.watch(eventLogProvider);
    final expedition     = ref.watch(expeditionProvider);
    final townVisit      = ref.watch(townVisitProvider);
    final properties     = ref.watch(propertiesProvider);
    final lastCombatReportJson   = ref.watch(gameProvider).lastCombatReportJson;
    final lastCombatLocationName = ref.watch(gameProvider).lastCombatLocationName;
    final pendingEventId        = ref.watch(pendingEventIdProvider);
    final pendingTravelEventId  = ref.watch(pendingTravelEventIdProvider);
    final pendingDevotionHeroIds = ref.watch(pendingDevotionChoicesProvider);
    final gps                   = ref.watch(gameProvider).goldPerSecond;
    final party                 = ref.watch(partyProvider);

    final merchantActive = ref.watch(gameProvider.select((s) => s.merchantActive));
    final merchantStock  = ref.watch(gameProvider.select((s) => s.merchantStock));
    final pendingReturnEventId = ref.watch(gameProvider.select((s) => s.pendingReturnEventId));

    final pendingEvent = pendingEventId == null
        ? null
        : allRoadEvents.where((e) => e.id == pendingEventId).firstOrNull;
    final pendingTravelEvent = pendingTravelEventId == null
        ? null
        : travelEventById(pendingTravelEventId);
    final pendingReturnEvent = pendingReturnEventId == null
        ? null
        : travelEventById(pendingReturnEventId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status bar ───────────────────────────────────────
          ParchmentPanel(
            accentColor: AshenColors.sepiaLine,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(label: 'DAY',     value: '$day'),
                _Stat(label: 'GOLD',    value: '$gold', valueStyle: AshenText.gold),
                _Stat(label: 'INCOME',  value: '${gps.toStringAsFixed(1)}/s'),
                _Stat(
                  label: 'RATIONS',
                  value: '$rations',
                  valueStyle: rations < 3
                      ? AshenText.body.copyWith(color: AshenColors.darkRed)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Road event ────────────────────────────────────────
          if (pendingEvent != null) ...[
            ParchmentPanel(
              accentColor: AshenColors.copper,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeading('EVENT ON THE ROAD'),
                  const SizedBox(height: 10),
                  Text(
                    pendingEvent.title,
                    style: AshenText.body.copyWith(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(pendingEvent.description, style: AshenText.dim),
                  const SizedBox(height: 12),
                  ...pendingEvent.choices.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AshenColors.parchment,
                            side: const BorderSide(color: AshenColors.border),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: const RoundedRectangleBorder(),
                          ),
                          onPressed: () => ref
                              .read(gameProvider.notifier)
                              .resolveEventChoice(entry.key),
                          child: Text(entry.value.label,
                              style: AshenText.body.copyWith(fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Travel event (pauses expedition) ─────────────────
          if (pendingTravelEvent != null) ...[
            ParchmentPanel(
              accentColor: const Color(0xFF8B7040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeading('ENCOUNTER ON THE ROAD'),
                  const SizedBox(height: 10),
                  Text(
                    pendingTravelEvent.title,
                    style: AshenText.body.copyWith(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(pendingTravelEvent.description, style: AshenText.dim),
                  const SizedBox(height: 12),
                  ...pendingTravelEvent.choices.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AshenColors.parchment,
                            side: const BorderSide(color: Color(0xFF8B7040)),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: const RoundedRectangleBorder(),
                          ),
                          onPressed: () => ref
                              .read(gameProvider.notifier)
                              .resolveTravelEventChoice(entry.key),
                          child: Text(entry.value.label,
                              style: AshenText.body.copyWith(fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Return encounter (fires during partyReturn journey) ──
          if (pendingReturnEvent != null) ...[
            ParchmentPanel(
              accentColor: const Color(0xFF7A6030),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeading('ENCOUNTER ON THE ROAD HOME'),
                  const SizedBox(height: 10),
                  Text(
                    pendingReturnEvent.title,
                    style: AshenText.body.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(pendingReturnEvent.description, style: AshenText.dim),
                  const SizedBox(height: 12),
                  ...pendingReturnEvent.choices.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AshenColors.parchment,
                            side: const BorderSide(color: Color(0xFF7A6030)),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: const RoundedRectangleBorder(),
                          ),
                          onPressed: () => ref
                              .read(gameProvider.notifier)
                              .resolveReturnEventChoice(entry.key),
                          child: Text(entry.value.label, style: AshenText.body.copyWith(fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Traveling merchant ────────────────────────────────
          if (merchantActive) ...[
            ParchmentPanel(
              accentColor: AshenColors.copper,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🛒', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      const Expanded(child: SectionHeading('TRAVELING MERCHANT')),
                      TextButton(
                        onPressed: () => ref.read(gameProvider.notifier).dismissMerchant(),
                        child: const Text(
                          'DISMISS',
                          style: TextStyle(color: AshenColors.ashGrey, fontSize: 10, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A wandering trader with unusual wares. Prices reflect rarity.',
                    style: AshenText.dim.copyWith(fontStyle: FontStyle.italic, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  ...merchantStock.asMap().entries.map((entry) {
                    final item = entry.value;
                    if (item.sold) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('  — SOLD —', style: AshenText.dim.copyWith(fontSize: 11)),
                      );
                    }
                    final displayName = item.isArmor
                        ? (allArmor.where((a) => a.id == item.id).firstOrNull?.name
                            ?? item.id.replaceAll('_', ' '))
                        : (allWeapons.where((w) => w.id == item.id).firstOrNull?.name
                            ?? item.id.replaceAll('_', ' '));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: AshenText.body.copyWith(fontSize: 12),
                                ),
                                Text(
                                  item.isArmor ? 'ARMOR' : 'WEAPON',
                                  style: AshenText.dim.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AshenColors.copper,
                              side: const BorderSide(color: AshenColors.copper),
                              shape: const RoundedRectangleBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              textStyle: const TextStyle(fontSize: 11, letterSpacing: 1),
                            ),
                            onPressed: gold >= item.price
                                ? () => ref.read(gameProvider.notifier).buyMerchantItem(entry.key)
                                : null,
                            child: Text('${item.price}g'),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Devotion perk pending choices ─────────────────────
          if (pendingDevotionHeroIds.isNotEmpty) ...[
            ParchmentPanel(
              accentColor: const Color(0xFF8A5FB0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('✦', style: TextStyle(fontSize: 16, color: Color(0xFF8A5FB0))),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'A BLESSING AWAITS',
                          style: TextStyle(
                            color: Color(0xFF8A5FB0),
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your faith has deepened. Visit the Party screen to choose a blessing.',
                    style: AshenText.dim,
                  ),
                  const SizedBox(height: 10),
                  ...pendingDevotionHeroIds.map((heroId) {
                    final hero = party.where((h) => h.id == heroId).firstOrNull;
                    if (hero == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8A5FB0),
                            side: const BorderSide(color: Color(0xFF8A5FB0)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: const RoundedRectangleBorder(),
                            textStyle: const TextStyle(fontSize: 11, letterSpacing: 1),
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DevotionScreen(heroId: heroId),
                            ),
                          ),
                          child: Text('${hero.name.toUpperCase()} — CHOOSE BLESSING'),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Town / monastery visit ────────────────────────────
          if (townVisit != null) ...[
            const SectionHeading('IN TOWN'),
            const SizedBox(height: 8),
            TownVisitPanel(visit: townVisit),
            const SizedBox(height: 16),
          ],

          // ── Expedition complete — awaiting new orders ────────
          if (expedition != null && expedition.isComplete && townVisit == null) ...[
            ParchmentPanel(
              accentColor: AshenColors.gold,
              child: Row(
                children: [
                  const Text('✦', style: TextStyle(color: AshenColors.gold, fontSize: 14)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expedition.locationName.toUpperCase(),
                          style: AshenText.body.copyWith(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Expedition complete. Visit the map to send them on another.',
                          style: AshenText.dim.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Active expedition ─────────────────────────────────
          if (expedition != null && !expedition.isComplete) ...[
            const SectionHeading('ON THE ROAD'),
            const SizedBox(height: 8),
            Builder(builder: (context) {
              final worldMap = ref.watch(gameProvider).worldMap;
              final loc = expedition.worldLocationId == null
                  ? null
                  : worldMap
                      .where((l) => l.id == expedition.worldLocationId)
                      .firstOrNull;
              final loreText = loc?.lore ?? loc?.description;
              return ParchmentPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          locationIcon(expedition.locationType),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(expedition.locationName,
                              style: AshenText.body
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          formatDuration(expedition.durationSeconds -
                              expedition.elapsedSeconds),
                          style: AshenText.dim,
                        ),
                      ],
                    ),
                    if (loreText != null) ...[
                      const SizedBox(height: 8),
                      Text(loreText,
                          style: AshenText.dim.copyWith(
                              fontStyle: FontStyle.italic, fontSize: 12)),
                    ],
                    const SizedBox(height: 10),
                    if (expedition.isTraveling) ...[
                      Row(
                        children: [
                          Text(
                            pendingTravelEventId != null ? '⏸ PAUSED' : 'TRAVELING',
                            style: AshenText.dim.copyWith(
                                fontSize: 9,
                                letterSpacing: 1.5,
                                color: pendingTravelEventId != null
                                    ? const Color(0xFF8B7040)
                                    : null),
                          ),
                          const Spacer(),
                          if (pendingTravelEventId == null)
                            Text(
                              '${formatDuration(expedition.travelSeconds - expedition.elapsedSeconds)} to arrival',
                              style: AshenText.dim.copyWith(fontSize: 11),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: expedition.travelProgress,
                        minHeight: 8,
                        backgroundColor: AshenColors.border,
                        valueColor: AlwaysStoppedAnimation(
                            pendingTravelEventId != null
                                ? const Color(0xFF8B7040)
                                : const Color(0xFF7A6530)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pendingTravelEventId != null
                            ? 'Travel paused — awaiting your decision'
                            : 'En route — ${(expedition.travelProgress * 100).toStringAsFixed(0)}% of the journey',
                        style: AshenText.dim.copyWith(
                            fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ] else ...[
                      LinearProgressIndicator(
                        value: expedition.atLocationProgress,
                        minHeight: 8,
                        backgroundColor: AshenColors.border,
                        valueColor:
                            const AlwaysStoppedAnimation(AshenColors.copper),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(expedition.atLocationProgress * 100).toStringAsFixed(0)}% complete',
                        style: AshenText.dim,
                      ),
                      // ── Mid-expedition supply buttons ─────────
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('SUPPLIES',
                              style: AshenText.dim.copyWith(
                                  fontSize: 9, letterSpacing: 1.5)),
                          const SizedBox(width: 10),
                          _SupplyChip(
                            label: 'HEALING KIT',
                            active: expedition.suppliesFlags & 1 != 0,
                            onBuy: expedition.suppliesFlags & 1 == 0 && gold >= 80
                                ? () => ref
                                    .read(gameProvider.notifier)
                                    .buyExpeditionSupply('healing_kit')
                                : null,
                          ),
                          const SizedBox(width: 6),
                          _SupplyChip(
                            label: 'LANTERN',
                            active: expedition.suppliesFlags & 2 != 0,
                            onBuy: expedition.suppliesFlags & 2 == 0 && gold >= 60
                                ? () => ref
                                    .read(gameProvider.notifier)
                                    .buyExpeditionSupply('lantern')
                                : null,
                          ),
                        ],
                      ),
                      _LiveCombatLog(expedition: expedition),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // ── Properties summary ───────────────────────────────
          if (properties.isNotEmpty) ...[
            const SectionHeading('HOLDINGS'),
            const SizedBox(height: 8),
            ParchmentPanel(
              accentColor: AshenColors.gold,
              child: Column(
                children: properties
                    .map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(p.name, style: AshenText.body)),
                              Text('${p.unlockedAddonIds.length} upgrades', style: AshenText.dim),
                              const SizedBox(width: 12),
                              Text('+${p.goldPerMinute}g/min',
                                  style: AshenText.gold),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Lore Codex link ──────────────────────────────────
          Row(
            children: [
              const Expanded(child: SectionHeading('EVENT LOG')),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AshenColors.ashGrey,
                  side: const BorderSide(color: AshenColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  shape: const RoundedRectangleBorder(),
                  textStyle: const TextStyle(fontSize: 9, letterSpacing: 1.5),
                ),
                icon: const Icon(Icons.menu_book_outlined, size: 12),
                label: const Text('CODEX'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CodexScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ParchmentPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: log.take(20).map((e) {
                final isReport = e.contains('Tap to view combat report');
                return InkWell(
                  onTap: isReport && lastCombatReportJson != null
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CombatReportScreen(
                                reportJson: lastCombatReportJson,
                                locationName: lastCombatLocationName ?? '',
                              ),
                            ),
                          )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('›  ',
                            style: TextStyle(color: AshenColors.copper)),
                        Expanded(
                          child: Text(e,
                              style: AshenText.body.copyWith(
                                color: isReport
                                    ? AshenColors.copper
                                    : AshenColors.parchment,
                                decoration: isReport
                                    ? TextDecoration.underline
                                    : null,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveCombatLog extends StatelessWidget {
  final Expedition expedition;
  const _LiveCombatLog({required this.expedition});

  @override
  Widget build(BuildContext context) {
    if (expedition.isTraveling) return const SizedBox.shrink();
    final log = expedition.liveCombatLog;
    if (log.isEmpty) return const SizedBox.shrink();

    final visibleCount =
        (expedition.atLocationProgress * log.length).floor().clamp(0, log.length);
    if (visibleCount == 0) return const SizedBox.shrink();

    // Show the 8 most recently revealed events, newest first.
    final visible = log.sublist(0, visibleCount).reversed.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Divider(color: AshenColors.border, height: 1),
        const SizedBox(height: 8),
        ...visible.map((line) {
          final isVital = line.contains('slain') ||
              line.contains('falls') ||
              line.contains('down') ||
              line.contains('gold') ||
              line.contains('miracle');
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '› ',
                  style: TextStyle(
                    color: isVital ? AshenColors.copper : AshenColors.border,
                    fontSize: 11,
                  ),
                ),
                Expanded(
                  child: Text(
                    line,
                    style: AshenText.dim.copyWith(
                      fontSize: 11,
                      color: isVital
                          ? AshenColors.parchment.withValues(alpha: 0.85)
                          : AshenColors.parchment.withValues(alpha: 0.55),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SupplyChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onBuy;
  const _SupplyChip({required this.label, required this.active, this.onBuy});

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: AshenColors.copper),
          color: AshenColors.copper.withAlpha(20),
        ),
        child: Text(
          '$label ✓',
          style: const TextStyle(
              color: AshenColors.copper, fontSize: 9, letterSpacing: 1),
        ),
      );
    }
    final cost = label == 'HEALING KIT' ? 80 : 60;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AshenColors.ashGrey,
        side: const BorderSide(color: AshenColors.border),
        shape: const RoundedRectangleBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 9, letterSpacing: 1),
      ),
      onPressed: onBuy,
      child: Text('$label  ${cost}g'),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _Stat({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label,
              style: AshenText.dim.copyWith(fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 2),
          Text(value, style: valueStyle ?? AshenText.body),
        ],
      );
}
