import '../models/faith.dart';
import '../models/enums.dart';

const List<Faith> allFaiths = [

  Faith(
    type: FaithType.luminantChurch,
    name: 'The Luminant Church',
    deity: 'The Eternal Flame',
    description: 'A monotheistic institution that has spread its light — and its crusades — across the known world. Its knights are holy warriors; its inquisitors are feared. The Church promises salvation and delivers fire.',
    inspiredBy: 'Medieval Catholic Church, Crusading Orders (Knights Templar, Hospitallers)',
    affinityClasses: [HeroClass.knight, HeroClass.priest],
    tiers: [
      DevotionTier(
        name: 'The Faithful',
        devotionRequired: 0,
        description: 'You have taken the vows. The Flame watches.',
        passiveBonuses: ['+5% damage against undead and demons', '+2 Faith stat'],
        abilities: ['Lay on Hands — restore a small amount of health to one ally'],
      ),
      DevotionTier(
        name: 'The Devoted',
        devotionRequired: 30,
        description: 'The Flame burns in your chest. Others can feel it.',
        passiveBonuses: ['+15% damage against undead and demons', '+5 Faith stat', 'Aura: allies nearby gain +1 armor'],
        abilities: ['Smite — a holy strike that deals bonus damage and briefly blinds', 'Ward of Light — absorb one attack for an ally'],
      ),
      DevotionTier(
        name: 'The Consecrated',
        devotionRequired: 70,
        description: 'You carry a fragment of the Eternal Flame within you. It does not go out.',
        passiveBonuses: ['+30% damage against undead and demons', '+10 Faith stat', 'Aura: undead enemies suffer -10% attack', 'Passive: 10% chance to revive with 1 HP on death (once per battle)'],
        abilities: ['Sundering Smite — massive holy damage that ignores armor', 'Miracle: Resurrection — revive one fallen ally at half health (once per dungeon)'],
      ),
    ],
  ),

  Faith(
    type: FaithType.oldWays,
    name: 'The Old Ways',
    deity: 'The Pantheon of Sky, Stone, and Sea',
    description: 'The ancient gods of storm and harvest who reigned before the Church arrived. Their worship was driven into the forests and highlands, but it never died. Wild, honest, and merciless as nature itself.',
    inspiredBy: 'Norse/Germanic/Celtic paganism, the Old Norse Eddas, Druidic traditions',
    affinityClasses: [HeroClass.ranger, HeroClass.knight],
    tiers: [
      DevotionTier(
        name: 'The Marked',
        devotionRequired: 0,
        description: 'You bear the old marks. The gods are watching — not yet impressed.',
        passiveBonuses: ['+5% damage in wilderness and forest locations', '+2 Strength and Dexterity'],
        abilities: ['Bloodcall — enter a light battle rage, +10% damage for 3 rounds'],
      ),
      DevotionTier(
        name: 'The Storm-Touched',
        devotionRequired: 30,
        description: 'The gods have answered. Lightning recognizes you.',
        passiveBonuses: ['+15% damage in all natural locations', '+5 Strength', 'Passive: 15% chance attacks call a lightning strike for bonus damage'],
        abilities: ['Gale Strike — a wind-buffeted blow that knocks enemies back', 'Stone Skin — temporarily harden skin, reducing damage taken'],
      ),
      DevotionTier(
        name: 'The Berserker-Chosen',
        devotionRequired: 70,
        description: 'A god rides in your bones when you fight. You are no longer merely human in battle.',
        passiveBonuses: ['+30% damage when below half health', '+15 Strength', 'Aura: allies gain +10% attack speed', 'Passive: become immune to fear and charm effects'],
        abilities: ['Godborn Fury — for 5 rounds you deal double damage and cannot be stopped', 'Runic Howl — terrify all enemies, forcing them to skip one attack'],
      ),
    ],
  ),

  Faith(
    type: FaithType.paleCourt,
    name: 'The Pale Court',
    deity: 'The Three-Faced Queen (Maiden, Crone, Corpse)',
    description: 'Ancestor worship and reverence for the dead, practiced by those who understand that death is not an end but a change of station. The Pale Court keeps records of every soul that has passed and expects its followers to do the same.',
    inspiredBy: 'Medieval death cults, the Danse Macabre, ancestor veneration, the Book of the Dead traditions',
    affinityClasses: [HeroClass.necromancer, HeroClass.priest],
    tiers: [
      DevotionTier(
        name: 'The Aware',
        devotionRequired: 0,
        description: 'You have looked at death without flinching. The Court is pleased.',
        passiveBonuses: ['+5% damage with necrotic abilities', '+2 Intelligence and Faith', 'Immune to fear effects'],
        abilities: ['Death Sense — briefly reveal all enemies\' health totals', 'Bone Ward — summon a fragment of bone to absorb one hit'],
      ),
      DevotionTier(
        name: 'The Grave-Sworn',
        devotionRequired: 30,
        description: 'The dead speak to you. Sometimes you even answer.',
        passiveBonuses: ['+15% necrotic damage', '+5 Intelligence', 'Passive: slain enemies have 20% chance to rise as a temporary skeleton ally'],
        abilities: ['Corpse Call — animate a nearby corpse to fight for you briefly', 'Wail of the Fallen — a scream from beyond that deals necrotic damage to all enemies'],
      ),
      DevotionTier(
        name: 'The Pale-Crowned',
        devotionRequired: 70,
        description: 'The Three-Faced Queen has set a pale crown on your brow. Death does not surprise you anymore.',
        passiveBonuses: ['+30% necrotic damage', '+15 Intelligence', 'Passive: you cannot be killed outright — if you would die you are instead reduced to 1 HP (once per battle)', 'Aura: all undead allies gain +20% damage'],
        abilities: ['Army of the Pale Court — raise up to 3 corpses simultaneously', 'Lifestealing Aura — drain health from all enemies each round for 4 rounds'],
      ),
    ],
  ),

  Faith(
    type: FaithType.compactOfSaints,
    name: 'The Compact of Saints',
    deity: 'The Countless Saints (no single deity)',
    description: 'Folk religion built on prayers to local saints, minor miracles, hedge magic, and the quiet hope that someone up there is listening. No grand church, no crusades — just candles, whispered prayers, and an extraordinary rate of answered petitions.',
    inspiredBy: 'Folk Catholicism, local saint veneration, medieval popular religion, wise women and hedge witches',
    affinityClasses: [HeroClass.priest, HeroClass.rogue],
    tiers: [
      DevotionTier(
        name: 'The Hopeful',
        devotionRequired: 0,
        description: 'You light candles and mean it. A saint has noticed.',
        passiveBonuses: ['+5% luck in all rolls', '+2 Luck and Faith', 'Items found are 10% more likely to be of higher rarity'],
        abilities: ['Fortunate Strike — a blessed attack with increased critical hit chance'],
      ),
      DevotionTier(
        name: 'The Petitioner',
        devotionRequired: 30,
        description: 'Your prayers are answered more often than they should be. The saints compare notes about you.',
        passiveBonuses: ['+15% luck', '+5 Luck', 'Passive: 20% chance shops offer rare items', 'Passive: 15% chance to avoid a critical hit'],
        abilities: ['Saint\'s Blessing — grant an ally a luck boost for the rest of the battle', 'Minor Miracle — instantly heal a small random amount (unpredictable)'],
      ),
      DevotionTier(
        name: 'The Beloved',
        devotionRequired: 70,
        description: 'You are a saint in all but name. The miracles barely surprise you anymore.',
        passiveBonuses: ['+30% luck on all rolls', '+15 Luck', 'Passive: once per dungeon, fail to die (unexplained survival)', 'Passive: vendors offer 20% discount'],
        abilities: ['Grand Miracle — a powerful random effect (could be devastating or extraordinary)', 'Saint\'s Intercession — remove all negative status effects from all allies'],
      ),
    ],
  ),

  Faith(
    type: FaithType.ashenRite,
    name: 'The Ashen Rite',
    deity: 'The Void That Speaks (no name — naming it invites it in)',
    description: 'Heretical, forbidden, hunted. The Ashen Rite holds that beneath all creation lies a consuming void, and that true power comes from bargaining with what lives in it. Practitioners are branded apostates by the Church. They don\'t particularly care.',
    inspiredBy: 'Medieval heretical movements, the Cathar tradition, occult philosophy, the darker edges of grimoire magic',
    affinityClasses: [HeroClass.warlock, HeroClass.necromancer],
    tiers: [
      DevotionTier(
        name: 'The Branded',
        devotionRequired: 0,
        description: 'You have spoken words that cannot be unspoken. The Void has heard you.',
        passiveBonuses: ['+5% all magic damage', '+2 Intelligence', 'Passive: your presence makes enemies uneasy — -5% enemy morale'],
        abilities: ['Void Touch — a cursed strike that deals damage over time'],
      ),
      DevotionTier(
        name: 'The Apostate',
        devotionRequired: 30,
        description: 'The Void has answered back. You hear it in silence now.',
        passiveBonuses: ['+20% all magic damage', '+5 Intelligence and Faith', 'Passive: spells have 15% chance to trigger twice', 'Warning: Church-affiliated NPCs are hostile'],
        abilities: ['Ashen Curse — place a devastating curse that weakens an enemy over time', 'Void Rift — tear open a small void that deals damage to all enemies'],
      ),
      DevotionTier(
        name: 'The Hollow',
        devotionRequired: 70,
        description: 'Something peers out through your eyes. The Void has made a home in you. You have made peace with this.',
        passiveBonuses: ['+40% all magic damage', '+15 Intelligence', 'Passive: spells have 25% chance to trigger twice', 'Passive: immune to all fear, charm, and mind effects', 'Warning: most town NPCs will not speak to you'],
        abilities: ['Consume — devour the soul of a dying enemy, instantly kill it and gain its remaining health', 'The Void Speaks — unleash a catastrophic void eruption dealing massive damage to all enemies (but also 10% damage to all allies)'],
      ),
    ],
  ),
];
