import 'dart:convert';
import 'package:flutter/material.dart';
import '../combat/combat_result.dart';
import '../theme/colors.dart';

class CombatReportScreen extends StatelessWidget {
  final String reportJson;
  final String locationName;

  const CombatReportScreen({
    super.key,
    required this.reportJson,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    final data = jsonDecode(reportJson) as Map<String, dynamic>;
    final encounters = data['encounters'] as List;
    final totalGold  = data['totalGold'] as int;
    final totalXp    = data['totalXp'] as int;
    final outcome    = CombatOutcome.values.byName(data['finalOutcome']);
    final loot       = List<String>.from(data['loot'] ?? []);

    return Scaffold(
      backgroundColor: AshenColors.background,
      appBar: AppBar(
        backgroundColor: AshenColors.surface,
        title: Text(
          locationName.toUpperCase(),
          style: const TextStyle(
              color: AshenColors.copper, letterSpacing: 3, fontSize: 13),
        ),
        iconTheme: const IconThemeData(color: AshenColors.copper),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AshenColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Summary banner ─────────────────────────────────────────
          _OutcomeBanner(outcome: outcome),
          const SizedBox(height: 16),

          // ── Totals ─────────────────────────────────────────────────
          _Panel(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat('GOLD', '+$totalGold', AshenColors.gold),
                _Stat('XP', '+$totalXp', AshenColors.copper),
                _Stat('ENCOUNTERS', '${encounters.length}', AshenColors.parchment),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Loot ───────────────────────────────────────────────────
          if (loot.isNotEmpty) ...[
            const Text('FOUND', style: AshenText.heading),
            const SizedBox(height: 8),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: loot
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Text('◆  ',
                                  style: TextStyle(
                                      color: AshenColors.gold, fontSize: 10)),
                              Text(item, style: AshenText.body),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Encounters ─────────────────────────────────────────────
          const Text('COMBAT LOG', style: AshenText.heading),
          const SizedBox(height: 8),
          ...encounters.asMap().entries.map((entry) {
            final i = entry.key;
            final enc = entry.value as Map<String, dynamic>;
            return _EncounterCard(index: i + 1, data: enc);
          }),
        ],
      ),
    );
  }
}

class _OutcomeBanner extends StatelessWidget {
  final CombatOutcome outcome;
  const _OutcomeBanner({required this.outcome});

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (outcome) {
      CombatOutcome.victory    => ('VICTORY', AshenColors.healthGreen),
      CombatOutcome.retreat    => ('RETREAT', AshenColors.recoverBlue),
      CombatOutcome.partyWiped => ('DEFEATED', AshenColors.bloodRed),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: color.withAlpha(30),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 22,
          letterSpacing: 6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EncounterCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> data;
  const _EncounterCard({required this.index, required this.data});

  @override
  State<_EncounterCard> createState() => _EncounterCardState();
}

class _EncounterCardState extends State<_EncounterCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final events   = widget.data['events'] as List;
    final outcome  = CombatOutcome.values.byName(widget.data['outcome']);
    final gold     = widget.data['goldFound'] as int;
    final xp       = widget.data['xpGained'] as int;

    final outcomeColor = switch (outcome) {
      CombatOutcome.victory    => AshenColors.healthGreen,
      CombatOutcome.retreat    => AshenColors.recoverBlue,
      CombatOutcome.partyWiped => AshenColors.bloodRed,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AshenColors.surface,
        border: Border.all(color: AshenColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    color: AshenColors.border,
                    child: Center(
                      child: Text('${widget.index}',
                          style: AshenText.dim.copyWith(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.data['enemyNames'] as String,
                        style: AshenText.body),
                  ),
                  Text('+${gold}g  +${xp}xp',
                      style: AshenText.gold.copyWith(fontSize: 12)),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: outcomeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AshenColors.ashGrey,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Expanded event log
          if (_expanded)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AshenColors.border)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: events.map((e) {
                  final ev = e as Map<String, dynamic>;
                  final type = CombatEventType.values.byName(ev['type']);
                  return _EventLine(text: ev['text'] as String, type: type);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventLine extends StatelessWidget {
  final String text;
  final CombatEventType type;
  const _EventLine({required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    final (color, prefix) = switch (type) {
      CombatEventType.heroAttack    => (AshenColors.parchment, '  '),
      CombatEventType.enemyAttack   => (AshenColors.parchmentDim, '  '),
      CombatEventType.heroKill      => (AshenColors.healthGreen, '✓ '),
      CombatEventType.heroDown      => (AshenColors.bloodRed, '✗ '),
      CombatEventType.crit          => (AshenColors.gold, '★ '),
      CombatEventType.ability       => (AshenColors.copper, '⚡ '),
      CombatEventType.faithMiracle  => (AshenColors.copper, '✦ '),
      CombatEventType.loot          => (AshenColors.gold, '◆ '),
      CombatEventType.narrative     => (AshenColors.parchmentDim, '  '),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prefix, style: TextStyle(color: color, fontSize: 12)),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontStyle: type == CombatEventType.narrative ||
                            type == CombatEventType.faithMiracle
                        ? FontStyle.italic
                        : FontStyle.normal)),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AshenColors.surface,
          border: Border.all(color: AshenColors.border),
        ),
        child: child,
      );
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label,
              style: AshenText.dim.copyWith(fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      );
}
