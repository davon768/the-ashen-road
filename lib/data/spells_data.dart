import '../models/spell.dart';
import '../models/enums.dart';

// ─── MAGE SPELLS ─────────────────────────────────────────────────────────────
// T1: Arcane basics available to all mages
// T2 Elementalist: Fire, frost and lightning burst power
// T2 Runescribe: Arcane runes, barriers, sustained force
// T2 Alchemist: Transmutation, acid, life conversion
// T3 Elementalist: Ultimate elemental destruction
// T3 Runescribe: Rune-empowered devastation
// T3 Alchemist: Grand reactions and catastrophic compounds

const _mageSpells = [

  // ── T1 — Arcane Basics ────────────────────────────────────────────────────

  Spell(
    id: 'arcane_missile',
    name: 'Arcane Missile',
    description: 'Fling a dart of pure arcane force at one target.',
    flavorText: 'The most basic channeling of raw magic — recorded in every surviving primer.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.damage, powerScale: 0.8,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'frost_bolt',
    name: 'Frost Bolt',
    description: 'Hurl a shard of killing ice at one target.',
    flavorText: 'Cold has no natural enemy in this world. It kills cleanly and without argument.',
    manaCost: 4, tier: 1,
    effectType: SpellEffectType.damage, powerScale: 0.9,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'fire_bolt',
    name: 'Fire Bolt',
    description: 'Launch a bolt of conjured flame at one target.',
    flavorText: 'Every apprentice learns this first. Every soldier fears it last.',
    manaCost: 4, tier: 1,
    effectType: SpellEffectType.damage, powerScale: 0.9,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'arcane_ward',
    name: 'Arcane Ward',
    description: 'Weave arcane force into a protective barrier around yourself.',
    flavorText: 'Structured force folded around the body. Imprecise, but effective.',
    manaCost: 4, tier: 1,
    effectType: SpellEffectType.buff, flatBonus: 8, duration: 3,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'scorch',
    name: 'Scorch',
    description: 'Set a target alight with persistent magical fire that burns for several rounds.',
    flavorText: 'A candle compared to a fireball. Candles are underestimated.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.dot, powerScale: 0.45, duration: 2,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'glacial_touch',
    name: 'Glacial Touch',
    description: 'Infuse a target with killing cold that seeps through their armor.',
    flavorText: 'The frost does not destroy armor. It simply passes through it.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.debuff, flatBonus: 6,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'spark',
    name: 'Spark',
    description: 'Release a quick jolt of static lightning at one target.',
    flavorText: 'Fast and cheap. The mage who says otherwise carries too many reagents.',
    manaCost: 2, tier: 1,
    effectType: SpellEffectType.damage, powerScale: 0.7,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'arcane_burst',
    name: 'Arcane Burst',
    description: 'Release a small eruption of raw arcane force that radiates outward.',
    flavorText: 'Not precise. Not elegant. Useful when surrounded.',
    manaCost: 4, tier: 1,
    effectType: SpellEffectType.damageAll, powerScale: 0.55,
    allowedClasses: [HeroClass.mage],
  ),

  // ── T2 — Elementalist ─────────────────────────────────────────────────────

  Spell(
    id: 'ice_lance',
    name: 'Ice Lance',
    description: 'Drive a lance of condensed frost into one target.',
    flavorText: 'Concentrated frost shaped into a weapon. It hits like a ballista bolt.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.2,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'lightning_bolt',
    name: 'Lightning Bolt',
    description: 'Unleash a bolt of crackling lightning at one target.',
    flavorText: 'The Ashen Age burned much knowledge. Some of it was how to call storms.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.3,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'fireball',
    name: 'Fireball',
    description: 'Hurl an explosive sphere of fire that detonates among all enemies.',
    flavorText: 'Ancient magic. Wasteful. Effective. No mage should be without it.',
    manaCost: 8, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.9,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'frost_nova',
    name: 'Frost Nova',
    description: 'Unleash a nova of killing frost that radiates outward to all enemies.',
    flavorText: 'Expands in all directions at once. In enclosed spaces, absolutely devastating.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.8,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'arcane_surge',
    name: 'Arcane Surge',
    description: 'Flood yourself with raw arcane energy, strengthening your defenses.',
    flavorText: 'The boundary between safe use and dangerous overreach. Worth crossing in a crisis.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.buff, flatBonus: 14, duration: 4,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'pyroblast',
    name: 'Pyroblast',
    description: 'Channel fire into a single massive projectile and hurl it at one target.',
    flavorText: 'The Elementalist does not win through subtlety. They win through this.',
    manaCost: 9, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.45,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'glacial_spikes',
    name: 'Glacial Spikes',
    description: 'Drive razor shards of ice upward through the ground beneath all enemies.',
    flavorText: 'The ground betrays them. This is the frost\'s favorite technique.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.85,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'chain_static',
    name: 'Chain Static',
    description: 'Wrap a target in crackling static charge that discharges painfully each round.',
    flavorText: 'Sustained electrical torment. Slightly less dignified than a thunderbolt. Slightly more effective.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.dot, powerScale: 0.5, duration: 3,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'ice_shards',
    name: 'Ice Shards',
    description: 'Detonate a spray of razor ice fragments that shred all enemies.',
    flavorText: 'Not a spell one recovers from quietly.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.75,
    allowedClasses: [HeroClass.mage],
  ),

  // ── T2 — Runescribe ───────────────────────────────────────────────────────

  Spell(
    id: 'rune_of_power',
    name: 'Rune of Power',
    description: 'Inscribe an arcane rune of defense that surrounds you with warding force.',
    flavorText: 'The Runescribes of the Ash Academies died in the Opening. Their runes did not.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.buff, flatBonus: 16, duration: 4,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'runic_strike',
    name: 'Runic Strike',
    description: 'Activate a carved arcane rune and direct its released energy at one target.',
    flavorText: 'It takes patience to inscribe. It takes nothing to release. This is the Runescribe\'s advantage.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.1,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'glyph_of_warding',
    name: 'Glyph of Warding',
    description: 'Trace a glyph that absorbs magical and physical force for many rounds.',
    flavorText: 'Five strokes. One long breath. Nothing gets through.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.buff, flatBonus: 12, duration: 5,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'sigil_blast',
    name: 'Sigil Blast',
    description: 'Detonate a volatile arcane sigil in the midst of all enemies.',
    flavorText: 'Compact. Contained. Catastrophic when released in the right company.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.8,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'runic_shatter',
    name: 'Runic Shatter',
    description: 'Destabilize the arcane structure around all enemies with cascading rune failures.',
    flavorText: 'The runes the Runescribe writes — and the ones inscribed in reality itself. Both can be broken.',
    manaCost: 8, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.95,
    allowedClasses: [HeroClass.mage],
  ),

  // ── T2 — Alchemist ────────────────────────────────────────────────────────

  Spell(
    id: 'acid_splash',
    name: 'Acid Splash',
    description: 'Hurl a flask of transmuted acid that eats through armor on contact.',
    flavorText: 'Not a weapon of war, exactly. A weapon of applied chemistry.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.debuff, flatBonus: 10,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'volatile_acid',
    name: 'Volatile Acid',
    description: 'Spread a corrosive acid mist across all enemies that eats at them each round.',
    flavorText: 'The Alchemists of Salthaven developed this. Their city smells accordingly.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.dotAll, powerScale: 0.4, duration: 3,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'alchemical_fire',
    name: 'Alchemical Fire',
    description: 'Release a burning compound that adheres to all enemies and cannot be extinguished.',
    flavorText: 'It does not extinguish in water. It does not care about your armor. It cares about burning.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.dotAll, powerScale: 0.45, duration: 2,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'transmute_pain',
    name: 'Transmute Pain',
    description: 'Convert the vital force being torn from a target into healing energy for yourself.',
    flavorText: 'One of the few applications of transmutation that improves the caster\'s mood.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.drain, powerScale: 0.9,
    allowedClasses: [HeroClass.mage],
  ),

  // ── T3 — Elementalist ─────────────────────────────────────────────────────

  Spell(
    id: 'chain_lightning',
    name: 'Chain Lightning',
    description: 'Lightning leaps from foe to foe, striking all enemies in sequence.',
    flavorText: 'Holding three separate charges and releasing simultaneously. Not recommended.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.0,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'blizzard',
    name: 'Blizzard',
    description: 'Call down a howling blizzard that damages all enemies each round.',
    flavorText: 'Call the winter down. Even those who survive the first round rarely survive the third.',
    manaCost: 11, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.5, duration: 3,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'meteor',
    name: 'Meteor',
    description: 'Call down a burning rock from the sky that obliterates all enemies.',
    flavorText: 'The most powerful arcane technique most mages will ever attempt. The world does not forget.',
    manaCost: 14, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.3,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'arcane_fissure',
    name: 'Arcane Fissure',
    description: 'Tear open a rift in arcane space that bleeds magic damage across all enemies each round.',
    flavorText: 'The Void Codex describes this as "teaching reality a bad habit." The mages who recovered it agreed.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.55, duration: 3,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'firestorm',
    name: 'Firestorm',
    description: 'Summon a raging inferno that burns through all enemies with sustained intensity.',
    flavorText: 'The Elementalist at full power does not start fires. They become one.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.2,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'absolute_zero',
    name: 'Absolute Zero',
    description: 'Drop the temperature around all enemies to a lethal extreme in an instant.',
    flavorText: 'Below this threshold, nothing moves. Nothing breathes. Everything stops.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.1,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'tempest',
    name: 'Tempest',
    description: 'Call a sustained electrical storm that lashes all enemies each round.',
    flavorText: 'The storm remembers nothing. This is one of its advantages.',
    manaCost: 11, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.55, duration: 3,
    allowedClasses: [HeroClass.mage],
  ),

  // ── T3 — Runescribe ───────────────────────────────────────────────────────

  Spell(
    id: 'runic_detonation',
    name: 'Runic Detonation',
    description: 'Channel every rune inscribed in your awareness into a single devastating strike on one target.',
    flavorText: 'Years of patient study. One moment of catastrophic release. Worth it, most agree.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.damage, powerScale: 1.6,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'ancient_seal',
    name: 'Ancient Seal',
    description: 'Invoke a pre-Ashen rune of destruction that erupts across all enemies.',
    flavorText: 'They burned the academies. They could not burn the seals already carved in the world.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.1,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'rune_of_annihilation',
    name: 'Rune of Annihilation',
    description: 'Activate a slow-burning annihilation rune that continuously erodes all enemies.',
    flavorText: 'Not quick. Not merciful. Thorough.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.6, duration: 3,
    allowedClasses: [HeroClass.mage],
  ),

  // ── T3 — Alchemist ────────────────────────────────────────────────────────

  Spell(
    id: 'grand_transmutation',
    name: 'Grand Transmutation',
    description: 'Forcibly transmute the supernatural properties sustaining an enemy, eliminating them.',
    flavorText: 'What the fire gave, the formula takes away.',
    manaCost: 10, tier: 3,
    effectType: SpellEffectType.dispel,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'catastrophe',
    name: 'Catastrophe',
    description: 'Trigger a catastrophic chemical cascade that devastates all enemies simultaneously.',
    flavorText: 'The Alchemist spent three years on this formula. The enemy has approximately three seconds.',
    manaCost: 14, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.3,
    allowedClasses: [HeroClass.mage],
  ),
  Spell(
    id: 'acid_rain',
    name: 'Acid Rain',
    description: 'Summon a downpour of transmuted acid that corrodes all enemies each round.',
    flavorText: 'The Alchemist calls it precipitation. Their enemies call it considerably worse things.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.55, duration: 3,
    allowedClasses: [HeroClass.mage],
  ),
];

