import 'package:flutter/material.dart' hide Hero;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/town_visit.dart';
import '../models/enums.dart';
import '../models/weapon.dart';
import '../models/armor.dart';
import '../models/item_instance.dart';
import '../data/weapons_data.dart';
import '../data/armor_data.dart';
import '../data/item_modifiers_data.dart';
import '../data/loot_tables.dart';
import '../data/spells_data.dart';
import '../models/spell.dart';
import '../state/providers.dart';
import '../theme/colors.dart';

class TraderScreen extends ConsumerWidget {
  final TownVisit visit;
  const TraderScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveVisit = ref.watch(townVisitProvider) ?? visit;
    final gold = ref.watch(goldProvider);
    final notifier = ref.read(gameProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AshenColors.background,
        appBar: AppBar(
          backgroundColor: AshenColors.surface,
          foregroundColor: AshenColors.parchment,
          title: Text(
            'THE TRADER',
            style: AshenText.heading.copyWith(fontSize: 14, letterSpacing: 3),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on,
                      size: 14, color: AshenColors.gold),
                  const SizedBox(width: 4),
                  Text('$gold g', style: AshenText.gold),
                ],
              ),
            ),
          ],
          bottom: const TabBar(
            labelColor: AshenColors.copper,
            unselectedLabelColor: AshenColors.ashGrey,
            indicatorColor: AshenColors.copper,
            labelStyle: TextStyle(letterSpacing: 2, fontSize: 11),
            tabs: [
              Tab(text: 'BUY'),
              Tab(text: 'SELL'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── BUY TAB ──────────────────────────────────────────
            liveVisit.traderStock.isEmpty
                ? _emptyBuyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: liveVisit.traderStock.length,
                    itemBuilder: (context, i) {
                      final offer = liveVisit.traderStock[i];
                      return _TraderItemCard(
                        offer: offer,
                        gold: gold,
                        onBuy: () => notifier.buyTraderItem(offer.offerId),
                      );
                    },
                  ),
            // ── SELL TAB ─────────────────────────────────────────
            const _SellTab(),
          ],
        ),
      ),
    );
  }

  Widget _emptyBuyState() => const Center(
        child: Text(
          'Nothing left to sell.',
          style: TextStyle(color: AshenColors.ashGrey, fontSize: 13),
        ),
      );
}

// ─── SELL TAB ─────────────────────────────────────────────────────────────────

class _SellTab extends ConsumerWidget {
  const _SellTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final party = ref.watch(partyProvider);

    final equippedInstanceIds = {
      for (final h in party)
        ...h.equipment.slotInstanceIds.values,
    };

    final instancedWeapons =
        inventory.itemInstances.where((i) => i.isWeapon).toList();
    final instancedArmor =
        inventory.itemInstances.where((i) => !i.isWeapon).toList();
    final regularWeapons = inventory.weapons.entries
        .map((e) => (id: e.key, qty: e.value))
        .where((e) => e.qty > 0)
        .toList();
    final regularArmor = inventory.armor.entries
        .map((e) => (id: e.key, qty: e.value))
        .where((e) => e.qty > 0)
        .toList();

    final hasAnything = instancedWeapons.isNotEmpty ||
        instancedArmor.isNotEmpty ||
        regularWeapons.isNotEmpty ||
        regularArmor.isNotEmpty;

    if (!hasAnything) {
      return const Center(
        child: Text(
          'Nothing in your pack to sell.',
          style: TextStyle(color: AshenColors.ashGrey, fontSize: 13),
        ),
      );
    }

    final items = <Widget>[];

    if (instancedWeapons.isNotEmpty) {
      items.add(_sellSectionHeader('ENCHANTED WEAPONS'));
      for (final inst in instancedWeapons) {
        final weapon =
            allWeapons.where((w) => w.id == inst.baseItemId).firstOrNull;
        if (weapon == null) continue;
        final isEquipped = equippedInstanceIds.contains(inst.instanceId);
        items.add(_InstancedSellCard(
          instance: inst,
          name: weapon.name,
          subtitle: '${weapon.minDamage}–${weapon.maxDamage} dmg  ·  ${_gripLabel(weapon.grip)}',
          isEquipped: isEquipped,
          sellValue: _instanceSellValue(inst, weapon.value),
          onSell: () => ref
              .read(gameProvider.notifier)
              .sellItemInstance(inst.instanceId),
        ));
      }
    }

