import 'package:flutter/material.dart' hide Hero;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../state/providers.dart';
import '../theme/colors.dart';
import '../theme/parchment_widgets.dart';
import '../widgets/hero_card.dart';
import '../models/hero.dart';
import '../models/enums.dart';
import '../models/stats.dart';
import '../data/classes_data.dart';
import '../data/class_abilities_data.dart';
import '../data/spells_data.dart';
import '../data/consumables_data.dart';
import '../models/spell.dart';
import '../models/quest.dart';
import 'devotion_screen.dart';

void _confirmRetire(BuildContext context, WidgetRef ref, Hero hero) {
  final bonus = (hero.heroClass == HeroClass.mage ||
          hero.heroClass == HeroClass.necromancer ||
          hero.heroClass == HeroClass.warlock)
      ? '+3% XP from all expeditions'
      : '+3% gold from all expeditions';
  showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AshenColors.surface,
      title: Text('Retire ${hero.name}?',
          style: AshenText.body.copyWith(fontWeight: FontWeight.bold)),
      content: Text(
        '${hero.name} will leave the company. Their legacy grants the party $bonus permanently.\n\n'
        'This cannot be undone.',
        style: AshenText.dim,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('CANCEL',
              style: TextStyle(color: AshenColors.parchmentDim)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('RETIRE',
              style: TextStyle(color: AshenColors.gold)),
        ),
      ],
    ),
  ).then((confirmed) {
    if (confirmed == true && context.mounted) {
      ref.read(gameProvider.notifier).retireHero(hero.id);
      Navigator.pop(context);
    }
  });
}

class PartyScreen extends ConsumerWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final party        = ref.watch(partyProvider);
    final maxPartySize = ref.watch(maxPartySizeProvider);
    final retPerks     = ref.watch(gameProvider.select((s) => s.retirementPerks));
    final activeQuests = ref.watch(gameProvider.select((s) => s.activeQuests));

    return Scaffold(
      backgroundColor: AshenColors.background,
      body: party.isEmpty
          ? _emptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('PARTY  ${party.length}/$maxPartySize', style: AshenText.heading),
                if (retPerks.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _RetirementBanner(perks: retPerks),
                ],
                if (activeQuests.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _ActiveQuestsBanner(quests: activeQuests),
                ],
                const SizedBox(height: 12),
                ...party.map(
                  (hero) => HeroCard(
                    hero: hero,
                    onTap: () => _showHeroDetail(context, ref, hero),
                  ),
                ),
                _BondsSummary(party: party),
                if (party.length < 5) ...[
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Seek companions at taverns, on the road,\nor in the aftermath of battle.',
                      style: AshenText.dim,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _emptyState() => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No heroes travel with you.',
                style: AshenText.body,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Seek companions at taverns in the towns ahead — or fortune may send them to you on the road.',
                style: AshenText.dim,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  void _showHeroDetail(BuildContext context, WidgetRef ref, Hero hero) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AshenColors.surface,
      shape: const Border(top: BorderSide(color: AshenColors.inkRed, width: 1.5)),
      builder: (_) => _HeroDetailSheet(hero: hero),
    );
  }
}

