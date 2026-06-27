import '../models/devotion_perk.dart';
import '../models/enums.dart';
import '../models/stats.dart';

// ─── LUMINANT CHURCH ──────────────────────────────────────────────────────────
// Light, order, justice. Rewards combat prowess and faithful service.

const _luminantPerks = [
  // Tier 1
  DevotionPerk(
    id: 'lc_t1_arms',
    faithType: FaithType.luminantChurch,
    tier: 1,
    name: 'Consecrated Arms',
    description: '+2 Strength, +1 Luck',
    flavorText: 'The Church blesses those who strike in its name. The blessing is felt.',
    statBonus: HeroStats(strength: 2, luck: 1),
  ),
  DevotionPerk(
    id: 'lc_t1_fortitude',
    faithType: FaithType.luminantChurch,
    tier: 1,
    name: 'Holy Fortitude',
    description: '+3 Endurance',
    flavorText: 'Faith braces the body as well as the soul. The Church has always known this.',
    statBonus: HeroStats(endurance: 3),
  ),
  // Tier 2
  DevotionPerk(
    id: 'lc_t2_eye',
    faithType: FaithType.luminantChurch,
    tier: 2,
    name: "Inquisitor's Eye",
    description: '+2 Dexterity, +1 Luck',
    flavorText: 'The Inquisitor sees what others choose not to. Precision follows.',
    statBonus: HeroStats(dexterity: 2, luck: 1),
  ),
  DevotionPerk(
    id: 'lc_t2_mandate',
    faithType: FaithType.luminantChurch,
    tier: 2,
    name: "Church's Mandate",
    description: '+20% gold from expeditions',
    flavorText: 'The Church taxes. The Church provides. You have learned to navigate both.',
    goldBonus: 0.20,
  ),
  // Tier 3
  DevotionPerk(
    id: 'lc_t3_zeal',
    faithType: FaithType.luminantChurch,
    tier: 3,
    name: 'Radiant Zeal',
    description: '+2 Faith, +1 Intelligence',
    flavorText: 'Your faith has become something others can see from a distance.',
    statBonus: HeroStats(faith: 2, intelligence: 1),
  ),
  DevotionPerk(
    id: 'lc_t3_recovery',
    faithType: FaithType.luminantChurch,
    tier: 3,
    name: 'Blessed Recovery',
    description: '+30% healing at faith sites and towns',
    flavorText: 'The Church heals its faithful generously. The faithful heal faster.',
    healBonus: 0.30,
  ),
  // Tier 4
  DevotionPerk(
    id: 'lc_t4_purpose',
    faithType: FaithType.luminantChurch,
    tier: 4,
    name: "The Arbiter's Purpose",
    description: '+3 Faith, +2 Strength',
    flavorText: 'The Arbiter\'s judgment flows through you now. The road knows it.',
    statBonus: HeroStats(faith: 3, strength: 2),
  ),
  DevotionPerk(
    id: 'lc_t4_mantle',
    faithType: FaithType.luminantChurch,
    tier: 4,
    name: "Saint's Mantle",
    description: '+25% XP from expeditions',
    flavorText: 'The saints walked this road and learned from every step. So do you.',
    xpBonus: 0.25,
  ),
];

// ─── OLD WAYS ─────────────────────────────────────────────────────────────────
// Nature, survival, the primal. Rewards endurance and primal strength.

