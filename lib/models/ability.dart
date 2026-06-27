enum AbilityTrigger { onAttack, onHit, onKill, onLowHealth, passive, onRoundStart }
enum AbilityTarget { self, singleEnemy, allEnemies, singleAlly, allAllies }

class Ability {
  final String id;
  final String name;
  final String description;
  final AbilityTrigger trigger;
  final AbilityTarget target;
  final double chance;    // 0.0 - 1.0, for proc-based abilities
  final int cooldown;     // in combat rounds, 0 = no cooldown
  final Map<String, dynamic> effect;

  const Ability({
    required this.id,
    required this.name,
    required this.description,
    required this.trigger,
    required this.target,
    this.chance = 1.0,
    this.cooldown = 0,
    required this.effect,
  });
}
