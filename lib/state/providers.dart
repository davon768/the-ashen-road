import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_state.dart';
import 'game_notifier.dart';
import 'save_service.dart';
import '../models/hero.dart';
import '../models/property.dart';
import '../models/enums.dart';
import '../models/expedition.dart';
import '../models/inventory.dart';
import '../models/world_location.dart';
import '../models/town_visit.dart';
import '../models/property_event.dart';
import '../services/replicate_service.dart';
import '../config/api_keys.dart';

final saveServiceProvider = Provider<SaveService>((ref) => SaveService());

// Replicate is always available — key is built into the app
final replicateServiceProvider = Provider<ReplicateService>(
  (ref) => ReplicateService(ApiKeys.replicate),
);

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);

// Slice providers — widgets subscribe only to what they need
final goldProvider = Provider<int>((ref) => ref.watch(gameProvider).gold);

final partyProvider =
    Provider<List<Hero>>((ref) => ref.watch(gameProvider).party);

final propertiesProvider = Provider<List<OwnedProperty>>(
    (ref) => ref.watch(gameProvider).properties);

final expeditionProvider = Provider<Expedition?>(
    (ref) => ref.watch(gameProvider).activeExpedition);

final eventLogProvider =
    Provider<List<String>>((ref) => ref.watch(gameProvider).eventLog);

final inGameDayProvider =
    Provider<int>((ref) => ref.watch(gameProvider).inGameDay);

final inventoryProvider =
    Provider<Inventory>((ref) => ref.watch(gameProvider).inventory);

final pendingEventIdProvider = Provider<String?>(
  (ref) => ref.watch(gameProvider).pendingEventId,
);

final pendingTravelEventIdProvider = Provider<String?>(
  (ref) => ref.watch(gameProvider).pendingTravelEventId,
);

final pendingDevotionChoicesProvider = Provider<List<String>>(
  (ref) => ref.watch(gameProvider).pendingDevotionChoices,
);

final worldMapProvider = Provider<List<WorldLocation>>(
  (ref) => ref.watch(gameProvider).worldMap,
);

final needsSubclassProvider = Provider<bool>(
  (ref) => ref
      .watch(partyProvider)
      .any((h) => h.level >= 10 && h.subclass == null),
);

/// True when no player character exists yet — triggers the character creator.
final needsCharacterCreationProvider = Provider<bool>(
  (ref) => !ref.watch(partyProvider).any((h) => h.isPlayerCharacter),
);

final townVisitProvider = Provider<TownVisit?>(
  (ref) => ref.watch(gameProvider).activeTownVisit,
);

final pendingPropertyEventsProvider = Provider<List<PendingPropertyEvent>>(
  (ref) => ref.watch(gameProvider).pendingPropertyEvents,
);

final maxPartySizeProvider = Provider<int>((ref) {
  final hasCastle = ref
      .watch(propertiesProvider)
      .any((p) => p.type == PropertyType.castle);
  return hasCastle ? 6 : 5;
});

/// Dev-mode flag — speeds up expeditions 30× while toggled on.
/// Never persisted; resets to false on every app launch.
class DevModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final devModeProvider =
    NotifierProvider<DevModeNotifier, bool>(DevModeNotifier.new);
