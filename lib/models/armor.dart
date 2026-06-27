import 'enums.dart';
import 'stats.dart';

class Armor {
  final String id;
  final String name;
  final String historicalName;
  final String era;
  final String description;
  final ArmorSlot slot;
  final Rarity rarity;
  final int defense;
  final int weight;           // affects movement and dodge
  final int value;
  final HeroStats statBonus;
  final List<HeroClass> allowedClasses;

  const Armor({
    required this.id,
    required this.name,
    required this.historicalName,
    required this.era,
    required this.description,
    required this.slot,
    required this.rarity,
    required this.defense,
    required this.weight,
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
