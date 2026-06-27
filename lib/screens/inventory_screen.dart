import 'package:flutter/material.dart' hide Hero;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../theme/colors.dart';
import '../models/hero.dart';
import '../models/enums.dart';
import '../models/weapon.dart';
import '../models/armor.dart';
import '../models/item_instance.dart';
import '../data/weapons_data.dart';
import '../data/armor_data.dart';
import '../data/consumables_data.dart';
import '../data/spells_data.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AshenColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AshenColors.surface,
            child: const TabBar(
              labelColor: AshenColors.copper,
              unselectedLabelColor: AshenColors.ashGrey,
              indicatorColor: AshenColors.copper,
              labelStyle: TextStyle(letterSpacing: 2, fontSize: 12),
              tabs: [
                Tab(text: 'WEAPONS'),
                Tab(text: 'ARMOR'),
                Tab(text: 'TOMES'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _WeaponsTab(),
            _ArmorTab(),
            _TomesTab(),
          ],
        ),
      ),
    );
  }
}

// ─── WEAPONS TAB ─────────────────────────────────────────────────────────────

class _WeaponsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final party = ref.watch(partyProvider);

    final instancedWeapons =
        inventory.itemInstances.where((i) => i.isWeapon).toList();
    final regularWeapons = inventory.weapons.entries
        .map((e) => (id: e.key, qty: e.value))
        .toList();

    if (instancedWeapons.isEmpty && regularWeapons.isEmpty) {
      return _emptyState('No weapons in your pack.',
          'Complete expeditions or buy from a trader.');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (instancedWeapons.isNotEmpty) ...[
          _sectionHeader('ENCHANTED WEAPONS'),
          ...instancedWeapons.map((inst) {
            final weapon =
                allWeapons.where((w) => w.id == inst.baseItemId).firstOrNull;
            if (weapon == null) return const SizedBox.shrink();
            final isEquipped = party.any((h) =>
                h.equipment.slotInstanceIds.values.contains(inst.instanceId));
            return _InstancedWeaponTile(
                instance: inst, weapon: weapon, isEquipped: isEquipped);
          }),
          if (regularWeapons.isNotEmpty) const SizedBox(height: 8),
        ],
        if (regularWeapons.isNotEmpty) ...[
          if (instancedWeapons.isNotEmpty) _sectionHeader('STANDARD WEAPONS'),
          ...regularWeapons.map((entry) {
            final weapon =
                allWeapons.where((w) => w.id == entry.id).firstOrNull;
            if (weapon == null) return const SizedBox.shrink();
            return _WeaponTile(weapon: weapon, qty: entry.qty);
          }),
        ],
      ],
    );
  }
}

// ─── ARMOR TAB ───────────────────────────────────────────────────────────────

class _ArmorTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final party = ref.watch(partyProvider);

    final instancedArmor =
        inventory.itemInstances.where((i) => !i.isWeapon).toList();
    final regularArmor = inventory.armor.entries
        .map((e) => (id: e.key, qty: e.value))
        .toList();

    if (instancedArmor.isEmpty && regularArmor.isEmpty) {
      return _emptyState('No armor in your pack.',
          'Complete expeditions or buy from a trader.');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (instancedArmor.isNotEmpty) ...[
          _sectionHeader('ENCHANTED ARMOR'),
          ...instancedArmor.map((inst) {
            final armor =
                allArmor.where((a) => a.id == inst.baseItemId).firstOrNull;
            if (armor == null) return const SizedBox.shrink();
            final isEquipped = party.any((h) =>
                h.equipment.slotInstanceIds.values.contains(inst.instanceId));
            return _InstancedArmorTile(
                instance: inst, armor: armor, isEquipped: isEquipped);
          }),
          if (regularArmor.isNotEmpty) const SizedBox(height: 8),
        ],
        if (regularArmor.isNotEmpty) ...[
          if (instancedArmor.isNotEmpty) _sectionHeader('STANDARD ARMOR'),
          ...regularArmor.map((entry) {
            final armor =
                allArmor.where((a) => a.id == entry.id).firstOrNull;
            if (armor == null) return const SizedBox.shrink();
            return _ArmorTile(armor: armor, qty: entry.qty);
          }),
        ],
      ],
    );
  }
}

// ─── INSTANCED WEAPON TILE ────────────────────────────────────────────────────