// ─── WARLOCK SPELLS ──────────────────────────────────────────────────────────
// T1: Shadow basics available to all warlocks
// T2 Demonologist: Summoned entities and fel pacts
// T2 Hexblade: Shadow melee, void strikes and soul-theft
// T2 Occultist: Dark rituals, eldritch blasts and cursework
// T3 Demonologist: Greater summoning and hellfire
// T3 Hexblade: Void mastery and shadow reaping
// T3 Occultist: Ritual power and eldritch dominion

const _warlockSpells = [

  // ── T1 — Shadow Basics ────────────────────────────────────────────────────

  Spell(
    id: 'shadow_bolt',
    name: 'Shadow Bolt',
    description: 'Launch a bolt of condensed shadow at one target.',
    flavorText: 'The simplest use of void energy. Every warlock\'s first lesson.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.damage, powerScale: 0.85,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'blood_pact',
    name: 'Blood Pact',
    description: 'Seal a compact with void power — sacrifice vital energy to deal major damage.',
    flavorText: 'The exchange is simple. The void takes a little; you take a lot. This is why warlocks are not trusted at healers\' conventions.',
    manaCost: 2, tier: 1,
    effectType: SpellEffectType.drain, powerScale: 1.1,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'curse_of_weakness',
    name: 'Curse of Weakness',
    description: 'A whispered curse that saps the enemy\'s physical might.',
    flavorText: 'The Pale Compact taught this to hedge-witches for pest control. Warlocks found better uses.',
    manaCost: 4, tier: 1,
    effectType: SpellEffectType.debuff, flatBonus: 5,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'drain_life',
    name: 'Drain Life',
    description: 'Tear life force from a living creature and draw it into yourself.',
    flavorText: 'The Void teaches that life is a currency. Some prefer to take rather than earn.',
    manaCost: 5, tier: 1,
    effectType: SpellEffectType.drain, powerScale: 0.8,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'void_grasp',
    name: 'Void Grasp',
    description: 'Reach into the void and pull something cold and sharp through an enemy\'s defenses.',
    flavorText: 'The void is not empty. This is what you realize the first time you reach into it.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.debuff, flatBonus: 7,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'shadow_word_agony',
    name: 'Shadow Word: Agony',
    description: 'Inscribe a word of shadow into an enemy\'s mind that tortures them each round.',
    flavorText: 'The Pale Compact prohibits this. The warlock notes the Pale Compact is not here.',
    manaCost: 4, tier: 1,
    effectType: SpellEffectType.dot, powerScale: 0.45, duration: 3,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'siphon_soul',
    name: 'Siphon Soul',
    description: 'Leech soul-force from one target, restoring some of your own vitality.',
    flavorText: 'Every warlock begins by learning they cannot take without giving something back. Then they figure out how to avoid that.',
    manaCost: 4, tier: 1,
    effectType: SpellEffectType.drain, powerScale: 0.75,
    allowedClasses: [HeroClass.warlock],
  ),

  // ── T2 — Demonologist ────────────────────────────────────────────────────

  Spell(
    id: 'summon_imp',
    name: 'Summon Imp',
    description: 'Tear a minor void entity through the veil. It fights alongside you for several rounds.',
    flavorText: 'Small, petty, and surprisingly committed to causing harm.',
    manaCost: 8, tier: 2,
    effectType: SpellEffectType.summon, flatBonus: 12, duration: 3,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'hellfire_pact',
    name: 'Hellfire Pact',
    description: 'Strike a compact with something from beyond — the price is steep, the power is greater.',
    flavorText: 'The contract is always the same. The Demonologist stopped reading the terms after the third time.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.drain, powerScale: 1.1,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'demonic_armor',
    name: 'Demonic Armor',
    description: 'Encase yourself in a skin of compressed void energy that repels physical harm.',
    flavorText: 'It looks like shadow. It feels like nothing at all — to the demon wearing it.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.buff, flatBonus: 14, duration: 4,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'fel_corruption',
    name: 'Fel Corruption',
    description: 'Unleash fel energy that corrupts all enemies simultaneously, burning them each round.',
    flavorText: 'Hellfire does not distinguish targets. The Demonologist appreciates this quality.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.dotAll, powerScale: 0.4, duration: 3,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'shadow_bolt_volley',
    name: 'Shadow Bolt Volley',
    description: 'Fire a rapid burst of shadow bolts that strikes all enemies.',
    flavorText: 'One bolt per enemy. The void does not run short of ammunition.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.8,
    allowedClasses: [HeroClass.warlock],
  ),

  // ── T2 — Hexblade ─────────────────────────────────────────────────────────

  Spell(
    id: 'fel_flame',
    name: 'Fel Flame',
    description: 'Ignite a target with hellfire that burns soul as well as flesh.',
    flavorText: 'Void fire resists nothing living. It burns what ordinary flame cannot touch.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.1,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'soul_rend',
    name: 'Soul Rend',
    description: 'Tear the soul partially free of its body — a technique learned from void entities.',
    flavorText: 'The target doesn\'t die immediately. That is, perhaps, the point.',
    manaCost: 8, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.25,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'shadow_slash',
    name: 'Shadow Slash',
    description: 'Extend your hand through the void and strike a target with condensed shadow edge.',
    flavorText: 'The Hexblade strikes in two places at once. Only one of them can be blocked.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.15,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'void_embrace',
    name: 'Void Embrace',
    description: 'Draw the void through a target, transferring their vitality into yourself.',
    flavorText: 'The embrace is not gentle. Nothing the void offers ever is.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.drain, powerScale: 1.0,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'cursed_blade',
    name: 'Cursed Blade',
    description: 'Weave a curse into the defenses of one enemy, rotting their armor from within.',
    flavorText: 'The Hexblade does not break your guard. They make it irrelevant.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.debuff, flatBonus: 12,
    allowedClasses: [HeroClass.warlock],
  ),

  // ── T2 — Occultist ────────────────────────────────────────────────────────

  Spell(
    id: 'corruption',
    name: 'Corruption',
    description: 'Afflict a target with a corruption that rots flesh from within each round.',
    flavorText: 'Not an instant kill. Something slower. Something the target has time to understand.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.dot, powerScale: 0.55, duration: 4,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'dark_pact',
    name: 'Dark Pact',
    description: 'Call upon protective void energy to shield yourself from harm.',
    flavorText: 'A bargain struck in shadow. The void takes something in return — always.',
    manaCost: 4, tier: 2,
    effectType: SpellEffectType.buff, flatBonus: 15, duration: 3,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'void_bolt',
    name: 'Void Bolt',
    description: 'Unleash a bolt of pure void energy that unmakes rather than strikes.',
    flavorText: 'A void bolt does not impact. It simply removes a portion of its target from existence.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.2,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'hex',
    name: 'Hex',
    description: 'Weave a debilitating curse that strips armor from an enemy target.',
    flavorText: 'Warlocks are the only practitioners who classify this as "polite."',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.debuff, flatBonus: 12, duration: 2,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'eldritch_blast',
    name: 'Eldritch Blast',
    description: 'Channel eldritch power into a destructive wave that strikes all enemies.',
    flavorText: 'The Occultist spent six months studying ancient rites to learn this. It took three seconds to use.',
    manaCost: 8, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.85,
    allowedClasses: [HeroClass.warlock],
  ),

  // ── T3 — Demonologist ─────────────────────────────────────────────────────

  Spell(
    id: 'summon_felguard',
    name: 'Summon Felguard',
    description: 'Drag a greater void warrior through the veil. It fights savagely for many rounds.',
    flavorText: 'It did not come willingly. This makes it angrier. This makes it better at the task.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.summon, flatBonus: 22, duration: 4,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'hellfire_barrage',
    name: 'Hellfire Barrage',
    description: 'Rain concentrated void-fire down on all enemies for several sustained rounds.',
    flavorText: 'The Demonologist opens the gate wide enough for fire to come through uninvited.',
    manaCost: 11, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.55, duration: 3,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'demonic_immolation',
    name: 'Demonic Immolation',
    description: 'Release a demon\'s consuming fire across all enemies in a devastating eruption.',
    flavorText: 'The demon does not survive the release. Neither do most things nearby.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.0,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'fel_infestation',
    name: 'Fel Infestation',
    description: 'Infest all enemies with void parasites that feed on them each round.',
    flavorText: 'Not a technique the Demonologist discusses in public. Deeply effective.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.6, duration: 4,
    allowedClasses: [HeroClass.warlock],
  ),

  // ── T3 — Hexblade ─────────────────────────────────────────────────────────

  Spell(
    id: 'soul_burn',
    name: 'Soul Burn',
    description: 'Set the target\'s very soul alight with void fire.',
    flavorText: 'The most painful experience possible. The warlock chose this career knowing that.',
    manaCost: 11, tier: 3,
    effectType: SpellEffectType.damage, powerScale: 1.5,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'void_step',
    name: 'Void Step',
    description: 'Phase briefly into the void, emerging inside a target and tearing vital force away.',
    flavorText: 'There and not there. The body goes. What it takes comes back with it.',
    manaCost: 11, tier: 3,
    effectType: SpellEffectType.drain, powerScale: 1.2,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'shadow_reaping',
    name: 'Shadow Reaping',
    description: 'Extend shadow blades that sweep through all enemies in a single reaping motion.',
    flavorText: 'The Hexblade does not fight. They harvest.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 0.95,
    allowedClasses: [HeroClass.warlock],
  ),

  // ── T3 — Occultist ────────────────────────────────────────────────────────

  Spell(
    id: 'dread_aura',
    name: 'Dread Aura',
    description: 'Radiate a wave of concentrated dread that strikes all enemies.',
    flavorText: 'Not merely an attack. A message, delivered at speed.',
    manaCost: 10, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 0.85,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'void_rift',
    name: 'Void Rift',
    description: 'Tear open a rift in reality that devours everything within reach.',
    flavorText: 'What comes out the other side is not the same thing that went in.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.0,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'grand_ritual',
    name: 'Grand Ritual',
    description: 'Perform a sustained occult ritual that continuously erodes all enemies over time.',
    flavorText: 'The Occultist is patient. The ritual is methodical. The result is inevitable.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.6, duration: 4,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'seal_of_doom',
    name: 'Seal of Doom',
    description: 'Inscribe a void seal on one target that erupts with annihilating force.',
    flavorText: 'The seal takes a moment to set. It does not take a moment to detonate.',
    manaCost: 14, tier: 3,
    effectType: SpellEffectType.damage, powerScale: 1.7,
    allowedClasses: [HeroClass.warlock],
  ),
  Spell(
    id: 'eldritch_storm',
    name: 'Eldritch Storm',
    description: 'Unleash an eldritch storm of void-charged force that ravages all enemies.',
    flavorText: 'The void does not have weather. The Occultist brings some.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.1,
    allowedClasses: [HeroClass.warlock],
  ),
];

