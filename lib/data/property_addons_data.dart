import '../models/property.dart';

class AddonDef {
  final String id;
  final String name;
  final String description;
  final int cost;
  final int incomeBonus;

  const AddonDef({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.incomeBonus,
  });
}

const Map<PropertyType, List<AddonDef>> allAddons = {

  // Tavern addons — improve the free-rest perk
  PropertyType.tavern: [
    AddonDef(
      id: 'tavern_cookery',
      name: 'Cookery',
      description: 'A proper kitchen. Resting at the tavern also restores mana.',
      cost: 500,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'tavern_brewery',
      name: 'Brewery',
      description: 'Your own barrels. Wandering traders stop by more often.',
      cost: 1200,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'tavern_rooms',
      name: 'Private Rooms',
      description: 'Separate quarters let the party rest twice per day instead of once.',
      cost: 2500,
      incomeBonus: 2,
    ),
    AddonDef(
      id: 'tavern_stage',
      name: "Bard's Stage",
      description: 'Word travels. Recruits who visit are one level higher on average.',
      cost: 5000,
      incomeBonus: 2,
    ),
  ],

  // Blacksmith addons — improve shop and damage bonus
  PropertyType.blacksmith: [
    AddonDef(
      id: 'blacksmith_apprentice',
      name: 'Apprentice',
      description: 'A trained hand at the bellows. Shop restocks uncommon items.',
      cost: 600,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'blacksmith_sharpening',
      name: 'Sharpening Station',
      description: 'Blades leave sharper. Party weapon damage bonus rises to +15%.',
      cost: 1500,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'blacksmith_armory',
      name: 'Full Armory',
      description: 'A locked back room of quality stock. Shop carries rare items.',
      cost: 3000,
      incomeBonus: 2,
    ),
    AddonDef(
      id: 'blacksmith_masterforge',
      name: "Master's Forge",
      description: 'A proper forge setup. Party damage bonus rises to +20%.',
      cost: 6000,
      incomeBonus: 3,
    ),
  ],

  // Apothecary addons — improve recovery speed
  PropertyType.apothecary: [
    AddonDef(
      id: 'apothecary_garden',
      name: 'Herb Garden',
      description: 'Fresh supply reduces costs. Recovery speed increases to 3×.',
      cost: 400,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'apothecary_distillery',
      name: 'Distillery',
      description: 'Tinctures improve treatment. Recovery speed increases to 4×.',
      cost: 1000,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'apothecary_surgery',
      name: 'Surgery Room',
      description: 'A clean back room. Full recovery time halved again — 8× base speed.',
      cost: 2000,
      incomeBonus: 2,
    ),
    AddonDef(
      id: 'apothecary_alchemical',
      name: 'Alchemical Press',
      description: 'Advanced compounds. Heroes recover almost instantly from any wound.',
      cost: 4000,
      incomeBonus: 2,
    ),
  ],

  // General Store addons — more expedition loot
  PropertyType.generalStore: [
    AddonDef(
      id: 'store_warehouse',
      name: 'Warehouse',
      description: 'Storage for bulk goods. Expeditions find +1 additional item.',
      cost: 300,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'store_contacts',
      name: 'Supply Contacts',
      description: 'Regional suppliers. Trader stock in any town has 1 extra item.',
      cost: 700,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'store_license',
      name: 'Trading Post License',
      description: 'Official papers. Expeditions find +1 more item (total +3).',
      cost: 1400,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'store_guild',
      name: 'Guild Membership',
      description: "The merchants' guild. Loot quality improves — higher rarity rolls.",
      cost: 2800,
      incomeBonus: 2,
    ),
  ],

  // Stables addons — further reduce expedition duration
  PropertyType.stables: [
    AddonDef(
      id: 'stables_haybarn',
      name: 'Hay Barn',
      description: 'Healthy stock. Travel time reduction rises to 25%.',
      cost: 500,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'stables_paddock',
      name: 'Breeding Paddock',
      description: 'Room for young horses. Travel time reduction rises to 30%.',
      cost: 1200,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'stables_farrier',
      name: 'Farrier Station',
      description: "Keeps hooves in top condition. Travel reduction rises to 35%.",
      cost: 2400,
      incomeBonus: 1,
    ),
    AddonDef(
      id: 'stables_training',
      name: 'Training Ring',
      description: 'Elite mounts. Travel time cut nearly in half — reduction rises to 45%.',
      cost: 5000,
      incomeBonus: 2,
    ),
  ],

  // Castle addons — improve garrison and perks
  PropertyType.castle: [
    AddonDef(
      id: 'castle_barracks',
      name: 'Barracks',
      description: 'Proper soldier quarters. Garrison heroes are 2 levels higher.',
      cost: 5000,
      incomeBonus: 3,
    ),
    AddonDef(
      id: 'castle_watchtower',
      name: 'Watchtower',
      description: 'Information is power. All world map locations are revealed.',
      cost: 10000,
      incomeBonus: 4,
    ),
    AddonDef(
      id: 'castle_granary',
      name: 'Granary',
      description: 'Feeds armies. Expedition recovery time for garrison heroes is instant.',
      cost: 20000,
      incomeBonus: 5,
    ),
    AddonDef(
      id: 'castle_treasury',
      name: 'Treasury Vault',
      description: "Merchants pay to know their gold is safe. Significant income boost.",
      cost: 40000,
      incomeBonus: 12,
    ),
  ],
};

AddonDef? addonById(String id) {
  for (final list in allAddons.values) {
    for (final a in list) {
      if (a.id == id) return a;
    }
  }
  return null;
}
