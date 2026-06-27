import 'enums.dart';
import 'stats.dart';

// A single node in a faith's devotion tree.
// Tiers 1-4 unlock at devotion 25 / 50 / 75 / 100.
// At each tier a hero picks exactly one of two perks; that choice is locked in.
class DevotionPerk {
  final String id;
  final FaithType faithType;
  final int tier;           // 1–4
  final String name;
  final String description; // mechanical description
  final String flavorText;

  // Stat bonuses applied to hero.perkStatBonus when this perk is chosen.
  final HeroStats statBonus;

  // Percentage bonuses applied during expedition/visit resolution.
  // 0.0 means no bonus for that category.
  final double goldBonus;        // fraction of total gold earned
  final double xpBonus;          // fraction of total XP earned
  final double devotionGainBonus;// fraction of devotion gained per expedition
  final double healBonus;        // fraction bonus to healing received at sites

  const DevotionPerk({
    required this.id,
    required this.faithType,
    required this.tier,
    required this.name,
    required this.description,
    required this.flavorText,
    this.statBonus = const HeroStats(
        strength: 0, dexterity: 0, endurance: 0,
        intelligence: 0, faith: 0, luck: 0),
    this.goldBonus = 0.0,
    this.xpBonus = 0.0,
    this.devotionGainBonus = 0.0,
    this.healBonus = 0.0,
  });
}

// Devotion thresholds at which each tier becomes available.
const devotionTierThresholds = [25.0, 50.0, 75.0, 100.0];

int devotionTierUnlocked(double devotion) {
  int tier = 0;
  for (final threshold in devotionTierThresholds) {
    if (devotion >= threshold) tier++;
  }
  return tier; // 0 = none, 1 = tier 1 unlocked, … 4 = all unlocked
}
