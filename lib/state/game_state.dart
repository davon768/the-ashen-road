import '../models/hero.dart';
import '../models/property.dart';
import '../models/property_event.dart';
import '../models/expedition.dart';
import '../models/inventory.dart';
import '../models/world_location.dart';
import '../models/town_visit.dart';
import '../models/quest.dart';
import '../utils/world_generator.dart';

// ─── MERCHANT ITEM ────────────────────────────────────────────────────────────

class MerchantItem {
  final String id;
  final bool isArmor;
  final int price;
  final bool sold;

  const MerchantItem({
    required this.id,
    required this.isArmor,
    required this.price,
    this.sold = false,
  });

  MerchantItem copyWith({bool? sold}) =>
      MerchantItem(id: id, isArmor: isArmor, price: price, sold: sold ?? this.sold);

  Map<String, dynamic> toJson() => {'id': id, 'isArmor': isArmor, 'price': price, 'sold': sold};

  factory MerchantItem.fromJson(Map<String, dynamic> j) => MerchantItem(
        id: j['id'] as String,
        isArmor: j['isArmor'] as bool,
        price: j['price'] as int,
        sold: j['sold'] as bool? ?? false,
      );
}

// ─── PARTY RETURN ────────────────────────────────────────────────────────────
// Tracks the party moving back to Ashenvale after an expedition resolves.
// Purely cosmetic — drives the map marker animation only.

class PartyReturn {
  final double destX;
  final double destY;
  final int totalSeconds;
  final int secondsRemaining;
  // True once the return-trip event has fired so it doesn't fire again.
  final bool eventFired;

  const PartyReturn({
    required this.destX,
    required this.destY,
    required this.totalSeconds,
    required this.secondsRemaining,
    this.eventFired = false,
  });

  /// 1.0 = party still at destination; 0.0 = party back home.
  double get returnProgress => totalSeconds == 0
      ? 0.0
      : (secondsRemaining / totalSeconds).clamp(0.0, 1.0);

  PartyReturn copyWith({int? secondsRemaining, bool? eventFired}) => PartyReturn(
        destX: destX,
        destY: destY,
        totalSeconds: totalSeconds,
        secondsRemaining: secondsRemaining ?? this.secondsRemaining,
        eventFired: eventFired ?? this.eventFired,
      );

  Map<String, dynamic> toJson() => {
        'destX': destX,
        'destY': destY,
        'totalSeconds': totalSeconds,
        'secondsRemaining': secondsRemaining,
        'eventFired': eventFired,
      };

  factory PartyReturn.fromJson(Map<String, dynamic> j) => PartyReturn(
        destX: (j['destX'] as num).toDouble(),
        destY: (j['destY'] as num).toDouble(),
        totalSeconds: j['totalSeconds'] as int,
        secondsRemaining: j['secondsRemaining'] as int,
        eventFired: j['eventFired'] as bool? ?? false,
      );
}

const _kSentinel = Object();

class GameState {
  final List<Hero> party;
  final int gold;
  final List<OwnedProperty> properties;
  final List<PendingPropertyEvent> pendingPropertyEvents;
  final Expedition? activeExpedition;
  final bool permadeathEnabled;
  final DateTime lastOnlineTime;
  final int totalPlaytimeSeconds;
  final int inGameDay;
  final List<String> eventLog;
  final Inventory inventory;
  final List<WorldLocation> worldMap;
  final String? pendingEventId;
  // Persisted separately so the report survives after a new expedition is sent.
  final String? lastCombatReportJson;
  final String? lastCombatLocationName;
  // Prevents immediately re-entering the same location.
  final String? lastCompletedLocationId;
  // Active town/monastery visit — cleared when player leaves town.
  final TownVisit? activeTownVisit;
  // Which in-game day the party last rested at the tavern (-1 = never).
  final int tavernRestDay;
  // Active return-journey animation after combat expedition resolves.
  // Null when party is at home or in an expedition.
  final PartyReturn? partyReturn;
  // Interactive travel event awaiting player resolution.
  // Non-null → expedition timer is paused; road screen shows choice panel.
  final String? pendingTravelEventId;
  // Hero IDs that have crossed a devotion tier threshold and need to pick a perk.
  final List<String> pendingDevotionChoices;
  // Retirement legacy bonuses accumulated from retired heroes.
  // Each entry is either 'gold_legacy' or 'xp_legacy'.
  final List<String> retirementPerks;
  // Active quests accepted at town notice boards.
  final List<Quest> activeQuests;
  // IDs (titles) of quests that have been completed and turned in.
  final List<String> completedQuestTitles;
  // ─── NEW SUPPLY / ECONOMY / SOCIAL FIELDS ──────────────────────────────────
  final int rations;
  final Map<String, int> locationVisitCounts;
  final List<String> investedLocationIds;
  // bond key = "idA:idB" (sorted alphabetically), value = expeditions together
  final Map<String, int> heroBonds;
  // Traveling merchant
  final bool merchantActive;
  final List<MerchantItem> merchantStock;
  final int nextMerchantDay;
  // Return-trip event: non-null while partyReturn is ticking and event not yet resolved
  final String? pendingReturnEventId;
  // trainingRecords[locationId] = list of heroIds that already trained there
  final Map<String, List<String>> trainingRecords;
  // Non-null while the "new companion joined" banner should be shown.
  final String? pendingHeroJoinName;