// ─── NECROMANCER SPELLS ──────────────────────────────────────────────────────
// T1: Death basics available to all necromancers
// T2 Lich: Soul sorcery, arcane death and spectral power
// T2 Death Knight: Bone mastery, reaping strikes and undead resilience
// T2 Plague Doctor: Disease, affliction and spreading pestilence
// T3 Lich: Soul dominion and death transcendence
// T3 Death Knight: Reaper incarnate and skeletal legions
// T3 Plague Doctor: Pandemic and catastrophic affliction

const _necromancerSpells = [

  // ── T1 — Death Basics ─────────────────────────────────────────────────────

  Spell(
    id: 'death_bolt',
    name: 'Death Bolt',
    description: 'Launch a bolt of pure death energy at one target.',
    flavorText: 'The color of nothing. It kills what it touches by reminding it what it already is.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.damage, powerScale: 0.8,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'bone_shard',
    name: 'Bone Shard',
    description: 'Fling a shard of sharpened bone with lethal force.',
    flavorText: 'The Ashen Age left this world rich in raw material. The necromancer wastes nothing.',
    manaCost: 4, tier: 1,
    effectType: SpellEffectType.damage, powerScale: 0.9,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'grave_chill',
    name: 'Grave Chill',
    description: 'Fill one target with grave-cold that numbs their resistance.',
    flavorText: 'The cemetery teaches this without being asked. Every necromancer\'s first lesson is not a spell — it\'s a feeling.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.debuff, flatBonus: 8, duration: 2,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'chill_of_death',
    name: 'Chill of Death',
    description: 'Infect a target with death\'s cold — it seeps in deeper each round.',
    flavorText: 'The cold of the grave does not stop. It does not tire. It does not hurry.',
    manaCost: 5, tier: 1,
    effectType: SpellEffectType.dot, powerScale: 0.5, duration: 3,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'dark_touch',
    name: 'Dark Touch',
    description: 'Draw life force from a target directly through the touch of death energy.',
    flavorText: 'The necromancer does not need to be close. The death energy does not require their presence.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.drain, powerScale: 0.75,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'crippling_curse',
    name: 'Crippling Curse',
    description: 'Lay a curse that weakens an enemy\'s physical frame and strips their defenses.',
    flavorText: 'Simple, economical, and permanent until dispelled. The necromancer\'s preferred qualities.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.debuff, flatBonus: 6,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'marrow_tap',
    name: 'Marrow Tap',
    description: 'Tap the marrow of a target, causing slow persistent damage from deep within.',
    flavorText: 'Not an external wound. Something found from the inside.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.dot, powerScale: 0.45, duration: 2,
    allowedClasses: [HeroClass.necromancer],
  ),

  // ── T2 — Lich ─────────────────────────────────────────────────────────────

  Spell(
    id: 'raise_dead',
    name: 'Raise Dead',
    description: 'Pull a fallen corpse to its feet. It will serve until it falls again.',
    flavorText: 'The Pale Court calls this resurrection. Necromancers call it recycling.',
    manaCost: 9, tier: 2,
    effectType: SpellEffectType.summon, flatBonus: 14, duration: 3,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'soul_cage',
    name: 'Soul Cage',
    description: 'Trap a fragment of a target\'s soul, converting it into raw power for yourself.',
    flavorText: 'The Lich does not take the whole soul. This is considered mercy in certain circles.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.drain, powerScale: 1.05,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'spectral_form',
    name: 'Spectral Form',
    description: 'Partially phase into the realm of the dead, making yourself difficult to harm.',
    flavorText: 'You are not quite here. The blade that finds you finds very little.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.buff, flatBonus: 16, duration: 4,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'arcane_decay',
    name: 'Arcane Decay',
    description: 'Unravel the arcane cohesion of all enemies, causing death-touched damage to each.',
    flavorText: 'The Lich knows that everything falls apart. This accelerates the schedule.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.8,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'soul_fray',
    name: 'Soul Fray',
    description: 'Begin unraveling a target\'s soul — the damage spreads over several rounds.',
    flavorText: 'A soul is not a single thing. Pull one thread and the rest follows.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.dot, powerScale: 0.55, duration: 3,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'void_touch',
    name: 'Void Touch',
    description: 'Send a tendril of void through a target\'s defenses, dissolving their resilience.',
    flavorText: 'The void touches everything, eventually. The Lich has learned to make it faster.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.debuff, flatBonus: 10,
    allowedClasses: [HeroClass.necromancer],
  ),

  // ── T2 — Death Knight ────────────────────────────────────────────────────

  Spell(
    id: 'bone_shield',
    name: 'Bone Shield',
    description: 'Summon a ring of animated bone to deflect incoming strikes.',
    flavorText: 'The dead are useful even when broken. Especially when broken.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.buff, flatBonus: 10, duration: 3,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'wither',
    name: 'Wither',
    description: 'Drain vital force from an enemy, reducing their physical resilience.',
    flavorText: 'Not a killing technique. A preparation technique.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.debuff, flatBonus: 6,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'bone_spear',
    name: 'Bone Spear',
    description: 'Fuse bone fragments mid-flight into a lance of lethal force.',
    flavorText: 'Multiple pieces. One intention. The mathematics is straightforward.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.2,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'death_strike',
    name: 'Death Strike',
    description: 'Channel death energy into a focused blow that strikes with exceptional force.',
    flavorText: 'The Death Knight does not swing a weapon. They swing finality.',
    manaCost: 8, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.3,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'bone_armor',
    name: 'Bone Armor',
    description: 'Encase yourself in a dense layer of fused bone that turns aside strikes.',
    flavorText: 'Heavy. Cold. Effective. The Death Knight considers these the finest three words.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.buff, flatBonus: 14, duration: 4,
    allowedClasses: [HeroClass.necromancer],
  ),

  // ── T2 — Plague Doctor ────────────────────────────────────────────────────

  Spell(
    id: 'plague_bolt',
    name: 'Plague Bolt',
    description: 'Hurl a bolt of distilled plague that begins consuming its target from within.',
    flavorText: 'The Plague Doctor carries a remedy for this. They do not share it.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.dot, powerScale: 0.55, duration: 3,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'virulent_poison',
    name: 'Virulent Poison',
    description: 'Inject a fast-acting necrotic poison that persists for a long duration.',
    flavorText: 'The Plague Doctor developed this. The Plague Doctor is very good at their job.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.dot, powerScale: 0.6, duration: 4,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'miasma',
    name: 'Miasma',
    description: 'Release a cloud of death-tainted air that burns through all enemies each round.',
    flavorText: 'The Plague Doctor wears the mask. Everyone else wears the consequence.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.dotAll, powerScale: 0.4, duration: 2,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'consuming_rot',
    name: 'Consuming Rot',
    description: 'Infect an enemy with aggressive rot that eats through their defenses.',
    flavorText: 'The rot is not selective. The Plague Doctor is.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.debuff, flatBonus: 8,
    allowedClasses: [HeroClass.necromancer],
  ),

  // ── T3 — Lich ─────────────────────────────────────────────────────────────

  Spell(
    id: 'liches_grasp',
    name: 'Lich\'s Grasp',
    description: 'Pull life force across the distance between you and a target.',
    flavorText: 'A technique recovered from pre-Ashen texts. Only partially understood. Fully devastating.',
    manaCost: 10, tier: 3,
    effectType: SpellEffectType.drain, powerScale: 1.0,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'death_coil',
    name: 'Death Coil',
    description: 'A coil of concentrated death force that seeks vital organs.',
    flavorText: 'It does not travel in a straight line. It travels in the most efficient line.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.damage, powerScale: 1.4,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'soul_harvest',
    name: 'Soul Harvest',
    description: 'Reap the soul-energy from a target with tremendous force, restoring your own vitality.',
    flavorText: 'The Lich does not merely drain life. They reclaim it as their own.',
    manaCost: 11, tier: 3,
    effectType: SpellEffectType.drain, powerScale: 1.15,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'void_dominion',
    name: 'Void Dominion',
    description: 'Assert absolute dominion over the death-field, crushing all enemies with void force.',
    flavorText: 'The Lich does not fight. They preside.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.0,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'soul_storm',
    name: 'Soul Storm',
    description: 'Release a storm of harvested soul-energy that ravages all enemies over time.',
    flavorText: 'The souls of the fallen do not rest. The Lich ensures this.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.6, duration: 3,
    allowedClasses: [HeroClass.necromancer],
  ),

  // ── T3 — Death Knight ────────────────────────────────────────────────────

  Spell(
    id: 'corpse_explosion',
    name: 'Corpse Explosion',
    description: 'Detonate a fallen corpse with tremendous violence, striking all enemies.',
    flavorText: 'There is always a body nearby. The necromancer considers this a resource.',
    manaCost: 11, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 0.9,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'army_of_the_dead',
    name: 'Army of the Dead',
    description: 'Raise multiple dead to fight alongside you, overwhelming enemies with numbers.',
    flavorText: 'The Church banned this technique in 14 separate edicts. It has not helped.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.summon, flatBonus: 20, duration: 4,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'reaper_scythe',
    name: 'Reaper\'s Scythe',
    description: 'Manifest a spectral reaping blade that sweeps through all enemies.',
    flavorText: 'The Death Knight is done with individual targets. The scythe does not think small.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.1,
    allowedClasses: [HeroClass.necromancer],
  ),

  // ── T3 — Plague Doctor ────────────────────────────────────────────────────

  Spell(
    id: 'blight',
    name: 'Blight',
    description: 'Spread a killing blight across the battlefield that damages all enemies each round.',
    flavorText: 'The Ashen Age left blight in the soil. The necromancer just spreads it faster.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.6, duration: 3,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'unholy_ground',
    name: 'Unholy Ground',
    description: 'Consecrate the battlefield to death — the ground itself bleeds necrotic energy each round.',
    flavorText: 'Found in the Gallows Moor codices, circa 180 years ago. The Church had the codices burned. The spell remains.',
    manaCost: 14, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.65, duration: 4,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'pandemic',
    name: 'Pandemic',
    description: 'Unleash a weaponized plague that spreads between all enemies and persists for many rounds.',
    flavorText: 'The Plague Doctor says: good hygiene is a personal choice. Pandemic is not.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.55, duration: 4,
    allowedClasses: [HeroClass.necromancer],
  ),
  Spell(
    id: 'death_by_a_thousand_cuts',
    name: 'Death by a Thousand Cuts',
    description: 'Layer a cascade of afflictions onto one target that compounds for many rounds.',
    flavorText: 'Slow. Thorough. Educational.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.dot, powerScale: 0.7, duration: 5,
    allowedClasses: [HeroClass.necromancer],
  ),
];

