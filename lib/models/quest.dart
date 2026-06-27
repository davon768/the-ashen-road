import 'enums.dart';

enum QuestType { expeditionCount, depthReach }

class Quest {
  final String id;
  final String title;
  final String description;
  final String questGiverName;
  final QuestType type;
  final int targetValue;
  final LocationType? targetLocationType;
  final int rewardGold;
  final int progress;
  final bool completed;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.questGiverName,
    required this.type,
    required this.targetValue,
    this.targetLocationType,
    required this.rewardGold,
    this.progress = 0,
    this.completed = false,
  });

  Quest copyWith({int? progress, bool? completed}) => Quest(
        id: id,
        title: title,
        description: description,
        questGiverName: questGiverName,
        type: type,
        targetValue: targetValue,
        targetLocationType: targetLocationType,
        rewardGold: rewardGold,
        progress: progress ?? this.progress,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'questGiverName': questGiverName,
        'type': type.name,
        'targetValue': targetValue,
        'targetLocationType': targetLocationType?.name,
        'rewardGold': rewardGold,
        'progress': progress,
        'completed': completed,
      };

  factory Quest.fromJson(Map<String, dynamic> j) => Quest(
        id: j['id'],
        title: j['title'],
        description: j['description'],
        questGiverName: j['questGiverName'],
        type: QuestType.values.byName(j['type']),
        targetValue: j['targetValue'],
        targetLocationType: j['targetLocationType'] != null
            ? LocationType.values.byName(j['targetLocationType'])
            : null,
        rewardGold: j['rewardGold'],
        progress: j['progress'] ?? 0,
        completed: j['completed'] ?? false,
      );
}