class _InstancedWeaponTile extends ConsumerWidget {
  final ItemInstance instance;
  final Weapon weapon;
  final bool isEquipped;
  const _InstancedWeaponTile(
      {required this.instance,
      required this.weapon,
      required this.isEquipped});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rarityColor = _rarityColor(instance.rarity);
    final sellValue = _instanceSellValue(instance, weapon.value);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            rarityColor.withValues(alpha: 0.08),
            AshenColors.surface,
          ],
          stops: const [0.0, 0.35],
        ),
        border: Border(
          left: BorderSide(color: rarityColor, width: 3),
          top: const BorderSide(color: AshenColors.border, width: 0.5),
          right: const BorderSide(color: AshenColors.border, width: 0.5),
          bottom: const BorderSide(color: AshenColors.border, width: 0.5),
        ),
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
                      Text(instance.displayName(weapon.name),
                          style: AshenText.body
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        instance.rarity.name.toUpperCase(),
                        style: TextStyle(
                          color: rarityColor,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isEquipped)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: rarityColor.withValues(alpha: 0.15),
                    child: Text('EQUIPPED',
                        style: TextStyle(
                            color: rarityColor,
                            fontSize: 9,
                            letterSpacing: 1.5)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${weapon.minDamage}–${weapon.maxDamage} dmg  ·  '
              '${_gripLabel(weapon.grip)}  ·  ${_typeLabel(weapon.type)}',
              style: AshenText.dim,
            ),
            if (instance.modifiers.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...instance.modifiers.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 10,
                            color: rarityColor.withValues(alpha: 0.8)),
                        const SizedBox(width: 6),
                        Text(m.displayText,
                            style: TextStyle(
                              color: rarityColor.withValues(alpha: 0.9),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            )),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (!isEquipped) ...[
                  _actionButton(
                    label: 'EQUIP',
                    color: rarityColor,
                    onTap: () => _showEquipPicker(context, ref),
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    label: 'SELL  $sellValue g',
                    color: AshenColors.ashGrey,
                    onTap: () => _confirmSell(
                      context,
                      instance.displayName(weapon.name),
                      () => ref.read(gameProvider.notifier).sellItemInstance(instance.instanceId),
                    ),
                  ),
                ] else
                  _actionButton(
                    label: 'UNEQUIP',
                    color: AshenColors.ashGrey,
                    onTap: () => _doUnequip(ref),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEquipPicker(BuildContext context, WidgetRef ref) {
    final party = ref.read(partyProvider);
    if (party.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AshenColors.surface,
      shape:
          const Border(top: BorderSide(color: AshenColors.inkRed, width: 1.5)),
      builder: (_) => _HeroPickerSheet(
        label: 'Equip ${instance.displayName(weapon.name)} on...',
        party: party,
        onSelect: (heroId) => ref
            .read(gameProvider.notifier)
            .equipItemInstance(heroId, instance.instanceId),
      ),
    );
  }

  void _doUnequip(WidgetRef ref) {
    final party = ref.read(partyProvider);
    for (final hero in party) {
      if (hero.equipment.slotInstanceIds.values
          .contains(instance.instanceId)) {
        ref.read(gameProvider.notifier).unequipWeapon(hero.id);
        return;
      }
    }
  }
}

// ─── INSTANCED ARMOR TILE ─────────────────────────────────────────────────────

class _InstancedArmorTile extends ConsumerWidget {
  final ItemInstance instance;
  final Armor armor;
  final bool isEquipped;
  const _InstancedArmorTile(
      {required this.instance,
      required this.armor,
      required this.isEquipped});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rarityColor = _rarityColor(instance.rarity);
    final sellValue = _instanceSellValue(instance, armor.value);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            rarityColor.withValues(alpha: 0.08),
            AshenColors.surface,
          ],
          stops: const [0.0, 0.35],
        ),
        border: Border(
          left: BorderSide(color: rarityColor, width: 3),
          top: const BorderSide(color: AshenColors.border, width: 0.5),
          right: const BorderSide(color: AshenColors.border, width: 0.5),
          bottom: const BorderSide(color: AshenColors.border, width: 0.5),
        ),
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
                      Text(instance.displayName(armor.name),
                          style: AshenText.body
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        instance.rarity.name.toUpperCase(),
                        style: TextStyle(
                          color: rarityColor,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isEquipped)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: rarityColor.withValues(alpha: 0.15),
                    child: Text('EQUIPPED',
                        style: TextStyle(
                            color: rarityColor,
                            fontSize: 9,
                            letterSpacing: 1.5)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${_slotLabel(armor.slot)}  ·  ${armor.defense} def  ·  ${armor.weight} wt',
              style: AshenText.dim,
            ),
            if (instance.modifiers.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...instance.modifiers.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 10,
                            color: rarityColor.withValues(alpha: 0.8)),
                        const SizedBox(width: 6),
                        Text(m.displayText,
                            style: TextStyle(
                              color: rarityColor.withValues(alpha: 0.9),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            )),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (!isEquipped) ...[
                  _actionButton(
                    label: 'EQUIP',
                    color: rarityColor,
                    onTap: () => _showEquipPicker(context, ref),
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    label: 'SELL  $sellValue g',
                    color: AshenColors.ashGrey,
                    onTap: () => _confirmSell(
                      context,
                      instance.displayName(armor.name),
                      () => ref.read(gameProvider.notifier).sellItemInstance(instance.instanceId),
                    ),
                  ),
                ] else
                  _actionButton(
                    label: 'UNEQUIP',
                    color: AshenColors.ashGrey,
                    onTap: () => _doUnequip(ref),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEquipPicker(BuildContext context, WidgetRef ref) {
    final party = ref.read(partyProvider);
    if (party.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AshenColors.surface,
      shape:
          const Border(top: BorderSide(color: AshenColors.inkRed, width: 1.5)),
      builder: (_) => _HeroPickerSheet(
        label: 'Equip ${instance.displayName(armor.name)} on...',
        party: party,
        onSelect: (heroId) => ref
            .read(gameProvider.notifier)
            .equipItemInstance(heroId, instance.instanceId),
      ),
    );
  }

  void _doUnequip(WidgetRef ref) {
    final party = ref.read(partyProvider);
    for (final hero in party) {
      final slotEntry = hero.equipment.slotInstanceIds.entries
          .where((e) => e.value == instance.instanceId)
          .firstOrNull;
      if (slotEntry != null) {
        final slot = _parseArmorSlot(slotEntry.key);
        if (slot != null) {
          ref.read(gameProvider.notifier).unequipArmor(hero.id, slot);
        }
        return;
      }
    }
  }

  ArmorSlot? _parseArmorSlot(String name) => switch (name) {
        'head'   => ArmorSlot.head,
        'body'   => ArmorSlot.body,
        'hands'  => ArmorSlot.hands,
        'legs'   => ArmorSlot.legs,
        'feet'   => ArmorSlot.feet,
        'shield' => ArmorSlot.shield,
        _        => null,
      };
}

// ─── STANDARD WEAPON TILE ────────────────────────────────────────────────────

class _WeaponTile extends ConsumerWidget {
  final Weapon weapon;
  final int qty;
  const _WeaponTile({required this.weapon, required this.qty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellValue   = (weapon.value * 0.5).floor();
    final accentColor = _rarityColor(weapon.rarity);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AshenColors.parchmentWarm, AshenColors.surface],
          stops: [0.0, 0.3],
        ),
        border: Border(
          left:   BorderSide(color: accentColor.withAlpha(200), width: 3),
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
              Expanded(
                child: Text(weapon.name,
                    style: AshenText.body.copyWith(fontWeight: FontWeight.bold)),
              ),
              if (qty > 1)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: AshenColors.border,
                  child: Text('x$qty',
                      style: AshenText.dim.copyWith(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(weapon.historicalName,
              style:
                  AshenText.dim.copyWith(color: accentColor, fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            '${weapon.minDamage}–${weapon.maxDamage} dmg  ·  ${_gripLabel(weapon.grip)}  ·  ${_typeLabel(weapon.type)}',
            style: AshenText.dim,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _actionButton(
                label: 'EQUIP',
                color: AshenColors.copper,
                onTap: () => _showEquipPicker(context, ref, weapon.id),
              ),
              const SizedBox(width: 8),
              _actionButton(
                label: 'SELL  $sellValue g',
                color: AshenColors.ashGrey,
                onTap: () => _confirmSell(
                  context,
                  weapon.name,
                  () => ref.read(gameProvider.notifier).sellWeapon(weapon.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEquipPicker(
      BuildContext context, WidgetRef ref, String weaponId) {
    final party = ref.read(partyProvider);
    if (party.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No heroes in your party.'),
            backgroundColor: AshenColors.surface),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AshenColors.surface,
      shape:
          const Border(top: BorderSide(color: AshenColors.inkRed, width: 1.5)),
      builder: (_) => _HeroPickerSheet(
        label: 'Equip ${weapon.name} on...',
        party: party,
        onSelect: (heroId) =>
            ref.read(gameProvider.notifier).equipWeapon(heroId, weaponId),
      ),
    );
  }
}

// ─── STANDARD ARMOR TILE ─────────────────────────────────────────────────────

class _ArmorTile extends ConsumerWidget {
  final Armor armor;
  final int qty;
  const _ArmorTile({required this.armor, required this.qty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellValue   = (armor.value * 0.5).floor();
    final accentColor = _rarityColor(armor.rarity);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AshenColors.parchmentWarm, AshenColors.surface],
          stops: [0.0, 0.3],
        ),
        border: Border(
          left:   BorderSide(color: accentColor.withAlpha(200), width: 3),
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
              Expanded(
                child: Text(armor.name,
                    style: AshenText.body.copyWith(fontWeight: FontWeight.bold)),
              ),
              if (qty > 1)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: AshenColors.border,
                  child: Text('x$qty',
                      style: AshenText.dim.copyWith(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(armor.historicalName,
              style:
                  AshenText.dim.copyWith(color: accentColor, fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            '${_slotLabel(armor.slot)}  ·  ${armor.defense} def  ·  ${armor.weight} wt',
            style: AshenText.dim,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _actionButton(
                label: 'EQUIP',
                color: AshenColors.copper,
                onTap: () => _showEquipPicker(context, ref, armor.id),
              ),
              const SizedBox(width: 8),
              _actionButton(
                label: 'SELL  $sellValue g',
                color: AshenColors.ashGrey,
                onTap: () => _confirmSell(
                  context,
                  armor.name,
                  () => ref.read(gameProvider.notifier).sellArmor(armor.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEquipPicker(
      BuildContext context, WidgetRef ref, String armorId) {
    final party = ref.read(partyProvider);
    if (party.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No heroes in your party.'),
            backgroundColor: AshenColors.surface),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AshenColors.surface,
      shape:
          const Border(top: BorderSide(color: AshenColors.inkRed, width: 1.5)),
      builder: (_) => _HeroPickerSheet(
        label: 'Equip ${armor.name} on...',
        party: party,
        onSelect: (heroId) =>
            ref.read(gameProvider.notifier).equipArmor(heroId, armorId),
      ),
    );
  }
}

// ─── SHARED WIDGETS ───────────────────────────────────────────────────────────

class _HeroPickerSheet extends StatelessWidget {
  final String label;
  final List<Hero> party;
  final void Function(String heroId) onSelect;

  const _HeroPickerSheet({
    required this.label,
    required this.party,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AshenText.body
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            ...party.map(
              (hero) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(hero.name, style: AshenText.body),
                subtitle: Text(
                  '${_className(hero.heroClass)}  ·  Lv ${hero.level}',
                  style: AshenText.dim,
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AshenColors.ashGrey),
                onTap: () {
                  onSelect(hero.id);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────

Widget _sectionHeader(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AshenText.dim.copyWith(
          letterSpacing: 2,
          fontSize: 10,
          color: AshenColors.copper,
        ),
      ),
    );

Widget _emptyState(String title, String subtitle) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.backpack_outlined,
                color: AshenColors.ashGrey, size: 40),
            const SizedBox(height: 12),
            Text(title, style: AshenText.body, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle, style: AshenText.dim, textAlign: TextAlign.center),
          ],
        ),
      ),
    );

Widget _actionButton({
  required String label,
  required Color color,
  required VoidCallback onTap,
}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withAlpha(180)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 11, letterSpacing: 1)),
      ),
    );

Future<void> _confirmSell(
  BuildContext context,
  String itemName,
  VoidCallback onConfirm,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AshenColors.surface,
      shape: const RoundedRectangleBorder(),
      title: Text(
        'SELL ITEM',
        style: TextStyle(
          color: AshenColors.copper,
          fontSize: 13,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Sell $itemName? This cannot be undone.',
        style: AshenText.dim,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('CANCEL',
              style: TextStyle(color: AshenColors.ashGrey, fontSize: 11, letterSpacing: 1)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('SELL',
              style: TextStyle(color: AshenColors.copper, fontSize: 11, letterSpacing: 1)),
        ),
      ],
    ),
  );
  if (confirmed == true) onConfirm();
}

int _instanceSellValue(ItemInstance instance, int baseValue) {
  final mult = switch (instance.rarity) {
    Rarity.common    => 0.5,
    Rarity.uncommon  => 0.65,
    Rarity.rare      => 0.8,
    Rarity.epic      => 1.0,
    Rarity.legendary => 1.3,
  };
  return (baseValue * mult).round().clamp(1, 99999);
}

Color _rarityColor(Rarity r) => switch (r) {
      Rarity.common    => AshenColors.ashGrey,
      Rarity.uncommon  => const Color(0xFF4CAF50),
      Rarity.rare      => const Color(0xFF2196F3),
      Rarity.epic      => const Color(0xFF9C27B0),
      Rarity.legendary => const Color(0xFFFF9800),
    };

String _gripLabel(WeaponGrip g) => switch (g) {
      WeaponGrip.oneHanded => 'One-handed',
      WeaponGrip.twoHanded => 'Two-handed',
      WeaponGrip.versatile => 'Versatile',
    };

String _typeLabel(WeaponType t) => switch (t) {
      WeaponType.sword    => 'Sword',
      WeaponType.axe      => 'Axe',
      WeaponType.polearm  => 'Polearm',
      WeaponType.blunt    => 'Blunt',
      WeaponType.dagger   => 'Dagger',
      WeaponType.bow      => 'Bow',
      WeaponType.crossbow => 'Crossbow',
      WeaponType.staff    => 'Staff',
      WeaponType.tome     => 'Tome',
      WeaponType.wand     => 'Wand',
    };

String _slotLabel(ArmorSlot s) => switch (s) {
      ArmorSlot.head   => 'Head',
      ArmorSlot.body   => 'Body',
      ArmorSlot.hands  => 'Hands',
      ArmorSlot.legs   => 'Legs',
      ArmorSlot.feet   => 'Feet',
      ArmorSlot.shield => 'Shield',
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

// ─── TOMES TAB ────────────────────────────────────────────────────────────────

class _TomesTab extends ConsumerWidget {
  const _TomesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final party     = ref.watch(partyProvider);
    final notifier  = ref.read(gameProvider.notifier);

    final tomes = inventory.consumables.entries
        .where((e) => isSpellTome(e.key) && e.value > 0)
        .toList();

    if (tomes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No spell tomes in your possession.\n\nTomes are found in dungeons and ruins at depth 3 and beyond.',
            style: AshenText.dim,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('SPELL TOMES', style: AshenText.heading),
        const SizedBox(height: 4),
        Text(
          'Use a tome to teach a spell to a caster in your party.',
          style: AshenText.dim,
        ),
        const SizedBox(height: 16),
        ...tomes.map((entry) {
          final tomeId  = entry.key;
          final qty     = entry.value;
          final spellId = tomeSpellId(tomeId)!;
          final spell   = spellById(spellId);
          if (spell == null) return const SizedBox.shrink();

          final eligibleCasters = party.where((h) =>
              spell.allowedClasses.contains(h.heroClass) &&
              !h.knownSpells.contains(spellId)).toList();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AshenColors.surface,
              border: const Border(
                left: BorderSide(color: AshenColors.copper, width: 2),
                top:    BorderSide(color: AshenColors.border, width: 0.5),
                right:  BorderSide(color: AshenColors.border, width: 0.5),
                bottom: BorderSide(color: AshenColors.border, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(
                    spell.name,
                    style: AshenText.body.copyWith(fontWeight: FontWeight.bold),
                  )),
                  if (qty > 1)
                    Text('×$qty', style: AshenText.dim.copyWith(fontSize: 12)),
                ]),
                const SizedBox(height: 2),
                Text(
                  spell.allowedClasses.map(_className).join(' · '),
                  style: AshenText.dim.copyWith(fontSize: 11, color: AshenColors.gold),
                ),
                const SizedBox(height: 6),
                Text(spell.description, style: AshenText.dim.copyWith(fontSize: 12)),
                const SizedBox(height: 10),
                if (eligibleCasters.isEmpty)
                  Text(
                    'No casters in your party can learn this spell.',
                    style: AshenText.dim.copyWith(
                        fontSize: 11, fontStyle: FontStyle.italic),
                  )
                else ...[
                  Text('TEACH TO:',
                      style: AshenText.dim.copyWith(
                          fontSize: 10, letterSpacing: 2,
                          color: AshenColors.copper)),
                  const SizedBox(height: 6),
                  ...eligibleCasters.map((hero) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      Expanded(child: Text(
                        '${hero.name}  ·  ${_className(hero.heroClass)}  Lv ${hero.level}',
                        style: AshenText.dim.copyWith(fontSize: 12),
                      )),
                      GestureDetector(
                        onTap: () => notifier.useSpellTome(hero.id, tomeId),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AshenColors.copper),
                          ),
                          child: const Text(
                            'LEARN',
                            style: TextStyle(
                                color: AshenColors.copper,
                                fontSize: 10,
                                letterSpacing: 1),
                          ),
                        ),
                      ),
                    ]),
                  )),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
