const kManaPotionMinor   = 'mana_potion_minor';
const kManaPotion        = 'mana_potion';
const kManaPotionGreater = 'mana_potion_greater';

class ConsumableDef {
  final String id;
  final String name;
  final String description;
  final int buyPrice;
  final int manaRestore;

  const ConsumableDef({
    required this.id,
    required this.name,
    required this.description,
    required this.buyPrice,
    this.manaRestore = 0,
  });
}

const allConsumables = [
  ConsumableDef(
    id: kManaPotionMinor,
    name: 'Minor Mana Draught',
    description: 'A small vial of concentrated aetheric fluid. Restores 20 mana.',
    buyPrice: 30,
    manaRestore: 20,
  ),
  ConsumableDef(
    id: kManaPotion,
    name: 'Mana Draught',
    description: 'A bottle of refined aetheric distillate. Restores 40 mana.',
    buyPrice: 75,
    manaRestore: 40,
  ),
  ConsumableDef(
    id: kManaPotionGreater,
    name: 'Greater Mana Draught',
    description: 'A rare vial of pure arcane essence. Restores 80 mana.',
    buyPrice: 180,
    manaRestore: 80,
  ),
];

ConsumableDef? consumableById(String id) {
  try {
    return allConsumables.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

int manaRestoreAmount(String consumableId) =>
    consumableById(consumableId)?.manaRestore ?? 0;

bool isSpellTome(String id) => id.startsWith('tome_');

String? tomeSpellId(String id) => isSpellTome(id) ? id.substring(5) : null;

String tomeName(String spellName) => 'Tome: $spellName';
