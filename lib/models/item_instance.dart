import 'enums.dart';

class ItemModifier {
  final String label;    // Human-readable: 'Critical Chance', 'Bonus Damage'
  final String statKey;  // Machine key for future combat integration
  final double value;
  final bool isPercent;

  const ItemModifier({
    required this.label,
    required this.statKey,
    required this.value,
    this.isPercent = true,
  });

  String get displayText {
    final sign = value >= 0 ? '+' : '';
    if (isPercent) {
      return '$sign${value.toStringAsFixed(0)}% $label';
    } else {
      return '$sign${value.toStringAsFixed(0)} $label';
    }
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'statKey': statKey,
    'value': value,
    'isPercent': isPercent,
  };

  factory ItemModifier.fromJson(Map<String, dynamic> j) => ItemModifier(
    label: j['label'] as String,
    statKey: j['statKey'] as String,
    value: (j['value'] as num).toDouble(),
    isPercent: j['isPercent'] as bool? ?? true,
  );
}

const _weaponPrefixes = <String, String>{
  'critChance':  'Lucky',
  'critDamage':  'Savage',
  'bonusDamage': 'Keen',
  'armorPen':    'Cleaving',
  'attackSpeed': 'Swift',
  'lifesteal':   'Vampiric',
  'spellPower':  'Arcane',
  'holyDamage':  'Sacred',
  'accuracy':    'Precise',
};

const _armorPrefixes = <String, String>{
  'bonusHp':          'Stalwart',
  'bonusDefense':     'Reinforced',
  'dodge':            'Nimble',
  'damageReduction':  'Warding',
  'thornsDamage':     'Spiked',
  'spellResist':      'Resistant',
  'holyResist':       'Warded',
  'weightReduction':  'Lightweight',
};

class ItemInstance {
  final String instanceId;
  final String baseItemId;
  final bool isWeapon;
  final Rarity rarity;
  final List<ItemModifier> modifiers;

  const ItemInstance({
    required this.instanceId,
    required this.baseItemId,
    required this.isWeapon,
    required this.rarity,
    this.modifiers = const [],
  });

  String displayName(String baseName) {
    if (modifiers.isEmpty) return baseName;
    final prefixMap = isWeapon ? _weaponPrefixes : _armorPrefixes;
    // Pick dominant modifier: highest value (flat counts 3× more than percent to normalise scale)
    ItemModifier? dominant;
    double dominantWeight = -1;
    for (final mod in modifiers) {
      final weight = mod.isPercent ? mod.value : mod.value * 3;
      if (weight > dominantWeight) {
        dominantWeight = weight;
        dominant = mod;
      }
    }
    final prefix = dominant != null ? prefixMap[dominant.statKey] : null;
    return prefix != null ? '$prefix $baseName' : baseName;
  }

  Map<String, dynamic> toJson() => {
    'instanceId': instanceId,
    'baseItemId': baseItemId,
    'isWeapon': isWeapon,
    'rarity': rarity.name,
    'modifiers': modifiers.map((m) => m.toJson()).toList(),
  };

  factory ItemInstance.fromJson(Map<String, dynamic> j) => ItemInstance(
    instanceId: j['instanceId'] as String,
    baseItemId: j['baseItemId'] as String,
    isWeapon: j['isWeapon'] as bool,
    rarity: Rarity.values.firstWhere((r) => r.name == j['rarity'],
        orElse: () => Rarity.common),
    modifiers: (j['modifiers'] as List? ?? [])
        .map((m) => ItemModifier.fromJson(m as Map<String, dynamic>))
        .toList(),
  );
}
