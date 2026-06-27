import 'enums.dart';

class DevotionTier {
  final String name;
  final String description;
  final int devotionRequired;   // 0-100
  final List<String> passiveBonuses;
  final List<String> abilities;

  const DevotionTier({
    required this.name,
    required this.description,
    required this.devotionRequired,
    required this.passiveBonuses,
    required this.abilities,
  });
}

class Faith {
  final FaithType type;
  final String name;
  final String description;
  final String inspiredBy;      // real-world historical reference
  final String deity;
  final List<DevotionTier> tiers;
  final List<HeroClass> affinityClasses; // classes that gain devotion faster

  const Faith({
    required this.type,
    required this.name,
    required this.description,
    required this.inspiredBy,
    required this.deity,
    required this.tiers,
    required this.affinityClasses,
  });
}
