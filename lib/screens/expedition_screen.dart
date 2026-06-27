import 'dart:math' show min, cos, sin;
import 'package:flutter/material.dart' hide Hero;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../theme/colors.dart';
import '../models/world_location.dart';
import '../models/enums.dart';
import '../models/hero.dart';
import '../models/expedition.dart';
import '../utils/location_generator.dart';
import '../widgets/hero_card.dart';
import '../state/game_notifier.dart';

// ─── MAIN EXPEDITION SCREEN ──────────────────────────────────────────────────

class ExpeditionScreen extends ConsumerWidget {
  const ExpeditionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _WorldMapView();
  }
}

// ─── WORLD MAP VIEW ───────────────────────────────────────────────────────────

class _WorldMapView extends ConsumerStatefulWidget {
  const _WorldMapView();

  @override
  ConsumerState<_WorldMapView> createState() => _WorldMapViewState();
}

class _WorldMapViewState extends ConsumerState<_WorldMapView> {
  late final TransformationController _transform;
  Size? _lastViewportSize;

  static const double _worldW = 1740;
  static const double _worldH = 1000;

  @override
  void initState() {
    super.initState();
    _transform = TransformationController();
  }

  void _initTransform(double vw, double vh) {
    final size = Size(vw, vh);
    if (_lastViewportSize == size) return;
    _lastViewportSize = size;
    // Fit the whole map in the viewport at 90% of available space.
    final s = min(vw / _worldW, vh / _worldH) * 0.9;
    final dx = (vw - _worldW * s) / 2;
    final dy = (vh - _worldH * s) / 2;
    _transform.value = Matrix4.identity()..translate(dx, dy)..scale(s);
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final worldMap    = ref.watch(worldMapProvider);
    final expedition  = ref.watch(expeditionProvider);
    final partyReturn = ref.watch(gameProvider.select((s) => s.partyReturn));
    final party       = ref.watch(partyProvider);
    final available   = party.where((h) => h.isAvailable).toList();
    final partyAvgLevel = available.isNotEmpty
        ? available.map((h) => h.level).reduce((a, b) => a + b) / available.length
        : party.isNotEmpty
            ? party.map((h) => h.level).reduce((a, b) => a + b) / party.length
            : 1.0;

    // Compute party marker position in the 1400×1000 map coordinate space.
    // Ashenvale (150, 500) is the home anchor all travel originates from.
    const homePos = Offset(150.0, 500.0);
    Offset? markerPos;

    if (expedition != null && !expedition.isComplete) {
      final dest = worldMap
          .where((l) => l.id == expedition.worldLocationId)
          .firstOrNull;
      if (dest != null) {
        final destOffset = Offset(dest.x, dest.y);
        markerPos = expedition.isTraveling
            ? Offset.lerp(homePos, destOffset, expedition.travelProgress)!
            : destOffset;
      }
    } else if (expedition != null && expedition.isComplete && expedition.worldLocationId != null) {
      // Party stays at the destination until the player acts (leaveTown etc.)
      final dest = worldMap
          .where((l) => l.id == expedition.worldLocationId)
          .firstOrNull;
      if (dest != null) markerPos = Offset(dest.x, dest.y);
    } else if (partyReturn != null) {
      // Return animation only plays after leaveTown()
      markerPos = Offset.lerp(
        homePos,
        Offset(partyReturn.destX, partyReturn.destY),
        partyReturn.returnProgress,
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AshenColors.surface,
          child: Row(
            children: [
              const Text('THE ASHEN ROAD', style: AshenText.heading),
              const Spacer(),
              if (expedition != null && !expedition.isComplete)
                Text(
                  expedition.isTraveling ? 'TRAVELING' : 'EXPLORING',
                  style: AshenText.dim.copyWith(fontSize: 10, letterSpacing: 1.5),
                )
              else
                Text(
                  '${worldMap.where((l) => l.discovered).length}/${worldMap.length} discovered',
                  style: AshenText.dim.copyWith(fontSize: 11),
                ),
            ],
          ),
        ),
        const Divider(color: AshenColors.border, height: 1),

        // Map
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              _initTransform(constraints.maxWidth, constraints.maxHeight);
              return InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                minScale: 0.1,
                maxScale: 4.0,
                transformationController: _transform,
                child: SizedBox(
                  width: _worldW,
                  height: _worldH,
                  child: Stack(
                    children: [
                      // Painted map (terrain, roads, fog — all from CustomPainter)
                      CustomPaint(
                        size: const Size(_worldW, _worldH),
                        painter: _MapPainter(worldMap: worldMap),
                      ),

                      // Location marker widgets (tap targets sit above the paint layer)
                      ...worldMap.map(
                        (loc) => Positioned(
                          left: loc.x - 14,
                          top: loc.y - 14,
                          child: GestureDetector(
                            onTap: loc.discovered
                                ? () => _onLocationTap(context, loc)
                                : null,
                            child: _LocationMarker(
                              location: loc,
                              locked: loc.discovered &&
                                  loc.minPartyLevel > partyAvgLevel,
                            ),
                          ),
                        ),
                      ),

                      // Party marker — follows the travel/return animation.
                      if (markerPos != null)
                        Positioned(
                          left: markerPos.dx - 11,
                          top: markerPos.dy - 32,
                          child: const _PartyMarker(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onLocationTap(BuildContext context, WorldLocation loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AshenColors.surface,
      shape: const Border(top: BorderSide(color: AshenColors.border)),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) =>
            _LocationSheet(location: loc, scrollController: scrollController),
      ),
    );
  }
}

// ─── MAP PAINTER ─────────────────────────────────────────────────────────────

const _spineIds = ['ashenvale', 'dunford', 'greywater', 'ironwall', 'grimhaven', 'ash_breach', 'void_spire'];

class _MapPainter extends CustomPainter {
  final List<WorldLocation> worldMap;
  const _MapPainter({required this.worldMap});

  // Sepia ink palette for terrain symbols
  static const _inkDark   = Color(0xFF2E2010);
  static const _inkMid    = Color(0xFF5A4228);
  static const _inkForest = Color(0xFF2D3A20);
  static const _inkStone  = Color(0xFF504438);
  static const _inkVoid   = Color(0xFF100C08);

  @override
  void paint(Canvas canvas, Size size) {
    // ── PARCHMENT BASE ──────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFCDB882),
    );

    // ── TERRAIN ZONE GRADIENTS ──────────────────────────────────
    // Subtle color bands: grey-green west → warm brown centre → ash-grey east
    final zones = [
      (0.0,    350.0,  const Color(0x20445A30)),  // living land — green tint
      (300.0,  650.0,  const Color(0x10604828)),  // transitional — warm brown
      (580.0,  950.0,  const Color(0x20585048)),  // blighted — grey
      (880.0,  1250.0, const Color(0x38302820)),  // deep blight — dark ash
      (1150.0, 1520.0, const Color(0x48201808)),  // void fringe — near black
      (1400.0, 1740.0, const Color(0x60100808)),  // far waste — void dark
    ];
    for (final (x1, x2, color) in zones) {
      final rect = Rect.fromLTWH(x1, 0, x2 - x1, size.height);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            colors: [color.withValues(alpha: 0), color, color.withValues(alpha: 0)],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(rect),
      );
    }

    // Eastern void darkness — hard fade at far right
    canvas.drawRect(
      Rect.fromLTWH(size.width - 350, 0, 350, size.height),
      Paint()
        ..shader = LinearGradient(
          colors: const [Color(0x00000000), Color(0x66100808)],
        ).createShader(Rect.fromLTWH(size.width - 350, 0, 350, size.height)),
    );

    // Soft vignette around edges
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.82,
          colors: [const Color(0x00000000), const Color(0x44000000)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final locationMap = {for (final l in worldMap) l.id: l};

    // ── TERRAIN SYMBOLS ─────────────────────────────────────────
    // Drawn first so roads and markers render on top.
    for (final loc in worldMap) {
      _drawTerrainSymbol(canvas, loc);
    }

    // ── BRANCH PATHS ────────────────────────────────────────────
    final drawn = <String>{};
    for (final loc in worldMap) {
      for (final connId in loc.connectedIds) {
        if (_spineIds.contains(loc.id) && _spineIds.contains(connId)) continue;
        final key = ([loc.id, connId]..sort()).join('-');
        if (drawn.contains(key)) continue;
        drawn.add(key);
        final conn = locationMap[connId];
        if (conn == null) continue;
        canvas.drawLine(
          Offset(loc.x, loc.y),
          Offset(conn.x, conn.y),
          Paint()
            ..color = loc.discovered && conn.discovered
                ? const Color(0x1C5A4220)
                : const Color(0x0D3C301C)
            ..strokeWidth = 1.0
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // ── ASHEN ROAD SPINE ───────────────────────────────────────
    for (var i = 0; i < _spineIds.length - 1; i++) {
      final a = locationMap[_spineIds[i]];
      final b = locationMap[_spineIds[i + 1]];
      if (a == null || b == null) continue;
      if (a.discovered && b.discovered) {
        // Outer track
        canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y),
            Paint()..color = const Color(0xDD8B6830)..strokeWidth = 10.0..strokeCap = StrokeCap.round);
        // Road surface
        canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y),
            Paint()..color = const Color(0xFFD4A84A)..strokeWidth = 6.0..strokeCap = StrokeCap.round);
        // Worn centre rut
        canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y),
            Paint()..color = const Color(0xFF3A2810)..strokeWidth = 2.0..strokeCap = StrokeCap.round);
      } else {
        canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y),
            Paint()..color = const Color(0x443A2E1E)..strokeWidth = 5.0..strokeCap = StrokeCap.round);
      }
    }

    // ── ROAD LABEL ─────────────────────────────────────────────
    final discoveredSpineCount = _spineIds
        .map((id) => locationMap[id])
        .whereType<WorldLocation>()
        .where((l) => l.discovered)
        .length;
    if (discoveredSpineCount >= 2) {
      final tp = TextPainter(
        text: const TextSpan(
          text: '— THE ASHEN ROAD —',
          style: TextStyle(
            color: Color(0xAA5A3E10),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, 524));
    }

    // ── FOG OF WAR ─────────────────────────────────────────────
    for (final loc in worldMap.where((l) => !l.discovered)) {
      canvas.drawCircle(
        Offset(loc.x, loc.y),
        52,
        Paint()
          ..color = const Color(0xEE181008)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
    }

    // ── DIRECTION LABELS ────────────────────────────────────────
    _drawLabel(canvas, '← WEST',   const Offset(20,   970), 10, const Color(0x885A3E10));
    _drawLabel(canvas, 'EAST →', Offset(size.width - 90, 970), 10, const Color(0x885A3E10));
  }

  // ── TERRAIN SYMBOL DRAWING ──────────────────────────────────

  void _drawTerrainSymbol(Canvas canvas, WorldLocation loc) {
    switch (loc.type) {
      case LocationType.wilderness: _drawTrees(canvas, loc.x, loc.y);
      case LocationType.castle:     _drawTower(canvas, loc.x, loc.y);
      case LocationType.ruins:      _drawRuins(canvas, loc.x, loc.y);
      case LocationType.dungeon:    _drawCave(canvas, loc.x, loc.y);
      case LocationType.monastery:  _drawCross(canvas, loc.x, loc.y);
      case LocationType.town:       _drawSettlement(canvas, loc.x, loc.y);
      case LocationType.cemetery:   _drawCemetery(canvas, loc.x, loc.y);
      case LocationType.library:    _drawLibraryArch(canvas, loc.x, loc.y);
      case LocationType.forge:      _drawForge(canvas, loc.x, loc.y);
      case LocationType.church:     _drawChurch(canvas, loc.x, loc.y);
      case LocationType.shrine:     _drawShrine(canvas, loc.x, loc.y);
      case LocationType.cultSite:   _drawCultSite(canvas, loc.x, loc.y);
    }
  }

  void _drawTrees(Canvas canvas, double x, double y) {
    final fill = Paint()..color = _inkForest..style = PaintingStyle.fill;
    final trunk = Paint()..color = _inkDark..style = PaintingStyle.fill;
    for (final (dx, dy, s) in [
      (-12.0, 7.0, 0.85), (0.0, -3.0, 1.1), (12.0, 7.0, 0.85)
    ]) {
      final path = Path()
        ..moveTo(x + dx, y + dy - 12 * s)
        ..lineTo(x + dx - 7 * s, y + dy + 5 * s)
        ..lineTo(x + dx + 7 * s, y + dy + 5 * s)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x + dx, y + dy + 7 * s), width: 2.5, height: 4),
        trunk,
      );
    }
  }

  void _drawTower(Canvas canvas, double x, double y) {
    final fill    = Paint()..color = _inkStone..style = PaintingStyle.fill;
    final outline = Paint()..color = _inkDark..style = PaintingStyle.stroke..strokeWidth = 1.2;
    canvas.drawRect(Rect.fromLTWH(x - 6, y - 7, 12, 20), fill);
    canvas.drawRect(Rect.fromLTWH(x - 6, y - 7, 12, 20), outline);
    // Battlements
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(x - 7 + i * 5, y - 12, 3.5, 5), fill);
    }
    // Arrow-slit window
    canvas.drawRect(
      Rect.fromCenter(center: Offset(x, y + 1), width: 2.5, height: 5),
      Paint()..color = _inkVoid..style = PaintingStyle.fill,
    );
  }

  void _drawRuins(Canvas canvas, double x, double y) {
    final p = Paint()
      ..color = _inkMid
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // Left pillar (tall, intact)
    canvas.drawLine(Offset(x - 9, y + 13), Offset(x - 9, y - 5), p);
    // Right pillar (shorter, broken)
    canvas.drawLine(Offset(x + 9, y + 13), Offset(x + 9, y + 3), p);
    // Partial lintel — only left half remains
    canvas.drawLine(Offset(x - 9, y - 5), Offset(x + 1, y - 7), p);
    // Rubble dots
    final dot = Paint()..color = _inkMid..style = PaintingStyle.fill;
    for (final (dx, dy) in [(-4.0, 15.0), (2.0, 14.0), (7.0, 16.0)]) {
      canvas.drawCircle(Offset(x + dx, y + dy), 1.5, dot);
    }
  }

  void _drawCave(Canvas canvas, double x, double y) {
    final dark = Paint()..color = _inkVoid..style = PaintingStyle.fill;
    final edge = Paint()..color = _inkDark..strokeWidth = 1.8..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(x - 12, y + 8)
      ..lineTo(x - 12, y)
      ..quadraticBezierTo(x - 12, y - 10, x, y - 10)
      ..quadraticBezierTo(x + 12, y - 10, x + 12, y)
      ..lineTo(x + 12, y + 8)
      ..close();
    canvas.drawPath(path, dark);
    canvas.drawPath(path, edge);
    canvas.drawLine(Offset(x - 15, y + 8), Offset(x + 15, y + 8), edge);
  }

  void _drawCross(Canvas canvas, double x, double y) {
    final p = Paint()
      ..color = _inkMid
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x, y - 14), Offset(x, y + 12), p);
    canvas.drawLine(Offset(x - 7, y - 5), Offset(x + 7, y - 5), p);
  }

  void _drawSettlement(Canvas canvas, double x, double y) {
    final fill    = Paint()..color = _inkMid..style = PaintingStyle.fill;
    final outline = Paint()..color = _inkDark..strokeWidth = 1.0..style = PaintingStyle.stroke;
    for (final (dx, w, h) in [(-11.0, 8.0, 10.0), (0.0, 10.0, 14.0), (11.0, 8.0, 10.0)]) {
      final body = Rect.fromLTWH(x + dx - w / 2, y + 4 - h, w, h);
      canvas.drawRect(body, fill);
      canvas.drawRect(body, outline);
      final roofH = w == 10.0 ? 6.0 : 4.0;
      final roof = Path()
        ..moveTo(x + dx - w / 2 - 1, y + 4 - h)
        ..lineTo(x + dx, y + 4 - h - roofH)
        ..lineTo(x + dx + w / 2 + 1, y + 4 - h)
        ..close();
      canvas.drawPath(roof, fill);
      canvas.drawPath(roof, outline);
    }
  }

  void _drawCemetery(Canvas canvas, double x, double y) {
    final stroke = Paint()
      ..color = _inkMid
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = _inkMid..style = PaintingStyle.fill;
    for (final (dx, dy) in [(-10.0, 1.0), (0.0, -3.0), (10.0, 1.0)]) {
      canvas.drawLine(Offset(x + dx, y + dy - 8), Offset(x + dx, y + dy + 5), stroke);
      canvas.drawLine(Offset(x + dx - 3.5, y + dy - 3), Offset(x + dx + 3.5, y + dy - 3), stroke);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + dx, y + dy + 8), width: 10, height: 4),
        fill,
      );
    }
  }

  void _drawLibraryArch(Canvas canvas, double x, double y) {
    final fill   = Paint()..color = _inkStone..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = _inkDark
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    // Two pillars
    canvas.drawRect(Rect.fromLTWH(x - 12, y - 6, 4, 17), fill);
    canvas.drawRect(Rect.fromLTWH(x + 8, y - 6, 4, 17), fill);
    // Arch
    final arch = Path()
      ..moveTo(x - 10, y - 6)
      ..quadraticBezierTo(x, y - 18, x + 10, y - 6);
    canvas.drawPath(arch, stroke);
    // Lintel block
    canvas.drawRect(Rect.fromLTWH(x - 10, y - 8, 20, 2), fill);
    // Book-stack on base (horizontal slabs)
    canvas.drawRect(Rect.fromLTWH(x - 5, y + 9, 10, 2), fill);
    canvas.drawRect(Rect.fromLTWH(x - 4, y + 6, 8, 3), fill);
    canvas.drawRect(Rect.fromLTWH(x - 3, y + 3, 6, 3), fill);
  }

  void _drawForge(Canvas canvas, double x, double y) {
    final darkFill  = Paint()..color = _inkDark..style = PaintingStyle.fill;
    final flameFill = Paint()..color = const Color(0xFF7A3818)..style = PaintingStyle.fill;
    // Anvil horn + body
    final anvil = Path()
      ..moveTo(x - 10, y + 2)
      ..lineTo(x - 10, y - 2)
      ..lineTo(x - 14, y - 6)
      ..lineTo(x - 8, y - 8)
      ..lineTo(x + 10, y - 8)
      ..lineTo(x + 10, y - 2)
      ..lineTo(x + 8, y + 2)
      ..close();
    canvas.drawPath(anvil, darkFill);
    // Base
    canvas.drawRect(Rect.fromLTWH(x - 7, y + 2, 15, 3), darkFill);
    canvas.drawRect(Rect.fromLTWH(x - 5, y + 5, 11, 3), darkFill);
    // Two flame wisps rising above
    final f1 = Path()
      ..moveTo(x - 2, y - 10)
      ..quadraticBezierTo(x - 5, y - 16, x - 1, y - 20)
      ..quadraticBezierTo(x + 3, y - 15, x, y - 10)
      ..close();
    canvas.drawPath(f1, flameFill);
    final f2 = Path()
      ..moveTo(x + 3, y - 9)
      ..quadraticBezierTo(x + 5, y - 15, x + 8, y - 17)
      ..quadraticBezierTo(x + 9, y - 12, x + 5, y - 9)
      ..close();
    canvas.drawPath(f2, flameFill);
  }

  void _drawChurch(Canvas canvas, double x, double y) {
    final fill   = Paint()..color = _inkStone..style = PaintingStyle.fill;
    final stroke = Paint()..color = _inkDark..strokeWidth = 1.3..style = PaintingStyle.stroke;
    // Nave body
    canvas.drawRect(Rect.fromLTWH(x - 9, y - 2, 18, 15), fill);
    canvas.drawRect(Rect.fromLTWH(x - 9, y - 2, 18, 15), stroke);
    // Pitched roof
    final roof = Path()
      ..moveTo(x - 10, y - 2)
      ..lineTo(x, y - 10)
      ..lineTo(x + 10, y - 2)
      ..close();
    canvas.drawPath(roof, fill);
    canvas.drawPath(roof, stroke);
    // Bell tower (left)
    canvas.drawRect(Rect.fromLTWH(x - 13, y - 8, 7, 21), fill);
    canvas.drawRect(Rect.fromLTWH(x - 13, y - 8, 7, 21), stroke);
    // Cross atop tower
    final crossC = Paint()..color = _inkDark..strokeWidth = 1.5..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x - 9.5, y - 18), Offset(x - 9.5, y - 10), crossC);
    canvas.drawLine(Offset(x - 12, y - 15), Offset(x - 7, y - 15), crossC);
  }

  void _drawShrine(Canvas canvas, double x, double y) {
    final fill   = Paint()..color = _inkMid..style = PaintingStyle.fill;
    final stroke = Paint()..color = _inkDark..strokeWidth = 1.5..style = PaintingStyle.stroke;
    // Central standing stone
    canvas.drawRect(Rect.fromLTWH(x - 3, y - 14, 6, 22), fill);
    canvas.drawRect(Rect.fromLTWH(x - 3, y - 14, 6, 22), stroke);
    // Rounded top
    canvas.drawOval(Rect.fromLTWH(x - 3, y - 17, 6, 6), fill);
    canvas.drawOval(Rect.fromLTWH(x - 3, y - 17, 6, 6), stroke);
    // Two flanking smaller stones
    canvas.drawRect(Rect.fromLTWH(x - 14, y - 7, 4, 15), fill);
    canvas.drawRect(Rect.fromLTWH(x - 14, y - 7, 4, 15), stroke);
    canvas.drawRect(Rect.fromLTWH(x + 10, y - 7, 4, 15), fill);
    canvas.drawRect(Rect.fromLTWH(x + 10, y - 7, 4, 15), stroke);
    // Rune spiral on central stone
    canvas.drawArc(
      Rect.fromCenter(center: Offset(x, y - 2), width: 5, height: 5),
      0, 5, false,
      Paint()..color = _inkVoid..strokeWidth = 1.0..style = PaintingStyle.stroke,
    );
  }

  void _drawCultSite(Canvas canvas, double x, double y) {
    final voidFill = Paint()..color = const Color(0xFF4A2060)..style = PaintingStyle.fill;
    final stroke   = Paint()..color = _inkVoid..strokeWidth = 1.3..style = PaintingStyle.stroke;
    // Circle of ritual stones (5 points)
    const radius = 11.0;
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * 3.14159 / 5) - 3.14159 / 2;
      final sx = x + radius * cos(angle);
      final sy = y + radius * sin(angle);
      canvas.drawRect(Rect.fromCenter(center: Offset(sx, sy), width: 3.5, height: 7), voidFill);
    }
    // Central void symbol — concentric rings
    canvas.drawCircle(Offset(x, y), 4.5, Paint()..color = _inkVoid..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(x, y), 6.5, stroke);
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, double size, Color color) {
    (TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, letterSpacing: 2)),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, pos);
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.worldMap != worldMap;
}

