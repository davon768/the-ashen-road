enum HeroClass { knight, ranger, priest, mage, rogue, necromancer, warlock }

enum Subclass {
  // Knight
  crusader, sentinel, berserker,
  // Ranger
  huntsman, pathfinder, beastmaster,
  // Priest
  inquisitor, hospitaller, zealot,
  // Mage
  elementalist, runescribe, alchemist,
  // Rogue
  assassin, shadowblade, trickster,
  // Necromancer
  lich, deathKnight, plagueDoctor,
  // Warlock
  demonologist, hexblade, occultist,
}

enum FaithType {
  luminantChurch,
  oldWays,
  paleCourt,
  compactOfSaints,
  ashenRite,
}

enum WeaponType {
  sword, axe, polearm, blunt, dagger, bow, crossbow, staff, tome, wand,
}

enum WeaponGrip { oneHanded, twoHanded, versatile }

enum ArmorSlot { head, body, hands, legs, feet, shield }

enum Rarity { common, uncommon, rare, epic, legendary }

enum HeroStatus { active, recovering, dead }

enum ItemType { potion, food, material, key, quest }

enum LocationType { town, dungeon, castle, wilderness, ruins, monastery, cemetery, library, forge, church, shrine, cultSite }

extension HeroClassX on HeroClass {
  bool get isCaster =>
      this == HeroClass.mage ||
      this == HeroClass.warlock ||
      this == HeroClass.necromancer ||
      this == HeroClass.priest;
}
