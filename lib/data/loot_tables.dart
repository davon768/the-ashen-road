import 'dart:math';
import 'weapons_data.dart';
import 'armor_data.dart';
import 'consumables_data.dart';
import '../models/enums.dart';

final _rng = Random();

class ItemLoot {
  final List<String> weaponIds;
  final List<String> armorIds;
  final List<String> consumableIds; // mana potions, spell tomes
  const ItemLoot({
    required this.weaponIds,
    required this.armorIds,
    this.consumableIds = const [],
  });

  bool get isEmpty => weaponIds.isEmpty && armorIds.isEmpty && consumableIds.isEmpty;
}

ItemLoot generateItemLoot(LocationType locationType, int depth, {bool guildBoost = false}) {
  final dropChance = switch (locationType) {
    LocationType.dungeon    => 0.40,
    LocationType.castle     => 0.45,
    LocationType.ruins      => 0.35,
    LocationType.monastery  => 0.30,
    LocationType.wilderness => 0.20,
    LocationType.town       => 0.15,
    LocationType.cemetery   => 0.35,
    LocationType.library    => 0.28,
    LocationType.forge      => 0.40,
    LocationType.church || LocationType.shrine || LocationType.cultSite => 0.0,
  };

  Rarity pickRarity() {
    final roll = _rng.nextDouble();
    final effectiveDepth = guildBoost ? depth + 1 : depth;
    if (effectiveDepth >= 5) {
      if (roll < 0.08) return Rarity.legendary;
      if (roll < 0.20) return Rarity.epic;
      if (roll < 0.40) return Rarity.rare;
      if (roll < 0.65) return Rarity.uncommon;
      return Rarity.common;
    } else if (effectiveDepth >= 3) {
      if (roll < 0.05) return Rarity.epic;
      if (roll < 0.18) return Rarity.rare;
      if (roll < 0.45) return Rarity.uncommon;
      return Rarity.common;
    } else {
      if (roll < 0.10) return Rarity.rare;
      if (roll < 0.30) return Rarity.uncommon;
      return Rarity.common;
    }
  }

  final weaponIds = <String>[];
  final armorIds  = <String>[];

  for (var i = 0; i < 2; i++) {
    if (_rng.nextDouble() > dropChance) continue;
    final rarity = pickRarity();
    final pool = allWeapons.where((w) => w.rarity == rarity).toList();
    if (pool.isNotEmpty) {
      weaponIds.add(pool[_rng.nextInt(pool.length)].id);
    }
  }

  for (var i = 0; i < 2; i++) {
    if (_rng.nextDouble() > dropChance) continue;
    final rarity = pickRarity();
    final pool = allArmor.where((a) => a.rarity == rarity).toList();
    if (pool.isNotEmpty) {
      armorIds.add(pool[_rng.nextInt(pool.length)].id);
    }
  }

  // Consumable drops (mana potions + spell tomes)
  final consumableIds = <String>[];
  if (depth >= 2 && _rng.nextDouble() < 0.18) {
    if (depth >= 4) {
      consumableIds.add(kManaPotionGreater);
    } else if (depth >= 3) {
      consumableIds.add(kManaPotion);
    } else {
      consumableIds.add(kManaPotionMinor);
    }
  }
  if (depth >= 3 && _rng.nextDouble() < 0.12) {
    final pool = _spellTomePool(locationType);
    if (pool.isNotEmpty) {
      consumableIds.add('tome_${pool[_rng.nextInt(pool.length)]}');
    }
  }

  return ItemLoot(weaponIds: weaponIds, armorIds: armorIds, consumableIds: consumableIds);
}

// Spell tomes available at each location type (T1 and T2 spells)
List<String> _spellTomePool(LocationType type) => switch (type) {
  LocationType.dungeon    => ['death_bolt', 'bone_shard', 'wither', 'shadow_bolt', 'corruption'],
  LocationType.castle     => ['arcane_missile', 'lightning_bolt', 'fireball', 'soul_rend'],
  LocationType.ruins      => ['frost_bolt', 'ice_lance', 'bone_spear', 'void_bolt'],
  LocationType.monastery  => ['smite', 'sacred_word', 'bless', 'holy_flame', 'mass_prayer'],
  LocationType.wilderness => ['drain_life', 'corruption', 'chill_of_death', 'arcane_ward'],
  LocationType.town       => ['arcane_missile', 'smite', 'shadow_bolt', 'sacred_word'],
  LocationType.cemetery   => ['grave_chill', 'bone_shard', 'wither', 'death_bolt', 'chill_of_death'],
  LocationType.library    => ['arcane_missile', 'frost_bolt', 'void_bolt', 'arcane_ward', 'ice_lance'],
  LocationType.forge      => ['lightning_bolt', 'fireball', 'soul_rend', 'bone_spear'],
  LocationType.church     => ['smite', 'sacred_word', 'bless', 'holy_flame', 'mass_prayer'],
  LocationType.shrine     => ['sacred_word', 'bless', 'smite', 'drain_life', 'wither'],
  LocationType.cultSite   => ['corruption', 'death_bolt', 'drain_life', 'void_bolt', 'shadow_bolt'],
};

/// Gold value a shop would pay for a weapon (50% of base value)
int weaponSellValue(String id) {
  final w = allWeapons.where((w) => w.id == id).firstOrNull;
  return ((w?.value ?? 0) * 0.5).floor().clamp(1, 99999);
}

/// Gold value a shop would pay for armor (50% of base value)
int armorSellValue(String id) {
  final a = allArmor.where((a) => a.id == id).firstOrNull;
  return ((a?.value ?? 0) * 0.5).floor().clamp(1, 99999);
}
