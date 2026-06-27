import 'enums.dart';

class Expedition {
  final String id;
  final String locationName;
  final LocationType locationType;
  final List<String> heroIds;
  final int durationSeconds;
  final int elapsedSeconds;
  final int depth;
  final bool completed;
  final String? combatReportJson;
  final String? worldLocationId;
  // Full list of combat event lines pre-computed at expedition start.
  // Events are revealed proportionally as elapsedSeconds advances.
  final List<String> liveCombatLog;
  // Seconds spent traveling before the party arrives at the location.
  // 0 = no travel phase (legacy or instant).
  final int travelSeconds;
  // Bitmask tracking which travel events have fired.
  // Bit 0 = event at 30% travel fired. Bit 1 = event at 70% travel fired.
  final int travelEventMask;
  // Bitmask for pre-expedition supply purchases.
  // Bit 0 = healing kit purchased. Bit 1 = lantern purchased.
  final int suppliesFlags;
  // Whether the campfire event has already fired on this expedition.
  final bool campfireFired;

  const Expedition({
    required this.id,
    required this.locationName,
    required this.locationType,
    required this.heroIds,
    required this.durationSeconds,
    this.elapsedSeconds = 0,
    this.depth = 0,
    this.completed = false,
    this.combatReportJson,
    this.worldLocationId,
    this.liveCombatLog = const [],
    this.travelSeconds = 0,
    this.travelEventMask = 0,
    this.suppliesFlags = 0,
    this.campfireFired = false,
  });

  double get progress =>
      durationSeconds == 0 ? 0 : (elapsedSeconds / durationSeconds).clamp(0.0, 1.0);

  bool get isComplete => elapsedSeconds >= durationSeconds;

  /// True while the party is still on the road to the destination.
  bool get isTraveling => travelSeconds > 0 && elapsedSeconds < travelSeconds;

  /// 0.0→1.0 through the travel leg only.
  double get travelProgress => travelSeconds == 0
      ? 1.0
      : (elapsedSeconds / travelSeconds).clamp(0.0, 1.0);

  /// 0.0→1.0 through the at-location leg only (combat / town visit).
  /// Falls back to [progress] when there is no travel phase.
  double get atLocationProgress {
    if (travelSeconds == 0) return progress;
    final atLocSeconds = durationSeconds - travelSeconds;
    if (atLocSeconds <= 0) return 1.0;
    final atLocElapsed = (elapsedSeconds - travelSeconds).clamp(0, atLocSeconds);
    return (atLocElapsed / atLocSeconds).clamp(0.0, 1.0);
  }

  Expedition copyWith({
    int? elapsedSeconds,
    int? depth,
    bool? completed,
    String? combatReportJson,
    String? worldLocationId,
    List<String>? liveCombatLog,
    int? travelSeconds,
    int? travelEventMask,
    int? suppliesFlags,
    bool? campfireFired,
  }) =>
      Expedition(
        id: id,
        locationName: locationName,
        locationType: locationType,
        heroIds: heroIds,
        durationSeconds: durationSeconds,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        depth: depth ?? this.depth,
        completed: completed ?? this.completed,
        combatReportJson: combatReportJson ?? this.combatReportJson,
        worldLocationId: worldLocationId ?? this.worldLocationId,
        liveCombatLog: liveCombatLog ?? this.liveCombatLog,
        travelSeconds: travelSeconds ?? this.travelSeconds,
        travelEventMask: travelEventMask ?? this.travelEventMask,
        suppliesFlags: suppliesFlags ?? this.suppliesFlags,
        campfireFired: campfireFired ?? this.campfireFired,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'locationName': locationName,
        'locationType': locationType.name,
        'heroIds': heroIds,
        'durationSeconds': durationSeconds,
        'elapsedSeconds': elapsedSeconds,
        'depth': depth,
        'completed': completed,
        'combatReportJson': combatReportJson,
        'worldLocationId': worldLocationId,
        'liveCombatLog': liveCombatLog,
        'travelSeconds': travelSeconds,
        'travelEventMask': travelEventMask,
        'suppliesFlags': suppliesFlags,
        'campfireFired': campfireFired,
      };

  factory Expedition.fromJson(Map<String, dynamic> j) => Expedition(
        id: j['id'],
        locationName: j['locationName'],
        locationType: LocationType.values.byName(j['locationType']),
        heroIds: List<String>.from(j['heroIds']),
        durationSeconds: j['durationSeconds'],
        elapsedSeconds: j['elapsedSeconds'] ?? 0,
        depth: j['depth'] ?? 0,
        completed: j['completed'] ?? false,
        combatReportJson: j['combatReportJson'],
        worldLocationId: j['worldLocationId'],
        liveCombatLog: List<String>.from(j['liveCombatLog'] ?? const []),
        travelSeconds: j['travelSeconds'] as int? ?? 0,
        travelEventMask: j['travelEventMask'] as int? ?? 0,
        suppliesFlags: j['suppliesFlags'] as int? ?? 0,
        campfireFired: j['campfireFired'] as bool? ?? false,
      );
}