class _HeroDetailSheet extends ConsumerWidget {
  final Hero hero;
  const _HeroDetailSheet({required this.hero});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveHero = ref.watch(partyProvider)
            .where((h) => h.id == hero.id)
            .firstOrNull ??
        hero;
    final s = liveHero.effectiveStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portrait
          if (liveHero.imageUrl != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: 140,
                  height: 210,
                  child: CachedNetworkImage(
                    imageUrl: liveHero.imageUrl!,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const Center(
                      child: CircularProgressIndicator(
                          color: AshenColors.copper, strokeWidth: 1.5),
                    ),
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),

          Row(
            children: [
              Expanded(
                child: Text(liveHero.name,
                    style: AshenText.body.copyWith(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (!liveHero.isPlayerCharacter)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (liveHero.level >= 20 && liveHero.status != HeroStatus.dead)
                      TextButton(
                        onPressed: () => _confirmRetire(context, ref, liveHero),
                        child: const Text(
                          'RETIRE',
                          style: TextStyle(color: AshenColors.gold, fontSize: 12),
                        ),
                      ),
                    TextButton(
                      onPressed: () {
                        ref.read(gameProvider.notifier).dismissHero(liveHero.id);
                        Navigator.pop(context);
                      },
                      child: Text(
                        liveHero.status == HeroStatus.dead ? 'RELEASE THE FALLEN' : 'DISMISS',
                        style: const TextStyle(color: AshenColors.darkRed, fontSize: 12),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (liveHero.status == HeroStatus.dead) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: const Color(0xFF2A0808),
              child: Text(
                '✦  ${liveHero.name} has fallen. Their road ends here.',
                style: AshenText.dim.copyWith(
                  color: AshenColors.darkRed,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
          ],

          Row(
            children: [
              Expanded(
                child: Text(
                  '${_className(liveHero.heroClass)}  ·  Age ${liveHero.age}  ·  Level ${liveHero.level}',
                  style: AshenText.dim,
                ),
              ),
              GestureDetector(
                onTap: () => _showClassAbilities(context, liveHero.heroClass),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ABILITIES',
                        style: AshenText.dim.copyWith(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: AshenColors.copper)),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right,
                        size: 13, color: AshenColors.copper),
                  ],
                ),
              ),
            ],
          ),
          const InkRule(),

          // HP / MP vitals
          _vitalsSection(liveHero),
          const InkRule(),

          // Mana consumables (casters only, out-of-combat)
          if (liveHero.heroClass.isCaster) ...[
            _consumableSection(context, ref, liveHero),
          ],

          // Level / XP progress
          _xpSection(liveHero),
          const InkRule(),

          // Stats grid
          const SectionHeading('ATTRIBUTES'),
          const SizedBox(height: 10),
          _statRow('Strength',     s.strength,     'Melee damage & carry weight'),
          _statRow('Dexterity',    s.dexterity,    'Attack speed, dodge & ranged damage'),
          _statRow('Endurance',    s.endurance,    'Max health & stamina'),
          _statRow('Intelligence', s.intelligence, 'Magic power & spell variety'),
          _statRow('Faith',        s.faith,        'Devotion gain & miracle strength'),
          _statRow('Luck',         s.luck,         'Critical hits & loot quality'),
          const InkRule(),

          // Subclass section
          _subclassSection(context, ref, liveHero),
          const InkRule(),

          // Equipment slots
          const SectionHeading('EQUIPMENT'),
          const SizedBox(height: 10),
          _weaponSlot(context, ref, liveHero),
          const SizedBox(height: 6),
          _armorSlot(context, ref, liveHero, ArmorSlot.head),
          _armorSlot(context, ref, liveHero, ArmorSlot.body),
          _armorSlot(context, ref, liveHero, ArmorSlot.hands),
          _armorSlot(context, ref, liveHero, ArmorSlot.legs),
          _armorSlot(context, ref, liveHero, ArmorSlot.feet),
          _armorSlot(context, ref, liveHero, ArmorSlot.shield),
          const InkRule(),

          // Combat abilities (all classes)
          _abilitySection(liveHero),
          const InkRule(),

          // Spell slots (casters only)
          if (liveHero.heroClass.isCaster) ...[
            _spellSection(context, ref, liveHero),
            const InkRule(),
          ],

          // Faith + devotion
          if (liveHero.faith != null) ...[
            const SectionHeading('FAITH'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: Text(_faithName(liveHero.faith), style: AshenText.body)),
                Text(
                  'Devotion ${liveHero.devotion.toStringAsFixed(0)}/100',
                  style: AshenText.dim,
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: liveHero.devotion / 100,
              minHeight: 6,
              backgroundColor: AshenColors.border,
              valueColor:
                  const AlwaysStoppedAnimation(AshenColors.copper),
            ),
            const SizedBox(height: 8),
            // Devotion perk summary
            if (liveHero.devotionPerkIds.isNotEmpty) ...[
              Text(
                'Blessings: ${liveHero.devotionPerkIds.length} chosen',
                style: AshenText.dim.copyWith(fontSize: 11, color: AshenColors.copper),
              ),
              const SizedBox(height: 4),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AshenColors.gold,
                  side: const BorderSide(color: AshenColors.copper),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: const RoundedRectangleBorder(),
                  textStyle: const TextStyle(fontSize: 11, letterSpacing: 2),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DevotionScreen(heroId: liveHero.id),
                  ));
                },
                child: const Text('VIEW DEVOTION TREE'),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _consumableSection(BuildContext context, WidgetRef ref, Hero h) {
    final inv = ref.watch(inventoryProvider);
    final available = allConsumables
        .where((c) => c.manaRestore > 0 && inv.hasConsumable(c.id))
        .toList();
    if (available.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading('DRAUGHTS'),
        const SizedBox(height: 8),
        ...available.map((c) {
          final count = inv.consumableCount(c.id);
          final atMax = h.currentMana >= h.maxMana;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${c.name}  ×$count', style: AshenText.body.copyWith(fontSize: 13)),
                      Text('+${c.manaRestore} mana', style: AshenText.dim.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: atMax ? AshenColors.ashGrey : AshenColors.copper,
                    side: BorderSide(color: atMax ? AshenColors.border : AshenColors.copper),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    shape: const RoundedRectangleBorder(),
                    textStyle: const TextStyle(fontSize: 10, letterSpacing: 1),
                  ),
                  onPressed: atMax
                      ? null
                      : () => ref.read(gameProvider.notifier).useConsumable(h.id, c.id),
                  child: Text(atMax ? 'FULL' : 'USE'),
                ),
              ],
            ),
          );
        }),
        const InkRule(),
      ],
    );
  }

  Widget _weaponSlot(BuildContext context, WidgetRef ref, Hero h) {
    final weapon = h.equipment.mainHand;
    return _slotRow(
      slotLabel: 'Main Hand',
      itemName: weapon?.name ?? '—',
      detail: weapon != null ? '${weapon.minDamage}–${weapon.maxDamage} dmg' : null,
      onUnequip: weapon != null
          ? () => ref.read(gameProvider.notifier).unequipWeapon(h.id)
          : null,
    );
  }

  Widget _armorSlot(BuildContext context, WidgetRef ref, Hero h, ArmorSlot slot) {
    final armor = switch (slot) {
      ArmorSlot.head   => h.equipment.head,
      ArmorSlot.body   => h.equipment.body,
      ArmorSlot.hands  => h.equipment.hands,
      ArmorSlot.legs   => h.equipment.legs,
      ArmorSlot.feet   => h.equipment.feet,
      ArmorSlot.shield => h.equipment.shield,
    };
    final label = switch (slot) {
      ArmorSlot.head   => 'Head',
      ArmorSlot.body   => 'Body',
      ArmorSlot.hands  => 'Hands',
      ArmorSlot.legs   => 'Legs',
      ArmorSlot.feet   => 'Feet',
      ArmorSlot.shield => 'Shield',
    };
    return _slotRow(
      slotLabel: label,
      itemName: armor?.name ?? '—',
      detail: armor != null ? '${armor.defense} def' : null,
      onUnequip: armor != null
          ? () => ref.read(gameProvider.notifier).unequipArmor(h.id, slot)
          : null,
    );
  }

  Widget _abilitySection(Hero h) {
    final abilities = abilitiesForClass(h.heroClass);
    if (abilities.isEmpty) return const SizedBox.shrink();

    final baseAbilities = abilities.where((a) => a.requiredSubclass == null).toList();
    final subAbilities  = abilities.where((a) => a.requiredSubclass != null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading('COMBAT ABILITIES'),
        const SizedBox(height: 10),

        // Base class abilities — always active
        ...baseAbilities.map((a) => _abilityCard(a, h)),

        // Subclass abilities
        if (subAbilities.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('SUBCLASS',
              style: AshenText.dim.copyWith(
                  fontSize: 10, letterSpacing: 2, color: AshenColors.ashGrey)),
          const SizedBox(height: 8),
          ...subAbilities.map((a) {
            final unlocked = h.subclass != null && h.subclass == a.requiredSubclass;
            return _abilityCard(a, h, locked: !unlocked);
          }),
        ],
      ],
    );
  }

  Widget _abilityCard(ClassAbility ability, Hero h, {bool locked = false}) {
    final borderColor = locked ? AshenColors.border : AshenColors.copper;
    final nameColor   = locked ? AshenColors.ashGrey : AshenColors.parchment;
    final textColor   = locked ? AshenColors.border : AshenColors.parchmentDim;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AshenColors.background,
        border: Border(left: BorderSide(color: borderColor, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(ability.name,
                  style: AshenText.body.copyWith(
                      fontSize: 13, fontWeight: FontWeight.bold, color: nameColor)),
            ),
            Text(ability.trigger,
                style: AshenText.dim.copyWith(
                    fontSize: 10,
                    letterSpacing: 1,
                    color: locked ? AshenColors.border : AshenColors.copper)),
          ]),
          const SizedBox(height: 4),
          Text(ability.description,
              style: AshenText.dim.copyWith(fontSize: 11, color: textColor)),
          if (locked) ...[
            const SizedBox(height: 4),
            Text(
              'Unlocks with ${_subclassName(ability.requiredSubclass)} specialisation (Level 10)',
              style: AshenText.dim.copyWith(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: AshenColors.border),
            ),
          ],
        ],
      ),
    );
  }

  String _subclassName(Subclass? s) => switch (s) {
        Subclass.berserker   => 'Berserker',
        Subclass.crusader    => 'Crusader',
        Subclass.sentinel    => 'Sentinel',
        Subclass.huntsman    => 'Huntsman',
        Subclass.pathfinder  => 'Pathfinder',
        Subclass.beastmaster => 'Beastmaster',
        Subclass.assassin    => 'Assassin',
        Subclass.shadowblade => 'Shadowblade',
        Subclass.trickster   => 'Trickster',
        Subclass.elementalist=> 'Elementalist',
        Subclass.runescribe  => 'Runescribe',
        Subclass.alchemist   => 'Alchemist',
        Subclass.inquisitor  => 'Inquisitor',
        Subclass.hospitaller => 'Hospitaller',
        Subclass.zealot      => 'Zealot',
        Subclass.lich        => 'Lich',
        Subclass.deathKnight => 'Death Knight',
        Subclass.plagueDoctor=> 'Plague Doctor',
        Subclass.demonologist=> 'Demonologist',
        Subclass.hexblade    => 'Hexblade',
        Subclass.occultist   => 'Occultist',
        null                 => 'Unknown',
      };

  Widget _spellSection(BuildContext context, WidgetRef ref, Hero h) {
    final notifier  = ref.read(gameProvider.notifier);
    final equipped  = h.equippedSpells;
    final maxSlots  = h.maxSpellSlots;
    final slotsFull = equipped.length >= maxSlots;
    final unequipped = h.knownSpells
        .where((id) => !equipped.contains(id))
        .map((id) => spellById(id))
        .whereType()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const SectionHeading('SPELL SLOTS'),
          const SizedBox(width: 8),
          Text(
            '${equipped.length}/$maxSlots',
            style: AshenText.dim.copyWith(fontSize: 11),
          ),
        ]),
        const SizedBox(height: 10),

        // Equipped spells
        ...equipped.map((id) {
          final spell = spellById(id);
          if (spell == null) return const SizedBox.shrink();
          return GestureDetector(
            onTap: () => _showSpellDetail(context, spell),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AshenColors.background,
                border: Border(
                  left: BorderSide(color: _tierBorderColor(spell.tier), width: 2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _tierChip(spell.tier),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(spell.name,
                            style: AshenText.body.copyWith(fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(spell.description,
                            style: AshenText.dim.copyWith(fontSize: 11)),
                        const SizedBox(height: 3),
                        Text('${spell.manaCost} mana  ·  ${_effectLabel(spell.effectType)}',
                            style: AshenText.dim.copyWith(
                                fontSize: 10, color: AshenColors.copper)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => notifier.unequipSpell(h.id, id),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8, top: 2),
                      child: Text('UNEQUIP',
                          style: TextStyle(
                              color: AshenColors.ashGrey,
                              fontSize: 10,
                              letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // Empty slots
        ...List.generate(maxSlots - equipped.length, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Container(
              width: 24, height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AshenColors.border),
              ),
              child: const Text('—', style: TextStyle(color: AshenColors.border, fontSize: 10)),
            ),
            const SizedBox(width: 8),
            Text('Empty slot', style: AshenText.dim.copyWith(fontSize: 12,
                color: AshenColors.border)),
          ]),
        )),

        // Known but not equipped
        if (unequipped.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('KNOWN SPELLS',
              style: AshenText.dim.copyWith(
                  fontSize: 10, letterSpacing: 2, color: AshenColors.copper)),
          const SizedBox(height: 8),
          ...unequipped.map((spell) => GestureDetector(
            onTap: () => _showSpellDetail(context, spell),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AshenColors.background,
                border: Border(
                  left: BorderSide(color: AshenColors.border, width: 2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _tierChip(spell.tier),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(spell.name,
                            style: AshenText.dim.copyWith(
                                fontSize: 13, color: AshenColors.parchmentDim)),
                        const SizedBox(height: 2),
                        Text(spell.description,
                            style: AshenText.dim.copyWith(fontSize: 11)),
                        const SizedBox(height: 3),
                        Text('${spell.manaCost} mana  ·  ${_effectLabel(spell.effectType)}',
                            style: AshenText.dim.copyWith(
                                fontSize: 10, color: AshenColors.ashGrey)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: slotsFull ? null : () => notifier.equipSpell(h.id, spell.id),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Text(
                        slotsFull ? 'FULL' : 'EQUIP',
                        style: TextStyle(
                            color: slotsFull ? AshenColors.border : AshenColors.copper,
                            fontSize: 10,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ],
    );
  }

  void _showClassAbilities(BuildContext context, HeroClass heroClass) {
    final def = allClasses.firstWhere((d) => d.heroClass == heroClass);
    final spells = heroClass.isCaster ? spellsForClass(heroClass) : <Spell>[];

    showModalBottomSheet(
      context: context,
      backgroundColor: AshenColors.surface,
      isScrollControlled: true,
      shape: const Border(top: BorderSide(color: AshenColors.copper, width: 1)),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (ctx2, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(def.name.toUpperCase(),
                style: AshenText.body.copyWith(
                    fontSize: 15, letterSpacing: 3, color: AshenColors.copper)),
            Text(def.role, style: AshenText.dim.copyWith(fontSize: 11)),
            const SizedBox(height: 16),

            if (heroClass.isCaster) ...[
              for (final tier in [1, 2, 3]) ...[
                _tierHeadingLabel(tier),
                const SizedBox(height: 8),
                ...spells.where((s) => s.tier == tier).map((spell) =>
                  GestureDetector(
                    onTap: () => _showSpellDetail(ctx, spell),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AshenColors.background,
                        border: Border(
                          left: BorderSide(
                              color: _tierBorderColor(tier), width: 2),
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
                                      decorationColor:
                                          AshenColors.copper.withAlpha(120))),
                              Text(
                                '${spell.manaCost} mana  ·  ${_effectLabel(spell.effectType)}',
                                style: AshenText.dim.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.info_outline,
                            size: 14, color: AshenColors.border),
                      ]),
                    ),
                  )),
                const SizedBox(height: 14),
              ],
            ] else ...[
              Text('SUBCLASS ABILITIES',
                  style: AshenText.dim.copyWith(
                      fontSize: 10, letterSpacing: 2, color: AshenColors.ashGrey)),
              const SizedBox(height: 10),
              for (final sub in def.subclasses) ...[
                Text(sub.name.toUpperCase(),
                    style: AshenText.body.copyWith(
                        fontSize: 12, letterSpacing: 1, color: AshenColors.copper)),
                const SizedBox(height: 2),
                Text(sub.description,
                    style: AshenText.dim.copyWith(fontSize: 11)),
                const SizedBox(height: 6),
                ...sub.signatureAbilities.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 8),
                      child: Row(children: [
                        const Text('·  ',
                            style: TextStyle(
                                color: AshenColors.copper, fontSize: 12)),
                        Text(a, style: AshenText.body.copyWith(fontSize: 12)),
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

  Widget _tierHeadingLabel(int tier) {
    final (color, label) = switch (tier) {
      1 => (AshenColors.ashGrey, 'TIER 1  ·  BASIC'),
      2 => (AshenColors.copper,  'TIER 2  ·  INTERMEDIATE'),
      _ => (AshenColors.inkRed,  'TIER 3  ·  ADVANCED'),
    };
    return Text(label,
        style: AshenText.dim.copyWith(
            fontSize: 10, letterSpacing: 2, color: color));
  }

  Color _tierBorderColor(int tier) => switch (tier) {
        1 => AshenColors.border,
        2 => AshenColors.copper.withAlpha(80),
        _ => AshenColors.inkRed.withAlpha(120),
      };

  void _showSpellDetail(BuildContext context, Spell spell) {
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
            // Header
            Row(children: [
              _tierChip(spell.tier),
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
              _effectLabel(spell.effectType).toUpperCase(),
              style: AshenText.dim.copyWith(
                  fontSize: 10, letterSpacing: 2, color: AshenColors.ashGrey),
            ),
            const SizedBox(height: 14),
            // Description
            Text(spell.description, style: AshenText.body.copyWith(fontSize: 13)),
            const SizedBox(height: 10),
            // Mechanical details
            _spellStatRow(spell),
            const SizedBox(height: 12),
            // Flavor text
            Text(spell.flavorText,
                style: AshenText.dim.copyWith(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AshenColors.parchmentDim)),
            const SizedBox(height: 14),
            // Allowed classes
            Text(
              'USABLE BY  ·  ${spell.allowedClasses.map((c) => c.name.toUpperCase()).join('  ·  ')}',
              style: AshenText.dim.copyWith(fontSize: 10, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spellStatRow(Spell spell) {
    final parts = <String>[];
    if (spell.powerScale > 0) {
      parts.add('Power ×${spell.powerScale.toStringAsFixed(1)}');
    }
    if (spell.flatBonus > 0) {
      final label = switch (spell.effectType) {
        SpellEffectType.buff    => '+${spell.flatBonus} defense',
        SpellEffectType.debuff  => '−${spell.flatBonus} enemy armor',
        SpellEffectType.summon  => '+${spell.flatBonus} dmg/round',
        _                       => '+${spell.flatBonus} flat',
      };
      parts.add(label);
    }
    if (spell.duration > 1) parts.add('${spell.duration} rounds');
    if (parts.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AshenColors.copper, width: 2)),
        color: Color(0x10D4956A),
      ),
      child: Text(
        parts.join('  ·  '),
        style: AshenText.dim.copyWith(fontSize: 12, color: AshenColors.copper),
      ),
    );
  }

  Widget _tierChip(int tier) => Container(
    width: 24,
    height: 16,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: switch (tier) {
        1 => AshenColors.border,
        2 => AshenColors.copper.withAlpha(80),
        _ => AshenColors.inkRed.withAlpha(120),
      },
    ),
    child: Text(
      'T$tier',
      style: const TextStyle(
          color: AshenColors.parchment, fontSize: 9, fontWeight: FontWeight.bold),
    ),
  );

  String _effectLabel(SpellEffectType t) => switch (t) {
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

  Widget _slotRow({
    required String slotLabel,
    required String itemName,
    String? detail,
    VoidCallback? onUnequip,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(slotLabel, style: AshenText.dim.copyWith(fontSize: 11)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(itemName,
                      style: itemName == '—'
                          ? AshenText.dim
                          : AshenText.body.copyWith(fontSize: 13)),
                  if (detail != null)
                    Text(detail, style: AshenText.dim.copyWith(fontSize: 11)),
                ],
              ),
            ),
            if (onUnequip != null)
              GestureDetector(
                onTap: onUnequip,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text('UNEQUIP',
                      style: TextStyle(
                          color: AshenColors.ashGrey,
                          fontSize: 10,
                          letterSpacing: 1)),
                ),
              ),
          ],
        ),
      );

  Widget _vitalsSection(Hero h) {
    final healthPct = (h.currentHealth / h.maxHealth).clamp(0.0, 1.0);
    final manaPct = h.maxMana > 0
        ? (h.currentMana / h.maxMana).clamp(0.0, 1.0)
        : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          SizedBox(
            width: 30,
            child: Text('HP', style: AshenText.dim.copyWith(fontSize: 11)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: healthPct,
              minHeight: 7,
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
          const SizedBox(width: 12),
          Text('${h.currentHealth} / ${h.maxHealth}',
              style: AshenText.dim.copyWith(fontSize: 12)),
        ]),
        if (h.heroClass.isCaster && h.maxMana > 0) ...[
          const SizedBox(height: 6),
          Row(children: [
            SizedBox(
              width: 30,
              child: Text('MP', style: AshenText.dim.copyWith(
                  fontSize: 11, color: AshenColors.manaBlue)),
            ),
            Expanded(
              child: LinearProgressIndicator(
                value: manaPct,
                minHeight: 7,
                backgroundColor: AshenColors.border,
                valueColor: const AlwaysStoppedAnimation(AshenColors.manaBlue),
              ),
            ),
            const SizedBox(width: 12),
            Text('${h.currentMana} / ${h.maxMana}',
                style: AshenText.dim.copyWith(
                    fontSize: 12, color: AshenColors.manaBlue)),
          ]),
        ],
      ],
    );
  }

  Widget _xpSection(Hero h) {
    final xpNeeded = h.level * 100;
    final progress = (h.experience / xpNeeded).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('LEVEL ${h.level}', style: AshenText.heading),
            const Spacer(),
            Text('${h.experience} / $xpNeeded XP', style: AshenText.dim),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          minHeight: 5,
          backgroundColor: AshenColors.border,
          valueColor: const AlwaysStoppedAnimation(AshenColors.copper),
        ),
        if (h.level < 10) ...[
          const SizedBox(height: 4),
          Text('Specialization unlocks at Level 10',
              style: AshenText.dim.copyWith(fontSize: 11)),
        ],
      ],
    );
  }

  Widget _subclassSection(BuildContext context, WidgetRef ref, Hero h) {
    final classDef = allClasses.firstWhere((c) => c.heroClass == h.heroClass);

    if (h.subclass != null) {
      final subDef =
          classDef.subclasses.firstWhere((s) => s.subclass == h.subclass);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading('SPECIALIZATION'),
          const SizedBox(height: 8),
          Text(subDef.name,
              style: AshenText.body
                  .copyWith(color: AshenColors.copper, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subDef.description, style: AshenText.dim),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: subDef.signatureAbilities
                .map((a) => _abilityChip(a))
                .toList(),
          ),
        ],
      );
    }

    if (h.level >= 10) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('SPECIALIZATION', style: AshenText.heading),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AshenColors.copper.withAlpha(40),
                  border: Border.all(color: AshenColors.copper),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('CHOOSE',
                    style: TextStyle(
                        color: AshenColors.copper,
                        fontSize: 10,
                        letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Your hero has grown powerful enough to specialize. This choice is permanent.',
            style: AshenText.dim,
          ),
          const SizedBox(height: 12),
          ...classDef.subclasses.map(
            (sub) => _subclassOption(context, ref, h, sub),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _subclassOption(
    BuildContext context,
    WidgetRef ref,
    Hero h,
    SubclassDefinition sub,
  ) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AshenColors.parchmentWarm, AshenColors.background],
            stops: [0.0, 0.3],
          ),
          border: Border(
            left:   BorderSide(color: AshenColors.copper, width: 2.5),
            top:    BorderSide(color: AshenColors.border, width: 0.5),
            right:  BorderSide(color: AshenColors.border, width: 0.5),
            bottom: BorderSide(color: AshenColors.border, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sub.name,
                style: AshenText.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(sub.description, style: AshenText.dim),
            const SizedBox(height: 6),
            _statBonusRow(sub.statBonus),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: sub.signatureAbilities
                  .map((a) => _abilityChip(a))
                  .toList(),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _confirmSubclass(context, ref, h, sub),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: const BoxDecoration(
                  border: Border(
                    left:   BorderSide(color: AshenColors.copper, width: 2),
                    top:    BorderSide(color: AshenColors.copper, width: 0.5),
                    right:  BorderSide(color: AshenColors.copper, width: 0.5),
                    bottom: BorderSide(color: AshenColors.copper, width: 0.5),
                  ),
                ),
                child: Text(
                  'BECOME ${sub.name.toUpperCase()}',
                  style: const TextStyle(
                      color: AshenColors.copper,
                      fontSize: 11,
                      letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      );

  void _confirmSubclass(
    BuildContext context,
    WidgetRef ref,
    Hero h,
    SubclassDefinition sub,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AshenColors.surface,
        title: Text('Become ${sub.name}?',
            style: AshenText.body
                .copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
          'This is permanent. ${h.name} will specialize as a ${sub.name} and cannot change path.',
          style: AshenText.dim,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL',
                style: TextStyle(color: AshenColors.ashGrey)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(gameProvider.notifier)
                  .chooseSubclass(h.id, sub.subclass);
              Navigator.pop(context);
            },
            child: const Text('CONFIRM',
                style: TextStyle(color: AshenColors.copper)),
          ),
        ],
      ),
    );
  }

  Widget _statBonusRow(HeroStats bonus) {
    final parts = <String>[];
    if (bonus.strength > 0)     parts.add('+${bonus.strength} STR');
    if (bonus.dexterity > 0)    parts.add('+${bonus.dexterity} DEX');
    if (bonus.endurance > 0)    parts.add('+${bonus.endurance} END');
    if (bonus.intelligence > 0) parts.add('+${bonus.intelligence} INT');
    if (bonus.faith > 0)        parts.add('+${bonus.faith} FAI');
    if (bonus.luck > 0)         parts.add('+${bonus.luck} LCK');
    return Text(parts.join('  '), style: AshenText.gold.copyWith(fontSize: 12));
  }

  Widget _abilityChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AshenColors.border,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: AshenText.dim.copyWith(fontSize: 10)),
      );

  Widget _statRow(String label, int value, String tooltip) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 110, child: Text(label, style: AshenText.body)),
            Text('$value', style: AshenText.gold),
            const SizedBox(width: 12),
            Expanded(child: Text(tooltip, style: AshenText.dim)),
          ],
        ),
      );

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
        FaithType.luminantChurch  => 'The Luminant Church',
        FaithType.oldWays         => 'The Old Ways',
        FaithType.paleCourt       => 'The Pale Court',
        FaithType.compactOfSaints => 'The Compact of Saints',
        FaithType.ashenRite       => 'The Ashen Rite',
        null                      => 'None',
      };
}