  const GameState({
    required this.party,
    required this.gold,
    required this.properties,
    this.pendingPropertyEvents = const [],
    this.activeExpedition,
    required this.permadeathEnabled,
    required this.lastOnlineTime,
    required this.totalPlaytimeSeconds,
    required this.inGameDay,
    required this.eventLog,
    required this.inventory,
    required this.worldMap,
    this.pendingEventId,
    this.lastCombatReportJson,
    this.lastCombatLocationName,
    this.lastCompletedLocationId,
    this.activeTownVisit,
    this.tavernRestDay = -1,
    this.partyReturn,
    this.pendingTravelEventId,
    this.pendingDevotionChoices = const [],
    this.retirementPerks = const [],
    this.activeQuests = const [],
    this.completedQuestTitles = const [],
    this.rations = 10,
    this.locationVisitCounts = const {},
    this.investedLocationIds = const [],
    this.heroBonds = const {},
    this.merchantActive = false,
    this.merchantStock = const [],
    this.nextMerchantDay = 5,
    this.pendingReturnEventId,
    this.trainingRecords = const {},
    this.pendingHeroJoinName,
  });

  double get goldPerSecond {
    if (properties.isEmpty) return 0;
    return properties.fold(0.0, (sum, p) => sum + p.goldPerMinute / 60.0);
  }

  List<Hero> get availableHeroes =>
      party.where((h) => h.isAvailable).toList();

