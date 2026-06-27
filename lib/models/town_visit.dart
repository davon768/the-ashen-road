import 'hero.dart';
import 'quest.dart';

// ─── HERO RECRUIT ─────────────────────────────────────────────────────────────

class HeroRecruit {
  final String recruitId;
  final Hero hero;
  final int hireCost;
  final bool hired;

  const HeroRecruit({
    required this.recruitId,
    required this.hero,
    required this.hireCost,
    this.hired = false,
  });

  HeroRecruit withHired() => HeroRecruit(
        recruitId: recruitId,
        hero: hero,
        hireCost: hireCost,
        hired: true,
      );

  Map<String, dynamic> toJson() => {
        'recruitId': recruitId,
        'hero': hero.toJson(),
        'hireCost': hireCost,
        'hired': hired,
      };

  factory HeroRecruit.fromJson(Map<String, dynamic> j) => HeroRecruit(
        recruitId: j['recruitId'],
        hero: Hero.fromJson(j['hero'] as Map<String, dynamic>),
        hireCost: j['hireCost'],
        hired: j['hired'] ?? false,
      );
}

// ─── TOWN NPC ─────────────────────────────────────────────────────────────────

class TownNpc {
  final String id;
  final String name;
  final String role;
  final String greeting;
  final String? questHint;
  final bool talked;

  const TownNpc({
    required this.id,
    required this.name,
    required this.role,
    required this.greeting,
    this.questHint,
    this.talked = false,
  });

  TownNpc withTalked() => TownNpc(
        id: id, name: name, role: role, greeting: greeting,
        questHint: questHint, talked: true,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'role': role, 'greeting': greeting,
        'questHint': questHint, 'talked': talked,
      };

  factory TownNpc.fromJson(Map<String, dynamic> j) => TownNpc(
        id: j['id'], name: j['name'], role: j['role'],
        greeting: j['greeting'], questHint: j['questHint'] as String?,
        talked: j['talked'] ?? false,
      );
}

// ─── TRADER OFFER ─────────────────────────────────────────────────────────────

class TraderOffer {
  final String offerId;
  final String itemId;
  final bool isWeapon;
  final bool isTome;   // if true, itemId is a spell ID; adds tome to consumables on purchase
  final String displayName;
  final int price;
  final bool purchased;

  const TraderOffer({
    required this.offerId,
    required this.itemId,
    required this.isWeapon,
    this.isTome = false,
    required this.displayName,
    required this.price,
    this.purchased = false,
  });

  TraderOffer withPurchased() => TraderOffer(
        offerId: offerId, itemId: itemId, isWeapon: isWeapon, isTome: isTome,
        displayName: displayName, price: price, purchased: true,
      );

  Map<String, dynamic> toJson() => {
        'offerId': offerId, 'itemId': itemId, 'isWeapon': isWeapon,
        'isTome': isTome, 'displayName': displayName,
        'price': price, 'purchased': purchased,
      };

  factory TraderOffer.fromJson(Map<String, dynamic> j) => TraderOffer(
        offerId: j['offerId'], itemId: j['itemId'],
        isWeapon: j['isWeapon'] as bool,
        isTome: j['isTome'] as bool? ?? false,
        displayName: j['displayName'], price: j['price'],
        purchased: j['purchased'] ?? false,
      );
}

// ─── TOWN VISIT ───────────────────────────────────────────────────────────────

enum TownVisitType { town, monastery, faithSite }

class TownVisit {
  final String locationId;
  final String locationName;
  final int depth;
  final TownVisitType visitType;
  final List<String> heroIds;
  final List<TownNpc> npcs;
  final List<TraderOffer> traderStock;
  final int innCostPerHero;
  final bool innUsed;
  final List<HeroRecruit> availableRecruits;
  // Faith site visits: messages describing devotion gains for each hero.
  final List<String> faithMessages;
  // Quests offered at the town notice board (towns only).
  final List<Quest> questOffers;

  const TownVisit({
    required this.locationId,
    required this.locationName,
    required this.depth,
    required this.visitType,
    required this.heroIds,
    required this.npcs,
    required this.traderStock,
    required this.innCostPerHero,
    this.innUsed = false,
    this.availableRecruits = const [],
    this.faithMessages = const [],
    this.questOffers = const [],
  });

  TownVisit copyWith({
    List<TownNpc>? npcs,
    List<TraderOffer>? traderStock,
    bool? innUsed,
    List<HeroRecruit>? availableRecruits,
    List<String>? faithMessages,
    List<Quest>? questOffers,
  }) =>
      TownVisit(
        locationId: locationId,
        locationName: locationName,
        depth: depth,
        visitType: visitType,
        heroIds: heroIds,
        npcs: npcs ?? this.npcs,
        traderStock: traderStock ?? this.traderStock,
        innCostPerHero: innCostPerHero,
        innUsed: innUsed ?? this.innUsed,
        availableRecruits: availableRecruits ?? this.availableRecruits,
        faithMessages: faithMessages ?? this.faithMessages,
        questOffers: questOffers ?? this.questOffers,
      );

  Map<String, dynamic> toJson() => {
        'locationId': locationId,
        'locationName': locationName,
        'depth': depth,
        'visitType': visitType.name,
        'heroIds': heroIds,
        'npcs': npcs.map((n) => n.toJson()).toList(),
        'traderStock': traderStock.map((t) => t.toJson()).toList(),
        'innCostPerHero': innCostPerHero,
        'innUsed': innUsed,
        'availableRecruits': availableRecruits.map((r) => r.toJson()).toList(),
        'faithMessages': faithMessages,
        'questOffers': questOffers.map((q) => q.toJson()).toList(),
      };

  factory TownVisit.fromJson(Map<String, dynamic> j) => TownVisit(
        locationId: j['locationId'],
        locationName: j['locationName'],
        depth: j['depth'] ?? 1,
        visitType: TownVisitType.values.byName(j['visitType'] ?? 'town'),
        heroIds: List<String>.from(j['heroIds']),
        npcs: (j['npcs'] as List).map((n) => TownNpc.fromJson(n)).toList(),
        traderStock: (j['traderStock'] as List)
            .map((t) => TraderOffer.fromJson(t))
            .toList(),
        innCostPerHero: j['innCostPerHero'],
        innUsed: j['innUsed'] ?? false,
        availableRecruits: (j['availableRecruits'] as List? ?? [])
            .map((r) => HeroRecruit.fromJson(r as Map<String, dynamic>))
            .toList(),
        faithMessages: List<String>.from(j['faithMessages'] as List? ?? []),
        questOffers: (j['questOffers'] as List? ?? [])
            .map((q) => Quest.fromJson(q as Map<String, dynamic>))
            .toList(),
      );
}
