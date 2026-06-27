import '../models/enums.dart';

class ClassAbility {
  final String name;
  final String description;
  final String trigger;
  final Subclass? requiredSubclass;

  const ClassAbility({
    required this.name,
    required this.description,
    required this.trigger,
    this.requiredSubclass,
  });
}

const Map<HeroClass, List<ClassAbility>> classAbilities = {

  HeroClass.knight: [
    ClassAbility(
      name: 'Shield Block',
      description: 'On taking a hit, the knight has a 20% chance to raise their shield and halve incoming damage.',
      trigger: '20% on hit taken',
    ),
    ClassAbility(
      name: 'Blood Rage',
      description: 'When the knight\'s HP drops below 50%, attacks grow more reckless and more powerful.',
      trigger: 'When below 50% HP',
      requiredSubclass: Subclass.berserker,
    ),
    ClassAbility(
      name: 'Sacred Strike',
      description: 'Against undead and supernatural foes, the knight\'s blows carry divine weight and deal bonus damage.',
      trigger: 'vs undead / supernatural',
      requiredSubclass: Subclass.crusader,
    ),
  ],

  HeroClass.ranger: [
    ClassAbility(
      name: 'Eagle Eye',
      description: 'The first attack of each encounter is lined up with careful precision, dealing 1.5× damage.',
      trigger: 'First attack of encounter',
    ),
    ClassAbility(
      name: 'Rapid Shot',
      description: 'After each attack, there is a 30% chance the ranger looses a second arrow at no additional cost.',
      trigger: '30% after each attack',
    ),
    ClassAbility(
      name: 'Headshot',
      description: 'On the opening round of combat, the huntsman draws a careful bead before firing for maximum damage.',
      trigger: 'Round 1 only',
      requiredSubclass: Subclass.huntsman,
    ),
  ],

  HeroClass.rogue: [
    ClassAbility(
      name: 'Shadow Strike',
      description: 'Before each main attack there is a 25% chance the rogue strikes first from shadow, dealing 2× damage.',
      trigger: '25% before main attack',
    ),
    ClassAbility(
      name: 'Poison Blade',
      description: 'Each successful hit has a 30% chance to coat the wound with poison, dealing 4 damage per round for 3 rounds.',
      trigger: '30% on hit',
    ),
    ClassAbility(
      name: 'Backstab',
      description: 'On the first round of combat the assassin strikes from concealment, dealing amplified damage.',
      trigger: 'Round 1 only',
      requiredSubclass: Subclass.assassin,
    ),
  ],

  HeroClass.mage: [
    ClassAbility(
      name: 'Arcane Echo',
      description: 'After casting a spell there is a 25% chance the spell resonates and fires a second time for free.',
      trigger: '25% after casting',
    ),
    ClassAbility(
      name: 'Mana Flow',
      description: 'Between encounters the mage recovers 20% of their maximum mana, sustaining them across a long expedition.',
      trigger: 'Between encounters',
    ),
    ClassAbility(
      name: 'Elemental Burst',
      description: 'When a spell surges with high damage output the elementalist\'s magic amplifies further, dealing bonus damage.',
      trigger: 'On high-damage spells',
      requiredSubclass: Subclass.elementalist,
    ),
  ],

  HeroClass.warlock: [
    ClassAbility(
      name: 'Soul Siphon',
      description: 'Damage spells drain life from targets, restoring 15% of damage dealt as HP to the warlock.',
      trigger: 'On every damage spell',
    ),
    ClassAbility(
      name: 'Demon Familiar',
      description: 'A bound demon strikes a random enemy at the start of each encounter for 10 + (level × 2) damage.',
      trigger: 'Start of each encounter',
    ),
    ClassAbility(
      name: 'Dark Ritual',
      description: 'When void power surges during a cast the occultist channels the forbidden name, amplifying the spell.',
      trigger: 'On powerful spells',
      requiredSubclass: Subclass.occultist,
    ),
  ],

  HeroClass.priest: [
    ClassAbility(
      name: 'Holy Ward',
      description: 'While the priest is alive and above 50% HP, the whole party takes 10% less damage from all sources.',
      trigger: 'Passive — party-wide',
    ),
    ClassAbility(
      name: 'Brand of Heresy',
      description: 'Against undead and supernatural enemies, the inquisitor marks the target for judgment, increasing damage dealt.',
      trigger: 'vs undead / supernatural',
      requiredSubclass: Subclass.inquisitor,
    ),
    ClassAbility(
      name: 'Field Surgery',
      description: 'After each combat round, if the hospitaller is below 50% HP they pray and restore 8% of their maximum HP.',
      trigger: 'End of round, below 50% HP',
      requiredSubclass: Subclass.hospitaller,
    ),
  ],

  HeroClass.necromancer: [
    ClassAbility(
      name: 'Bone Armor',
      description: 'The necromancer passively reinforces their body with animated bone, granting +6 defense against physical attacks.',
      trigger: 'Passive — always active',
    ),
    ClassAbility(
      name: 'Phylactery Bond',
      description: 'On each kill the lich drains residual life energy from the fallen, restoring 10 HP.',
      trigger: 'On each kill',
      requiredSubclass: Subclass.lich,
    ),
  ],

};

List<ClassAbility> abilitiesForClass(HeroClass cls) =>
    classAbilities[cls] ?? [];
