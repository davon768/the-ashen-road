import '../models/enums.dart';
import '../models/stats.dart';

class ClassDefinition {
  final HeroClass heroClass;
  final String name;
  final String description;
  final String role;          // e.g. "Tank", "Healer", "DPS"
  final HeroStats baseStats;
  final List<SubclassDefinition> subclasses;
  final List<WeaponType> preferredWeapons;

  const ClassDefinition({
    required this.heroClass,
    required this.name,
    required this.description,
    required this.role,
    required this.baseStats,
    required this.subclasses,
    required this.preferredWeapons,
  });
}

class SubclassDefinition {
  final Subclass subclass;
  final String name;
  final String description;
  final int unlockLevel;      // level required to specialize
  final HeroStats statBonus;  // bonus on top of base class stats
  final List<String> signatureAbilities;

  const SubclassDefinition({
    required this.subclass,
    required this.name,
    required this.description,
    required this.unlockLevel,
    required this.statBonus,
    required this.signatureAbilities,
  });
}

const List<ClassDefinition> allClasses = [

  ClassDefinition(
    heroClass: HeroClass.knight,
    name: 'Knight',
    description: 'A heavily armored warrior trained in weapons and tactics. The backbone of any warband. Slow, powerful, and near-impossible to put down.',
    role: 'Tank / Melee DPS',
    baseStats: HeroStats(strength: 8, dexterity: 4, endurance: 9, intelligence: 2, faith: 4, luck: 3),
    preferredWeapons: [WeaponType.sword, WeaponType.blunt, WeaponType.polearm],
    subclasses: [
      SubclassDefinition(
        subclass: Subclass.crusader,
        name: 'Crusader',
        description: 'A holy warrior of the Luminant Church. Combines martial excellence with divine power, smiting the unholy with sword and flame.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 3, dexterity: 0, endurance: 2, intelligence: 0, faith: 5, luck: 0),
        signatureAbilities: ['Sacred Strike', 'Aura of Conviction', 'Judgment'],
      ),
      SubclassDefinition(
        subclass: Subclass.sentinel,
        name: 'Sentinel',
        description: 'A fortress in human form. The Sentinel exists to absorb punishment and protect those behind them.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 1, dexterity: 0, endurance: 8, intelligence: 0, faith: 0, luck: 1),
        signatureAbilities: ['Iron Wall', 'Shield Bash', 'Last Stand'],
      ),
      SubclassDefinition(
        subclass: Subclass.berserker,
        name: 'Berserker',
        description: 'A warrior who trades defense for overwhelming offense. Enters a killing rage that makes them terrifying — and reckless.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 8, dexterity: 2, endurance: 0, intelligence: 0, faith: 0, luck: 0),
        signatureAbilities: ['Blood Rage', 'Frenzied Assault', 'Deathblow'],
      ),
    ],
  ),

  ClassDefinition(
    heroClass: HeroClass.ranger,
    name: 'Ranger',
    description: 'A scout, hunter, and wilderness survivor. Deadly at range and nearly invisible in natural terrain. Struggles in enclosed spaces.',
    role: 'Ranged DPS / Scout',
    baseStats: HeroStats(strength: 4, dexterity: 9, endurance: 6, intelligence: 3, faith: 2, luck: 6),
    preferredWeapons: [WeaponType.bow, WeaponType.crossbow, WeaponType.dagger],
    subclasses: [
      SubclassDefinition(
        subclass: Subclass.huntsman,
        name: 'Huntsman',
        description: 'A master archer who has turned the skills of the hunt onto human prey. Every shot is deliberate and devastating.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 8, endurance: 0, intelligence: 0, faith: 0, luck: 2),
        signatureAbilities: ['Pinning Shot', 'Barrage', 'Headshot'],
      ),
      SubclassDefinition(
        subclass: Subclass.pathfinder,
        name: 'Pathfinder',
        description: 'An explorer and guide who moves through unknown terrain with ease and spots danger before it spots them.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 3, endurance: 3, intelligence: 2, faith: 0, luck: 5),
        signatureAbilities: ['Trailblaze', 'Ambush', 'Terrain Reading'],
      ),
      SubclassDefinition(
        subclass: Subclass.beastmaster,
        name: 'Beastmaster',
        description: 'A ranger who has forged a bond with an animal companion. They fight as one.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 2, dexterity: 4, endurance: 2, intelligence: 0, faith: 0, luck: 2),
        signatureAbilities: ['Beast Bond', 'Pack Tactics', 'Feral Roar'],
      ),
    ],
  ),

  ClassDefinition(
    heroClass: HeroClass.priest,
    name: 'Priest',
    description: 'A servant of faith whose power comes from devotion rather than training. Heals, protects, and when necessary, burns.',
    role: 'Healer / Support',
    baseStats: HeroStats(strength: 3, dexterity: 3, endurance: 5, intelligence: 5, faith: 10, luck: 4),
    preferredWeapons: [WeaponType.blunt, WeaponType.staff],
    subclasses: [
      SubclassDefinition(
        subclass: Subclass.inquisitor,
        name: 'Inquisitor',
        description: 'A priest who has turned the weapons of faith outward. Hunts heretics, burns witches, and punishes sinners with holy fire.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 2, dexterity: 0, endurance: 0, intelligence: 2, faith: 6, luck: 0),
        signatureAbilities: ['Brand of Heresy', 'Holy Fire', 'Trial by Ordeal'],
      ),
      SubclassDefinition(
        subclass: Subclass.hospitaller,
        name: 'Hospitaller',
        description: 'A healer-priest dedicated to keeping their companions alive no matter the cost to themselves.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 0, endurance: 3, intelligence: 3, faith: 4, luck: 0),
        signatureAbilities: ['Field Surgery', 'Mass Healing Prayer', 'Sanctuary'],
      ),
      SubclassDefinition(
        subclass: Subclass.zealot,
        name: 'Zealot',
        description: 'A priest who channels devotion into auras of supernatural power that empower every ally nearby.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 0, endurance: 0, intelligence: 4, faith: 8, luck: 0),
        signatureAbilities: ['Aura of Zeal', 'Martyr\'s Fire', 'Divine Mandate'],
      ),
    ],
  ),

  ClassDefinition(
    heroClass: HeroClass.mage,
    name: 'Mage',
    description: 'A scholar of the arcane arts. Fragile but capable of devastating magical attacks. Their power grows slowly but becomes overwhelming.',
    role: 'Magic DPS / Utility',
    baseStats: HeroStats(strength: 2, dexterity: 4, endurance: 3, intelligence: 11, faith: 3, luck: 7),
    preferredWeapons: [WeaponType.staff, WeaponType.wand, WeaponType.tome],
    subclasses: [
      SubclassDefinition(
        subclass: Subclass.elementalist,
        name: 'Elementalist',
        description: 'Commands fire, ice, and lightning. A raw destructive force.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 0, endurance: 0, intelligence: 8, faith: 0, luck: 2),
        signatureAbilities: ['Fireball', 'Frost Nova', 'Chain Lightning'],
      ),
      SubclassDefinition(
        subclass: Subclass.runescribe,
        name: 'Runescribe',
        description: 'An inscriber of magical sigils that persist on the battlefield, controlling space and punishing enemies who enter zones.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 2, endurance: 0, intelligence: 6, faith: 0, luck: 2),
        signatureAbilities: ['Binding Rune', 'Ward Sigil', 'Runic Detonation'],
      ),
      SubclassDefinition(
        subclass: Subclass.alchemist,
        name: 'Alchemist',
        description: 'A mage who transmutes substances into weapons: explosive concoctions, acidic draughts, and transformative elixirs.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 3, endurance: 0, intelligence: 5, faith: 0, luck: 5),
        signatureAbilities: ['Alchemical Bomb', 'Transmute', 'Philosopher\'s Draught'],
      ),
    ],
  ),

  ClassDefinition(
    heroClass: HeroClass.rogue,
    name: 'Rogue',
    description: 'A cutpurse, assassin, and survivor. Works from the shadows, strikes hard, and is gone before anyone knows what happened.',
    role: 'Burst DPS / Utility',
    baseStats: HeroStats(strength: 4, dexterity: 10, endurance: 4, intelligence: 4, faith: 1, luck: 7),
    preferredWeapons: [WeaponType.dagger, WeaponType.sword],
    subclasses: [
      SubclassDefinition(
        subclass: Subclass.assassin,
        name: 'Assassin',
        description: 'Specialized in eliminating single targets with brutal, overwhelming damage before they can respond.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 2, dexterity: 6, endurance: 0, intelligence: 0, faith: 0, luck: 2),
        signatureAbilities: ['Backstab', 'Mark for Death', 'Execute'],
      ),
      SubclassDefinition(
        subclass: Subclass.shadowblade,
        name: 'Shadowblade',
        description: 'A master of stealth who strikes from invisibility and can disappear mid-combat.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 8, endurance: 0, intelligence: 2, faith: 0, luck: 0),
        signatureAbilities: ['Fade', 'Shadow Step', 'Umbral Strike'],
      ),
      SubclassDefinition(
        subclass: Subclass.trickster,
        name: 'Trickster',
        description: 'A dirty fighter who uses poisons, tricks, and debilitating blows to control and weaken enemies.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 4, endurance: 0, intelligence: 3, faith: 0, luck: 6),
        signatureAbilities: ['Envenomed Blade', 'Blind', 'Smoke Bomb'],
      ),
    ],
  ),

  ClassDefinition(
    heroClass: HeroClass.necromancer,
    name: 'Necromancer',
    description: 'A practitioner of death magic who raises fallen enemies as servants. A necromancer alone is vulnerable; with an army of the dead, terrifying.',
    role: 'Summoner / Attrition',
    baseStats: HeroStats(strength: 2, dexterity: 3, endurance: 4, intelligence: 10, faith: 7, luck: 4),
    preferredWeapons: [WeaponType.staff, WeaponType.tome],
    subclasses: [
      SubclassDefinition(
        subclass: Subclass.lich,
        name: 'Lich',
        description: 'A necromancer who has partially crossed the threshold of death. Powerful, nearly immortal, and increasingly inhuman.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 0, endurance: 0, intelligence: 10, faith: 5, luck: 0),
        signatureAbilities: ['Phylactery Bond', 'Finger of Death', 'Undying'],
      ),
      SubclassDefinition(
        subclass: Subclass.deathKnight,
        name: 'Death Knight',
        description: 'Combines necromantic power with martial skill. Wades into melee surrounded by an aura of death.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 5, dexterity: 0, endurance: 4, intelligence: 3, faith: 3, luck: 0),
        signatureAbilities: ['Death Grip', 'Plague Strike', 'Army of the Dead'],
      ),
      SubclassDefinition(
        subclass: Subclass.plagueDoctor,
        name: 'Plague Doctor',
        description: 'A necromancer who weaponizes disease, rot, and miasma. Enemies wither slowly under their afflictions.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 2, endurance: 2, intelligence: 7, faith: 2, luck: 2),
        signatureAbilities: ['Contagion', 'Miasma Cloud', 'Rot'],
      ),
    ],
  ),

  ClassDefinition(
    heroClass: HeroClass.warlock,
    name: 'Warlock',
    description: 'One who has made a bargain with something that should not be bargained with. Their power is immense and comes with costs that grow over time.',
    role: 'Dark Magic DPS / Summoner',
    baseStats: HeroStats(strength: 3, dexterity: 4, endurance: 4, intelligence: 9, faith: 8, luck: 2),
    preferredWeapons: [WeaponType.wand, WeaponType.tome, WeaponType.sword],
    subclasses: [
      SubclassDefinition(
        subclass: Subclass.demonologist,
        name: 'Demonologist',
        description: 'Summons and binds demonic entities. The demons obey — for now.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 0, endurance: 0, intelligence: 6, faith: 8, luck: 0),
        signatureAbilities: ['Summon Imp', 'Infernal Binding', 'Greater Demon Pact'],
      ),
      SubclassDefinition(
        subclass: Subclass.hexblade,
        name: 'Hexblade',
        description: 'Bonds their weapon to their patron, creating a cursed blade that feeds on the souls it slays.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 5, dexterity: 3, endurance: 0, intelligence: 4, faith: 3, luck: 0),
        signatureAbilities: ['Hex', 'Soul Harvest', 'Pact Blade'],
      ),
      SubclassDefinition(
        subclass: Subclass.occultist,
        name: 'Occultist',
        description: 'A ritual specialist who performs forbidden ceremonies mid-battle for catastrophic effects.',
        unlockLevel: 10,
        statBonus: HeroStats(strength: 0, dexterity: 0, endurance: 0, intelligence: 8, faith: 5, luck: 2),
        signatureAbilities: ['Dark Ritual', 'Eldritch Blast', 'The Forbidden Name'],
      ),
    ],
  ),
];
