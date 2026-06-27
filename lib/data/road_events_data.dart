import '../models/road_event.dart';
import '../models/enums.dart';

const List<RoadEvent> allRoadEvents = [

  // ─── ORIGINAL EVENTS ──────────────────────────────────────────────────────

  RoadEvent(
    id: 'wounded_soldier',
    title: 'A Wounded Soldier',
    description: 'A soldier in tattered colors lies by the road, breathing shallowly. His wounds are fresh and his eyes are desperate.',
    choices: [
      EventChoice(
        label: 'Aid him  (–20g)',
        outcome: 'You spend coin on poultices and water. He mumbles thanks before losing consciousness. A good deed on a dark road.',
        effect: EventEffect(goldDelta: -20, devotionDelta: 6),
      ),
      EventChoice(
        label: 'Ignore him',
        outcome: 'You ride past. The road does not forgive, but neither does it judge.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Search his pockets',
        outcome: 'You take what coin he has. He doesn\'t have the strength to resist. The road is watching.',
        effect: EventEffect(goldDelta: 40, devotionDelta: -10),
      ),
    ],
  ),

  RoadEvent(
    id: 'bandit_toll',
    title: 'Bandits at the Crossroads',
    description: 'A dozen armed men block the road ahead. Their leader grins and names his price: forty gold, or your blood.',
    choices: [
      EventChoice(
        label: 'Pay the toll  (–40g)',
        outcome: 'You pay. They step aside with mocking bows. Coin spent is life kept.',
        effect: EventEffect(goldDelta: -40),
      ),
      EventChoice(
        label: 'Fight through',
        outcome: 'The fight is short and brutal. You win, but your people take wounds in the process.',
        effect: EventEffect(goldDelta: 55, partyDamage: 12),
      ),
      EventChoice(
        label: 'Bluff your way through',
        outcome: 'You name a title you don\'t have and stare them down. Half leave. The other half take a different kind of payment.',
        effect: EventEffect(goldDelta: -15, devotionDelta: -3),
      ),
    ],
  ),

  RoadEvent(
    id: 'church_bells',
    title: 'Church Bells at Dusk',
    description: 'Somewhere across the dark fields, a church bell rings the vesper hour. The sound carries strange and clear. Your heroes with faith feel something stir.',
    choices: [
      EventChoice(
        label: 'Pause and listen',
        outcome: 'You stop a while on the road. The bells fade. Your faithful companions seem steadier for it.',
        effect: EventEffect(devotionDelta: 8),
      ),
      EventChoice(
        label: 'Press on',
        outcome: 'The bells fade behind you. Time is gold.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'fallen_merchant',
    title: 'The Fallen Merchant',
    description: 'A merchant\'s cart has overturned in the ditch. The man is unharmed but desperate, his goods scattered across the mud. He begs for help.',
    choices: [
      EventChoice(
        label: 'Help him recover his goods',
        outcome: 'An hour of labor and everything is back in the cart. He presses a purse on you with shaking hands.',
        effect: EventEffect(goldDelta: 35, devotionDelta: 4),
      ),
      EventChoice(
        label: 'Take what you need and leave',
        outcome: 'He shouts curses at your backs. You ride on with fuller packs.',
        effect: EventEffect(goldDelta: 60, devotionDelta: -8),
      ),
      EventChoice(
        label: 'Ignore the mess entirely',
        outcome: 'Not your problem. The road is long.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'strange_altar',
    title: 'The Strange Altar',
    description: 'In a clearing off the road stands a rough-hewn altar, old and stained with something dark. Fresh offerings have been left. Something about it raises the hair on your neck.',
    choices: [
      EventChoice(
        label: 'Pray at the altar',
        outcome: 'You pray. The silence answers. Your devoted feel a cold power pass through them.',
        effect: EventEffect(devotionDelta: 10, partyDamage: 5),
      ),
      EventChoice(
        label: 'Destroy the altar  (–15g, materials)',
        outcome: 'It takes time and effort to pull it apart. Your faithful companions breathe easier for it.',
        effect: EventEffect(goldDelta: -15, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Take the offerings',
        outcome: 'Coin and trinkets left for something old. You take them. The air feels heavier afterward.',
        effect: EventEffect(goldDelta: 45, devotionDelta: -12),
      ),
    ],
  ),

  RoadEvent(
    id: 'plague_cart',
    title: 'The Plague Cart',
    description: 'A covered cart rolls slowly ahead. The driver wears a cloth over his face. Groans come from within. Plague, or something that looks like it.',
    choices: [
      EventChoice(
        label: 'Give coin for medicine  (–50g)',
        outcome: 'You purchase what herbs and poultices the driver carries. Your party is poorer but cleaner.',
        effect: EventEffect(goldDelta: -50, partyHeal: 20),
      ),
      EventChoice(
        label: 'Ride around it quickly',
        outcome: 'You give the cart a wide berth. No sense tempting fate.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Investigate',
        outcome: 'You open the cart. The occupants reach for you. Not plague — something worse. Your party takes wounds getting clear.',
        effect: EventEffect(goldDelta: 25, partyDamage: 18),
      ),
    ],
  ),

  RoadEvent(
    id: 'tax_collector',
    title: 'The King\'s Tax Collector',
    description: 'A man in official colors blocks the road with two guards. He presents a writ demanding tithe from all who travel this road. The writ looks genuine.',
    choices: [
      EventChoice(
        label: 'Pay the tithe  (–60g)',
        outcome: 'You pay. He marks a ledger and waves you through. Legal robbery.',
        effect: EventEffect(goldDelta: -60),
      ),
      EventChoice(
        label: 'Bribe him quietly  (–30g)',
        outcome: 'The ledger entry disappears for the right price. He pockets the coin without a word.',
        effect: EventEffect(goldDelta: -30),
      ),
      EventChoice(
        label: 'Intimidate him',
        outcome: 'You let your weapons speak. He decides this road isn\'t worth the trouble and steps aside.',
        effect: EventEffect(partyDamage: 5, devotionDelta: -4),
      ),
    ],
  ),

  RoadEvent(
    id: 'crossroads_ghost',
    title: 'The Crossroads Shade',
    description: 'At a fork in the road, a pale figure blocks the way. It has no face — only a hand, extended, waiting.',
    choices: [
      EventChoice(
        label: 'Place gold in its hand  (–30g)',
        outcome: 'The coin falls through the ghost and into the earth. The shape fades. The road is clear.',
        effect: EventEffect(goldDelta: -30, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Drive it away with faith',
        outcome: 'Your devoted heroes speak the words. The shade recoils and dissolves into the evening air.',
        effect: EventEffect(devotionDelta: -5),
      ),
      EventChoice(
        label: 'Force through',
        outcome: 'You charge. The thing tears at your people as you pass. Cold wounds — the kind that linger.',
        effect: EventEffect(partyDamage: 15),
      ),
    ],
  ),

  RoadEvent(
    id: 'abandoned_camp',
    title: 'Abandoned Camp',
    description: 'A campsite sits just off the road, recently vacated. Bedrolls, cooking gear, and a fire still smoldering. Whoever was here left in a hurry.',
    choices: [
      EventChoice(
        label: 'Loot the camp',
        outcome: 'You take what\'s useful. Coin, rations, and a small blade.',
        effect: EventEffect(goldDelta: 45, weaponRewardId: 'seax'),
      ),
      EventChoice(
        label: 'Set up and rest',
        outcome: 'Your party uses the camp to recover. Whoever fled it never came back.',
        effect: EventEffect(partyHeal: 25),
      ),
      EventChoice(
        label: 'Leave it and move on',
        outcome: 'Something about it feels wrong. The road is safer.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'pilgrim_request',
    title: 'The Pilgrim\'s Request',
    description: 'An old pilgrim with no horse and worn sandals asks if your party is headed anywhere near the monastery on the hill. He has walked from the coast.',
    choices: [
      EventChoice(
        label: 'Escort him to the monastery',
        outcome: 'The detour costs you half a day, but the old man\'s prayers over you at the gate are worth more.',
        effect: EventEffect(devotionDelta: 12, goldDelta: -10),
      ),
      EventChoice(
        label: 'Give him coin for the road  (–20g)',
        outcome: 'You can\'t take him there, but you give him enough for a horse. He blesses you and walks on.',
        effect: EventEffect(goldDelta: -20, devotionDelta: 6),
      ),
      EventChoice(
        label: 'Turn him away',
        outcome: 'He nods once and continues walking. You have your own road.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'dark_omen',
    title: 'Dark Omens',
    description: 'Ravens circle overhead in a perfect ring. The horses grow skittish. Three crows land in the road and watch you pass. Your faithful heroes murmur quietly.',
    choices: [
      EventChoice(
        label: 'Make an offering to avert the omen  (–25g)',
        outcome: 'You leave coin and bread at the roadside. The ravens scatter. Your party breathes easier.',
        effect: EventEffect(goldDelta: -25, devotionDelta: 7),
      ),
      EventChoice(
        label: 'Ignore it',
        outcome: 'Superstition. You ride through. The ravens follow for a while, then they don\'t.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Read the omen',
        outcome: 'Your most faithful hero studies the birds\' flight. The meaning is dark but clear. A warning, not a curse.',
        effect: EventEffect(devotionDelta: 4, partyDamage: 5),
      ),
    ],
  ),

  RoadEvent(
    id: 'blood_moon',
    title: 'The Blood Moon',
    description: 'The moon rises red over the Ashen Road, vast and low and wrong-looking. An old soldier in your group says it means war. He\'s said it twice before and been right both times.',
    choices: [
      EventChoice(
        label: 'Rest and recover under it',
        outcome: 'You make camp and let the moon pass. Your injured feel the strange warmth of it.',
        effect: EventEffect(partyHeal: 30),
      ),
      EventChoice(
        label: 'Keep marching',
        outcome: 'No time for omens. The road doesn\'t wait.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'fortune_teller',
    title: 'The Fortune Teller',
    description: 'A wagon on the roadside, hung with lanterns. A woman with silver rings beckons from the door. "Cross my palm with silver and I\'ll tell you where the road leads."',
    choices: [
      EventChoice(
        label: 'Pay for a reading  (–30g)',
        outcome: 'She speaks of gold, iron, and a choice that costs more than coin. Then she sends you on your way.',
        effect: EventEffect(goldDelta: -30, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Rob her wagon',
        outcome: 'She watches calmly as you take her earnings. At the door she says, "The road remembers thieves."',
        effect: EventEffect(goldDelta: 55, devotionDelta: -14),
      ),
      EventChoice(
        label: 'Ride past',
        outcome: 'The road ahead is the only fortune you need.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'poisoned_well',
    title: 'The Poisoned Well',
    description: 'A village well with a crude skull scratched into the stone. Three dead crows lie at the base. Your party is thirsty.',
    choices: [
      EventChoice(
        label: 'Risk drinking from it',
        outcome: 'Most of your party shrugs it off. A couple feel worse for wear.',
        effect: EventEffect(partyDamage: 10),
      ),
      EventChoice(
        label: 'Find another source  (–15g to buy water)',
        outcome: 'You pay a farmer down the road. Safe, clean, and expensive.',
        effect: EventEffect(goldDelta: -15),
      ),
      EventChoice(
        label: 'Clean the well  (–20g, time)',
        outcome: 'An hour of labor. When you leave, the well is clear and the village will drink safely.',
        effect: EventEffect(goldDelta: -20, devotionDelta: 8),
      ),
    ],
  ),

  RoadEvent(
    id: 'treasure_map',
    title: 'A Dead Traveler\'s Map',
    description: 'A body by the road holds no coin — but inside his coat is a rough map with an X marked in the hills. Scratched beside it in blood: "worth it."',
    choices: [
      EventChoice(
        label: 'Investigate the marked spot',
        outcome: 'Three hours off the road. Whatever was buried there was dug up by someone else years ago. A rusted iron box and a crow.',
        effect: EventEffect(partyDamage: 5, devotionDelta: -2),
      ),
      EventChoice(
        label: 'Sell the map in the next town  (+30g)',
        outcome: 'Someone else\'s fool\'s errand, for coin.',
        effect: EventEffect(goldDelta: 30),
      ),
      EventChoice(
        label: 'Leave it with the body',
        outcome: 'Not your treasure. Not your grave. You leave both where you found them.',
        effect: EventEffect(devotionDelta: 3),
      ),
    ],
  ),

  // ─── LORE EVENTS ──────────────────────────────────────────────────────────

  RoadEvent(
    id: 'road_milestone',
    title: 'The Road\'s Milestone',
    description: 'A stone marker stands at the roadside, carved with the Church\'s flame sigil and a number that no longer corresponds to any known distance. Beneath the flame, someone has scratched in rough letters: "Built on ash. Leads to ash."',
    choices: [
      EventChoice(
        label: 'Read the inscription aloud',
        outcome: 'Your most literate hero reads it to the party. The words carry on the empty road longer than they should. Whoever carved them knew the history of this place.',
        effect: EventEffect(devotionDelta: 4),
      ),
      EventChoice(
        label: 'Note the number and move on',
        outcome: 'Milestones on this road count to something that no longer exists at the other end. Useful to remember.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Scratch out the Church\'s flame',
        outcome: 'You deface the marker. A small act of old spite. The scratched inscription beneath it now stands alone.',
        effect: EventEffect(devotionDelta: -8),
      ),
    ],
  ),

  RoadEvent(
    id: 'ash_from_east',
    title: 'Ash from the East',
    description: 'The wind turns and carries ash from somewhere beyond the road\'s end — grey, weightless, and faintly warm. It coats your party\'s shoulders like snow that does not melt. This is not the ash of fires. No one says what kind of ash it is.',
    choices: [
      EventChoice(
        label: 'Pray against it',
        outcome: 'Your faithful heroes speak words of warding. The ash settles on your shoulders regardless, unimpressed by theology.',
        effect: EventEffect(devotionDelta: 6),
      ),
      EventChoice(
        label: 'Collect a vial of it  (+25g when sold)',
        outcome: 'The ash is soft between your fingers, like old bone ground fine. Someone in the next town will pay to study it — or pray over it.',
        effect: EventEffect(goldDelta: 25),
      ),
      EventChoice(
        label: 'Push through without stopping',
        outcome: 'Nothing to be done about it. The road goes east and the ash comes west. You go east anyway.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'old_ways_shrine',
    title: 'A Hidden Shrine',
    description: 'A clearing just off the road, easy to miss. Standing stones, moss-covered, with fresh offerings at their base — bread, grey feathers, three copper coins arranged in a triangle. The shrine is very old. The offerings are from this morning.',
    choices: [
      EventChoice(
        label: 'Leave an offering  (–15g)',
        outcome: 'The road-god who watched over travelers before the Church had a name you cannot speak anymore. The gesture is understood anyway. Something loosens in the air.',
        effect: EventEffect(goldDelta: -15, devotionDelta: 10, targetFaith: FaithType.oldWays),
      ),
      EventChoice(
        label: 'Take the offerings',
        outcome: 'The coins feel warm in your palm. Warmer than the weather accounts for. You take them and leave quickly.',
        effect: EventEffect(goldDelta: 30, devotionDelta: -12, targetFaith: FaithType.oldWays),
      ),
      EventChoice(
        label: 'Mark the location and move on',
        outcome: 'Useful to know there are Old Ways practitioners nearby. People who keep the old shrines tend to keep good maps and honest counsel.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'grimhaven_veteran',
    title: 'The Man Who Came Back',
    description: 'A man in the corner of a roadside inn, staring at his hands. His armor is fourteen years old and he maintains it with obsessive care. The innkeeper says he has been there for a month, paying his board by washing dishes after dark.',
    choices: [
      EventChoice(
        label: 'Buy him a drink and listen  (–15g)',
        outcome: 'He talks in fragments — formation orders, the voice that came from Grimhaven\'s walls before the battle, how Verdane\'s visor opened and nothing was behind it. He has told this story to everyone who passes. No one stays to hear the end.',
        effect: EventEffect(goldDelta: -15, devotionDelta: 5, partyDamage: 8),
      ),
      EventChoice(
        label: 'Ask what he saw',
        outcome: 'He doesn\'t wait for you to buy him anything. He tells everyone. He will be telling it when he dies. The story is worse than you expected.',
        effect: EventEffect(partyDamage: 8),
      ),
      EventChoice(
        label: 'Leave him to it',
        outcome: 'Whatever happened at Grimhaven is not your business. The road ahead is your business. You keep walking.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'saint_aldric_cup',
    title: 'A Saint\'s Relic',
    description: 'A peddler on the road is selling, among other things, a battered tin cup he claims belonged to Saint Aldric — the bandit-king of Greywater who spent thirty years building the city he spent twenty years robbing. He has documentation. The documentation is obviously forged. The cup itself is genuinely old.',
    choices: [
      EventChoice(
        label: 'Buy the cup  (–40g)',
        outcome: 'Forged papers or not, Aldric was real and the cup has been prayed over by enough people that authenticity hardly matters anymore. Your faithful heroes hold it with care.',
        effect: EventEffect(goldDelta: -40, devotionDelta: 12, targetFaith: FaithType.compactOfSaints),
      ),
      EventChoice(
        label: 'Examine it and decline',
        outcome: 'The cup is old. The saint is older. You have no room for tin cups, whatever they once held.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Point out the forgery, negotiate  (–20g)',
        outcome: 'The peddler thanks you for not having him arrested and drops his price considerably. A genuine antique at an honest rate.',
        effect: EventEffect(goldDelta: -20, devotionDelta: 7, targetFaith: FaithType.compactOfSaints),
      ),
    ],
  ),

  RoadEvent(
    id: 'pale_court_procession',
    title: 'The Procession',
    description: 'A funeral procession moves slowly along the road: eight people in grey cloaks, carrying a shrouded body on a litter. Pale Court tradition requires seven hours of walking before burial. They are four hours in. They ask only that you not rush past and scatter the ash they are laying.',
    choices: [
      EventChoice(
        label: 'Walk with them a while',
        outcome: 'You slow your pace and join the procession for an hour. The Pale Court do not speak during the walk, but they nod at you when you part. The dead are accounted for.',
        effect: EventEffect(devotionDelta: 8, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Offer a crossing-toll coin  (–10g)',
        outcome: 'An old custom, older than the Church. The coin goes in the shroud. The practitioners nod. The dead are provided for.',
        effect: EventEffect(goldDelta: -10, devotionDelta: 5, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Ride carefully around them',
        outcome: 'They step aside without complaint. The dead wait for no one and neither do you.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'void_touched_ground',
    title: 'The Field That Doesn\'t Grow',
    description: 'A field beside the road where nothing grows. Not barren — wrong. The soil is the right color, properly worked, but what was planted here did not come up. A farmer\'s tools lean against a fence that no longer holds a farm. This field has failed for three years running.',
    choices: [
      EventChoice(
        label: 'Examine the soil',
        outcome: 'Your most observant hero crouches and studies. The soil is fine — softer than it should be, and faintly warm, like ash pressed into earth until it looks like dirt. The ash is patient.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Ask at the nearest village  (–10g for information)',
        outcome: 'The farmer left last year. No one will take the land at any price. Three neighboring fields are beginning to show the same symptoms. The village does not say the word "void" aloud.',
        effect: EventEffect(goldDelta: -10),
      ),
      EventChoice(
        label: 'Pray over it',
        outcome: 'Your faithful heroes say whatever prayers seem appropriate for a field. The field does not respond. The words feel less certain here than they do anywhere else on the road.',
        effect: EventEffect(devotionDelta: -5),
      ),
    ],
  ),

  RoadEvent(
    id: 'refugees_from_east',
    title: 'Children of the Road',
    description: 'A group of seven — three adults, four children — walking west. They carry everything they own in two bundles. One of the adults has burns on his arms that match no fire you have seen. They are from somewhere east of Salthaven and will say nothing more than that.',
    choices: [
      EventChoice(
        label: 'Give them enough to reach safety  (–50g)',
        outcome: 'Enough coin for a week of road and passage west. They accept without meeting your eyes. People from that far east have stopped expecting kindness and are simply relieved when it comes.',
        effect: EventEffect(goldDelta: -50, devotionDelta: 10),
      ),
      EventChoice(
        label: 'Escort them to the next town',
        outcome: 'Half a day\'s detour. They say nothing on the road. At the gate, the burned man presses a small parcel into your hands — dried meat and an Old Ways charm in grey cord. He says it has kept him alive. You believe him.',
        effect: EventEffect(goldDelta: -5, devotionDelta: 8, partyHeal: 12),
      ),
      EventChoice(
        label: 'Let them pass',
        outcome: 'The road moves in both directions. They go west. You go east.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'church_defector',
    title: 'Going the Wrong Way',
    description: 'A man on the road wearing Church robes that have been deliberately altered — the insignia cut away with something sharp, the hems left raw. He is walking east. That itself is strange enough. He explains, if asked, that he has specific business in the direction from which everyone else is running.',
    choices: [
      EventChoice(
        label: 'Let him travel with you awhile',
        outcome: 'He is a former brother, well-trained and surprisingly candid about what the Church knows — and refuses to know — about the east. He parts ways at a crossroads with useful information and a quiet blessing.',
        effect: EventEffect(partyHeal: 10, devotionDelta: 4),
      ),
      EventChoice(
        label: 'Warn him to turn back',
        outcome: 'He thanks you for the concern with complete sincerity and continues east. He has already made his peace with what\'s ahead.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Report him to Church authorities  (+40g reward)',
        outcome: 'The Church pays well for voluntary departures. The former brother is taken quietly. You don\'t ask what happens next.',
        effect: EventEffect(goldDelta: 40, devotionDelta: -12),
      ),
    ],
  ),

  RoadEvent(
    id: 'three_faced_sign',
    title: 'At the Tree Line',
    description: 'Three figures stand at the edge of the forest as your party passes — a young girl, an old woman, and a figure in a grey shroud. They watch without moving. When you look again there are two; then one; then none. Your Pale Court companions fall very quiet, then recite something low and fast under their breath.',
    choices: [
      EventChoice(
        label: 'Make the sign of the Court',
        outcome: 'The formal greeting: two fingers at the brow, then down. Your Court-devoted heroes perform it without being asked. The tree line says nothing back. The tree line rarely does. It is still a courtesy worth making.',
        effect: EventEffect(devotionDelta: 12, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Investigate the tree line',
        outcome: 'Three sets of footprints where the figures stood. They stop where the watchers stopped and do not continue in any direction. The ground is cold under your fingers regardless of the weather.',
        effect: EventEffect(partyDamage: 5),
      ),
      EventChoice(
        label: 'Keep moving',
        outcome: 'Whatever that was, staring at it longer served no one. The road continues.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'inquisitors_list',
    title: 'Old Business',
    description: 'In the ruins of a roadside waystation, your party finds a Church writ — an inquisitor\'s list of persons to be questioned. The list is fifty years old. Several entries are crossed out. One uncrossed entry reads: "Aldric of the Greywater, alias Aldric the Penitent, alias Saint Aldric." Beneath it: "Unavailable for questioning. Deceased."',
    choices: [
      EventChoice(
        label: 'Burn it',
        outcome: 'Some records are better erased. The Church had fifty years to act on that list and did not. You finish the job.',
        effect: EventEffect(devotionDelta: 6),
      ),
      EventChoice(
        label: 'Keep it as leverage  (+5g, useful someday)',
        outcome: 'Information about old Church business keeps indefinitely. You fold it carefully and say nothing.',
        effect: EventEffect(goldDelta: 5),
      ),
      EventChoice(
        label: 'Send it to Greywater  (–20g, courier)',
        outcome: 'Someone in Greywater will want to know their saint was on a list, and that the Church never crossed his name off. You arrange a courier.',
        effect: EventEffect(goldDelta: -20, devotionDelta: 8),
      ),
    ],
  ),

  RoadEvent(
    id: 'old_ways_village',
    title: 'The Village Off the Map',
    description: 'A path off the road leads to a small village that appears on no Church map. The people here keep the Old Ways openly — not defiantly, simply. They haven\'t been found. They offer food, fire, and a night\'s rest. They ask one thing in return: do not mention the turning.',
    choices: [
      EventChoice(
        label: 'Accept and honor the promise',
        outcome: 'You spend an evening. They know things about the road ahead that no map records — old paths, old dangers, old kindnesses. You leave rested and better informed.',
        effect: EventEffect(goldDelta: 15, devotionDelta: 8, targetFaith: FaithType.oldWays, partyHeal: 30),
      ),
      EventChoice(
        label: 'Accept and break the promise  (+80g Church reward)',
        outcome: 'The information is worth money to the right authorities. You have it. You use it. The village probably has time to scatter before anyone arrives.',
        effect: EventEffect(goldDelta: 80, devotionDelta: -20, targetFaith: FaithType.oldWays),
      ),
      EventChoice(
        label: 'Decline the stop',
        outcome: 'Some things are safer not to know the location of. You keep to the road.',
        effect: EventEffect(),
      ),
    ],
  ),

  // ─── COMPANION EVENTS ─────────────────────────────────────────────────────

  RoadEvent(
    id: 'wandering_sellsword',
    title: 'A Wandering Sellsword',
    description: 'A lone fighter sits beside a burned-out campfire at the roadside. Their sword is good, their pack is empty. They watch your party with knowing eyes. "I\'ve been looking for work," they say. "The kind that doesn\'t ask what I\'ve done before."',
    choices: [
      EventChoice(
        label: 'Take them on',
        outcome: 'They shake your hand without ceremony and fall in step behind the party. Whatever their history, they carry their weight.',
        effect: EventEffect(heroJoins: true),
      ),
      EventChoice(
        label: 'Turn them down',
        outcome: 'They nod and settle back by the cold fire. "Another time, then," they say, as though they\'ll still be there.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'lone_survivor',
    title: 'The Lone Survivor',
    description: 'A battered figure stumbles from the trees — gear torn, face bloody, but eyes still sharp. "There were six of us," they say. "The dungeon took the rest." They look at your party with the desperate clarity of someone who knows they cannot go back alone. "I need to keep moving. I\'ll fight."',
    choices: [
      EventChoice(
        label: 'Bring them with you',
        outcome: 'They fall in behind without another word. The road ahead is the only answer either of you has.',
        effect: EventEffect(heroJoins: true),
      ),
      EventChoice(
        label: 'Send them toward the nearest town',
        outcome: 'You give them directions and coin for the road. They accept without argument and walk west.',
        effect: EventEffect(goldDelta: -15),
      ),
    ],
  ),

  RoadEvent(
    id: 'ashen_architect',
    title: 'Who Built the Road',
    description: 'In the foundation stone of an old bridge, your party notices carvings beneath the Church\'s surface markings — older, architectural. Among them: a name in a pre-Church script, and one symbol. Your most learned hero translates: "The Ashwood. My road leads home."',
    choices: [
      EventChoice(
        label: 'Make a rubbing of the stone  (–5g, materials)',
        outcome: 'Whoever built this road was not the Church. The Church named it and claimed it, but they built on someone else\'s foundation. The rubbing is made and kept. The road does not comment.',
        effect: EventEffect(goldDelta: -5, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Dig around the foundation',
        outcome: 'An hour of labor. Beneath the marked stone: a sealed iron box, very old and corroded. Inside: dust and the outline of something long since dissolved. Also one coin of a denomination no mint still makes. It was put there to be found.',
        effect: EventEffect(goldDelta: 50, partyDamage: 3),
      ),
      EventChoice(
        label: 'Read it and move on',
        outcome: 'History is everywhere on this road. Most of it is uncomfortable. You note it and continue.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'lone_missionary',
    title: 'The Preacher',
    description: 'A young priest in plain Church robes is delivering a sermon from a roadside cart, alone, to a field of empty sky. He has been going for some time by the volume of his voice. When your party passes, he shifts and delivers the sermon at you instead.',
    choices: [
      EventChoice(
        label: 'Listen to the sermon',
        outcome: 'He is well-trained and genuinely believes every word. Whatever else the Church has done, this particular priest found his faith honestly. Your devoted heroes listen with more interest than expected.',
        effect: EventEffect(devotionDelta: 4, targetFaith: FaithType.luminantChurch),
      ),
      EventChoice(
        label: 'Debate him  (–15g, time)',
        outcome: 'He is better at argument than you expected. You reach an impasse after an hour. He thanks you with complete sincerity and returns to the empty sky. Something in the exchange sharpens your thinking.',
        effect: EventEffect(goldDelta: -15, devotionDelta: 8, targetFaith: FaithType.luminantChurch),
      ),
      EventChoice(
        label: 'Ride past',
        outcome: 'His voice fades behind you. He keeps going.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'pale_mothers_prophecy',
    title: 'A Page from the Accounting',
    description: 'A traveling scholar offers, for a fee, a page torn from a hand-copied edition of the Pale Mother\'s Accounting — the record she kept of every soul she believed had passed. The page is a passage from the final chapter, written thirty years before The Opening. It describes, in precise detail, what is now the eastern sky.',
    choices: [
      EventChoice(
        label: 'Buy the page  (–35g)',
        outcome: 'The Pale Mother\'s handwriting is cramped and certain. She lists names of the unquiet dead, geographical markers, and a single note at the bottom: "The Three-Faced Queen\'s crown cracked. What came through the crack has no name yet." She wrote it thirty years before anyone saw it.',
        effect: EventEffect(goldDelta: -35, devotionDelta: 10, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Read it in the shop without buying',
        outcome: 'The scholar watches you without complaint. The page describes the east with accuracy that only makes sense if you\'ve already seen it. You hand it back.',
        effect: EventEffect(devotionDelta: 3, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Leave it',
        outcome: 'Prophecy after the fact is just history with better timing. You have enough to carry.',
        effect: EventEffect(),
      ),
    ],
  ),

  // ─── SPELL TOME EVENTS ────────────────────────────────────────────────────

  RoadEvent(
    id: 'abandoned_satchel',
    title: 'An Abandoned Satchel',
    description: 'A scholar\'s satchel lies in the ditch beside the road — good leather, silver clasp, no sign of the owner. Inside, among scattered notes and a broken compass, is a bound scroll sealed with a mage\'s wax mark.',
    choices: [
      EventChoice(
        label: 'Take the scroll',
        outcome: 'The wax mark crumbles when you break it. Whatever ward it held has long since faded. The scroll is intact — Arcane Missile, a basic casting primer. Someone studied this.',
        effect: EventEffect(spellTomeId: 'arcane_missile'),
      ),
      EventChoice(
        label: 'Leave the satchel where it is',
        outcome: 'Not your property. Not your road. You leave it and move on.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'hedge_witch_bargain',
    title: 'The Hedge Witch\'s Bargain',
    description: 'An old woman sits at a crossroads fire, stirring something that smells of iron and rosemary. She looks up without surprise. "I\'ve been waiting," she says. "I have a teaching. The teaching costs something." She holds out her hand.',
    choices: [
      EventChoice(
        label: 'Pay her price  (–60g)',
        outcome: 'You drop the coins without counting them. She teaches for an hour beside the fire, her voice low and precise. By the time she\'s done, you have a tome — her words copied onto the last clean page of her notebook.',
        effect: EventEffect(goldDelta: -60, spellTomeId: 'sacred_word'),
      ),
      EventChoice(
        label: 'Ask what she wants first',
        outcome: '"Sixty gold and your word that you\'ll use it honestly." You barter her down to fifty. She seems unsurprised by that too.',
        effect: EventEffect(goldDelta: -50, spellTomeId: 'sacred_word'),
      ),
      EventChoice(
        label: 'Decline and move on',
        outcome: 'She nods like she expected that. "Next time, then," she says. You don\'t ask what she means by next time.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'dying_warlock',
    title: 'The Dying Warlock',
    description: 'A man in burnt robes sits with his back against a milestone, breathing shallowly. His hands are marked with void-script — Ashen Rite, maybe, or something older. He sees you looking and manages a grim smile. "Nothing left to spend it on," he says, and holds out a small bound codex.',
    choices: [
      EventChoice(
        label: 'Accept the codex and tend his wounds  (–30g)',
        outcome: 'You use what coin you have on clean water and poultice. He thanks you with the quiet sincerity of someone who doesn\'t expect to survive. The codex contains Shadow Bolt — his first working, he says. The one he always went back to.',
        effect: EventEffect(goldDelta: -30, spellTomeId: 'shadow_bolt', partyHeal: 10),
      ),
      EventChoice(
        label: 'Accept the codex and leave him',
        outcome: 'You take what he offers. He doesn\'t protest. "Fair enough," he says, and closes his eyes. You don\'t look back.',
        effect: EventEffect(spellTomeId: 'shadow_bolt', devotionDelta: -5),
      ),
      EventChoice(
        label: 'Decline — you want nothing tied to the Ashen Rite',
        outcome: 'He lowers the codex without argument. "Wise, maybe." He coughs. "Or maybe just cautious. Hard to tell the difference on this road."',
        effect: EventEffect(),
      ),
    ],
  ),

  // ─── NEW THEMATIC NPC EVENTS ─────────────────────────────────────────────

  RoadEvent(
    id: 'the_archivist',
    title: 'The Archivist',
    description: 'A slight figure in grey travelling robes is walking the road ahead of you, making notes in a small leather book. He stops and turns, unsurprised by your company. "I catalogue what I find on this road," he says. "I have recently found something that belongs to no one living. I would prefer it went to someone who intends to live."',
    choices: [
      EventChoice(
        label: 'Accept what he found  (–45g, fair price)',
        outcome: 'You exchange coin for a sealed vellum scroll — a spell, transcribed in a careful, deliberate hand. The archivist records the transaction in his book and continues his notes.',
        effect: EventEffect(goldDelta: -45, spellTomeId: 'arcane_fissure'),
      ),
      EventChoice(
        label: 'Ask what he\'s catalogued on this stretch',
        outcome: 'He reads aloud from his notes for several minutes — deaths, encounters, objects left behind. One entry stops you. You press him on it. He tells you where to look.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Move on without engaging',
        outcome: 'He notes your passing in his book without looking up.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'graveyard_keeper_road',
    title: 'The Graveyard Keeper',
    description: 'An old man is marking a stretch of roadside with small white stones — an unofficial grave-line, the kind that accumulates wherever people die in quantity. He looks up when you approach. "Anyone yours?" he asks.',
    choices: [
      EventChoice(
        label: 'Help him finish the marking',
        outcome: 'You spend an hour placing stones. He speaks the names aloud as you work — names no one has said since the deaths. Your company is quieter for the rest of the day, but steadier.',
        effect: EventEffect(partyHeal: 12, devotionDelta: 8, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Ask what happened here',
        outcome: '"Old business," he says. "From before. The road remembers even when people don\'t." He tells you something useful about what\'s ahead.',
        effect: EventEffect(devotionDelta: 4),
      ),
      EventChoice(
        label: 'Give him coin and move on  (–20g)',
        outcome: 'He takes the coin for the stone-work and nods. The names get marked. Somebody\'s.',
        effect: EventEffect(goldDelta: -20, devotionDelta: 6),
      ),
    ],
  ),

  RoadEvent(
    id: 'pale_court_clerk',
    title: 'The Pale Court Clerk',
    description: 'A young man in pale grey sits at a travelling desk set up beside the road, transcribing from a document into a leather ledger. He doesn\'t look up. "You are expected," he says. "Not by me — by the record. Your company is in the ledger already. I didn\'t put you there."',
    choices: [
      EventChoice(
        label: 'Ask to see your entry',
        outcome: 'He turns the ledger to show you. Your company\'s name, a departure date, an arrival date. The arrival date is tomorrow. "I just copy what\'s given," he says. "I don\'t interpret." He turns the ledger back.',
        effect: EventEffect(devotionDelta: 6, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Bribe him to change the entry  (–50g)',
        outcome: 'He takes the coin without looking at it. "I can change the date," he says. "I cannot change what the record knows." He scratches out the arrival time. You feel the relief immediately, then less so, then not at all.',
        effect: EventEffect(goldDelta: -50, devotionDelta: -4),
      ),
      EventChoice(
        label: 'Tell him he\'s imagining things',
        outcome: '"Possibly," he says, returning to his transcription. "The ledger doesn\'t agree."',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'iron_captain',
    title: 'The Iron Captain',
    description: 'A large figure in battered plate armour has made camp at a crossroads — no banner, no emblem, a face that is half iron plate fixed by rivets over old scarring. He waves you over without standing. "Sit," he says. "I have been here since before this road had a name and I will likely be here after. Tell me what you saw this morning and I\'ll tell you what it means."',
    choices: [
      EventChoice(
        label: 'Share what you\'ve seen on the road',
        outcome: 'He listens without speaking. When you\'re done he says six words that make several previous encounters suddenly explicable. He doesn\'t offer more.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Ask him to join your company',
        outcome: '"I am already in service," he says. He doesn\'t say to what. You don\'t press. He hands you something useful from the pack at his feet and turns back to his fire.',
        effect: EventEffect(goldDelta: 35),
      ),
      EventChoice(
        label: 'Move on without stopping',
        outcome: 'His voice carries easily after you: "Three bends east. Don\'t go left." You note it.',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'void_scholar',
    title: 'The Void Scholar',
    description: 'A woman sits cross-legged on a flat stone off the path, writing in a book that is writing back. The pages turn themselves. She looks up when your company slows. "I\'m cataloguing the places void pressure is highest along this road," she says. "You\'re standing in one of them."',
    choices: [
      EventChoice(
        label: 'Ask what void pressure means for your company',
        outcome: '"Nothing immediate," she says. "Unless you\'re sensitive. Are any of your people sensitive?" She studies your casters for a moment. "Yes. They\'ll want to know." She writes something and tears the page out for you.',
        effect: EventEffect(devotionDelta: 6),
      ),
      EventChoice(
        label: 'Offer to help with her research  (costs time)',
        outcome: 'She teaches you something specific and useful — a technique for reading the landscape that your casters will find applicable tonight. The page she gives you contains a working spell.',
        effect: EventEffect(goldDelta: -10, spellTomeId: 'void_bolt', partyDamage: 5),
      ),
      EventChoice(
        label: 'Move away from the void pressure quickly',
        outcome: 'She watches you go. "Reasonable," she calls after you. "Also noted in the ledger."',
        effect: EventEffect(),
      ),
    ],
  ),

  RoadEvent(
    id: 'forge_exile_road',
    title: 'The Forge Exile',
    description: 'A woman sits at a cold roadside camp, her hands wrapped in burn cloth, her tools laid out carefully despite everything. "I made something the Church couldn\'t classify," she says, before you ask. "They called it profane. I called it accurate. They kept the forge." She looks at your equipment with professional attention.',
    choices: [
      EventChoice(
        label: 'Hire her to repair your arms  (–30g)',
        outcome: 'She works fast and without comment. The quality is remarkable. Her hands shake slightly but the weld lines are perfect.',
        effect: EventEffect(goldDelta: -30, partyHeal: 18),
      ),
      EventChoice(
        label: 'Ask what she made',
        outcome: '"A blade that kept a record of each hand it passed through. Genealogy of violence, I called it." She shows you the burn scars on her palms. "The Church had a different name for it."',
        effect: EventEffect(devotionDelta: -3),
      ),
      EventChoice(
        label: 'Give her coin to start again  (–40g)',
        outcome: 'She looks at the coin for a long moment. "I\'ll remember this," she says. You believe her entirely.',
        effect: EventEffect(goldDelta: -40, devotionDelta: 10),
      ),
    ],
  ),

  // ─── HANKEE ───────────────────────────────────────────────────────────────

  RoadEvent(
    id: 'hankee',
    title: 'Hankee of the Road',
    description: 'A small dwarf woman with a crown of blonde hair and vivid blue vestments stands square in the middle of the road, arms folded. She regards your party with the deep suspicion of someone who has been wronged by travelers before. Then her nostrils flare.\n\n"You smell like elderberries!"\n\nA log the size of a mill beam rolls out of the treeline without warning and strikes her with a sound like a church door closing. She does not get up. The road is quiet. A coinpurse and a blade lie in the mud beside her.',
    choices: [
      EventChoice(
        label: 'Collect her belongings',
        outcome: 'You gather what she left behind. Sixty-nine gold coins and a sword. The elderberry accusation dies with her.',
        effect: EventEffect(
          goldDelta: 69,
          weaponRewardPool: [
            'seax', 'viking_sword', 'arming_sword', 'falchion', 'longsword', 'estoc', 'messer',
          ],
        ),
      ),
    ],
  ),

];
