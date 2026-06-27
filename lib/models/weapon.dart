import 'enums.dart';
import 'stats.dart';

class Weapon {
  final String id;
  final String name;
  final String historicalName;
  final String era;
  final String description;
  final WeaponType type;
  final WeaponGrip grip;
  final Rarity rarity;
  final int minDamage;
  final int maxDamage;
  final double attackSpeed;   // attacks per second
  final int range;            // 1 = melee, 2+ = ranged tiles
  final int value;            // coin price
  final HeroStats statBonus;
  final List<HeroClass> allowedClasses; // empty = all classes

  const Weapon({
    required this.id,
    required this.name,
    required this.historicalName,
    required this.era,
    required this.description,
    required this.type,
    required this.grip,
    required this.rarity,
    required this.minDamage,
    required this.maxDamage,
    required this.attackSpeed,
    this.range = 1,
    required this.value,
    this.statBonus = const HeroStats(
      strength: 0, dexterity: 0, endurance: 0,
      intelligence: 0, faith: 0, luck: 0,
    ),
    this.allowedClasses = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
