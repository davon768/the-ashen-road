import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../theme/colors.dart';
import '../theme/parchment_widgets.dart';
import '../models/enums.dart';
import '../models/property.dart';
import '../data/weapons_data.dart';
import '../data/armor_data.dart';
import '../models/weapon.dart';
import '../models/armor.dart';

// Compute max rarity visible in the Iron Hearth based on owned addons.
Rarity _shopMaxRarity(List<OwnedProperty> properties) {
  final bs = properties.where((p) => p.type == PropertyType.blacksmith).firstOrNull;
  if (bs == null) return Rarity.uncommon;
  if (bs.unlockedAddonIds.contains('blacksmith_armory')) return Rarity.legendary;
  if (bs.unlockedAddonIds.contains('blacksmith_apprentice')) return Rarity.rare;
  return Rarity.uncommon;
}

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AshenColors.background,
        appBar: AppBar(
          backgroundColor: AshenColors.surface,
          elevation: 0,
          title: const Text(
            'THE IRON HEARTH',
            style: TextStyle(
              color: AshenColors.copper,
              fontSize: 14,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: AshenColors.copper,
            unselectedLabelColor: AshenColors.ashGrey,
            indicatorColor: AshenColors.copper,
            labelStyle: TextStyle(letterSpacing: 2, fontSize: 12),
            tabs: [
              Tab(text: 'WEAPONS'),
              Tab(text: 'ARMOR'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _WeaponsShopTab(),
            _ArmorShopTab(),
          ],
        ),
      ),
    );
  }
}

// ─── WEAPONS SHOP ─────────────────────────────────────────────────────────────

class _WeaponsShopTab extends ConsumerWidget {
  const _WeaponsShopTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gold       = ref.watch(goldProvider);
    final properties = ref.watch(propertiesProvider);
    final maxRarity  = _shopMaxRarity(properties);
    final visible    = allWeapons.where((w) => w.rarity.index <= maxRarity.index).toList();
    final lockedCount = allWeapons.length - visible.length;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visible.length + (lockedCount > 0 ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == visible.length) return _LockedTierBanner(lockedCount: lockedCount);
        return _WeaponShopTile(weapon: visible[i], gold: gold);
      },
    );
  }
}

class _WeaponShopTile extends ConsumerWidget {
  final Weapon weapon;
  final int gold;
  const _WeaponShopTile({required this.weapon, required this.gold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAfford = gold >= weapon.value;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AshenColors.surface,
        border: Border.all(
            color: _rarityColor(weapon.rarity).withAlpha(canAfford ? 100 : 40)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weapon.name,
                    style: AshenText.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: canAfford
                            ? AshenColors.parchment
                            : AshenColors.parchmentDim)),
                const SizedBox(height: 2),
                Text(weapon.historicalName,
                    style: AshenText.dim.copyWith(
                        color: _rarityColor(weapon.rarity), fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  '${weapon.minDamage}–${weapon.maxDamage} dmg  ·  '
                  '${_gripLabel(weapon.grip)}  ·  ${_typeLabel(weapon.type)}',
                  style: AshenText.dim,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${weapon.value}g',
                style: AshenText.gold.copyWith(
                    color: canAfford
                        ? AshenColors.gold
                        : AshenColors.parchmentDim),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: canAfford
                    ? () => ref.read(gameProvider.notifier).buyWeapon(weapon.id)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: canAfford
                            ? AshenColors.copper
                            : AshenColors.border),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'BUY',
                    style: TextStyle(
                        color: canAfford
                            ? AshenColors.copper
                            : AshenColors.ashGrey,
                        fontSize: 11,
                        letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── ARMOR SHOP ───────────────────────────────────────────────────────────────

class _ArmorShopTab extends ConsumerWidget {
  const _ArmorShopTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gold       = ref.watch(goldProvider);
    final properties = ref.watch(propertiesProvider);
    final maxRarity  = _shopMaxRarity(properties);
    final visible    = allArmor.where((a) => a.rarity.index <= maxRarity.index).toList();
    final lockedCount = allArmor.length - visible.length;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visible.length + (lockedCount > 0 ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == visible.length) return _LockedTierBanner(lockedCount: lockedCount);
        return _ArmorShopTile(armor: visible[i], gold: gold);
      },
    );
  }
}

class _ArmorShopTile extends ConsumerWidget {
  final Armor armor;
  final int gold;
  const _ArmorShopTile({required this.armor, required this.gold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAfford = gold >= armor.value;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AshenColors.surface,
        border: Border.all(
            color: _rarityColor(armor.rarity).withAlpha(canAfford ? 100 : 40)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(armor.name,
                    style: AshenText.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: canAfford
                            ? AshenColors.parchment
                            : AshenColors.parchmentDim)),
                const SizedBox(height: 2),
                Text(armor.historicalName,
                    style: AshenText.dim.copyWith(
                        color: _rarityColor(armor.rarity), fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  '${_slotLabel(armor.slot)}  ·  ${armor.defense} def  ·  ${armor.weight} wt',
                  style: AshenText.dim,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${armor.value}g',
                style: AshenText.gold.copyWith(
                    color: canAfford
                        ? AshenColors.gold
                        : AshenColors.parchmentDim),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: canAfford
                    ? () => ref.read(gameProvider.notifier).buyArmor(armor.id)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: canAfford
                            ? AshenColors.copper
                            : AshenColors.border),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'BUY',
                    style: TextStyle(
                        color: canAfford
                            ? AshenColors.copper
                            : AshenColors.ashGrey,
                        fontSize: 11,
                        letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── LOCKED TIER BANNER ──────────────────────────────────────────────────────

class _LockedTierBanner extends StatelessWidget {
  final int lockedCount;
  const _LockedTierBanner({required this.lockedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: AshenColors.border, width: 2)),
        color: AshenColors.surfaceAlt,
      ),
      child: Text(
        '$lockedCount higher-quality items are locked. '
        'Upgrade the Iron Hearth with an Apprentice or Full Armory to unlock them.',
        style: const TextStyle(
          color: AshenColors.ashGrey, fontSize: 11, fontStyle: FontStyle.italic),
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────

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