// ─── PRIEST SPELLS ────────────────────────────────────────────────────────────
// T1: Faith basics available to all priests
// T2 Inquisitor: Holy damage, purging and righteous fire
// T2 Hospitaller: Healing, support and divine protection
// T2 Zealot: Divine fury, sacred rage and wrath
// T3 Inquisitor: Righteous destruction and holy judgment
// T3 Hospitaller: Miracles and divine intervention
// T3 Zealot: Wrath incarnate and divine conflagration

const _priestSpells = [

  // ── T1 — Faith Basics ─────────────────────────────────────────────────────

  Spell(
    id: 'smite',
    name: 'Smite',
    description: 'Channel divine wrath into a focused strike on one target.',
    flavorText: 'The faiths differ on almost everything. They agree that this is the correct response.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.damage, powerScale: 0.85,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'holy_flame',
    name: 'Holy Flame',
    description: 'Call down a pillar of cleansing divine fire on one target.',
    flavorText: 'Particularly devastating to the unholy. The fire knows the difference.',
    manaCost: 4, tier: 1,
    effectType: SpellEffectType.damage, powerScale: 0.95,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'sacred_word',
    name: 'Sacred Word',
    description: 'Speak a word of power that knits wounds closed on the most injured hero.',
    flavorText: 'The first thing taught in every seminary. The last thing needed in every battle.',
    manaCost: 4, tier: 1,
    effectType: SpellEffectType.heal, powerScale: 0.8,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'mend',
    name: 'Mend',
    description: 'Close a wound with a swift touch of divine focus.',
    flavorText: 'Not a miracle. A practised application of faith in small, precise doses.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.heal, powerScale: 0.7,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'lesser_ward',
    name: 'Lesser Ward',
    description: 'Weave a minor divine protection around yourself against incoming blows.',
    flavorText: 'Insufficient on its own. A foundation for the rest.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.buff, flatBonus: 7, duration: 3,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'divine_light',
    name: 'Divine Light',
    description: 'Release a pulse of holy light that scorches all enemies simultaneously.',
    flavorText: 'The five faiths debate what the light is. It burns regardless of the theology.',
    manaCost: 4, tier: 1,
    effectType: SpellEffectType.damageAll, powerScale: 0.55,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'benediction',
    name: 'Benediction',
    description: 'Speak a blessing of unmaking that strips one supernatural trait from an enemy.',
    flavorText: 'A blessing for you. Rather less of one for the target.',
    manaCost: 3, tier: 1,
    effectType: SpellEffectType.dispel,
    allowedClasses: [HeroClass.priest],
  ),

  // ── T2 — Inquisitor ───────────────────────────────────────────────────────

  Spell(
    id: 'divine_wrath',
    name: 'Divine Wrath',
    description: 'Focus the full weight of divine anger through yourself onto one target.',
    flavorText: 'The gods are not gentle. The priest is not always either.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.2,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'consecrate',
    name: 'Consecrate',
    description: 'Burn holy fire into the ground beneath all enemies.',
    flavorText: 'The ground remembers what walked on it. The priest makes it remember something else.',
    manaCost: 8, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.75,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'searing_light',
    name: 'Searing Light',
    description: 'Focus a beam of divine radiance to searing intensity against one target.',
    flavorText: 'The Inquisitor does not prosecute with words when light is available.',
    manaCost: 8, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.3,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'brand_of_heresy',
    name: 'Brand of Heresy',
    description: 'Burn a brand of divine censure into an enemy that sears them each round.',
    flavorText: 'The Inquisition found this more efficient than the paperwork.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.dot, powerScale: 0.5, duration: 3,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'mark_of_judgment',
    name: 'Mark of Judgment',
    description: 'Mark one enemy with divine condemnation, weakening their defenses.',
    flavorText: 'The mark does not hurt. What follows does.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.debuff, flatBonus: 10,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'righteous_cleave',
    name: 'Righteous Cleave',
    description: 'Sweep a blade of divine force through all enemies in a righteous arc.',
    flavorText: 'The Inquisitor is not gentle. The Light is not gentle. They are in agreement.',
    manaCost: 8, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.8,
    allowedClasses: [HeroClass.priest],
  ),

  // ── T2 — Hospitaller ─────────────────────────────────────────────────────

  Spell(
    id: 'bless',
    name: 'Bless',
    description: 'Call divine protection around yourself, hardening you against attacks.',
    flavorText: 'The divine will not shield a coward. It will, however, shield someone doing their best.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.buff, flatBonus: 10, duration: 4,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'mass_prayer',
    name: 'Mass Prayer',
    description: 'A prayer that simultaneously knits wounds across the entire party.',
    flavorText: 'The faiths quarrel. The wounded do not care. The priest learns this early.',
    manaCost: 9, tier: 2,
    effectType: SpellEffectType.healAll, powerScale: 0.6,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'purge',
    name: 'Purge',
    description: 'Tear one supernatural trait from an enemy with divine force.',
    flavorText: 'Some things exist only because nothing has told them to stop. This does.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.dispel,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'greater_heal',
    name: 'Greater Heal',
    description: 'Channel a substantial current of divine healing into the most injured hero.',
    flavorText: 'Three of these and a battlefield looks different. The Hospitaller knows the number.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.heal, powerScale: 1.3,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'restoration',
    name: 'Restoration',
    description: 'Spread gentle healing across all heroes to restore their wounds.',
    flavorText: 'Not dramatic. Not impressive. The Hospitaller has stopped caring which words apply.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.healAll, powerScale: 0.5,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'protective_light',
    name: 'Protective Light',
    description: 'Weave divine light into a sustained barrier that absorbs harm for many rounds.',
    flavorText: 'The Hospitaller\'s answer to the question: can you keep them alive long enough?',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.buff, flatBonus: 12, duration: 5,
    allowedClasses: [HeroClass.priest],
  ),

  // ── T2 — Zealot ──────────────────────────────────────────────────────────

  Spell(
    id: 'divine_fury',
    name: 'Divine Fury',
    description: 'Channel the full force of fanatical devotion into a devastating strike on one target.',
    flavorText: 'The Zealot is not angry. They are certain. The difference is significant.',
    manaCost: 7, tier: 2,
    effectType: SpellEffectType.damage, powerScale: 1.25,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'wrath_of_the_penitent',
    name: 'Wrath of the Penitent',
    description: 'Release the accumulated weight of divine fury across all enemies at once.',
    flavorText: 'The penitent has confessed everything. Now they act accordingly.',
    manaCost: 8, tier: 2,
    effectType: SpellEffectType.damageAll, powerScale: 0.8,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'fervor',
    name: 'Fervor',
    description: 'Ignite yourself with divine fervor that dramatically hardens you against harm.',
    flavorText: 'The Zealot does not feel the wound. They feel the purpose. This serves adequately.',
    manaCost: 5, tier: 2,
    effectType: SpellEffectType.buff, flatBonus: 16, duration: 3,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'sacred_fire',
    name: 'Sacred Fire',
    description: 'Set an enemy ablaze with holy fire that burns them each round.',
    flavorText: 'The Zealot will accept the charge of excessive enthusiasm. It is accurate.',
    manaCost: 6, tier: 2,
    effectType: SpellEffectType.dot, powerScale: 0.5, duration: 3,
    allowedClasses: [HeroClass.priest],
  ),

  // ── T3 — Inquisitor ───────────────────────────────────────────────────────

  Spell(
    id: 'holy_nova',
    name: 'Holy Nova',
    description: 'Release an explosion of holy force that strikes all enemies at once.',
    flavorText: 'Not subtle. Not quiet. The priest is not always subtle or quiet.',
    manaCost: 10, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 0.95,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'judgment',
    name: 'Judgment',
    description: 'Call divine sentence down upon one enemy — the sentence is damage, significant and final.',
    flavorText: 'The Luminant Church calls this "the last word of the Arbiter." The Old Ways call it "what the fire said." Either way, the target burns.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.damage, powerScale: 1.6,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'holy_fire',
    name: 'Holy Fire',
    description: 'Blanket the battlefield in divine flame that sears all enemies each round.',
    flavorText: 'The Inquisitor does not put the fire out. The Inquisitor is the fire.',
    manaCost: 11, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.55, duration: 3,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'crusaders_verdict',
    name: 'Crusader\'s Verdict',
    description: 'Deliver the Crusade\'s final verdict on one enemy with overwhelming divine force.',
    flavorText: 'There is no appeal. The Crusader does not have an appeals process.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.damage, powerScale: 1.5,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'righteous_fire',
    name: 'Righteous Fire',
    description: 'The ground erupts in righteous flame beneath all enemies for several sustained rounds.',
    flavorText: 'Found in the Iron Chapter\'s restricted codex. The chapter considers it a last resort. The Inquisitor considers it a greeting.',
    manaCost: 13, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.6, duration: 3,
    allowedClasses: [HeroClass.priest],
  ),

  // ── T3 — Hospitaller ─────────────────────────────────────────────────────

  Spell(
    id: 'divine_shield',
    name: 'Divine Shield',
    description: 'Surround yourself with a shield of pure divine force.',
    flavorText: 'The most ancient prayer in the canon. It has never stopped working.',
    manaCost: 8, tier: 3,
    effectType: SpellEffectType.buff, flatBonus: 20, duration: 3,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'radiance',
    name: 'Radiance',
    description: 'Blinding divine radiance heals all living heroes.',
    flavorText: 'The world went dark in the Ashen Age. The priest carries the memory of the light.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.healAll, powerScale: 0.9,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'sanctuary',
    name: 'Sanctuary',
    description: 'Call a dome of divine light around all heroes, granting substantial protection for several rounds.',
    flavorText: 'Three faiths claim authorship of this prayer. All three are correct. It has been re-discovered independently more times than anyone has counted.',
    manaCost: 11, tier: 3,
    effectType: SpellEffectType.buff, flatBonus: 25, duration: 3,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'miracle',
    name: 'Miracle',
    description: 'Call upon the divine directly, flooding all heroes with powerful healing.',
    flavorText: 'The Compact of Saints says miracles require three days of fasting and a written petition. The Hospitaller disagrees.',
    manaCost: 14, tier: 3,
    effectType: SpellEffectType.healAll, powerScale: 1.2,
    allowedClasses: [HeroClass.priest],
  ),

  // ── T3 — Zealot ──────────────────────────────────────────────────────────

  Spell(
    id: 'gods_wrath',
    name: 'God\'s Wrath',
    description: 'Channel absolute divine fury through yourself and unleash it against all enemies.',
    flavorText: 'The Zealot is a vessel. At this point, what pours out is not entirely their own.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.damageAll, powerScale: 1.1,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'holy_conflagration',
    name: 'Holy Conflagration',
    description: 'Set the battlefield ablaze with divine fire that continues to burn all enemies.',
    flavorText: 'The Zealot has no gentle settings. This is one of the ungainly ones.',
    manaCost: 12, tier: 3,
    effectType: SpellEffectType.dotAll, powerScale: 0.6, duration: 3,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'divine_verdict',
    name: 'Divine Verdict',
    description: 'Deliver the final and absolute verdict of divine power on one target.',
    flavorText: 'There are no witnesses. The verdict is the last thing.',
    manaCost: 14, tier: 3,
    effectType: SpellEffectType.damage, powerScale: 1.7,
    allowedClasses: [HeroClass.priest],
  ),
  Spell(
    id: 'martyrs_fire',
    name: 'Martyr\'s Fire',
    description: 'Convert your own pain into holy fire, draining the enemy\'s vitality with divine force.',
    flavorText: 'The Zealot offers themselves as fuel. The gods are not wasteful.',
    manaCost: 11, tier: 3,
    effectType: SpellEffectType.drain, powerScale: 1.0,
    allowedClasses: [HeroClass.priest],
  ),
];

// ─── MASTER LIST ──────────────────────────────────────────────────────────────

const allSpells = [
  ..._mageSpells,
  ..._warlockSpells,
  ..._necromancerSpells,
  ..._priestSpells,
];

Spell? spellById(String id) {
  try {
    return allSpells.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
}

List<Spell> spellsForClass(HeroClass cls) =>
    allSpells.where((s) => s.allowedClasses.contains(cls)).toList();
