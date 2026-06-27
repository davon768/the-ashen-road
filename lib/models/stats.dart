class HeroStats {
  final int strength;     // melee damage, carry weight
  final int dexterity;    // ranged damage, attack speed, dodge
  final int endurance;    // max health, stamina, recovery speed
  final int intelligence; // magic power, spell variety
  final int faith;        // devotion gain rate, miracle strength
  final int luck;         // crit chance, loot quality, rare encounters

  const HeroStats({
    this.strength = 5,
    this.dexterity = 5,
    this.endurance = 5,
    this.intelligence = 5,
    this.faith = 5,
    this.luck = 5,
  });

  HeroStats copyWith({
    int? strength,
    int? dexterity,
    int? endurance,
    int? intelligence,
    int? faith,
    int? luck,
  }) {
    return HeroStats(
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      endurance: endurance ?? this.endurance,
      intelligence: intelligence ?? this.intelligence,
      faith: faith ?? this.faith,
      luck: luck ?? this.luck,
    );
  }

  HeroStats operator +(HeroStats other) => HeroStats(
        strength: strength + other.strength,
        dexterity: dexterity + other.dexterity,
        endurance: endurance + other.endurance,
        intelligence: intelligence + other.intelligence,
        faith: faith + other.faith,
        luck: luck + other.luck,
      );

  int get maxHealth => 50 + (endurance * 10);
  int get meleeDamage => 5 + (strength * 2);
  int get rangedDamage => 5 + (dexterity * 2);
  int get magicPower => 5 + (intelligence * 2);
  double get critChance => 0.05 + (luck * 0.01);

  Map<String, dynamic> toJson() => {
        'strength': strength,
        'dexterity': dexterity,
        'endurance': endurance,
        'intelligence': intelligence,
        'faith': faith,
        'luck': luck,
      };

  factory HeroStats.fromJson(Map<String, dynamic> json) => HeroStats(
        strength: json['strength'] ?? 5,
        dexterity: json['dexterity'] ?? 5,
        endurance: json['endurance'] ?? 5,
        intelligence: json['intelligence'] ?? 5,
        faith: json['faith'] ?? 5,
        luck: json['luck'] ?? 5,
      );
}