  GameState copyWith({
    List<Hero>? party,
    int? gold,
    List<OwnedProperty>? properties,
    List<PendingPropertyEvent>? pendingPropertyEvents,
    Expedition? activeExpedition,
    bool? clearExpedition,
    bool? permadeathEnabled,
    DateTime? lastOnlineTime,
    int? totalPlaytimeSeconds,
    int? inGameDay,
    List<String>? eventLog,
    Inventory? inventory,
    List<WorldLocation>? worldMap,
    Object? pendingEventId = _kSentinel,
    Object? lastCombatReportJson = _kSentinel,
    Object? lastCombatLocationName = _kSentinel,
    Object? lastCompletedLocationId = _kSentinel,
    Object? activeTownVisit = _kSentinel,
    int? tavernRestDay,
    Object? partyReturn = _kSentinel,
    Object? pendingTravelEventId = _kSentinel,
    List<String>? pendingDevotionChoices,
    List<String>? retirementPerks,
    List<Quest>? activeQuests,
    List<String>? completedQuestTitles,
    int? rations,
    Map<String, int>? locationVisitCounts,
    List<String>? investedLocationIds,
    Map<String, int>? heroBonds,
    bool? merchantActive,
    List<MerchantItem>? merchantStock,
    int? nextMerchantDay,
    Object? pendingReturnEventId = _kSentinel,
    Map<String, List<String>>? trainingRecords,
    Object? pendingHeroJoinName = _kSentinel,
  }) {
    return GameState(
      party: party ?? this.party,
      gold: gold ?? this.gold,
      properties: properties ?? this.properties,
      pendingPropertyEvents:
          pendingPropertyEvents ?? this.pendingPropertyEvents,
      activeExpedition:
          clearExpedition == true ? null : activeExpedition ?? this.activeExpedition,
      permadeathEnabled: permadeathEnabled ?? this.permadeathEnabled,
      lastOnlineTime: lastOnlineTime ?? this.lastOnlineTime,
      totalPlaytimeSeconds: totalPlaytimeSeconds ?? this.totalPlaytimeSeconds,
      inGameDay: inGameDay ?? this.inGameDay,
      eventLog: eventLog ?? this.eventLog,
      inventory: inventory ?? this.inventory,
      worldMap: worldMap ?? this.worldMap,
      pendingEventId: pendingEventId == _kSentinel
          ? this.pendingEventId
          : pendingEventId as String?,
      lastCombatReportJson: lastCombatReportJson == _kSentinel
          ? this.lastCombatReportJson
          : lastCombatReportJson as String?,
      lastCombatLocationName: lastCombatLocationName == _kSentinel
          ? this.lastCombatLocationName
          : lastCombatLocationName as String?,
      lastCompletedLocationId: lastCompletedLocationId == _kSentinel
          ? this.lastCompletedLocationId
          : lastCompletedLocationId as String?,
      activeTownVisit: activeTownVisit == _kSentinel
          ? this.activeTownVisit
          : activeTownVisit as TownVisit?,
      tavernRestDay: tavernRestDay ?? this.tavernRestDay,
      partyReturn: partyReturn == _kSentinel
          ? this.partyReturn
          : partyReturn as PartyReturn?,
      pendingTravelEventId: pendingTravelEventId == _kSentinel
          ? this.pendingTravelEventId
          : pendingTravelEventId as String?,
      pendingDevotionChoices: pendingDevotionChoices ?? this.pendingDevotionChoices,
      retirementPerks: retirementPerks ?? this.retirementPerks,
      activeQuests: activeQuests ?? this.activeQuests,
      completedQuestTitles: completedQuestTitles ?? this.completedQuestTitles,
      rations: rations ?? this.rations,
      locationVisitCounts: locationVisitCounts ?? this.locationVisitCounts,
      investedLocationIds: investedLocationIds ?? this.investedLocationIds,
      heroBonds: heroBonds ?? this.heroBonds,
      merchantActive: merchantActive ?? this.merchantActive,
      merchantStock: merchantStock ?? this.merchantStock,
      nextMerchantDay: nextMerchantDay ?? this.nextMerchantDay,
      pendingReturnEventId: pendingReturnEventId == _kSentinel
          ? this.pendingReturnEventId
          : pendingReturnEventId as String?,
      trainingRecords: trainingRecords ?? this.trainingRecords,
      pendingHeroJoinName: pendingHeroJoinName == _kSentinel
          ? this.pendingHeroJoinName
          : pendingHeroJoinName as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'party': party.map((h) => h.toJson()).toList(),
        'gold': gold,
        'properties': properties.map((p) => p.toJson()).toList(),
        'pendingPropertyEvents':
            pendingPropertyEvents.map((e) => e.toJson()).toList(),
        'activeExpedition': activeExpedition?.toJson(),
        'permadeathEnabled': permadeathEnabled,
        'lastOnlineTime': lastOnlineTime.toIso8601String(),
        'totalPlaytimeSeconds': totalPlaytimeSeconds,
        'inGameDay': inGameDay,
        'eventLog': eventLog,
        'inventory': inventory.toJson(),
        'worldMap': worldMap.map((l) => l.toJson()).toList(),
        'pendingEventId': pendingEventId,
        'lastCombatReportJson': lastCombatReportJson,
        'lastCombatLocationName': lastCombatLocationName,
        'lastCompletedLocationId': lastCompletedLocationId,
        'activeTownVisit': activeTownVisit?.toJson(),
        'tavernRestDay': tavernRestDay,
        'partyReturn': partyReturn?.toJson(),
        'pendingTravelEventId': pendingTravelEventId,
        'pendingDevotionChoices': pendingDevotionChoices,
        'retirementPerks': retirementPerks,
        'activeQuests': activeQuests.map((q) => q.toJson()).toList(),
        'completedQuestTitles': completedQuestTitles,
        'rations': rations,
        'locationVisitCounts': locationVisitCounts,
        'investedLocationIds': investedLocationIds,
        'heroBonds': heroBonds,
        'merchantActive': merchantActive,
        'merchantStock': merchantStock.map((m) => m.toJson()).toList(),
        'nextMerchantDay': nextMerchantDay,
        'pendingReturnEventId': pendingReturnEventId,
        'trainingRecords': trainingRecords.map((k, v) => MapEntry(k, v)),
        'pendingHeroJoinName': pendingHeroJoinName,
      };

  factory GameState.fromJson(Map<String, dynamic> j) => GameState(
        party: (j['party'] as List).map((h) => Hero.fromJson(h)).toList(),
        gold: j['gold'] ?? 0,
        properties: (j['properties'] as List)
            .map((p) => OwnedProperty.fromJson(p))
            .toList(),
        pendingPropertyEvents: (j['pendingPropertyEvents'] as List?)
                ?.map((e) => PendingPropertyEvent.fromJson(e))
                .toList() ??
            const [],
        activeExpedition: j['activeExpedition'] != null
            ? Expedition.fromJson(j['activeExpedition'])
            : null,
        permadeathEnabled: j['permadeathEnabled'] ?? false,
        lastOnlineTime: DateTime.parse(j['lastOnlineTime']),
        totalPlaytimeSeconds: j['totalPlaytimeSeconds'] ?? 0,
        inGameDay: j['inGameDay'] ?? 1,
        eventLog: List<String>.from(j['eventLog'] ?? []),
        inventory: j['inventory'] != null
            ? Inventory.fromJson(j['inventory'])
            : Inventory.empty(),
        worldMap: j['worldMap'] != null
            ? (j['worldMap'] as List)
                .map((l) => WorldLocation.fromJson(l))
                .toList()
            : generateWorldMap(),
        pendingEventId: j['pendingEventId'] as String?,
        lastCombatReportJson: j['lastCombatReportJson'] as String?,
        lastCombatLocationName: j['lastCombatLocationName'] as String?,
        lastCompletedLocationId: j['lastCompletedLocationId'] as String?,
        activeTownVisit: j['activeTownVisit'] != null
            ? TownVisit.fromJson(j['activeTownVisit'])
            : null,
        tavernRestDay: j['tavernRestDay'] ?? -1,
        partyReturn: j['partyReturn'] != null
            ? PartyReturn.fromJson(j['partyReturn'] as Map<String, dynamic>)
            : null,
        pendingTravelEventId: j['pendingTravelEventId'] as String?,
        pendingDevotionChoices: List<String>.from(j['pendingDevotionChoices'] as List? ?? []),
        retirementPerks: List<String>.from(j['retirementPerks'] as List? ?? []),
        activeQuests: (j['activeQuests'] as List? ?? [])
            .map((q) => Quest.fromJson(q as Map<String, dynamic>))
            .toList(),
        completedQuestTitles: List<String>.from(j['completedQuestTitles'] as List? ?? []),
        rations: j['rations'] as int? ?? 10,
        locationVisitCounts: (j['locationVisitCounts'] as Map?)
                ?.map((k, v) => MapEntry(k as String, v as int)) ??
            {},
        investedLocationIds: List<String>.from(j['investedLocationIds'] as List? ?? []),
        heroBonds: (j['heroBonds'] as Map?)?.map((k, v) => MapEntry(k as String, v as int)) ?? {},
        merchantActive: j['merchantActive'] as bool? ?? false,
        merchantStock: (j['merchantStock'] as List? ?? [])
            .map((m) => MerchantItem.fromJson(m as Map<String, dynamic>))
            .toList(),
        nextMerchantDay: j['nextMerchantDay'] as int? ?? 5,
        pendingReturnEventId: j['pendingReturnEventId'] as String?,
        trainingRecords: (j['trainingRecords'] as Map?)?.map(
                (k, v) => MapEntry(k as String, List<String>.from(v as List))) ??
            {},
        pendingHeroJoinName: j['pendingHeroJoinName'] as String?,
      );

  factory GameState.newGame() => GameState(
        party: [],
        gold: 100,
        properties: [],
        permadeathEnabled: false,
        lastOnlineTime: DateTime.now(),
        totalPlaytimeSeconds: 0,
        inGameDay: 1,
        eventLog: ['Your journey on the Ashen Road begins.'],
        inventory: Inventory.empty(),
        worldMap: generateWorldMap(),
        rations: 10,
        nextMerchantDay: 5,
      );
}
