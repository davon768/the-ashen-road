enum CombatOutcome { victory, retreat, partyWiped }

class CombatEvent {
  final String text;
  final CombatEventType type;

  const CombatEvent(this.text, this.type);
}

enum CombatEventType {
  heroAttack, enemyAttack, heroKill, heroDown,
  crit, ability, faithMiracle, loot, narrative,
}

class EncounterResult {
  final String enemyNames;
  final List<CombatEvent> events;
  final CombatOutcome outcome;
  final int goldFound;
  final int xpGained;

  const EncounterResult({
    required this.enemyNames,
    required this.events,
    required this.outcome,
    required this.goldFound,
    required this.xpGained,
  });
}

class ExpeditionCombatResult {
  final List<EncounterResult> encounters;
  final int totalGold;
  final int totalXp;
  final List<String> injuredHeroIds;
  final List<String> deadHeroIds;
  final CombatOutcome finalOutcome;
  final List<String> lootDescriptions;
  final Map<String, int> heroFinalMana; // mana remaining after all encounters

  const ExpeditionCombatResult({
    required this.encounters,
    required this.totalGold,
    required this.totalXp,
    required this.injuredHeroIds,
    required this.deadHeroIds,
    required this.finalOutcome,
    required this.lootDescriptions,
    this.heroFinalMana = const {},
  });
}
