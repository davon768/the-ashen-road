enum PropertyType { tavern, blacksmith, apothecary, generalStore, stables, castle }

class OwnedProperty {
  final String id;
  final String name;
  final PropertyType type;
  final int level;           // kept for backward-compat JSON; not used in new UI
  final int goldPerMinute;   // passive income (base + sum of addon bonuses)
  final int upgradeCost;     // kept for backward-compat JSON; not used in new UI
  final List<String> unlockedAddonIds;

  const OwnedProperty({
    required this.id,
    required this.name,
    required this.type,
    required this.level,
    required this.goldPerMinute,
    required this.upgradeCost,
    this.unlockedAddonIds = const [],
  });

  OwnedProperty copyWith({
    int? level,
    int? goldPerMinute,
    int? upgradeCost,
    List<String>? unlockedAddonIds,
  }) =>
      OwnedProperty(
        id: id,
        name: name,
        type: type,
        level: level ?? this.level,
        goldPerMinute: goldPerMinute ?? this.goldPerMinute,
        upgradeCost: upgradeCost ?? this.upgradeCost,
        unlockedAddonIds: unlockedAddonIds ?? this.unlockedAddonIds,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'level': level,
        'goldPerMinute': goldPerMinute,
        'upgradeCost': upgradeCost,
        'unlockedAddonIds': unlockedAddonIds,
      };

  factory OwnedProperty.fromJson(Map<String, dynamic> j) => OwnedProperty(
        id: j['id'],
        name: j['name'],
        type: PropertyType.values.byName(j['type']),
        level: j['level'],
        goldPerMinute: j['goldPerMinute'],
        upgradeCost: j['upgradeCost'],
        unlockedAddonIds: (j['unlockedAddonIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );
}

// Starting costs to purchase each property type for the first time
const Map<PropertyType, int> propertyCosts = {
  PropertyType.tavern: 500,
  PropertyType.blacksmith: 800,
  PropertyType.apothecary: 600,
  PropertyType.generalStore: 400,
  PropertyType.stables: 700,
  PropertyType.castle: 5000,
};

// Modest trickle — income is a bonus, not the point
const Map<PropertyType, int> baseIncomePerMinute = {
  PropertyType.tavern:       2,
  PropertyType.blacksmith:   3,
  PropertyType.apothecary:   2,
  PropertyType.generalStore: 1,
  PropertyType.stables:      2,
  PropertyType.castle:       8,
};

// Short description of each property's functional perk
const Map<PropertyType, String> propertyPerk = {
  PropertyType.tavern:
      'Free full rest for your party — once per day.',
  PropertyType.blacksmith:
      'Unlocks your personal shop. Party weapons deal +10% damage.',
  PropertyType.apothecary:
      'Party recovers from injuries twice as fast.',
  PropertyType.generalStore:
      'Expeditions always find one extra loot item.',
  PropertyType.stables:
      'All expedition travel times reduced by 20%.',
  PropertyType.castle:
      'Party size limit raised to 6. Garrison heroes available for hire.',
};
