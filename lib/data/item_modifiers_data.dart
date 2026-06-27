import 'dart:math';
import '../models/item_instance.dart';
import '../models/enums.dart';

typedef _Mod = ({
  String label,
  String statKey,
  double min,
  double max,
  bool isPercent
});

const List<_Mod> _weaponPool = [
  (label: 'Critical Chance',  statKey: 'critChance',   min: 5.0,  max: 15.0, isPercent: true),
  (label: 'Critical Damage',  statKey: 'critDamage',   min: 10.0, max: 30.0, isPercent: true),
  (label: 'Attack Speed',     statKey: 'attackSpeed',  min: 5.0,  max: 15.0, isPercent: true),
  (label: 'Armor Penetration',statKey: 'armorPen',     min: 3.0,  max: 12.0, isPercent: false),
  (label: 'Bonus Damage',     statKey: 'bonusDamage',  min: 2.0,  max: 8.0,  isPercent: false),
  (label: 'Accuracy',         statKey: 'accuracy',     min: 5.0,  max: 20.0, isPercent: true),
  (label: 'Life on Hit',      statKey: 'lifesteal',    min: 3.0,  max: 10.0, isPercent: false),
  (label: 'Spell Power',      statKey: 'spellPower',   min: 5.0,  max: 15.0, isPercent: true),
  (label: 'Holy Damage',      statKey: 'holyDamage',   min: 5.0,  max: 15.0, isPercent: true),
  (label: 'Spell Power',      statKey: 'spellPower',   min: 10.0, max: 20.0, isPercent: true),
  (label: 'Critical Chance',  statKey: 'critChance',   min: 8.0,  max: 18.0, isPercent: true),
  (label: 'Bonus Damage',     statKey: 'bonusDamage',  min: 4.0,  max: 12.0, isPercent: false),
];

const List<_Mod> _armorPool = [
  (label: 'Max Health',       statKey: 'bonusHp',         min: 10.0, max: 40.0,  isPercent: false),
  (label: 'Defense',          statKey: 'bonusDefense',    min: 2.0,  max: 8.0,   isPercent: false),
  (label: 'Dodge Chance',     statKey: 'dodge',           min: 3.0,  max: 12.0,  isPercent: true),
  (label: 'Damage Reduction', statKey: 'damageReduction', min: 2.0,  max: 8.0,   isPercent: true),
  (label: 'Attack Speed',     statKey: 'attackSpeed',     min: 3.0,  max: 10.0,  isPercent: true),
  (label: 'Defense',          statKey: 'bonusDefense',    min: 4.0,  max: 14.0,  isPercent: false),
  (label: 'Spell Resistance', statKey: 'spellResist',     min: 5.0,  max: 15.0,  isPercent: true),
  (label: 'Holy Resistance',  statKey: 'holyResist',      min: 5.0,  max: 15.0,  isPercent: true),
  (label: 'Max Health',       statKey: 'bonusHp',         min: 20.0, max: 60.0,  isPercent: false),
  (label: 'Thorns Damage',    statKey: 'thornsDamage',    min: 2.0,  max: 8.0,   isPercent: false),
  (label: 'Carry Weight',     statKey: 'weightReduction', min: 1.0,  max: 3.0,   isPercent: false),
  (label: 'Damage Reduction', statKey: 'damageReduction', min: 3.0,  max: 10.0,  isPercent: true),
];

int _modifierCount(Rarity rarity, Random rng) => switch (rarity) {
  Rarity.common    => 0,
  Rarity.uncommon  => 1,
  Rarity.rare      => 2,
  Rarity.epic      => 3,
  Rarity.legendary => 4 + rng.nextInt(2),
};

List<ItemModifier> generateModifiers(Random rng, Rarity rarity, bool isWeapon) {
  final count = _modifierCount(rarity, rng);
  if (count == 0) return const [];

  final pool = List<_Mod>.from(isWeapon ? _weaponPool : _armorPool);
  pool.shuffle(rng);

  return pool.take(count).map((e) {
    final raw = e.min + rng.nextDouble() * (e.max - e.min);
    return ItemModifier(
      label: e.label,
      statKey: e.statKey,
      value: double.parse(raw.toStringAsFixed(1)),
      isPercent: e.isPercent,
    );
  }).toList();
}

/// Number of modifiers a given rarity tier generates (for display before purchase).
int modifierCountForRarity(Rarity rarity) => switch (rarity) {
  Rarity.common    => 0,
  Rarity.uncommon  => 1,
  Rarity.rare      => 2,
  Rarity.epic      => 3,
  Rarity.legendary => 5,
};
