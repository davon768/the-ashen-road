import 'package:flutter/material.dart' hide Hero;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../theme/colors.dart';
import '../theme/parchment_widgets.dart';
import '../models/enums.dart';
import '../models/spell.dart';
import '../data/classes_data.dart';
import '../data/faiths_data.dart';
import '../data/spells_data.dart';
import 'opening_narration_screen.dart';

class CharacterCreatorScreen extends ConsumerStatefulWidget {
  const CharacterCreatorScreen({super.key});

  @override
  ConsumerState<CharacterCreatorScreen> createState() =>
      _CharacterCreatorScreenState();
}

class _CharacterCreatorScreenState
    extends ConsumerState<CharacterCreatorScreen> {
  final _nameController       = TextEditingController();
  final _appearanceController = TextEditingController();
  HeroClass _heroClass = HeroClass.knight;
  FaithType _faith     = FaithType.luminantChurch;
  bool _hardcore       = false;
  bool _isFemale       = false;

  @override
  void dispose() {
    _nameController.dispose();
    _appearanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.trim();
    final canBegin = name.isNotEmpty;

    return Scaffold(
      backgroundColor: AshenColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──────────────────────────────────────────
              const Center(
                child: Text(
                  'THE ASHEN ROAD',
                  style: TextStyle(
                    color: AshenColors.copper,
                    fontSize: 26,
                    letterSpacing: 6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Container(
                  height: 1,
                  width: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AshenColors.inkRed,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Before you take the first step, tell us who you are.',
                  style: AshenText.dim,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),

              // ── Name ───────────────────────────────────────────
              const SectionHeading('YOUR NAME'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: AshenText.body,
                maxLength: 30,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Enter your name…',
                  hintStyle: AshenText.dim,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AshenColors.border),
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AshenColors.copper),
                    borderRadius: BorderRadius.zero,
                  ),
                  filled: true,
                  fillColor: AshenColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 32),

              // ── Gender ─────────────────────────────────────────
              const SectionHeading('GENDER'),
              const SizedBox(height: 8),
              _ModeChoice(
                selected: _isFemale,
                onChanged: (v) => setState(() => _isFemale = v),
                option1Label: 'MALE',
                option1Desc: 'Your portrait and pronoun defaults reflect a male character.',
                option2Label: 'FEMALE',
                option2Desc: 'Your portrait and pronoun defaults reflect a female character.',
                dangerOnSelected: false,
              ),
              const SizedBox(height: 32),

              // ── Class ──────────────────────────────────────────
              const SectionHeading('YOUR CLASS'),
              const SizedBox(height: 4),
              const Text(
                'This determines your starting stats and fighting style.',
                style: AshenText.dim,
              ),
              const SizedBox(height: 12),
              ...allClasses.map((def) => _ClassOption(
                    definition: def,
                    selected: _heroClass == def.heroClass,
                    onTap: () => setState(() => _heroClass = def.heroClass),
                  )),
              const SizedBox(height: 32),

              // ── Faith ──────────────────────────────────────────
              const SectionHeading('YOUR FAITH'),
              const SizedBox(height: 4),
              const Text(
                'Shapes how devotion grows and what miracles may find you.',
                style: AshenText.dim,
              ),
              const SizedBox(height: 12),
              ...allFaiths.map((faith) => _FaithOption(
                    faith: faith,
                    selected: _faith == faith.type,
                    onTap: () => setState(() => _faith = faith.type),
                  )),
              const SizedBox(height: 32),

              // ── Appearance ─────────────────────────────────────
              const SectionHeading('APPEARANCE'),
              const SizedBox(height: 4),
              const Text(
                'Describe how your character looks. This shapes your AI portrait.',
                style: AshenText.dim,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _appearanceController,
                style: AshenText.body,
                maxLength: 120,
                maxLines: 2,
                decoration: InputDecoration(
                  counterText: '',
                  hintText:
                      'e.g. scarred jaw, silver hair, hollow grey eyes, '
                      'black travelling cloak…',
                  hintStyle: AshenText.dim.copyWith(fontSize: 12),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AshenColors.border),
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AshenColors.copper),
                    borderRadius: BorderRadius.zero,
                  ),
                  filled: true,
                  fillColor: AshenColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 32),

              // ── Mode ───────────────────────────────────────────
              const SectionHeading('DIFFICULTY'),
              const SizedBox(height: 8),
              _ModeChoice(
                selected: _hardcore,
                onChanged: (v) => setState(() => _hardcore = v),
              ),
              const SizedBox(height: 40),

              // ── Begin ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canBegin
                        ? AshenColors.darkRed
                        : AshenColors.border,
                    foregroundColor: AshenColors.parchment,
                    disabledForegroundColor:
                        AshenColors.ashGrey.withAlpha(180),
                    disabledBackgroundColor: AshenColors.border,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(),
                    elevation: 0,
                  ),
                  onPressed: canBegin ? _begin : null,
                  child: const Text(
                    'BEGIN YOUR JOURNEY',
                    style: TextStyle(
                      letterSpacing: 3,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!canBegin)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text('Enter a name to continue.', style: AshenText.dim),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _begin() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(gameProvider.notifier).createPlayerCharacter(
          name,
          _heroClass,
          _faith,
          hardcore: _hardcore,
          isFemale: _isFemale,
          appearanceHint: _appearanceController.text.trim().isEmpty
              ? null
              : _appearanceController.text.trim(),
        );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OpeningNarrationScreen()),
    );
  }
}

