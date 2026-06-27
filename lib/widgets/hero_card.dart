import 'dart:io';
import 'package:flutter/material.dart' hide Hero;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/hero.dart';
import '../models/enums.dart';
import '../theme/colors.dart';

class HeroCard extends StatelessWidget {
  final Hero hero;
  final VoidCallback? onTap;
  final bool selected;

  const HeroCard({
    super.key,
    required this.hero,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (hero.status) {
      HeroStatus.active     => AshenColors.healthGreen,
      HeroStatus.recovering => AshenColors.recoverBlue,
      HeroStatus.dead       => AshenColors.deadGrey,
    };

    final healthPct = hero.currentHealth / hero.maxHealth;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AshenColors.parchmentWarm,
              selected ? AshenColors.surfaceAlt : AshenColors.surface,
            ],
            stops: const [0.0, 0.25],
          ),
          border: Border(
            left: BorderSide(
              color: selected ? AshenColors.copper : AshenColors.inkRed,
              width: selected ? 3.0 : 2.5,
            ),
            top:    const BorderSide(color: AshenColors.border, width: 0.5),
            right:  const BorderSide(color: AshenColors.border, width: 0.5),
            bottom: const BorderSide(color: AshenColors.border, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-body portrait — tap to expand
            _PortraitColumn(hero: hero),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + status badge
                  Row(
                    children: [
                      if (hero.isPlayerCharacter)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Text('★',
                              style: TextStyle(
                                  color: AshenColors.gold, fontSize: 12)),
                        ),
                      Expanded(
                        child: Text(hero.name,
                            style: AshenText.body
                                .copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        color: statusColor.withAlpha(50),
                        child: Text(
                          _statusLabel(hero),
                          style: TextStyle(color: statusColor, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Class · Level · Faith
                  Text(
                    '${_className(hero.heroClass)}  ·  Lv ${hero.level}'
                    '  ·  ${_faithName(hero.faith)}',
                    style: AshenText.dim,
                  ),
                  const SizedBox(height: 8),

                  // Health bar
                  Row(
                    children: [
                      const Text('HP  ', style: AshenText.dim),
                      Expanded(
                        child: ClipRect(
                          child: LinearProgressIndicator(
                            value: healthPct,
                            minHeight: 6,
                            backgroundColor: AshenColors.border,
                            valueColor: AlwaysStoppedAnimation(
                              healthPct > 0.5
                                  ? AshenColors.healthGreen
                                  : healthPct > 0.25
                                      ? Colors.orange
                                      : AshenColors.bloodRed,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${hero.currentHealth}/${hero.maxHealth}',
                          style: AshenText.dim),
                    ],
                  ),

                  // Mana bar (casters only)
                  if (hero.heroClass.isCaster && hero.maxMana > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('MP  ', style: AshenText.dim),
                        Expanded(
                          child: ClipRect(
                            child: LinearProgressIndicator(
                              value: (hero.currentMana / hero.maxMana)
                                  .clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: AshenColors.border,
                              valueColor: const AlwaysStoppedAnimation(
                                  AshenColors.manaBlue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${hero.currentMana}/${hero.maxMana}',
                            style: AshenText.dim),
                      ],
                    ),
                  ],

                  // Recovery countdown
                  if (hero.status == HeroStatus.recovering)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Recovering — ${_formatTime(hero.recoverySecondsRemaining)}',
                        style: const TextStyle(
                            color: AshenColors.recoverBlue, fontSize: 11),
                      ),
                    ),

                  const SizedBox(height: 8),
                  _StatsRow(hero: hero),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(Hero h) => switch (h.status) {
        HeroStatus.active     => 'READY',
        HeroStatus.recovering => 'HEALING',
        HeroStatus.dead       => 'DEAD',
      };

  String _className(HeroClass c) => switch (c) {
        HeroClass.knight      => 'Knight',
        HeroClass.ranger      => 'Ranger',
        HeroClass.priest      => 'Priest',
        HeroClass.mage        => 'Mage',
        HeroClass.rogue       => 'Rogue',
        HeroClass.necromancer => 'Necromancer',
        HeroClass.warlock     => 'Warlock',
      };

  String _faithName(FaithType? f) => switch (f) {
        FaithType.luminantChurch   => 'Luminant Church',
        FaithType.oldWays          => 'Old Ways',
        FaithType.paleCourt        => 'Pale Court',
        FaithType.compactOfSaints  => 'Compact of Saints',
        FaithType.ashenRite        => 'Ashen Rite',
        null                       => 'No Faith',
      };

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }
}

// ─── PORTRAIT COLUMN ─────────────────────────────────────────────────────────
// Sits on the left of the card. Shows the full-body image or a styled
// placeholder while generation is in progress.

class _PortraitColumn extends StatelessWidget {
  final Hero hero;
  const _PortraitColumn({required this.hero});

  // Portrait dimensions — 2:3 ratio to match the generation aspect ratio.
  static const double _w = 88;
  static const double _h = 132;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // opaque behaviour ensures this detector wins the arena over the outer
      // card GestureDetector so the expand always fires when tapping the portrait
      behavior: HitTestBehavior.opaque,
      onTap: hero.imageUrl != null ? () => _expand(context) : null,
      child: SizedBox(
        width: _w,
        height: _h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image or placeholder
            ClipRect(child: _image()),

            // Expand hint — only when image is ready
            if (hero.imageUrl != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  color: Colors.black87,
                  child: const Icon(Icons.open_in_full,
                      color: AshenColors.copper, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    if (hero.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: hero.imageUrl!,
        width: _w,
        height: _h,
        fit: BoxFit.cover,
        placeholder: (_, _) => _placeholder(loading: true),
        errorWidget: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder(loading: true);
  }

  Widget _placeholder({bool loading = false}) {
    final color = _classColor(hero.heroClass);
    return Container(
      color: color.withAlpha(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: color.withAlpha(180),
              ),
            )
          else
            Text(
              _classInitial(hero.heroClass),
              style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 6),
          Text(
            loading ? 'Painting...' : _classShort(hero.heroClass),
            style: TextStyle(color: color.withAlpha(160), fontSize: 9),
          ),
        ],
      ),
    );
  }

  void _expand(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      barrierLabel: 'Close',
      transitionDuration: const Duration(milliseconds: 180),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: child,
      ),
      pageBuilder: (ctx, _, __) => _FullBodyViewer(hero: hero),
    );
  }

  Color _classColor(HeroClass c) => switch (c) {
        HeroClass.knight      => const Color(0xFF6B8CBA),
        HeroClass.ranger      => const Color(0xFF5A8A5A),
        HeroClass.priest      => const Color(0xFFD4AF37),
        HeroClass.mage        => const Color(0xFF9B59B6),
        HeroClass.rogue       => const Color(0xFF4A4535),
        HeroClass.necromancer => const Color(0xFF7D3C98),
        HeroClass.warlock     => const Color(0xFF8B0000),
      };

  String _classInitial(HeroClass c) => switch (c) {
        HeroClass.knight      => 'K',
        HeroClass.ranger      => 'R',
        HeroClass.priest      => 'P',
        HeroClass.mage        => 'M',
        HeroClass.rogue       => 'Rg',
        HeroClass.necromancer => 'N',
        HeroClass.warlock     => 'W',
      };

  String _classShort(HeroClass c) => switch (c) {
        HeroClass.knight      => 'Knight',
        HeroClass.ranger      => 'Ranger',
        HeroClass.priest      => 'Priest',
        HeroClass.mage        => 'Mage',
        HeroClass.rogue       => 'Rogue',
        HeroClass.necromancer => 'Necromancer',
        HeroClass.warlock     => 'Warlock',
      };
}

// ─── FULL-BODY VIEWER ────────────────────────────────────────────────────────

class _FullBodyViewer extends StatefulWidget {
  final Hero hero;
  const _FullBodyViewer({required this.hero});

  @override
  State<_FullBodyViewer> createState() => _FullBodyViewerState();
}

class _FullBodyViewerState extends State<_FullBodyViewer> {
  _SaveState _saveState = _SaveState.idle;
  String? _savedPath;

  Future<void> _savePortrait() async {
    if (_saveState == _SaveState.saving) return;
    setState(() => _saveState = _SaveState.saving);

    try {
      final url = widget.hero.imageUrl!;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception('download failed');

      final baseDir = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final saveDir =
          Directory('${baseDir.path}${Platform.pathSeparator}The Ashen Road${Platform.pathSeparator}Portraits');
      await saveDir.create(recursive: true);

      final safeName = widget.hero.name
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(' ', '_')
          .toLowerCase();
      final ext = Uri.parse(url).path.split('.').last.isNotEmpty
          ? Uri.parse(url).path.split('.').last
          : 'webp';
      final file = File(
          '${saveDir.path}${Platform.pathSeparator}${safeName}_portrait.$ext');
      await file.writeAsBytes(response.bodyBytes);

      if (mounted) {
        setState(() {
          _saveState = _SaveState.done;
          _savedPath = file.path;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _saveState = _SaveState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hero = widget.hero;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.black87,
        child: SafeArea(
          child: Column(
            children: [
              // Header bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    if (hero.isPlayerCharacter)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text('★',
                            style: TextStyle(
                                color: AshenColors.gold, fontSize: 14)),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hero.name,
                              style: AshenText.heading.copyWith(fontSize: 20)),
                          Text(
                            '${_className(hero.heroClass)}  ·  '
                            'Level ${hero.level}  ·  '
                            '${_faithName(hero.faith)}',
                            style: AshenText.dim,
                          ),
                        ],
                      ),
                    ),
                    // Save button
                    GestureDetector(
                      onTap: _savePortrait,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _saveState == _SaveState.saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: AshenColors.copper, strokeWidth: 1.5),
                              )
                            : Icon(
                                _saveState == _SaveState.done
                                    ? Icons.check
                                    : Icons.download,
                                color: _saveState == _SaveState.error
                                    ? AshenColors.bloodRed
                                    : AshenColors.copper,
                                size: 20,
                              ),
                      ),
                    ),
                    const Icon(Icons.close,
                        color: AshenColors.ashGrey, size: 20),
                  ],
                ),
              ),

              // Full-body image — BoxFit.contain shows the whole figure
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: hero.imageUrl!,
                      fit: BoxFit.contain,
                      placeholder: (_, _) => const Center(
                        child: CircularProgressIndicator(
                            color: AshenColors.copper, strokeWidth: 1.5),
                      ),
                      errorWidget: (_, _, _) => const Center(
                        child: Icon(Icons.broken_image,
                            color: AshenColors.ashGrey, size: 48),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: _saveState == _SaveState.done && _savedPath != null
                      ? Text(
                          'Saved to $_savedPath',
                          style: AshenText.dim.copyWith(
                              fontSize: 10, color: AshenColors.copper),
                          textAlign: TextAlign.center,
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(color: AshenColors.copper, width: 1),
                            ),
                          ),
                          child: Text(
                            'Tap anywhere to close',
                            style: AshenText.dim.copyWith(fontSize: 11),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
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

  String _faithName(FaithType? f) => switch (f) {
        FaithType.luminantChurch   => 'Luminant Church',
        FaithType.oldWays          => 'Old Ways',
        FaithType.paleCourt        => 'Pale Court',
        FaithType.compactOfSaints  => 'Compact of Saints',
        FaithType.ashenRite        => 'Ashen Rite',
        null                       => 'No Faith',
      };
}

enum _SaveState { idle, saving, done, error }

// ─── STATS ROW ───────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Hero hero;
  const _StatsRow({required this.hero});

  @override
  Widget build(BuildContext context) {
    final s = hero.effectiveStats;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _stat('STR', s.strength),
        _stat('DEX', s.dexterity),
        _stat('END', s.endurance),
        _stat('INT', s.intelligence),
        _stat('FTH', s.faith),
        _stat('LCK', s.luck),
      ],
    );
  }

  Widget _stat(String label, int value) => Column(
        children: [
          Text(label, style: AshenText.dim.copyWith(fontSize: 10)),
          Text('$value', style: AshenText.body.copyWith(fontSize: 13)),
        ],
      );
}