const _oldWaysPerks = [
  // Tier 1
  DevotionPerk(
    id: 'ow_t1_roadwise',
    faithType: FaithType.oldWays,
    tier: 1,
    name: 'Road-Wise',
    description: '+2 Dexterity, +1 Luck',
    flavorText: 'The Old Ways teach you to read the land before the road teaches you harder.',
    statBonus: HeroStats(dexterity: 2, luck: 1),
  ),
  DevotionPerk(
    id: 'ow_t1_vitality',
    faithType: FaithType.oldWays,
    tier: 1,
    name: 'Wild Vitality',
    description: '+3 Endurance',
    flavorText: "The land's health flows into those who acknowledge it by name.",
    statBonus: HeroStats(endurance: 3),
  ),
  // Tier 2
  DevotionPerk(
    id: 'ow_t2_thorn',
    faithType: FaithType.oldWays,
    tier: 2,
    name: 'Thorn Blood',
    description: '+2 Strength, +1 Luck',
    flavorText: 'The land defends those who are part of it. Its defenses are your defenses.',
    statBonus: HeroStats(strength: 2, luck: 1),
  ),
  DevotionPerk(
    id: 'ow_t2_ward',
    faithType: FaithType.oldWays,
    tier: 2,
    name: 'Earthen Ward',
    description: '+3 Endurance, +1 Strength',
    flavorText: 'Stone does not yield. Neither do you. The Old Ways approve of this consistency.',
    statBonus: HeroStats(endurance: 3, strength: 1),
  ),
  // Tier 3
  DevotionPerk(
    id: 'ow_t3_hunter',
    faithType: FaithType.oldWays,
    tier: 3,
    name: "Hunter's Blood",
    description: '+3 Dexterity, +1 Strength',
    flavorText: 'You are what the land made of you. The land made you fast.',
    statBonus: HeroStats(dexterity: 3, strength: 1),
  ),
  DevotionPerk(
    id: 'ow_t3_grace',
    faithType: FaithType.oldWays,
    tier: 3,
    name: 'Ancient Grace',
    description: '+20% XP from expeditions',
    flavorText: 'The Old Ways have always taught through experience. The road is the lesson.',
    xpBonus: 0.20,
  ),
  // Tier 4
  DevotionPerk(
    id: 'ow_t4_pact',
    faithType: FaithType.oldWays,
    tier: 4,
    name: 'The Old Pact',
    description: '+25% devotion gained from all sources',
    flavorText: 'You have given yourself to the Old Ways. They have given themselves to you.',
    devotionGainBonus: 0.25,
  ),
  DevotionPerk(
    id: 'ow_t4_fury',
    faithType: FaithType.oldWays,
    tier: 4,
    name: 'Primal Fury',
    description: '+4 Strength, +2 Dexterity',
    flavorText: 'The land does not contain you anymore. It never quite did.',
    statBonus: HeroStats(strength: 4, dexterity: 2),
  ),
];

// ─── PALE COURT ───────────────────────────────────────────────────────────────
// Death, knowledge, inevitability. Rewards intelligence and patient accumulation.

const _paleCourtPerks = [
  // Tier 1
  DevotionPerk(
    id: 'pc_t1_ledger',
    faithType: FaithType.paleCourt,
    tier: 1,
    name: "Ledger's Weight",
    description: '+2 Intelligence, +1 Luck',
    flavorText: 'The Pale Court measures everything. You learn to measure too.',
    statBonus: HeroStats(intelligence: 2, luck: 1),
  ),
  DevotionPerk(
    id: 'pc_t1_dust',
    faithType: FaithType.paleCourt,
    tier: 1,
    name: 'Dust to Dust',
    description: '+15% XP from expeditions',
    flavorText: 'Every death is a lesson. You have attended enough of them to learn something.',
    xpBonus: 0.15,
  ),
  // Tier 2
  DevotionPerk(
    id: 'pc_t2_sight',
    faithType: FaithType.paleCourt,
    tier: 2,
    name: 'Pale Sight',
    description: '+2 Intelligence, +2 Luck',
    flavorText: 'The Pale Court sees what is and what will be. Some of that sight is yours now.',
    statBonus: HeroStats(intelligence: 2, luck: 2),
  ),
  DevotionPerk(
    id: 'pc_t2_comfort',
    faithType: FaithType.paleCourt,
    tier: 2,
    name: 'Cold Comfort',
    description: '+25% healing at faith sites',
    flavorText: "The cold that doesn't kill teaches the body to repair itself faster.",
    healBonus: 0.25,
  ),
  // Tier 3
  DevotionPerk(
    id: 'pc_t3_count',
    faithType: FaithType.paleCourt,
    tier: 3,
    name: "The Count's Favor",
    description: '+20% gold from expeditions',
    flavorText: 'The Pale Court pays its debts. Coin arrives from unexpected places.',
    goldBonus: 0.20,
  ),
  DevotionPerk(
    id: 'pc_t3_strength',
    faithType: FaithType.paleCourt,
    tier: 3,
    name: 'Hollow Strength',
    description: '+3 Endurance, +1 Strength',
    flavorText: 'The hollow endure more than the whole. The Court has always known this.',
    statBonus: HeroStats(endurance: 3, strength: 1),
  ),
  // Tier 4
  DevotionPerk(
    id: 'pc_t4_champion',
    faithType: FaithType.paleCourt,
    tier: 4,
    name: "Court's Champion",
    description: '+4 Intelligence, +2 Faith',
    flavorText: 'The Pale Court speaks through you now. The ledger is yours to read.',
    statBonus: HeroStats(intelligence: 4, faith: 2),
  ),
  DevotionPerk(
    id: 'pc_t4_final',
    faithType: FaithType.paleCourt,
    tier: 4,
    name: 'The Final Entry',
    description: '+20% XP, +15% gold from expeditions',
    flavorText: 'The last page is always the most informative. You have reached the last page.',
    xpBonus: 0.20,
    goldBonus: 0.15,
  ),
];