// ─── PARTY MARKER ────────────────────────────────────────────────────────────

class _PartyMarker extends ConsumerWidget {
  const _PartyMarker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final party = ref.watch(gameProvider.select((s) => s.party));
    final active = party.where((h) => h.status == HeroStatus.active).toList();
    Color markerColor = const Color(0xFFD4A84A); // default gold
    if (active.isNotEmpty) {
      final avgHpPct = active.fold(0.0, (sum, h) => sum + h.currentHealth / h.maxHealth) / active.length;
      if (avgHpPct < 0.4) {
        markerColor = const Color(0xFFCC3333); // red
      } else if (avgHpPct < 0.7) {
        markerColor = const Color(0xFFCC8833); // orange
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2E2010), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: markerColor.withAlpha(170),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text('⚔', style: TextStyle(fontSize: 11, height: 1.1)),
          ),
        ),
        Container(width: 2, height: 8, color: markerColor),
        Container(
          width: 6,
          height: 3,
          decoration: BoxDecoration(
            color: markerColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ─── LOCATION MARKER ─────────────────────────────────────────────────────────

class _LocationMarker extends StatelessWidget {
  final WorldLocation location;
  final bool locked;
  const _LocationMarker({required this.location, this.locked = false});

  @override
  Widget build(BuildContext context) {
    if (!location.discovered) {
      return SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2418),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3A3020), width: 1),
            ),
          ),
        ),
      );
    }

    final color = locked
        ? const Color(0xFF5A5048)
        : _typeColor(location.type);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withAlpha(locked ? 15 : 30),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: locked ? 1 : 2),
              ),
              child: Center(
                child: Text(
                  locked ? '🔒' : _typeSymbol(location.type),
                  style: TextStyle(fontSize: locked ? 10 : 12),
                ),
              ),
            ),
            if (locked)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1408),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF5A4830), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '${location.minPartyLevel}',
                      style: const TextStyle(
                        fontSize: 6.5,
                        color: Color(0xFFB89A60),
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 90,
          child: Text(
            location.name,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(color: Colors.black, blurRadius: 4),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _typeColor(LocationType t) => switch (t) {
        LocationType.town       => const Color(0xFFD4AF37),
        LocationType.dungeon    => const Color(0xFF8B0000),
        LocationType.castle     => const Color(0xFFB87333),
        LocationType.wilderness => const Color(0xFF3A6B35),
        LocationType.ruins      => const Color(0xFF4A4535),
        LocationType.monastery  => const Color(0xFF2E5C8A),
        LocationType.cemetery   => const Color(0xFF7A6580),
        LocationType.library    => const Color(0xFF4A6870),
        LocationType.forge      => const Color(0xFFB04820),
        LocationType.church     => const Color(0xFFD4AF37),
        LocationType.shrine     => const Color(0xFF5A8A4A),
        LocationType.cultSite   => const Color(0xFF6A3080),
      };

  String _typeSymbol(LocationType t) => switch (t) {
        LocationType.town       => '⌂',
        LocationType.dungeon    => '☠',
        LocationType.castle     => '♜',
        LocationType.wilderness => '♣',
        LocationType.ruins      => '∆',
        LocationType.monastery  => '✝',
        LocationType.cemetery   => '†',
        LocationType.library    => '📜',
        LocationType.forge      => '🔥',
        LocationType.church     => '⛪',
        LocationType.shrine     => '◎',
        LocationType.cultSite   => '✦',
      };
}

// ─── LOCATION BOTTOM SHEET ────────────────────────────────────────────────────

class _LocationSheet extends ConsumerStatefulWidget {
  final WorldLocation location;
  final ScrollController scrollController;
  const _LocationSheet({required this.location, required this.scrollController});

  @override
  ConsumerState<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends ConsumerState<_LocationSheet> {
  final Set<String> _selectedHeroIds = {};
  final Set<String> _selectedSupplies = {};

  @override
  void initState() {
    super.initState();
    // Request AI image for this location if it doesn't have one yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.location.imageUrl == null) {
        ref.read(gameProvider.notifier)
            .generateLocationImage(widget.location.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final party    = ref.watch(partyProvider);
    final available = party.where((h) => h.isAvailable).toList();
    // Watch live location so image URL update refreshes the UI
    final loc = ref.watch(worldMapProvider).firstWhere(
          (l) => l.id == widget.location.id,
          orElse: () => widget.location,
        );
    final gameState = ref.watch(gameProvider);
    final lastCompletedId = gameState.lastCompletedLocationId;
    final isBlockedRepeat = lastCompletedId != null && lastCompletedId == loc.id;
    final activeTownVisit = ref.watch(townVisitProvider);
    final isInTown = activeTownVisit != null;
    final partyAvgLevel = available.isNotEmpty
        ? available.map((h) => h.level).reduce((a, b) => a + b) / available.length
        : party.isNotEmpty
            ? party.map((h) => h.level).reduce((a, b) => a + b) / party.length
            : 1.0;
    final isLevelLocked = loc.minPartyLevel > 0 && partyAvgLevel < loc.minPartyLevel;
    final canSend = _selectedHeroIds.isNotEmpty && !isBlockedRepeat && !isInTown && !isLevelLocked;
    final rations = gameState.rations;
    final gold    = gameState.gold;
    final rationCost = GameNotifier.rationCostForDuration(loc.durationSeconds);
    final hasEnoughRations = rations >= rationCost;
    final visitCount = gameState.locationVisitCounts[loc.id] ?? 0;
    final isInvested = gameState.investedLocationIds.contains(loc.id);

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      children: [
          // AI location image
          if (loc.imageUrl != null)
            ClipRect(
              child: Image.network(
                loc.imageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 80,
              color: AshenColors.surface,
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AshenColors.copper,
                  ),
                ),
              ),
            ),

          Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Location header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.name,
                        style: AshenText.body.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(loc.typeLabel, style: AshenText.dim),
                        const SizedBox(width: 10),
                        _depthStars(loc.depth),
                        const SizedBox(width: 10),
                        Text(formatDuration(loc.durationSeconds),
                            style: AshenText.dim),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(loc.description, style: AshenText.dim),
          const Divider(color: AshenColors.border, height: 20),

          // Hero selector
          const Text('SELECT HEROES', style: AshenText.heading),
          const SizedBox(height: 8),
          if (available.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No heroes are ready. Recruit companions or wait for recovery.',
                style: AshenText.dim,
              ),
            )
          else
            ...available.map((hero) => HeroCard(
                  hero: hero,
                  selected: _selectedHeroIds.contains(hero.id),
                  onTap: () => setState(() {
                    if (_selectedHeroIds.contains(hero.id)) {
                      _selectedHeroIds.remove(hero.id);
                    } else {
                      _selectedHeroIds.add(hero.id);
                    }
                  }),
                )),

          const SizedBox(height: 16),

          // ─── RATIONS ────────────────────────────────────────────────────
          const Text('SUPPLIES', style: AshenText.heading),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rations: $rations  ·  Cost: $rationCost',
                  style: AshenText.dim.copyWith(
                    color: hasEnoughRations ? AshenColors.ashGrey : AshenColors.darkRed,
                  ),
                ),
              ),
              _SmallButton(
                label: 'BUY 5 (75g)',
                onPressed: gold >= 75
                    ? () => ref.read(gameProvider.notifier).buyRations(5)
                    : null,
              ),
            ],
          ),
          if (!hasEnoughRations)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'WARNING: party departs hungry. Each hero will lose 20 HP on arrival.',
                style: AshenText.dim.copyWith(color: AshenColors.darkRed, fontSize: 11),
              ),
            ),
          const SizedBox(height: 10),

          // ─── PRE-EXPEDITION SUPPLIES ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SupplyToggle(
                  label: 'HEALING KIT',
                  cost: 80,
                  active: _selectedSupplies.contains('healing_kit'),
                  onBuy: !_selectedSupplies.contains('healing_kit') && gold >= 80
                      ? () => setState(() => _selectedSupplies.add('healing_kit'))
                      : null,
                  tooltip: 'Party heals 40 HP at 50% of the expedition',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SupplyToggle(
                  label: 'LANTERN',
                  cost: 60,
                  active: _selectedSupplies.contains('lantern'),
                  onBuy: !_selectedSupplies.contains('lantern') &&
                          gold >= (_selectedSupplies.contains('healing_kit') ? 80 + 60 : 60)
                      ? () => setState(() => _selectedSupplies.add('lantern'))
                      : null,
                  tooltip: 'Better loot in dungeons and ruins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ─── CARTOGRAPHER / INVEST ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SmallButton(
                  label: 'INVEST (200g)',
                  onPressed: gold >= 200 && !isInvested
                      ? () => ref.read(gameProvider.notifier).investInLocation(loc.id)
                      : null,
                  active: isInvested,
                  tooltip: '+50% gold on next expedition here',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SmallButton(
                  label: 'CARTOGRAPHER (250g)',
                  onPressed: gold >= 250
                      ? () => ref.read(gameProvider.notifier).cartographerReveal(loc.id)
                      : null,
                  tooltip: 'Reveal nearest undiscovered location',
                ),
              ),
            ],
          ),
          if (visitCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Visits: $visitCount${visitCount >= 5 ? "  ·  +25% gold" : visitCount >= 3 ? "  ·  Enemies are alert" : ""}',
                style: AshenText.dim.copyWith(fontSize: 11),
              ),
            ),
          const Divider(color: AshenColors.border, height: 20),

          // Level lock warning
          if (isLevelLocked) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1208),
                border: Border.all(color: const Color(0xFF5A4020), width: 1),
              ),
              child: Row(
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Requires average party level ${loc.minPartyLevel}. '
                      'Your party is level ${partyAvgLevel.toStringAsFixed(1)}.',
                      style: AshenText.dim.copyWith(
                        color: const Color(0xFFB89A60),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Depart button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canSend
                    ? AshenColors.darkRed
                    : AshenColors.border,
                foregroundColor: AshenColors.parchment,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(),
              ),
              onPressed: canSend ? _send : null,
              child: Text(
                isInTown
                    ? 'DEPART ${activeTownVisit!.locationName.toUpperCase()} FIRST'
                    : isBlockedRepeat
                        ? 'REST BEFORE RETURNING HERE'
                        : canSend
                            ? 'DEPART  (${formatDuration(loc.durationSeconds)})'
                            : 'SELECT AT LEAST ONE HERO',
                style: const TextStyle(letterSpacing: 1),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Est. reward: ${(loc.durationSeconds / 60 * 15).round()}–'
              '${(loc.durationSeconds / 60 * 22).round()} gold',
              style: AshenText.dim.copyWith(fontSize: 11),
            ),
          ),
          ],        // Column children
          ),        // Column
          ),        // Padding
        ],          // ListView children
    );
  }

  void _send() {
    final loc = widget.location;
    final before = ref.read(gameProvider).activeExpedition;
    int supplyFlags = 0;
    if (_selectedSupplies.contains('healing_kit')) supplyFlags |= 1;
    if (_selectedSupplies.contains('lantern')) supplyFlags |= 2;
    ref.read(gameProvider.notifier).sendExpedition(
          _selectedHeroIds.toList(),
          loc.name,
          loc.type,
          loc.durationSeconds,
          depth: loc.depth,
          worldLocationId: loc.id,
          supplyFlags: supplyFlags,
        );
    final after = ref.read(gameProvider).activeExpedition;
    if (after != before) Navigator.pop(context);
  }

  Widget _depthStars(int depth) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Text(
          i < depth ? '★' : '☆',
          style: TextStyle(
            color: i < depth ? AshenColors.copper : AshenColors.border,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

// ─── SMALL ACTION BUTTON ──────────────────────────────────────────────────────

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool active;
  final String? tooltip;

  const _SmallButton({
    required this.label,
    required this.onPressed,
    this.active = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: active ? AshenColors.copper : AshenColors.ashGrey,
        side: BorderSide(
          color: active ? AshenColors.copper : AshenColors.border,
        ),
        shape: const RoundedRectangleBorder(),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        textStyle: const TextStyle(fontSize: 10, letterSpacing: 1),
      ),
      onPressed: onPressed,
      child: Text(label, textAlign: TextAlign.center),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}

// ─── SUPPLY TOGGLE ────────────────────────────────────────────────────────────

class _SupplyToggle extends StatelessWidget {
  final String label;
  final int cost;
  final bool active;
  final VoidCallback? onBuy;
  final String? tooltip;

  const _SupplyToggle({
    required this.label,
    required this.cost,
    required this.active,
    required this.onBuy,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: active ? AshenColors.copper : AshenColors.ashGrey,
        side: BorderSide(
          color: active ? AshenColors.copper : AshenColors.border,
        ),
        shape: const RoundedRectangleBorder(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        textStyle: const TextStyle(fontSize: 10, letterSpacing: 1),
      ),
      onPressed: active ? null : onBuy,
      child: Text(
        active ? '$label ✓' : '$label (${cost}g)',
        textAlign: TextAlign.center,
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: btn);
    return btn;
  }
}