// ─── CLASS OPTION CARD ───────────────────────────────────────────────────────

class _ClassOption extends StatelessWidget {
  final ClassDefinition definition;
  final bool selected;
  final VoidCallback onTap;

  const _ClassOption({
    required this.definition,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              selected
                  ? AshenColors.copper.withAlpha(35)
                  : AshenColors.parchmentWarm,
              selected
                  ? AshenColors.copper.withAlpha(12)
                  : AshenColors.surface,
            ],
            stops: const [0.0, 0.3],
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
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                _classIcon(definition.heroClass),
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        definition.name,
                        style: AshenText.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: selected
                              ? AshenColors.copper
                              : AshenColors.parchment,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(definition.role,
                          style: AshenText.dim.copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    definition.description,
                    style: AshenText.dim.copyWith(fontSize: 11),
                    maxLines: selected ? null : 2,
                    overflow: selected ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                  if (selected) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _showClassAbilities(context, definition),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'VIEW ABILITIES',
                            style: AshenText.dim.copyWith(
                                fontSize: 10,
                                letterSpacing: 2,
                                color: AshenColors.copper),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right,
                              size: 13, color: AshenColors.copper),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle,
                    color: AshenColors.copper, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  String _classIcon(HeroClass c) => switch (c) {
        HeroClass.knight      => '⚔',
        HeroClass.ranger      => '🏹',
        HeroClass.priest      => '✝',
        HeroClass.mage        => '✦',
        HeroClass.rogue       => '🗡',
        HeroClass.necromancer => '☠',
        HeroClass.warlock     => '◈',
      };
}

// ─── CLASS ABILITIES SHEET ───────────────────────────────────────────────────

void _showClassAbilities(BuildContext context, ClassDefinition def) {
  final isCaster = def.heroClass.isCaster;
  final spells = isCaster ? spellsForClass(def.heroClass) : <Spell>[];

  showModalBottomSheet(
    context: context,
    backgroundColor: AshenColors.surface,
    isScrollControlled: true,
    shape: const Border(top: BorderSide(color: AshenColors.copper, width: 1)),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (ctx, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          // Header
          Text(
            def.name.toUpperCase(),
            style: AshenText.body.copyWith(
                fontSize: 15, letterSpacing: 3, color: AshenColors.copper),
          ),
          Text(def.role, style: AshenText.dim.copyWith(fontSize: 11)),
          const SizedBox(height: 16),

          if (isCaster) ...[
            // Spell list grouped by tier
            for (final tier in [1, 2, 3]) ...[
              _tierHeading(tier),
              const SizedBox(height: 8),
              ...spells
                  .where((s) => s.tier == tier)
                  .map((s) => _SpellListTile(spell: s)),
              const SizedBox(height: 14),
            ],
          ] else ...[
            // Signature abilities by subclass
            Text(
              'SUBCLASS ABILITIES',
              style: AshenText.dim.copyWith(
                  fontSize: 10, letterSpacing: 2, color: AshenColors.ashGrey),
            ),
            const SizedBox(height: 10),
            for (final sub in def.subclasses) ...[
              Text(
                sub.name.toUpperCase(),
                style: AshenText.body.copyWith(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: AshenColors.copper),
              ),
              const SizedBox(height: 2),
              Text(sub.description,
                  style: AshenText.dim.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              ...sub.signatureAbilities.map((ability) => Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 8),
                    child: Row(children: [
                      const Text('·  ',
                          style: TextStyle(
                              color: AshenColors.copper, fontSize: 12)),
                      Text(ability,
                          style: AshenText.body.copyWith(fontSize: 12)),
                    ]),
                  )),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    ),
  );
}

Widget _tierHeading(int tier) {
  final color = switch (tier) {
    1 => AshenColors.ashGrey,
    2 => AshenColors.copper,
    _ => AshenColors.inkRed,
  };
  final label = switch (tier) {
    1 => 'TIER 1  ·  BASIC',
    2 => 'TIER 2  ·  INTERMEDIATE',
    _ => 'TIER 3  ·  ADVANCED',
  };
  return Text(label,
      style: AshenText.dim.copyWith(
          fontSize: 10, letterSpacing: 2, color: color));
}

class _SpellListTile extends StatelessWidget {
  final Spell spell;
  const _SpellListTile({required this.spell});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSpellDetailCreator(context, spell),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AshenColors.background,
          border: Border(
            left: BorderSide(color: _tierColor(spell.tier), width: 2),
          ),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spell.name,
                    style: AshenText.body.copyWith(
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: AshenColors.copper.withAlpha(120))),
                Text(
                  '${spell.manaCost} mana  ·  ${_spellEffectLabel(spell.effectType)}',
                  style: AshenText.dim.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.info_outline, size: 14, color: AshenColors.border),
        ]),
      ),
    );
  }
}