// ─── COMPACT OF SAINTS ────────────────────────────────────────────────────────
// Community, sacrifice, healing. Rewards faith and the protection of others.

const _compactPerks = [
  // Tier 1
  DevotionPerk(
    id: 'cs_t1_touch',
    faithType: FaithType.compactOfSaints,
    tier: 1,
    name: "Saint's Touch",
    description: '+3 Faith, +1 Endurance',
    flavorText: "The saints' hands guide yours. Their endurance is now yours to draw on.",
    statBonus: HeroStats(faith: 3, endurance: 1),
  ),
  DevotionPerk(
    id: 'cs_t1_martyr',
    faithType: FaithType.compactOfSaints,
    tier: 1,
    name: "Martyr's Will",
    description: '+2 Endurance, +2 Strength',
    flavorText: 'They endured what should not be endured. So can you, now.',
    statBonus: HeroStats(endurance: 2, strength: 2),
  ),
  // Tier 2
  DevotionPerk(
    id: 'cs_t2_hands',
    faithType: FaithType.compactOfSaints,
    tier: 2,
    name: 'Sacred Hands',
    description: '+30% healing at faith sites and towns',
    flavorText: 'What the Compact heals, it heals completely.',
    healBonus: 0.30,
  ),
  DevotionPerk(
    id: 'cs_t2_fellowship',
    faithType: FaithType.compactOfSaints,
    tier: 2,
    name: "Fellowship's Strength",
    description: '+2 Endurance, +2 Strength',
    flavorText: 'The Compact has always held that you are made stronger by those who stand beside you.',
    statBonus: HeroStats(endurance: 2, strength: 2),
  ),
  // Tier 3
  DevotionPerk(
    id: 'cs_t3_blessing',
    faithType: FaithType.compactOfSaints,
    tier: 3,
    name: "Road's Blessing",
    description: '+20% XP from expeditions',
    flavorText: 'The Compact teaches patience. The road teaches everything else.',
    xpBonus: 0.20,
  ),
  DevotionPerk(
    id: 'cs_t3_covenant',
    faithType: FaithType.compactOfSaints,
    tier: 3,
    name: 'Holy Covenant',
    description: '+3 Faith, +1 Intelligence',
    flavorText: "The Compact's voice is many. It is also yours now.",
    statBonus: HeroStats(faith: 3, intelligence: 1),
  ),
  // Tier 4
  DevotionPerk(
    id: 'cs_t4_resolve',
    faithType: FaithType.compactOfSaints,
    tier: 4,
    name: "The Saint's Resolve",
    description: '+4 Faith, +2 Endurance',
    flavorText: 'The saints resolved and the road carried them forward. It does the same for you.',
    statBonus: HeroStats(faith: 4, endurance: 2),
  ),
  DevotionPerk(
    id: 'cs_t4_miracle',
    faithType: FaithType.compactOfSaints,
    tier: 4,
    name: 'Miracle Worker',
    description: '+35% healing, +15% gold from expeditions',
    flavorText: 'What the Compact wills, the road provides. What the road withholds, the Compact recovers.',
    healBonus: 0.35,
    goldBonus: 0.15,
  ),
];

// ─── ASHEN RITE ───────────────────────────────────────────────────────────────
// Power, void, ambition, fire. Rewards raw magical force and acquisition.