// ─── RETIREMENT PERKS BANNER ─────────────────────────────────────────────────

class _RetirementBanner extends StatelessWidget {
  final List<String> perks;
  const _RetirementBanner({required this.perks});

  @override
  Widget build(BuildContext context) {
    final goldCount = perks.where((p) => p == 'gold_legacy').length;
    final xpCount   = perks.where((p) => p == 'xp_legacy').length;
    final parts = <String>[];
    if (goldCount > 0) parts.add('+${(goldCount * 3)}% gold');
    if (xpCount > 0)   parts.add('+${(xpCount * 3)}% XP');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AshenColors.gold, width: 2)),
        color: AshenColors.parchmentWarm,
      ),
      child: Text(
        '✦ ${perks.length} ${perks.length == 1 ? 'hero has' : 'heroes have'} retired. '
        'Legacy bonuses: ${parts.join(', ')} from all expeditions.',
        style: AshenText.dim.copyWith(fontSize: 11, color: AshenColors.gold),
      ),
    );
  }
}

// ─── ACTIVE QUESTS BANNER ────────────────────────────────────────────────────

class _ActiveQuestsBanner extends StatelessWidget {
  final List<Quest> quests;
  const _ActiveQuestsBanner({required this.quests});

  @override
  Widget build(BuildContext context) {
    final active = quests.where((q) => !q.completed).toList();
    if (active.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AshenColors.copper, width: 2)),
        color: AshenColors.parchmentWarm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE QUESTS',
            style: AshenText.dim.copyWith(
                fontSize: 9, letterSpacing: 1.5, color: AshenColors.copper),
          ),
          const SizedBox(height: 4),
          ...active.map((q) {
            final progressText = q.type == QuestType.expeditionCount
                ? '${q.progress}/${q.targetValue}'
                : q.progress >= q.targetValue ? 'Complete' : 'Pending';
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(q.title,
                        style: AshenText.dim.copyWith(fontSize: 11)),
                  ),
                  Text(progressText,
                      style: AshenText.dim
                          .copyWith(fontSize: 10, color: AshenColors.copper)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── BONDS SUMMARY ────────────────────────────────────────────────────────────

class _BondsSummary extends ConsumerWidget {
  final List<Hero> party;
  const _BondsSummary({required this.party});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bonds = ref.watch(gameProvider.select((s) => s.heroBonds));
    if (bonds.isEmpty || party.length < 2) return const SizedBox.shrink();

    // Find pairs with at least 1 expedition together
    final pairs = <(String, String, int)>[];
    final ids = party.map((h) => h.id).toList()..sort();
    for (int i = 0; i < ids.length; i++) {
      for (int j = i + 1; j < ids.length; j++) {
        final key = '${ids[i]}:${ids[j]}';
        final count = bonds[key] ?? 0;
        if (count > 0) {
          pairs.add((ids[i], ids[j], count));
        }
      }
    }
    if (pairs.isEmpty) return const SizedBox.shrink();
    pairs.sort((a, b) => b.$3.compareTo(a.$3));

    String heroName(String id) =>
        party.where((h) => h.id == id).firstOrNull?.name ?? id;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ParchmentPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HERO BONDS',
              style: AshenText.dim.copyWith(
                  letterSpacing: 2, fontSize: 10, color: AshenColors.copper),
            ),
            const SizedBox(height: 8),
            ...pairs.map((pair) {
              final bonded = pair.$3 >= 5;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    if (bonded)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Text('♥',
                            style: TextStyle(
                                fontSize: 11, color: AshenColors.copper)),
                      ),
                    Expanded(
                      child: Text(
                        '${heroName(pair.$1)} & ${heroName(pair.$2)}',
                        style: AshenText.body.copyWith(fontSize: 12),
                      ),
                    ),
                    Text(
                      '${pair.$3} exp${bonded ? "  ·  +5% gold" : ""}',
                      style: AshenText.dim.copyWith(
                          fontSize: 11,
                          color: bonded ? AshenColors.copper : null),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
