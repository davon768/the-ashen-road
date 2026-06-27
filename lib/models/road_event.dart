import 'enums.dart';

class EventEffect {
  final int goldDelta;
  final double devotionDelta;
  /// When set, devotionDelta only applies to heroes with this faith.
  /// When null, devotionDelta applies to all heroes who have any faith.
  final FaithType? targetFaith;
  final int partyDamage; // flat HP lost by all active heroes
  final int partyHeal;   // flat HP restored to all heroes
  /// If true and party has room, a random hero joins the party when this choice is made.
  final bool heroJoins;
  /// If set, a spell tome for this spell ID is added to the inventory.
  final String? spellTomeId;
  /// If set, a weapon with this ID is added to the inventory.
  final String? weaponRewardId;

  const EventEffect({
    this.goldDelta = 0,
    this.devotionDelta = 0,
    this.targetFaith,
    this.partyDamage = 0,
    this.partyHeal = 0,
    this.heroJoins = false,
    this.spellTomeId,
    this.weaponRewardId,
  });
}

class EventChoice {
  final String label;
  final String outcome;
  final EventEffect effect;

  const EventChoice({
    required this.label,
    required this.outcome,
    required this.effect,
  });
}

class RoadEvent {
  final String id;
  final String title;
  final String description;
  final List<EventChoice> choices;

  const RoadEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.choices,
  });
}