const _ashenRitePerks = [
  // Tier 1
  DevotionPerk(
    id: 'ar_t1_ember',
    faithType: FaithType.ashenRite,
    tier: 1,
    name: "Ember's Kiss",
    description: '+3 Intelligence, +1 Luck',
    flavorText: 'The Ashen Rite burns the mind bright. Some things only ignition can reveal.',
    statBonus: HeroStats(intelligence: 3, luck: 1),
  ),
  DevotionPerk(
    id: 'ar_t1_resolve',
    faithType: FaithType.ashenRite,
    tier: 1,
    name: 'Ashen Resolve',
    description: '+2 Endurance, +2 Intelligence',
    flavorText: 'The rite tempers as much as it burns. You have learned to carry the heat.',
    statBonus: HeroStats(endurance: 2, intelligence: 2),
  ),
  // Tier 2
  DevotionPerk(
    id: 'ar_t2_bargain',
    faithType: FaithType.ashenRite,
    tier: 2,
    name: 'Dark Bargain',
    description: '+4 Intelligence',
    flavorText: 'The void does not withhold from its faithful. You have learned to ask correctly.',
    statBonus: HeroStats(intelligence: 4),
  ),
  DevotionPerk(
    id: 'ar_t2_hunger',
    faithType: FaithType.ashenRite,
    tier: 2,
    name: "Rite's Hunger",
    description: '+2 Intelligence, +2 Dexterity',
    flavorText: 'The void makes you faster. It makes you reach further than your arms should allow.',
    statBonus: HeroStats(intelligence: 2, dexterity: 2),
  ),
  // Tier 3
  DevotionPerk(
    id: 'ar_t3_mastery',
    faithType: FaithType.ashenRite,
    tier: 3,
    name: 'Void Mastery',
    description: '+3 Intelligence, +1 Faith',
    flavorText: 'You have learned to carry what the Opening revealed. Most could not.',
    statBonus: HeroStats(intelligence: 3, faith: 1),
  ),
  DevotionPerk(
    id: 'ar_t3_price',
    faithType: FaithType.ashenRite,
    tier: 3,
    name: "The Rite's Price",
    description: '+25% gold from expeditions',
    flavorText: 'The Ashen Rite demands much. It repays in kind. Always in kind.',
    goldBonus: 0.25,
  ),
  // Tier 4
  DevotionPerk(
    id: 'ar_t4_champion',
    faithType: FaithType.ashenRite,
    tier: 4,
    name: 'Void Champion',
    description: '+5 Intelligence, +2 Strength',
    flavorText: 'The void has reshaped you. The road cannot hold what you have become.',
    statBonus: HeroStats(intelligence: 5, strength: 2),
  ),
  DevotionPerk(
    id: 'ar_t4_gift',
    faithType: FaithType.ashenRite,
    tier: 4,
    name: "The Opening's Gift",
    description: '+20% XP, +20% devotion gained from all sources',
    flavorText: 'The Opening gave you something. You are still learning what it was.',
    xpBonus: 0.20,
    devotionGainBonus: 0.20,
  ),
];

// ─── MASTER LIST ─────────────────────────────────────────────────────────────

const allDevotionPerks = [
  ..._luminantPerks,
  ..._oldWaysPerks,
  ..._paleCourtPerks,
  ..._compactPerks,
  ..._ashenRitePerks,
];

/// All perks for a specific faith, ordered by tier then slot (a before b).
List<DevotionPerk> perksForFaith(FaithType faith) =>
    allDevotionPerks.where((p) => p.faithType == faith).toList();

/// The two perks available at a given tier for a given faith.
List<DevotionPerk> perksForFaithAndTier(FaithType faith, int tier) =>
    perksForFaith(faith).where((p) => p.tier == tier).toList();

DevotionPerk? devotionPerkById(String id) =>
    allDevotionPerks.where((p) => p.id == id).firstOrNull;

/// Compute the combined stat bonus from a list of chosen perk IDs.
HeroStats computePerkStatBonus(List<String> perkIds) {
  var total = const HeroStats(
      strength: 0, dexterity: 0, endurance: 0,
      intelligence: 0, faith: 0, luck: 0);
  for (final id in perkIds) {
    final perk = devotionPerkById(id);
    if (perk != null) total = total + perk.statBonus;
  }
  return total;
}

/// Sum of all gold bonus percentages from chosen perks.
double computeGoldBonus(List<String> perkIds) =>
    perkIds.fold(0.0, (sum, id) => sum + (devotionPerkById(id)?.goldBonus ?? 0.0));

/// Sum of all XP bonus percentages from chosen perks.
double computeXpBonus(List<String> perkIds) =>
    perkIds.fold(0.0, (sum, id) => sum + (devotionPerkById(id)?.xpBonus ?? 0.0));

/// Sum of all devotion gain bonus percentages from chosen perks.
double computeDevotionGainBonus(List<String> perkIds) =>
    perkIds.fold(0.0, (sum, id) => sum + (devotionPerkById(id)?.devotionGainBonus ?? 0.0));

/// Sum of all heal bonus percentages from chosen perks.
double computeHealBonus(List<String> perkIds) =>
    perkIds.fold(0.0, (sum, id) => sum + (devotionPerkById(id)?.healBonus ?? 0.0));