void _showSpellDetailCreator(BuildContext context, Spell spell) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AshenColors.surface,
    shape: const Border(top: BorderSide(color: AshenColors.copper, width: 1)),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _ccTierChip(spell.tier),
            const SizedBox(width: 10),
            Expanded(
              child: Text(spell.name,
                  style: AshenText.body.copyWith(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Text('${spell.manaCost} MANA',
                style: AshenText.dim.copyWith(
                    fontSize: 11, letterSpacing: 2, color: AshenColors.copper)),
          ]),
          const SizedBox(height: 4),
          Text(
            _spellEffectLabel(spell.effectType).toUpperCase(),
            style: AshenText.dim.copyWith(
                fontSize: 10, letterSpacing: 2, color: AshenColors.ashGrey),
          ),
          const SizedBox(height: 14),
          Text(spell.description,
              style: AshenText.body.copyWith(fontSize: 13)),
          if (spell.powerScale > 0 || spell.flatBonus > 0 || spell.duration > 1) ...[
            const SizedBox(height: 10),
            _ccSpellStatBlock(spell),
          ],
          const SizedBox(height: 12),
          Text(spell.flavorText,
              style: AshenText.dim.copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AshenColors.parchmentDim)),
        ],
      ),
    ),
  );
}

Widget _ccTierChip(int tier) => Container(
      width: 24,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: _tierColor(tier)),
      child: Text(
        'T$tier',
        style: const TextStyle(
            color: AshenColors.parchment,
            fontSize: 9,
            fontWeight: FontWeight.bold),
      ),
    );

Widget _ccSpellStatBlock(Spell spell) {
  final parts = <String>[];
  if (spell.powerScale > 0) parts.add('Power ×${spell.powerScale.toStringAsFixed(1)}');
  if (spell.flatBonus > 0) {
    final label = switch (spell.effectType) {
      SpellEffectType.buff   => '+${spell.flatBonus} defense',
      SpellEffectType.debuff => '−${spell.flatBonus} enemy armor',
      SpellEffectType.summon => '+${spell.flatBonus} dmg/round',
      _                      => '+${spell.flatBonus} flat',
    };
    parts.add(label);
  }
  if (spell.duration > 1) parts.add('${spell.duration} rounds');
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: const BoxDecoration(
      border: Border(left: BorderSide(color: AshenColors.copper, width: 2)),
      color: Color(0x10D4956A),
    ),
    child: Text(parts.join('  ·  '),
        style: AshenText.dim.copyWith(fontSize: 12, color: AshenColors.copper)),
  );
}

