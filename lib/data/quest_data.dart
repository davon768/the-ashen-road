import 'dart:math';
import '../models/quest.dart';
import '../models/enums.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ─── QUEST POOL ──────────────────────────────────────────────────────────────
// Each entry is a factory that stamps out a fresh Quest with a unique ID.
// Depth param allows higher-value quests at deeper locations.

typedef _QuestFactory = Quest Function(int depth);

const _questGivers = [
  'The Innkeeper',
  'A Scarred Soldier',
  'The Town Steward',
  'A Travelling Merchant',
  'A Gaunt Scholar',
  'The Local Constable',
  'A Weeping Widow',
  'An Old Campaigner',
];

final List<_QuestFactory> _questPool = [
  // Dungeon expeditions
  (depth) => Quest(
        id: _uuid.v4(),
        title: 'Cleanse the Hollow',
        description: 'Clear out the dungeon nearby — the dead have been restless. Complete 3 dungeon expeditions.',
        questGiverName: _questGivers[0],
        type: QuestType.expeditionCount,
        targetValue: 3,
        targetLocationType: LocationType.dungeon,
        rewardGold: 120 + depth * 30,
      ),
  (depth) => Quest(
        id: _uuid.v4(),
        title: 'Purge the Depths',
        description: 'The townsfolk fear the dungeon beneath the hill. Fight your way through it twice more.',
        questGiverName: _questGivers[1],
        type: QuestType.expeditionCount,
        targetValue: 2,
        targetLocationType: LocationType.dungeon,
        rewardGold: 90 + depth * 25,
      ),

  // Wilderness expeditions
  (depth) => Quest(
        id: _uuid.v4(),
        title: 'Thinning the Pack',
        description: 'Beasts from the wilds have been raiding farms. Clear the wilderness twice.',
        questGiverName: _questGivers[2],
        type: QuestType.expeditionCount,
        targetValue: 2,
        targetLocationType: LocationType.wilderness,
        rewardGold: 80 + depth * 20,
      ),
  (depth) => Quest(
        id: _uuid.v4(),
        title: 'The Long Hunt',
        description: 'Hunters have not returned from the wilderness. Lead three expeditions to find what lurks there.',
        questGiverName: _questGivers[7],
        type: QuestType.expeditionCount,
        targetValue: 3,
        targetLocationType: LocationType.wilderness,
        rewardGold: 110 + depth * 25,
      ),

  // Ruins expeditions
  (depth) => Quest(
        id: _uuid.v4(),
        title: 'Seal the Old Gate',
        description: 'Something stirs in the ruins. Drive your party through them twice to put it down.',
        questGiverName: _questGivers[4],
        type: QuestType.expeditionCount,
        targetValue: 2,
        targetLocationType: LocationType.ruins,
        rewardGold: 100 + depth * 25,
      ),

  // Castle expeditions
  (depth) => Quest(
        id: _uuid.v4(),
        title: 'Storm the Fallen Keep',
        description: 'Bandits have seized the old castle. Clear it out — twice if you must.',
        questGiverName: _questGivers[3],
        type: QuestType.expeditionCount,
        targetValue: 2,
        targetLocationType: LocationType.castle,
        rewardGold: 130 + depth * 30,
      ),

  // Cemetery expeditions
  (depth) => Quest(
        id: _uuid.v4(),
        title: 'Lay Them to Rest',
        description: 'The cemetery is walking again. Put down the risen dead — three times over.',
        questGiverName: _questGivers[6],
        type: QuestType.expeditionCount,
        targetValue: 3,
        targetLocationType: LocationType.cemetery,
        rewardGold: 100 + depth * 20,
      ),

  // Depth-reach quests
  (depth) => Quest(
        id: _uuid.v4(),
        title: 'Into the Heart',
        description: 'Prove your courage. Descend to depth ${(depth + 2).clamp(3, 6)} in any expedition.',
        questGiverName: _questGivers[5],
        type: QuestType.depthReach,
        targetValue: (depth + 2).clamp(3, 6),
        rewardGold: 150 + depth * 40,
      ),
  (depth) => Quest(
        id: _uuid.v4(),
        title: 'Descent Proven',
        description: 'Go where lesser adventurers fear. Reach depth ${(depth + 1).clamp(3, 5)} in a single expedition.',
        questGiverName: _questGivers[1],
        type: QuestType.depthReach,
        targetValue: (depth + 1).clamp(3, 5),
        rewardGold: 120 + depth * 30,
      ),

  // General any-type expeditions
  (depth) => Quest(
        id: _uuid.v4(),
        title: 'Roads Run Red',
        description: 'The roads are not safe. Complete 4 expeditions of any kind.',
        questGiverName: _questGivers[3],
        type: QuestType.expeditionCount,
        targetValue: 4,
        rewardGold: 160 + depth * 20,
      ),
  (depth) => Quest(
        id: _uuid.v4(),
        title: 'Earn Your Name',
        description: 'Word of deeds travels fast in this land. Complete 3 expeditions.',
        questGiverName: _questGivers[0],
        type: QuestType.expeditionCount,
        targetValue: 3,
        rewardGold: 90 + depth * 15,
      ),
];

/// Returns 1-2 quest offers for a town visit, excluding already-active/completed IDs.
List<Quest> generateQuestOffers(
  Random rng,
  int depth,
  List<String> activeQuestTitles,
  List<String> completedQuestIds,
) {
  final shuffled = [..._questPool]..shuffle(rng);
  final result = <Quest>[];
  for (final factory in shuffled) {
    if (result.length >= 2) break;
    final q = factory(depth);
    // Skip if a quest with the same title is already active
    if (activeQuestTitles.contains(q.title)) continue;
    result.add(q);
  }
  return result;
}
