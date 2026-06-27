enum EnemyType {
  human, undead, beast, supernatural, elite,
}

enum EnemyTrait {
  critImmune,    // crits deal normal damage — undead have no vital points
  selfRegen,     // heals 5% maxHp at the end of each round — higher-tier undead
  armorPiercing, // ignores hero defense — beasts tear through gaps in armor
  phaseOnCrit,   // crits deal 1.3× instead of 2× — spirits partially disperse
  partyDamage,   // attacks all heroes at 55% power instead of one target
  drainOnHit,    // heals self for 35% of damage dealt
  fleeOnLowHp,   // 35% chance to flee when below 30% HP, dropping some coin
}

class Enemy {
  final String id;
  final String name;
  final EnemyType type;
  final int maxHp;
  int currentHp;
  final int minDamage;
  final int maxDamage;
  int armor; // mutable — debuff spells reduce this in-encounter
  final double critChance;
  final int xpValue;
  final int goldValue;
  final bool isBoss;
  final Set<EnemyTrait> traits;

  Enemy({
    required this.id,
    required this.name,
    required this.type,
    required this.maxHp,
    required this.minDamage,
    required this.maxDamage,
    required this.armor,
    this.critChance = 0.05,
    required this.xpValue,
    required this.goldValue,
    this.isBoss = false,
    this.traits = const {},
  }) : currentHp = maxHp;

  bool get isAlive => currentHp > 0;

  void takeDamage(int amount) {
    currentHp = (currentHp - amount).clamp(0, maxHp);
  }
}
