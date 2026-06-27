import 'property.dart';

class PropertyEventChoice {
  final String label;
  final String outcome;
  final int goldDelta;
  final int devotionDelta;

  const PropertyEventChoice({
    required this.label,
    required this.outcome,
    this.goldDelta = 0,
    this.devotionDelta = 0,
  });
}

class PropertyEventDef {
  final String id;
  final String title;
  final String description;
  final PropertyType forType;
  final List<PropertyEventChoice> choices;

  const PropertyEventDef({
    required this.id,
    required this.title,
    required this.description,
    required this.forType,
    required this.choices,
  });
}

// A pending event attached to a specific owned property instance.
class PendingPropertyEvent {
  final String propertyId;
  final String defId;

  const PendingPropertyEvent({
    required this.propertyId,
    required this.defId,
  });

  Map<String, dynamic> toJson() => {
        'propertyId': propertyId,
        'defId': defId,
      };

  factory PendingPropertyEvent.fromJson(Map<String, dynamic> j) =>
      PendingPropertyEvent(
        propertyId: j['propertyId'],
        defId: j['defId'],
      );
}