    if (instancedArmor.isNotEmpty) {
      items.add(_sellSectionHeader('ENCHANTED ARMOR'));
      for (final inst in instancedArmor) {
        final armor =
            allArmor.where((a) => a.id == inst.baseItemId).firstOrNull;
        if (armor == null) continue;
        final isEquipped = equippedInstanceIds.contains(inst.instanceId);
        items.add(_InstancedSellCard(
          instance: inst,
          name: armor.name,
          subtitle: '${_slotLabel(armor.slot)}  ·  ${armor.defense} def',
          isEquipped: isEquipped,
          sellValue: _instanceSellValue(inst, armor.value),
          onSell: () => ref
              .read(gameProvider.notifier)
              .sellItemInstance(inst.instanceId),
        ));
      }
    }

    if (regularWeapons.isNotEmpty) {
      items.add(_sellSectionHeader('WEAPONS'));
      for (final entry in regularWeapons) {
        final weapon =
            allWeapons.where((w) => w.id == entry.id).firstOrNull;
        if (weapon == null) continue;
        items.add(_SellCard(
          name: weapon.name,
          subtitle: '${weapon.minDamage}–${weapon.maxDamage} dmg  ·  ${_gripLabel(weapon.grip)}',
          qty: entry.qty,
          sellValue: weaponSellValue(entry.id),
          onSell: () => ref.read(gameProvider.notifier).sellWeapon(entry.id),
        ));
      }
    }

    if (regularArmor.isNotEmpty) {
      items.add(_sellSectionHeader('ARMOR'));
      for (final entry in regularArmor) {
        final armor =
            allArmor.where((a) => a.id == entry.id).firstOrNull;
        if (armor == null) continue;
        items.add(_SellCard(
          name: armor.name,
          subtitle: '${_slotLabel(armor.slot)}  ·  ${armor.defense} def  ·  ${armor.weight} wt',
          qty: entry.qty,
          sellValue: armorSellValue(entry.id),
          onSell: () => ref.read(gameProvider.notifier).sellArmor(entry.id),
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: items,
    );
  }

  Widget _sellSectionHeader(String label) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Text(
          label,
          style: AshenText.dim.copyWith(
            fontSize: 10,
            letterSpacing: 2,
            color: AshenColors.copper,
          ),
        ),
      );
}

// ─── SELL CARD (regular, non-instanced) ──────────────────────────────────────

class _SellCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final int qty;
  final int sellValue;
  final VoidCallback onSell;