Color _tierColor(int tier) => switch (tier) {
      1 => AshenColors.border,
      2 => AshenColors.copper.withAlpha(80),
      _ => AshenColors.inkRed.withAlpha(120),
    };

String _spellEffectLabel(SpellEffectType t) => switch (t) {
      SpellEffectType.damage    => 'Damage',
      SpellEffectType.damageAll => 'AoE Damage',
      SpellEffectType.dot       => 'DoT',
      SpellEffectType.dotAll    => 'AoE DoT',
      SpellEffectType.heal      => 'Heal',
      SpellEffectType.healAll   => 'Heal All',
      SpellEffectType.drain     => 'Drain',
      SpellEffectType.buff      => 'Defense Buff',
      SpellEffectType.debuff    => 'Debuff',
      SpellEffectType.dispel    => 'Dispel',
      SpellEffectType.summon    => 'Summon',
    };

// ─── MODE CHOICE ─────────────────────────────────────────────────────────────

class _ModeChoice extends StatelessWidget {
  final bool selected;
  final ValueChanged<bool> onChanged;
  final String option1Label;
  final String option1Desc;
  final String option2Label;
  final String option2Desc;
  final bool dangerOnSelected;

  const _ModeChoice({
    required this.selected,
    required this.onChanged,
    this.option1Label  = 'STANDARD',
    this.option1Desc   = 'Heroes who fall in battle recover over time.',
    this.option2Label  = 'HARDCORE',
    this.option2Desc   = 'Death is permanent. Choose every step with care.',
    this.dangerOnSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ModeCard(
          label: option1Label,
          description: option1Desc,
          selected: !selected,
          onTap: () => onChanged(false),
        )),
        const SizedBox(width: 8),
        Expanded(child: _ModeCard(
          label: option2Label,
          description: option2Desc,
          selected: selected,
          dangerColor: dangerOnSelected,
          onTap: () => onChanged(true),
        )),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final bool dangerColor;
  final VoidCallback onTap;

  const _ModeCard({
    required this.label,
    required this.description,
    required this.selected,
    this.dangerColor = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = dangerColor ? AshenColors.darkRed : AshenColors.copper;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              selected
                  ? activeColor.withAlpha(35)
                  : AshenColors.parchmentWarm,
              selected
                  ? activeColor.withAlpha(12)
                  : AshenColors.surface,
            ],
            stops: const [0.0, 0.3],
          ),
          border: Border(
            left: BorderSide(
              color: selected ? activeColor : AshenColors.inkRed,
              width: selected ? 3.0 : 2.5,
            ),
            top:    const BorderSide(color: AshenColors.border, width: 0.5),
            right:  const BorderSide(color: AshenColors.border, width: 0.5),
            bottom: const BorderSide(color: AshenColors.border, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: AshenText.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: selected ? activeColor : AshenColors.parchment,
                  ),
                ),
                const Spacer(),
                if (selected)
                  Icon(Icons.check_circle, color: activeColor, size: 14),
              ],
            ),
            const SizedBox(height: 4),
            Text(description, style: AshenText.dim.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ─── FAITH OPTION CARD ───────────────────────────────────────────────────────

class _FaithOption extends StatelessWidget {
  final dynamic faith;
  final bool selected;
  final VoidCallback onTap;

  const _FaithOption({
    required this.faith,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              selected
                  ? AshenColors.copper.withAlpha(35)
                  : AshenColors.parchmentWarm,
              selected
                  ? AshenColors.copper.withAlpha(12)
                  : AshenColors.surface,
            ],
            stops: const [0.0, 0.3],
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faith.name as String,
                    style: AshenText.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? AshenColors.copper
                          : AshenColors.parchment,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    faith.deity as String,
                    style: AshenText.dim.copyWith(
                        fontSize: 11, color: AshenColors.gold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    faith.description as String,
                    style: AshenText.dim.copyWith(fontSize: 11),
                    maxLines: selected ? null : 2,
                    overflow: selected ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (selected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle,
                    color: AshenColors.copper, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
