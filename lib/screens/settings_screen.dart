import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../theme/colors.dart';
import '../theme/parchment_widgets.dart';
import 'character_creator_screen.dart';
import 'changelog_screen.dart';
import 'guide_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AshenColors.background,
      appBar: AppBar(
        backgroundColor: AshenColors.surface,
        title: const Text('SETTINGS',
            style: TextStyle(
                color: AshenColors.copper, letterSpacing: 4, fontSize: 14)),
        iconTheme: const IconThemeData(color: AshenColors.copper),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AshenColors.inkRed, AshenColors.border, Colors.transparent],
                stops: [0.0, 0.35, 1.0],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading('GAMEPLAY'),
            const SizedBox(height: 12),
            _PermadeathToggle(),
            const SizedBox(height: 24),
            const SectionHeading('AI PORTRAITS'),
            const SizedBox(height: 8),
            const Text(
              'Hero portraits are generated automatically when you recruit a new companion. '
              'They appear within a few seconds of recruitment.',
              style: AshenText.dim,
            ),
            const SizedBox(height: 12),
            _RegeneratePortraitsButton(),
            const InkRule(),
            const SectionHeading('INFORMATION'),
            const SizedBox(height: 12),
            _NavRow(
              label: 'In-Game Guide',
              subtitle: 'How to play, combat, classes, lore, and more.',
              icon: Icons.help_outline,
              onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const GuideScreen())),
            ),
            const SizedBox(height: 8),
            _NavRow(
              label: 'Changelog',
              subtitle: 'Release notes and patch history.',
              icon: Icons.history,
              onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ChangelogScreen())),
            ),
            const InkRule(),
            const SectionHeading('DANGER ZONE'),
            const SizedBox(height: 12),
            _HardResetButton(),
          ],
        ),
      ),
    );
  }
}

class _RegeneratePortraitsButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AshenColors.parchmentWarm, AshenColors.surface],
          stops: [0.0, 0.3],
        ),
        border: Border(
          left:   BorderSide(color: AshenColors.copper, width: 3),
          top:    BorderSide(color: AshenColors.border, width: 0.5),
          right:  BorderSide(color: AshenColors.border, width: 0.5),
          bottom: BorderSide(color: AshenColors.border, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Regenerate Portraits',
              style: AshenText.body.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(
            'Wipes all current hero portraits and generates fresh ones. '
            'Useful if images look wrong or are missing.',
            style: AshenText.dim,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AshenColors.copper,
                side: const BorderSide(color: AshenColors.copper),
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                ref.read(gameProvider.notifier).wipeAndRegeneratePortraits();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Portraits cleared. New images will appear shortly.',
                      style: TextStyle(color: AshenColors.parchment),
                    ),
                    backgroundColor: AshenColors.surface,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: const Text('REGENERATE ALL PORTRAITS',
                  style: TextStyle(letterSpacing: 1.5, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HardResetButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AshenColors.parchmentWarm, AshenColors.surface],
          stops: [0.0, 0.3],
        ),
        border: Border(
          left:   BorderSide(color: AshenColors.darkRed, width: 3),
          top:    const BorderSide(color: AshenColors.border, width: 0.5),
          right:  const BorderSide(color: AshenColors.border, width: 0.5),
          bottom: const BorderSide(color: AshenColors.border, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hard Reset',
              style: AshenText.body.copyWith(
                  fontWeight: FontWeight.bold, color: AshenColors.darkRed)),
          const SizedBox(height: 4),
          const Text(
            'Deletes all progress and returns to character creation. '
            'This cannot be undone.',
            style: AshenText.dim,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AshenColors.darkRed,
                side: const BorderSide(color: AshenColors.darkRed),
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () => _confirmReset(context, ref),
              child: const Text('RESET ALL PROGRESS',
                  style: TextStyle(letterSpacing: 1.5, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AshenColors.surface,
        title: Text('Reset everything?',
            style: AshenText.body
                .copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text(
          'All progress, heroes, gold, and properties will be permanently '
          'deleted. You will return to character creation.',
          style: AshenText.dim,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL',
                style: TextStyle(color: AshenColors.ashGrey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(gameProvider.notifier).hardReset();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const CharacterCreatorScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('RESET',
                style: TextStyle(color: AshenColors.darkRed)),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final void Function(BuildContext) onTap;
  const _NavRow({required this.label, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AshenColors.surface,
      child: InkWell(
        onTap: () => onTap(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              left:   BorderSide(color: AshenColors.border, width: 0.5),
              top:    BorderSide(color: AshenColors.border, width: 0.5),
              right:  BorderSide(color: AshenColors.border, width: 0.5),
              bottom: BorderSide(color: AshenColors.border, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AshenColors.copper, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AshenText.body.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AshenText.dim.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AshenColors.ashGrey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermadeathToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(gameProvider).permadeathEnabled;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AshenColors.parchmentWarm, AshenColors.surface],
          stops: [0.0, 0.3],
        ),
        border: Border(
          left:   BorderSide(color: AshenColors.inkRed, width: 3),
          top:    BorderSide(color: AshenColors.border, width: 0.5),
          right:  BorderSide(color: AshenColors.border, width: 0.5),
          bottom: BorderSide(color: AshenColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Permadeath',
                    style: AshenText.body.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                const Text(
                  'When enabled, heroes who fall in battle are gone forever.',
                  style: AshenText.dim,
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (v) =>
                ref.read(gameProvider.notifier).setPermadeath(v),
            activeThumbColor: AshenColors.darkRed,
            inactiveTrackColor: AshenColors.border,
          ),
        ],
      ),
    );
  }
}