  const _SellCard({
    required this.name,
    required this.subtitle,
    required this.qty,
    required this.sellValue,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AshenColors.surface,
        border: Border(
          left: const BorderSide(color: AshenColors.ashGrey, width: 2),
          top: const BorderSide(color: AshenColors.border, width: 0.5),
          right: const BorderSide(color: AshenColors.border, width: 0.5),
          bottom: const BorderSide(color: AshenColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name,
                        style: AshenText.body
                            .copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                    if (qty > 1) ...[
                      const SizedBox(width: 8),
                      Text('×$qty',
                          style: AshenText.dim.copyWith(fontSize: 11)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AshenText.dim.copyWith(fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AshenColors.copper,
              side: const BorderSide(color: AshenColors.copper),
              shape: const RoundedRectangleBorder(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              textStyle:
                  const TextStyle(fontSize: 10, letterSpacing: 1.5),
            ),
            onPressed: onSell,
            child: Text('SELL  $sellValue g'),
          ),
        ],
      ),
    );
  }
}

// ─── SELL CARD (instanced / enchanted) ───────────────────────────────────────

class _InstancedSellCard extends StatelessWidget {
  final ItemInstance instance;
  final String name;
  final String subtitle;
  final bool isEquipped;
  final int sellValue;
  final VoidCallback onSell;

  const _InstancedSellCard({
    required this.instance,
    required this.name,
    required this.subtitle,
    required this.isEquipped,
    required this.sellValue,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor(instance.rarity);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AshenColors.surface,
        border: Border(
          left: BorderSide(color: rarityColor, width: 2),
          top: const BorderSide(color: AshenColors.border, width: 0.5),
          right: const BorderSide(color: AshenColors.border, width: 0.5),
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
                Row(
                  children: [
                    Text(name,
                        style: AshenText.body.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    if (isEquipped) ...[
                      const SizedBox(width: 8),
                      Text('EQUIPPED',
                          style: TextStyle(
                              color: rarityColor,
                              fontSize: 9,
                              letterSpacing: 1.5)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  instance.rarity.name.toUpperCase(),
                  style: TextStyle(
                      color: rarityColor, fontSize: 9, letterSpacing: 2),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AshenText.dim.copyWith(fontSize: 11)),
                if (instance.modifiers.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...instance.modifiers.map((m) => Text(
                        '+ ${m.displayText}',
                        style: TextStyle(
                            color: rarityColor.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontStyle: FontStyle.italic),
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!isEquipped)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: rarityColor,
                side: BorderSide(color: rarityColor),
                shape: const RoundedRectangleBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                textStyle:
                    const TextStyle(fontSize: 10, letterSpacing: 1.5),
              ),
              onPressed: onSell,
              child: Text('SELL  $sellValue g'),
            )
          else
            Text('unequip first',
                style: AshenText.dim.copyWith(
                    fontSize: 10, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

// ─── TRADER ITEM CARD ─────────────────────────────────────────────────────────

class _TraderItemCard extends StatelessWidget {
  final TraderOffer offer;
  final int gold;
  final VoidCallback onBuy;

  const _TraderItemCard({
    required this.offer,
    required this.gold,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    if (offer.isTome) return _TomeCard(offer: offer, gold: gold, onBuy: onBuy);

    final weapon = offer.isWeapon
        ? allWeapons.where((w) => w.id == offer.itemId).firstOrNull
        : null;
    final armor = !offer.isWeapon
        ? allArmor.where((a) => a.id == offer.itemId).firstOrNull
        : null;

    final rarity = weapon?.rarity ?? armor?.rarity ?? Rarity.common;
    final rarityColor = _rarityColor(rarity);
    final canAfford = gold >= offer.price && !offer.purchased;
    final modCount = modifierCountForRarity(rarity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AshenColors.surface,
        border: Border(
          left: BorderSide(color: rarityColor, width: 3),
          top: const BorderSide(color: AshenColors.border, width: 0.5),
          right: const BorderSide(color: AshenColors.border, width: 0.5),
          bottom: const BorderSide(color: AshenColors.border, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ─────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  offer.isWeapon ? Icons.sports_kabaddi : Icons.shield,
                  size: 14,
                  color: offer.purchased ? AshenColors.border : rarityColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.displayName,
                        style: AshenText.body.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: offer.purchased
                              ? AshenColors.ashGrey
                              : AshenColors.parchment,
                          decoration: offer.purchased
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _RarityBadge(rarity: rarity, purchased: offer.purchased),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!offer.purchased)
                  Text(
                    '${offer.price} g',
                    style: AshenText.body.copyWith(
                      color: canAfford
                          ? AshenColors.gold
                          : AshenColors.parchmentDim,
                      fontSize: 14,
                    ),
                  )
                else
                  Text('SOLD',
                      style: AshenText.dim.copyWith(
                          fontSize: 11, color: AshenColors.border)),
              ],
            ),

            const SizedBox(height: 8),

            // ── Base stats ─────────────────────────────────────────────────
            if (weapon != null) _WeaponStats(weapon: weapon),
            if (armor != null) _ArmorStats(armor: armor),

            // ── Modifier preview ───────────────────────────────────────────
            if (modCount > 0) ...[
              const SizedBox(height: 8),
              _ModifierPreview(count: modCount, rarity: rarity,
                  purchased: offer.purchased),
            ],

            // ── Buy button ─────────────────────────────────────────────────
            if (!offer.purchased) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        canAfford ? AshenColors.copper : AshenColors.ashGrey,
                    side: BorderSide(
                        color: canAfford
                            ? AshenColors.copper
                            : AshenColors.border),
                    shape: const RoundedRectangleBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle:
                        const TextStyle(fontSize: 11, letterSpacing: 2),
                  ),
                  onPressed: canAfford ? onBuy : null,
                  child: Text(canAfford
                      ? 'BUY  ${offer.price} g'
                      : 'NEED ${offer.price} g'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── TOME CARD ────────────────────────────────────────────────────────────────

class _TomeCard extends StatelessWidget {
  final TraderOffer offer;
  final int gold;
  final VoidCallback onBuy;
  const _TomeCard({required this.offer, required this.gold, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    final spell = spellById(offer.itemId);
    final canAfford = gold >= offer.price && !offer.purchased;
    final tierLabel = spell != null ? 'TIER ${spell.tier}' : 'SPELL';
    final classes = spell?.allowedClasses
        .map((c) => _classShort(c))
        .join(' · ') ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AshenColors.surface,
        border: Border(
          left: BorderSide(
              color: offer.purchased
                  ? AshenColors.border
                  : AshenColors.copper,
              width: 3),
          top: const BorderSide(color: AshenColors.border, width: 0.5),
          right: const BorderSide(color: AshenColors.border, width: 0.5),
          bottom: const BorderSide(color: AshenColors.border, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.menu_book,
                    size: 14,
                    color: offer.purchased
                        ? AshenColors.border
                        : AshenColors.copper),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.displayName,
                        style: AshenText.body.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: offer.purchased
                              ? AshenColors.ashGrey
                              : AshenColors.parchment,
                          decoration: offer.purchased
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$tierLabel  ·  $classes',
                        style: AshenText.dim.copyWith(
                            fontSize: 10,
                            letterSpacing: 1,
                            color: offer.purchased
                                ? AshenColors.border
                                : AshenColors.copper),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!offer.purchased)
                  Text(
                    '${offer.price} g',
                    style: AshenText.body.copyWith(
                      color: canAfford
                          ? AshenColors.gold
                          : AshenColors.parchmentDim,
                      fontSize: 14,
                    ),
                  )
                else
                  Text('SOLD',
                      style: AshenText.dim.copyWith(
                          fontSize: 11, color: AshenColors.border)),
              ],
            ),
            if (spell != null) ...[
              const SizedBox(height: 8),
              Text(
                spell.description,
                style: AshenText.dim.copyWith(fontSize: 12),
              ),
              if (spell.manaCost > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${spell.manaCost} mana  ·  ${_effectShort(spell.effectType)}',
                  style: AshenText.dim.copyWith(fontSize: 11),
                ),
              ],
            ],
            if (!offer.purchased) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: canAfford
                        ? AshenColors.copper
                        : AshenColors.ashGrey,
                    side: BorderSide(
                        color: canAfford
                            ? AshenColors.copper
                            : AshenColors.border),
                    shape: const RoundedRectangleBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle:
                        const TextStyle(fontSize: 11, letterSpacing: 2),
                  ),
                  onPressed: canAfford ? onBuy : null,
                  child: Text(canAfford
                      ? 'BUY  ${offer.price} g'
                      : 'NEED ${offer.price} g'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _classShort(HeroClass c) => switch (c) {
    HeroClass.mage        => 'Mage',
    HeroClass.warlock     => 'Warlock',
    HeroClass.necromancer => 'Necromancer',
    HeroClass.priest      => 'Priest',
    HeroClass.knight      => 'Knight',
    HeroClass.ranger      => 'Ranger',
    HeroClass.rogue       => 'Rogue',
  };

  String _effectShort(SpellEffectType t) => switch (t) {
    SpellEffectType.damage    => 'Damage',
    SpellEffectType.damageAll => 'AoE Damage',
    SpellEffectType.dot       => 'DoT',
    SpellEffectType.dotAll    => 'AoE DoT',
    SpellEffectType.heal      => 'Heal',
    SpellEffectType.healAll   => 'Heal All',
    SpellEffectType.drain     => 'Life Drain',
    SpellEffectType.buff      => 'Defense Buff',
    SpellEffectType.debuff    => 'Debuff',
    SpellEffectType.dispel    => 'Dispel',
    SpellEffectType.summon    => 'Summon',
  };
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _RarityBadge extends StatelessWidget {
  final Rarity rarity;
  final bool purchased;
  const _RarityBadge({required this.rarity, required this.purchased});

  @override
  Widget build(BuildContext context) {
    final color =
        purchased ? AshenColors.border : _rarityColor(rarity);
    return Text(
      rarity.name.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: 10,
        letterSpacing: 2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _WeaponStats extends StatelessWidget {
  final Weapon weapon;
  const _WeaponStats({required this.weapon});

  @override
  Widget build(BuildContext context) => Text(
        '${weapon.minDamage}–${weapon.maxDamage} dmg  ·  '
        '${_gripLabel(weapon.grip)}  ·  ${_typeLabel(weapon.type)}',
        style: AshenText.dim.copyWith(fontSize: 12),
      );
}

class _ArmorStats extends StatelessWidget {
  final Armor armor;
  const _ArmorStats({required this.armor});

  @override
  Widget build(BuildContext context) => Text(
        '${_slotLabel(armor.slot)}  ·  ${armor.defense} def  ·  ${armor.weight} wt',
        style: AshenText.dim.copyWith(fontSize: 12),
      );
}

class _ModifierPreview extends StatelessWidget {
  final int count;
  final Rarity rarity;
  final bool purchased;
  const _ModifierPreview(
      {required this.count,
      required this.rarity,
      required this.purchased});

  @override
  Widget build(BuildContext context) {
    final color = purchased
        ? AshenColors.border
        : _rarityColor(rarity).withValues(alpha: 0.7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AshenColors.parchmentWarm.withValues(alpha: 0.3),
        border: Border(left: BorderSide(color: color, width: 2)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 11, color: color),
          const SizedBox(width: 6),
          Text(
            purchased
                ? 'Modifiers revealed in your inventory'
                : '$count modifier${count > 1 ? 's' : ''} — revealed on purchase',
            style: AshenText.dim.copyWith(
                fontSize: 11, color: color, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ── Color helpers (mirrored from inventory_screen) ───────────────────────────

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
