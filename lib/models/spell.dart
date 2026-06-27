import 'enums.dart';

enum SpellEffectType {
  damage,    // single-target magic damage
  damageAll, // hits all enemies (lower per-target)
  dot,       // damage over duration rounds to one target
  dotAll,    // damage over duration rounds to all enemies
  heal,      // heals the most injured hero
  healAll,   // heals all living heroes
  drain,     // damages one target, heals caster for portion
  buff,      // adds flatBonus to caster defense for encounter
  debuff,    // reduces target enemy armor by flatBonus
  dispel,    // removes one random trait from target enemy
  summon,    // conjured ally: flatBonus damage per round for duration rounds
}

class Spell {
  final String id;
  final String name;
  final String description;
  final String flavorText;
  final int manaCost;
  final int tier;           // 1=basic, 2=intermediate, 3=advanced
  final SpellEffectType effectType;
  final double powerScale;  // multiplied by caster.effectiveStats.magicPower
  final int flatBonus;      // used by buff/debuff/summon
  final int duration;       // rounds for DoT, summon, buff
  final List<HeroClass> allowedClasses;

  const Spell({
    required this.id,
    required this.name,
    required this.description,
    required this.flavorText,
    required this.manaCost,
    required this.tier,
    required this.effectType,
    this.powerScale = 1.0,
    this.flatBonus = 0,
    this.duration = 1,
    required this.allowedClasses,
  });
}
