// ─── IN-GAME GUIDE ───────────────────────────────────────────────────────────
// Guide content for the help screen. Written in the game's voice — sparse,
// atmospheric, and direct. Add articles freely; the screen renders them all.

class GuideCategory {
  final String id;
  final String title;
  final String icon;
  final List<GuideArticle> articles;
  const GuideCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.articles,
  });
}

class GuideArticle {
  final String title;
  final List<GuideBlock> blocks;
  const GuideArticle({required this.title, required this.blocks});
}

class GuideBlock {
  final String text;
  final bool isHeader;
  const GuideBlock(this.text, {this.isHeader = false});
  const GuideBlock.header(String text) : this(text, isHeader: true);
}

// ─────────────────────────────────────────────────────────────────────────────

const allGuideCategories = <GuideCategory>[

  // ── GETTING STARTED ────────────────────────────────────────────────────────
  GuideCategory(
    id: 'getting_started',
    title: 'Getting Started',
    icon: '⚑',
    articles: [
      GuideArticle(
        title: 'The Game Loop',
        blocks: [
          GuideBlock('The Ashen Road is a passive strategy game. Your heroes fight, travel, and earn gold while the clock runs — you manage, equip, and direct from the sidelines.'),
          GuideBlock.header('Your First Day'),
          GuideBlock('You begin at Ashenvale with a small party and a handful of gold. Open the Expedition tab and tap a nearby location to send your heroes out. They will handle the fighting themselves.'),
          GuideBlock('While they are away, check the Holdings tab and invest in your first property. Income arrives each morning at dawn. Everything else follows from there.'),
          GuideBlock.header('The Three Resources'),
          GuideBlock('Gold pays for everything. Rations keep your heroes alive on long expeditions. Time is the resource you cannot earn back — every choice has a duration cost.'),
        ],
      ),
      GuideArticle(
        title: 'The Ashen Road',
        blocks: [
          GuideBlock('The Road runs west to east through seven tiers of danger. Ashenvale is safe. The Void Spire, at the far end, is not.'),
          GuideBlock('The Church built this road to push back The Opening — the catastrophe that flooded the east with ash thirty years ago. The crusade failed. The road remains.'),
          GuideBlock.header('How to Progress'),
          GuideBlock('Explore side locations near each spine town to level your heroes and earn gold. When your party reaches the level requirement for the next spine node, push forward. There is no rush, but farming content your party has outgrown yields reduced XP.'),
          GuideBlock.header('Discovery'),
          GuideBlock('Visiting a location reveals nearby undiscovered sites. Tap the cartographer option in any location sheet to pay for a targeted reveal.'),
        ],
      ),
    ],
  ),

  // ── EXPEDITIONS & ROAD ─────────────────────────────────────────────────────
  GuideCategory(
    id: 'expeditions',
    title: 'Expeditions',
    icon: '⚔',
    articles: [
      GuideArticle(
        title: 'Sending a Party',
        blocks: [
          GuideBlock('Open the Expedition tab. Tap any discovered location on the map to open its sheet. Select heroes, choose supplies, and tap Depart.'),
          GuideBlock('Only one expedition can run at a time. Heroes on expedition are unavailable for anything else.'),
          GuideBlock.header('Level Gates'),
          GuideBlock('Deeper locations require your party\'s average level to meet a minimum. Locked locations show a 🔒 badge with the required level. You cannot depart until the requirement is met.'),
          GuideBlock('Depth 3 requires level 5. Depth 4 requires level 10. Depth 5 requires level 14. Depth 6 requires level 18. Depth 7 requires level 22.'),
          GuideBlock.header('Revisiting Locations'),
          GuideBlock('You cannot immediately return to a location you just left — the party needs at least one other expedition first. Revisiting the same location many times alerts the enemies there, making them harder. Five visits grants a gold bonus as the location becomes a known hunting ground.'),
        ],
      ),
      GuideArticle(
        title: 'Rations & Supplies',
        blocks: [
          GuideBlock('Every expedition costs rations based on its duration. The longer the journey, the more rations consumed.'),
          GuideBlock('If you cannot cover the ration cost, your party departs hungry. Each hero loses 20 HP on arrival — before combat begins.'),
          GuideBlock.header('Pre-Expedition Supplies'),
          GuideBlock('Before departure you can purchase two optional supplies from the location sheet:'),
          GuideBlock('Healing Kit (80g) — The party heals 40 HP at the expedition\'s halfway point. Useful for long dungeons.'),
          GuideBlock('Lantern (60g) — Improves loot quality in dungeons and ruins. Not useful elsewhere.'),
          GuideBlock.header('Buying Rations'),
          GuideBlock('Rations can be purchased in bulk from the location sheet (75g for five days) or from town traders. Keep a buffer — running dry mid-expedition is brutal.'),
        ],
      ),
      GuideArticle(
        title: 'Travel Events',
        blocks: [
          GuideBlock('On longer expeditions the Road Screen shows the party travelling to their destination. Events trigger at roughly 30% and 70% of the travel leg.'),
          GuideBlock('Travel events include ambushes, chance finds, NPC encounters, and the campfire rest. Most events are random; some are influenced by equipment or party composition.'),
          GuideBlock.header('The Road Screen'),
          GuideBlock('The Road Screen shows the active expedition in real time: travel progress, current event, and once the party arrives — live combat events as they happen.'),
          GuideBlock('You can purchase supplies mid-expedition from the Road Screen if the party is at a location (between combat rounds). This uses the buyExpeditionSupply action rather than pre-expedition prices.'),
        ],
      ),
      GuideArticle(
        title: 'Town Visits',
        blocks: [
          GuideBlock('When a combat expedition ends at a town or monastery, the party stays on location. A town visit panel appears on the Road Screen.'),
          GuideBlock('Town visits offer traders (weapons, armour, spell tomes), NPCs, inn rest, and wandering heroes for hire.'),
          GuideBlock.header('The Trader'),
          GuideBlock('Traders sell a mix of gear and spell tomes. Stock is generated fresh each visit based on the location\'s depth tier — deeper towns carry rarer items.'),
          GuideBlock('Spell tomes only appear for spells your party does not already know. There is no point shopping for spells you have.'),
          GuideBlock.header('Resting at the Inn'),
          GuideBlock('Paying the inn cost heals all heroes to full and restores mana. Cost scales with depth. Healing is the only thing the inn does — it does not grant time.'),
          GuideBlock.header('Leaving Town'),
          GuideBlock('Tap "Leave" on the Road Screen to send the party home. They travel back automatically. While returning, they are unavailable for new expeditions.'),
        ],
      ),
    ],
  ),

  // ── COMBAT ─────────────────────────────────────────────────────────────────
  GuideCategory(
    id: 'combat',
    title: 'Combat',
    icon: '☠',
    articles: [
      GuideArticle(
        title: 'How Combat Works',
        blocks: [
          GuideBlock('Combat is fully automatic. Your heroes and the enemies take turns in rounds. You observe the outcome in the live log on the Road Screen.'),
          GuideBlock('Each encounter is a group of enemies spawned by the location type and depth. Dungeons lean undead; wilderness leans beast; ruins lean supernatural.'),
          GuideBlock.header('Encounter Scale'),
          GuideBlock('Each location runs several encounters back to back — the exact count varies by location type. Dungeons run the most. Churches and shrines run none.'),
          GuideBlock('Locations at depth 4 and above also spawn a named boss as a final encounter. Bosses have significantly more HP, special traits, and higher XP rewards.'),
          GuideBlock.header('Scaling'),
          GuideBlock('Enemy stats scale with depth. A depth 1 bandit is trivial at level 8. A depth 6 creature at level 10 will destroy an unprepared party. Push when you are ready.'),
        ],
      ),
      GuideArticle(
        title: 'Hero Stats & Damage',
        blocks: [
          GuideBlock('Strength drives melee physical damage. Dexterity improves hit rate and crit chance. Endurance increases max HP. Intelligence drives spell damage and max mana. Faith fuels devotion and holy abilities. Luck improves critical hits and rare outcomes.'),
          GuideBlock.header('Defense'),
          GuideBlock('Your heroes\' armor from equipped gear reduces incoming damage before it reaches HP. Enemies have armor too — armor-piercing weapons and abilities ignore part of it.'),
          GuideBlock.header('Critical Hits'),
          GuideBlock('Critical hits deal 2× damage by default. Equipment and abilities can raise the multiplier or the crit chance.'),
          GuideBlock.header('Enemy Traits'),
          GuideBlock('Elite enemies and bosses carry traits. Crit Immune blocks all critical hits. Phase on Crit means the creature phases out when crit, avoiding the attack. Party Damage means their attacks hit all heroes. Drain on Hit recovers HP from your heroes. Self Regen heals each round. Armor Piercing ignores armor entirely. Flee on Low HP means the creature attempts escape at low health.'),
        ],
      ),
      GuideArticle(
        title: 'Injuries & Death',
        blocks: [
          GuideBlock('A hero who reaches 0 HP during combat is injured. Injured heroes cannot join expeditions until they recover. Recovery time scales with how low they fell.'),
          GuideBlock.header('Permadeath'),
          GuideBlock('Permadeath can be toggled per hero in the character creation screen. With permadeath enabled, reaching 0 HP means the hero is gone permanently.'),
          GuideBlock('Your Player Character always has permadeath available as an option. Think carefully before enabling it in the far wastes.'),
          GuideBlock.header('Combat Outcomes'),
          GuideBlock('Victory: party clears all encounters. Normal outcome with full loot and XP. Retreat: party is forced back mid-expedition — reduced rewards, some injuries. Party Wipe: all heroes are downed. Injuries assigned, expedition ends early, all loot lost.'),
        ],
      ),
    ],
  ),

  // ── HEROES ─────────────────────────────────────────────────────────────────
  GuideCategory(
    id: 'heroes',
    title: 'Heroes',
    icon: '⚔',
    articles: [
      GuideArticle(
        title: 'Leveling & XP',
        blocks: [
          GuideBlock('Heroes earn XP from every expedition they participate in. Each hero earns the full expedition XP total — it is not split between party members. Bringing more heroes does not reduce individual XP gains.'),
          GuideBlock.header('XP Diminishing Returns'),
          GuideBlock('If your party\'s average level significantly exceeds the content depth, XP is reduced — by half if overleveled by 4 or more, by 75% if overleveled by 8 or more. The event log notes when this applies.'),
          GuideBlock('There is no punishment for exploring old content, but there is no XP reason to either. New content earns full XP.'),
          GuideBlock.header('Level Milestones'),
          GuideBlock('Level 5: subclass selection unlocks, tier 2 spells begin appearing, third spell slot available. Level 10: fourth spell slot, tier 3 spell auto-learn possible. Level 15: fifth spell slot. Level 20: sixth spell slot (max).'),
        ],
      ),
      GuideArticle(
        title: 'Subclasses',
        blocks: [
          GuideBlock('At level 5, each hero can choose a subclass. Subclasses define the advanced direction of a hero\'s build. A pending subclass choice is indicated by a dot on the Party tab.'),
          GuideBlock('Subclasses are permanent. Choose carefully — they gate which class abilities become available.'),
          GuideBlock.header('Fighter Subclasses'),
          GuideBlock('Champion: heavy armor specialist, maximum damage. Guardian: tank and party protector. Berserker: reckless damage dealer with high risk, high reward.'),
          GuideBlock.header('Rogue Subclasses'),
          GuideBlock('Shadowblade: assassin, crit-focused single target. Trickster: debuffs, escapes, and utility. Ranger: ranged attacks and positioning.'),
          GuideBlock.header('Caster Subclasses'),
          GuideBlock('Mage: Elementalist (fire/frost/lightning), Runescribe (arcane runes and barriers), Alchemist (acid and transmutation). Warlock: Demonologist (summoning), Hexblade (shadow melee), Occultist (rituals and curses). Necromancer: Lich (soul sorcery), Death Knight (bone and reaping), Plague Doctor (disease). Priest: Inquisitor (holy damage), Hospitaller (healing and protection), Zealot (divine fury).'),
        ],
      ),
      GuideArticle(
        title: 'Equipment',
        blocks: [
          GuideBlock('Heroes have seven equipment slots: main hand, off hand, head, body, hands, legs, feet, and shield.'),
          GuideBlock('Weapons define your attack style. Two-handers deal more damage but cannot use a shield. Shields add significant defense.'),
          GuideBlock.header('Item Modifiers'),
          GuideBlock('Some items from traders carry item modifiers — special bonuses beyond the base stat. Examples: bonus damage, crit chance, lifesteal, spell power, dodge, damage reduction, armor penetration. Modified items show their modifiers in the item detail view.'),
          GuideBlock.header('Weight'),
          GuideBlock('Armor has a weight value. High total weight reduces speed and dodge. Casters in heavy armor lose mobility — equip light or medium armor on spellcasters.'),
        ],
      ),
      GuideArticle(
        title: 'Devotion & Perks',
        blocks: [
          GuideBlock('Heroes who follow a faith accumulate Devotion from combat victories and faith site visits. Devotion unlocks Devotion Perks — passive bonuses chosen by you.'),
          GuideBlock('Each faith has three perk tiers. Reaching each tier grants a choice from several options. Choices are permanent.'),
          GuideBlock.header('The Five Faiths'),
          GuideBlock('The Luminant Church: order and light, defensive and healing perks. The Pale Court: death and remembrance, XP and recovery perks. The Old Ways: nature and cycles, survivability and foraging perks. The Ashen Rite: void and ash, damage and cursing perks. The Compact of Saints: pragmatic faith, gold and social perks.'),
          GuideBlock.header('Faith Sites'),
          GuideBlock('Churches, shrines, and cult sites on the map grant devotion when visited. Each site type benefits one or two specific faiths. A hero with no matching faith still gains the expedition XP — they just do not gain devotion from the site.'),
        ],
      ),
    ],
  ),

  // ── CLASSES & SPELLS ───────────────────────────────────────────────────────
  GuideCategory(
    id: 'spells',
    title: 'Classes & Spells',
    icon: '✦',
    articles: [
      GuideArticle(
        title: 'Caster Classes',
        blocks: [
          GuideBlock('Four hero classes can cast spells: Mage, Warlock, Necromancer, and Priest. Non-casters cannot use spells or spell tomes.'),
          GuideBlock.header('Mage'),
          GuideBlock('Intellectual and precise. Mages deal elemental damage, construct arcane defenses, and transmute matter. Three archetypes: Elementalist (raw power bursts), Runescribe (sustained arcane force), Alchemist (acid, fire compounds, and life conversion).'),
          GuideBlock.header('Warlock'),
          GuideBlock('Hungry and deliberate. Warlocks drain life, bargain with void entities, and curse their enemies. Archetypes: Demonologist (summoning and hellfire), Hexblade (shadow-infused melee), Occultist (eldritch blasts and dark rituals).'),
          GuideBlock.header('Necromancer'),
          GuideBlock('Patient and clinical. Necromancers raise the dead, afflict the living, and operate at the boundary of existence. Archetypes: Lich (soul magic and arcane death), Death Knight (bone armor and reaping strikes), Plague Doctor (disease, poison, and pestilence).'),
          GuideBlock.header('Priest'),
          GuideBlock('Driven and principled. Priests channel divine will to damage the unholy and protect the faithful. Archetypes: Inquisitor (holy fire and condemnation), Hospitaller (mass healing and miracles), Zealot (divine fury and wrath).'),
        ],
      ),
      GuideArticle(
        title: 'Learning Spells',
        blocks: [
          GuideBlock('Casters begin with a small selection of tier 1 spells. New spells are learned in two ways: leveling up and buying tomes.'),
          GuideBlock.header('Level-Up Auto-Learn'),
          GuideBlock('When a caster levels up, they automatically learn one spell from their class appropriate to their level. Tier 1 spells are granted at lower levels, tier 2 at level 5+, tier 3 at level 15+. The specific spell is random within the tier pool.'),
          GuideBlock.header('Spell Tomes'),
          GuideBlock('Traders at towns sell spell tomes — books containing one spell. Tomes are filtered to spells your party does not already know, so you will never see a tome for a spell you have.'),
          GuideBlock('Tome prices: 80–130g (tier 1), 160–260g (tier 2), 320–520g (tier 3). Tier 2 tomes appear at depth 3+ towns; tier 3 at depth 5+.'),
          GuideBlock.header('Spell Pool'),
          GuideBlock('There are 143 total spells across the four caster classes — roughly 34–39 per class, organized in tier 1 (basics), tier 2 (subclass specializations), and tier 3 (mastery spells). No class can learn another class\'s spells.'),
        ],
      ),
      GuideArticle(
        title: 'Spell Slots & Mana',
        blocks: [
          GuideBlock('A caster can have many spells learned but can only equip a limited number for combat. Equipped spells fill Spell Slots.'),
          GuideBlock('Spell slots: 2 at level 1, 3 at level 5, 4 at level 10, 5 at level 15, 6 at level 20.'),
          GuideBlock.header('Mana'),
          GuideBlock('Each spell costs mana to cast. Max mana is determined by Intelligence and level. Mana is consumed in combat; casters recover 20% max mana between encounters. Inn rest restores mana to full.'),
          GuideBlock('If a caster runs out of mana they fall back to basic attacks — still useful, but significantly weaker than spells. Plan mana-heavy builds for shorter dungeons or bring an inn visit.'),
          GuideBlock.header('Choosing Spells'),
          GuideBlock('Open the Party screen, select a hero, and tap their equipped spells to manage the loadout. Mix offensive and defensive spells. A tier 3 spell that costs 14 mana is useless if your hero runs dry in the second encounter.'),
        ],
      ),
      GuideArticle(
        title: 'Spell Types',
        blocks: [
          GuideBlock('Every spell has an effect type that determines what it does in combat.'),
          GuideBlock('Damage: single-target hit. DamageAll: hits all enemies. DoT: single target damage over time for several rounds. DoTAll: damage over time applied to all enemies. Heal: heals the most injured hero. HealAll: heals all heroes. Drain: damages an enemy and heals the caster for part of the damage. Buff: raises the caster\'s defense for a number of rounds. Debuff: reduces one enemy\'s defense. Dispel: strips one supernatural trait from an enemy. Summon: calls a creature that fights alongside the party for several rounds.'),
          GuideBlock.header('Spell Tier Differences'),
          GuideBlock('Tier 1 spells are efficient but moderate in power. Tier 2 spells hit harder or affect all enemies but cost more mana. Tier 3 spells are devastating — high mana cost, high impact. A well-timed tier 3 can end an encounter by itself.'),
        ],
      ),
    ],
  ),

  // ── HOLDINGS ───────────────────────────────────────────────────────────────
  GuideCategory(
    id: 'holdings',
    title: 'Holdings',
    icon: '⌂',
    articles: [
      GuideArticle(
        title: 'Properties',
        blocks: [
          GuideBlock('Holdings are properties you own in Ashenvale. Each produces daily income and can be upgraded with addons that change or expand its function.'),
          GuideBlock('Income is paid at dawn each in-game day. The number of days per expedition depends on expedition duration — longer expeditions advance the calendar faster.'),
          GuideBlock.header('Property Types'),
          GuideBlock('Tavern: steady income, addon options that improve recruiting and supply quality. General Store: income plus supply discounts and contact networks. Blacksmith: weapon and armor quality bonuses for your party. Library: XP bonuses, codex unlocks. Church: devotion income for faithful heroes. Guild Hall: unlock specialist hero types. Warehouse: storage and trade bonuses.'),
          GuideBlock.header('Buying Properties'),
          GuideBlock('Open Holdings and tap the "Buy" button on any available slot. Properties cost gold to purchase. Some require a minimum depth reached before they become available.'),
        ],
      ),
      GuideArticle(
        title: 'Addons',
        blocks: [
          GuideBlock('Each property can be upgraded with Addons — permanent improvements that change or add to what the property does. Most properties have 3–4 possible addons.'),
          GuideBlock('Addons are not mutually exclusive by default, but some slots are limited. Buy the ones that fit your strategy.'),
          GuideBlock.header('Examples'),
          GuideBlock('Tavern Stage: wandering hero recruits arrive one level higher. Brewery: monasteries you visit gain a small trader stock. General Store Contacts: one extra trader item appears at every town visit. Library Archive: a bonus XP multiplier applies to all expeditions. Church Bell: devotion accumulated per visit is increased.'),
        ],
      ),
    ],
  ),

  // ── THE LORE ───────────────────────────────────────────────────────────────
  GuideCategory(
    id: 'lore',
    title: 'The Lore',
    icon: '†',
    articles: [
      GuideArticle(
        title: 'The Opening',
        blocks: [
          GuideBlock('Thirty-two years ago, something happened in the east. The Church\'s records call it The Opening — a threshold event that fractured the boundary between the material world and something else.'),
          GuideBlock('The immediate result was catastrophic: the Charred Cathedral was destroyed in a single night, the ash began to fall, and the eastern provinces became what they are now. The long-term result is still unfolding.'),
          GuideBlock.header('The Grimhaven Crusade'),
          GuideBlock('The Church\'s response was military. High Inquisitor Verdane led fourteen thousand soldiers to Grimhaven to push back whatever had come through. The battle lasted six hours. None of the soldiers died — they simply became something else. They are still there. Verdane leads them. He has not spoken since.'),
          GuideBlock('This failure ended the Church\'s aggressive eastern policy. The road remains, but officially it is now maintained for "scholarly purposes."'),
        ],
      ),
      GuideArticle(
        title: 'The Five Faiths',
        blocks: [
          GuideBlock('Five distinct religious traditions operate in the Reaches. None of them agree on the cause of The Opening, but all of them have an interpretation.'),
          GuideBlock.header('The Luminant Church'),
          GuideBlock('The dominant institutional faith. Organized, politically powerful, and defensive. The Church officially classifies The Opening as divine punishment for theological deviation — specifically the Old Ways. Most historians note the timing does not support this reading. The Church does not have historians anymore.'),
          GuideBlock.header('The Pale Court'),
          GuideBlock('A tradition organized around the cataloguing of death. The Pale Court keeps records of every person who has died in the Reaches — or tries to. Their three-century archive is the most complete census of mortality ever assembled. They believe consciousness persists after death and that proper recording is a form of respect.'),
          GuideBlock.header('The Old Ways'),
          GuideBlock('The pre-Church tradition of the land — nature cycles, the ancestors, the standing stones. The Church suppressed it for two centuries with limited success. Old Ways practitioners did not disappear; they moved. The deep forest, the moorland, the shrines the demolition crews could not knock down.'),
          GuideBlock.header('The Ashen Rite'),
          GuideBlock('The newest faith, organized after The Opening specifically to study it. The Rite holds that the ash is sacred — the residue of something transforming, not dying. They have been studying the east for thirty years and believe they are close to understanding what The Opening was for. Nobody else finds this reassuring.'),
          GuideBlock.header('The Compact of Saints'),
          GuideBlock('A merchant faith that venerates pragmatic historical figures — people who got things done. Officially ecumenical. Practically: worshipped by traders and road-workers who need saints who understand that things cost money and sometimes you have to compromise.'),
        ],
      ),
      GuideArticle(
        title: 'The Codex',
        blocks: [
          GuideBlock('The Codex screen (accessible from the road screen) contains lore entries for every location you have visited. Each entry is drawn from the historical record — or what passes for one in the Reaches.'),
          GuideBlock('Codex entries are written in the same voice as the road itself: dry, specific, and occasionally deeply alarming.'),
          GuideBlock('The Codex fills as you explore. Visiting Grimhaven unlocks its entry. You will not enjoy reading it.'),
        ],
      ),
    ],
  ),

];
