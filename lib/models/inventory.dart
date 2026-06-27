import 'item_instance.dart';

class Inventory {
  final Map<String, int> weapons;      // weaponId -> quantity (base items)
  final Map<String, int> armor;        // armorId  -> quantity (base items)
  final List<ItemInstance> itemInstances; // modded items from traders
  final Map<String, int> consumables;  // consumableId -> quantity (potions, tomes)

  const Inventory({
    this.weapons = const {},
    this.armor   = const {},
    this.itemInstances = const [],
    this.consumables = const {},
  });

  bool hasWeapon(String id)      => (weapons[id]     ?? 0) > 0;
  bool hasArmor(String id)       => (armor[id]       ?? 0) > 0;
  bool hasConsumable(String id)  => (consumables[id] ?? 0) > 0;

  int weaponCount(String id)     => weapons[id]     ?? 0;
  int armorCount(String id)      => armor[id]       ?? 0;
  int consumableCount(String id) => consumables[id] ?? 0;

  ItemInstance? findInstance(String instanceId) =>
      itemInstances.where((i) => i.instanceId == instanceId).firstOrNull;

  Inventory addWeapon(String id, [int qty = 1]) {
    final updated = Map<String, int>.from(weapons);
    updated[id] = (updated[id] ?? 0) + qty;
    return Inventory(weapons: updated, armor: armor, itemInstances: itemInstances, consumables: consumables);
  }

  Inventory removeWeapon(String id) {
    final count = (weapons[id] ?? 0) - 1;
    final updated = Map<String, int>.from(weapons);
    if (count <= 0) { updated.remove(id); } else { updated[id] = count; }
    return Inventory(weapons: updated, armor: armor, itemInstances: itemInstances, consumables: consumables);
  }

  Inventory addArmor(String id, [int qty = 1]) {
    final updated = Map<String, int>.from(armor);
    updated[id] = (updated[id] ?? 0) + qty;
    return Inventory(weapons: weapons, armor: updated, itemInstances: itemInstances, consumables: consumables);
  }

  Inventory removeArmor(String id) {
    final count = (armor[id] ?? 0) - 1;
    final updated = Map<String, int>.from(armor);
    if (count <= 0) { updated.remove(id); } else { updated[id] = count; }
    return Inventory(weapons: weapons, armor: updated, itemInstances: itemInstances, consumables: consumables);
  }

  Inventory addItemInstance(ItemInstance inst) => Inventory(
        weapons: weapons, armor: armor,
        itemInstances: [...itemInstances, inst],
        consumables: consumables,
      );

  Inventory removeItemInstance(String instanceId) => Inventory(
        weapons: weapons, armor: armor,
        itemInstances: itemInstances.where((i) => i.instanceId != instanceId).toList(),
        consumables: consumables,
      );

  Inventory addConsumable(String id, [int qty = 1]) {
    final updated = Map<String, int>.from(consumables);
    updated[id] = (updated[id] ?? 0) + qty;
    return Inventory(weapons: weapons, armor: armor, itemInstances: itemInstances, consumables: updated);
  }

  Inventory removeConsumable(String id) {
    final count = (consumables[id] ?? 0) - 1;
    final updated = Map<String, int>.from(consumables);
    if (count <= 0) { updated.remove(id); } else { updated[id] = count; }
    return Inventory(weapons: weapons, armor: armor, itemInstances: itemInstances, consumables: updated);
  }

  Map<String, dynamic> toJson() => {
        'weapons': weapons,
        'armor': armor,
        'itemInstances': itemInstances.map((i) => i.toJson()).toList(),
        'consumables': consumables,
      };

  factory Inventory.fromJson(Map<String, dynamic> j) => Inventory(
        weapons: Map<String, int>.from(
            (j['weapons'] as Map? ?? {}).map((k, v) => MapEntry(k as String, v as int))),
        armor: Map<String, int>.from(
            (j['armor'] as Map? ?? {}).map((k, v) => MapEntry(k as String, v as int))),
        itemInstances: (j['itemInstances'] as List? ?? [])
            .map((e) => ItemInstance.fromJson(e as Map<String, dynamic>))
            .toList(),
        consumables: Map<String, int>.from(
            (j['consumables'] as Map? ?? {}).map((k, v) => MapEntry(k as String, v as int))),
      );

  factory Inventory.empty() => const Inventory();
}
