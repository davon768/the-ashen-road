import '../models/road_event.dart';
import '../models/enums.dart';

class TravelEvent {
  final String id;
  final String title;
  final String description;
  final List<EventChoice> choices;

  const TravelEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.choices,
  });
}

// ─── TOWN-BOUND EVENTS ───────────────────────────────────────────────────────

const _townEvents = [
  TravelEvent(
    id: 'tt_caravan',
    title: 'A Merchant Caravan',
    description: 'A slow caravan blocks the road ahead — wagons heaped with goods, nervous outriders watching the tree-line. The lead drover calls back: "Safer with numbers. Stay with us a spell?"',
    choices: [
      EventChoice(
        label: 'Travel with them',
        outcome: 'You match the caravan\'s pace. The drover presses coin on you for the company — dull work, but honest.',
        effect: EventEffect(goldDelta: 20),
      ),
      EventChoice(
        label: 'Push ahead',
        outcome: 'You move past with a nod and leave them to their pace.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Take one of their purses',
        outcome: 'The outriders put up more fight than expected. You take what you came for, but not without cost.',
        effect: EventEffect(goldDelta: 50, partyDamage: 12, devotionDelta: -8),
      ),
    ],
  ),

  TravelEvent(
    id: 'tt_checkpoint',
    title: 'The Checkpoint',
    description: 'Two road wardens in Church livery have set a temporary post across the road. They ask to see your company\'s writs of passage — which you do not have.',
    choices: [
      EventChoice(
        label: 'Pay the unofficial toll  (–25g)',
        outcome: 'You cross palms. The wardens step aside without ceremony.',
        effect: EventEffect(goldDelta: -25),
      ),
      EventChoice(
        label: 'Invoke the Right of Open Road',
        outcome: 'You cite the old charter. One warden doesn\'t care. The other is embarrassed enough to let you through. It takes time.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Take the field-track around',
        outcome: 'The detour costs supplies but avoids the question entirely.',
        effect: EventEffect(goldDelta: -10),
      ),
    ],
  ),

  TravelEvent(
    id: 'tt_pilgrims',
    title: 'The Pilgrims',
    description: 'A small group of pilgrims rests at a roadside shrine. Their leader rises and offers your company bread and a blessing of safe arrival. Her eyes are steady and kind.',
    choices: [
      EventChoice(
        label: 'Accept their hospitality',
        outcome: 'You share their bread. The blessing is brief and sincere. Your company moves on feeling steadier.',
        effect: EventEffect(partyHeal: 15, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Share coin with them  (–15g)',
        outcome: 'You leave them better provisioned. The leader thanks you by name, though you never gave it.',
        effect: EventEffect(goldDelta: -15, devotionDelta: 10),
      ),
      EventChoice(
        label: 'Press on',
        outcome: 'No time for shrines. The road awaits.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tt_bridge',
    title: 'The Broken Bridge',
    description: 'The bridge over the mill-stream has a section collapsed into the water below. A local farmer is watching from the far bank, arms crossed. "Toll for use of my ford," he says. "Upstream a mile."',
    choices: [
      EventChoice(
        label: 'Pay the ford toll  (–20g)',
        outcome: 'You wade through cold water up to the knee. Quicker than it looked.',
        effect: EventEffect(goldDelta: -20),
      ),
      EventChoice(
        label: 'Argue — the ford is common land',
        outcome: 'You\'re right. He knows it. He moves out of your way without another word.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Swim the stream at the bridge',
        outcome: 'Cold, undignified, and successful. Your gear is heavier for it.',
        effect: EventEffect(partyDamage: 5),
      ),
    ],
  ),

  TravelEvent(
    id: 'tt_beggar',
    title: 'The Roadside Beggar',
    description: 'A man sits in the dust at the milestone, hand out, eyes down. Not asking loudly — just waiting. His coat was good cloth, once. A soldier\'s posture under the ruin of it.',
    choices: [
      EventChoice(
        label: 'Give him coin  (–10g)',
        outcome: 'He takes it without drama. Nods once. When you look back he is gone from the milestone as if he was never there.',
        effect: EventEffect(goldDelta: -10, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Ask what happened to him',
        outcome: '"Same as happens to everyone," he says. "Slower for some." He asks you nothing and takes nothing.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Share your road rations',
        outcome: 'He eats without looking up. "Company\'s good," he says finally. "Thank you for not making it strange."',
        effect: EventEffect(partyDamage: 3, devotionDelta: 7),
      ),
    ],
  ),

  TravelEvent(
    id: 'tt_herald',
    title: 'The Travelling Herald',
    description: 'A herald on a fast horse catches up to your company and slows alongside you. He\'s carrying official dispatches — sealed in three colours. "Anything worth knowing on this road?" he asks. Information flows both ways in this trade.',
    choices: [
      EventChoice(
        label: 'Buy his news  (–25g)',
        outcome: 'He sells you everything useful he knows about the next stretch. Good value — the Church pays him to know things.',
        effect: EventEffect(goldDelta: -25, devotionDelta: 4),
      ),
      EventChoice(
        label: 'Trade rumours',
        outcome: 'You swap what you know. He rides away faster. You walk slower, thinking.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Let him pass',
        outcome: 'He spurs ahead. Whatever news he carried, it wasn\'t yours to know.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tt_dispute',
    title: 'The Merchant Dispute',
    description: 'Two merchants have pulled their carts off the road and are arguing loudly over a broken axle and whose fault it is. Neither is going anywhere soon. One of them calls to you: "Stranger! You\'ve got eyes. Whose fault?"',
    choices: [
      EventChoice(
        label: 'Arbitrate the dispute',
        outcome: 'You listen to both sides with the patience of someone who has done this before. The judgment you give is fair and both know it. The grateful one presses coin on you.',
        effect: EventEffect(goldDelta: 30, devotionDelta: 4),
      ),
      EventChoice(
        label: 'Help fix the axle  (costs time)',
        outcome: 'You spend an hour with a borrowed tool. Both men are embarrassed into gratitude. They split the fee between them.',
        effect: EventEffect(goldDelta: 20, partyDamage: 5),
      ),
      EventChoice(
        label: 'Keep walking',
        outcome: 'The argument follows you down the road for another quarter mile, then fades.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tt_dog',
    title: 'The Stray',
    description: 'A thin dog falls into step with your company at the edge of town — not begging, not playing, just walking alongside with quiet determination. It has something in its mouth: a leather purse, clasped shut.',
    choices: [
      EventChoice(
        label: 'Take the purse',
        outcome: 'The dog releases it without fuss and continues alongside you for another mile before turning back. The purse contains less than you hoped and more than you expected.',
        effect: EventEffect(goldDelta: 35),
      ),
      EventChoice(
        label: 'Follow where the dog leads',
        outcome: 'It takes you two streets off the road to a doorstep, drops the purse, and sits. Someone\'s property, returned. They pay you for the trouble.',
        effect: EventEffect(goldDelta: 25, devotionDelta: 6),
      ),
      EventChoice(
        label: 'Leave it to its business',
        outcome: 'The dog turns back at the town boundary as if it had always planned to. Road animals have their own roads.',
        effect: EventEffect(),
      ),
    ],
  ),
];

// ─── DUNGEON-BOUND EVENTS ────────────────────────────────────────────────────

const _dungeonEvents = [
  TravelEvent(
    id: 'td_camp',
    title: 'The Abandoned Camp',
    description: 'The remains of a previous party\'s camp: a fire-circle of stones, a broken sword, a leather satchel left behind. Nobody went back for any of it. The satchel might still hold something.',
    choices: [
      EventChoice(
        label: 'Search the satchel',
        outcome: 'Coin, a bent blade, scraps of notes in a hand you can\'t read. Worth something at least.',
        effect: EventEffect(goldDelta: 30),
      ),
      EventChoice(
        label: 'Check for traps first',
        outcome: 'There was a snare wire under the satchel flap. You find the coin and step away cleanly.',
        effect: EventEffect(goldDelta: 20),
      ),
      EventChoice(
        label: 'Leave it alone',
        outcome: 'Someone left it. There\'s a reason for everything left behind on this road.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'td_hooded',
    title: 'The Lamp Seller',
    description: 'A hooded figure sits at the side of the path with a lantern and several oil flasks for sale. The prices are fair. They say nothing about where they are going or where they came from.',
    choices: [
      EventChoice(
        label: 'Buy a lamp and oil  (–20g)',
        outcome: 'Good light underground is worth more than gold. The figure takes your coin without looking at it.',
        effect: EventEffect(goldDelta: -20, partyHeal: 10),
      ),
      EventChoice(
        label: 'Ask who they are',
        outcome: 'They tilt their head. "Someone who has been where you are going," they say. You buy nothing. They seem unsurprised.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Keep moving',
        outcome: 'The figure does not call after you.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'td_warning',
    title: 'Warning Markers',
    description: 'The path ahead is lined with carved warning markers — crosses, bones, knotted rope — too many to count. They extend as far as you can see in both directions. Someone maintained these recently.',
    choices: [
      EventChoice(
        label: 'Heed the warnings and take another route',
        outcome: 'The long way round takes time but feels safer. Whatever the markers warned about, you don\'t meet it.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Press through anyway',
        outcome: 'You move through the markers. Nothing happens. Nothing needed to.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Study the markers carefully',
        outcome: 'Old carvings, recent additions. The newest warn about things that sound familiar. You file the information away.',
        effect: EventEffect(devotionDelta: 3),
      ),
    ],
  ),

  TravelEvent(
    id: 'td_injured',
    title: 'The Injured Scout',
    description: 'A man is slumped against a rock beside the path, leg wrapped in cloth gone dark with blood. He looks up at your approach. "Don\'t," he says. "Whatever they sent you for. Don\'t."',
    choices: [
      EventChoice(
        label: 'Tend his wound  (–15g in supplies)',
        outcome: 'You use your road kit on him. He gives you what information he has, which is less reassuring than nothing.',
        effect: EventEffect(goldDelta: -15, partyHeal: 8, devotionDelta: 4),
      ),
      EventChoice(
        label: 'Ask what he encountered',
        outcome: 'He tells you. It matches what you expected, mostly. You press on with your eyes open.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Give him water and push on',
        outcome: 'The most you can do with what you have. He nods. You move.',
        effect: EventEffect(partyHeal: 5),
      ),
    ],
  ),

  TravelEvent(
    id: 'td_torch',
    title: 'The Lit Torch',
    description: 'A torch burns in a bracket set into the rock at the path\'s edge — freshly lit, well-placed, meant to be found. Someone put this here within the last hour. The path beyond it is dark.',
    choices: [
      EventChoice(
        label: 'Take the torch',
        outcome: 'Good light, well-made. Whatever left it for you either wanted you to have it or wanted you to come further in. Both are worth considering.',
        effect: EventEffect(partyHeal: 10),
      ),
      EventChoice(
        label: 'Wait to see who comes for it',
        outcome: 'Nothing comes. After twenty minutes you take it anyway. Patience is a virtue; so is warmth.',
        effect: EventEffect(partyHeal: 8, partyDamage: 3),
      ),
      EventChoice(
        label: 'Leave it and use your own light',
        outcome: 'Not your gift. Not your obligation. You keep moving on your own terms.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'td_graffiti',
    title: 'The Last Warning',
    description: 'Scratched into the rock face beside the path: "TURN BACK — BRECKEN\'S COMPANY, THIRD DAY." Below it, in a different hand and rougher cuts: "BRECKEN IS DEAD. KEEP MOVING. THIRD DAY." Below that, nothing.',
    choices: [
      EventChoice(
        label: 'Add your own mark',
        outcome: 'A name, a date. The record continues. Whoever reads it next will know someone was here and kept going.',
        effect: EventEffect(devotionDelta: 3),
      ),
      EventChoice(
        label: 'Study the dates carefully',
        outcome: 'The gap between the two messages is two days. That\'s how long Brecken lasted after the first warning. You adjust your pace.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Keep moving — don\'t dwell on it',
        outcome: 'Brecken is dead. The dungeon is still there. So are you.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'td_bones',
    title: 'The Old Equipment',
    description: 'A scatter of old bones on the path, long stripped, with rusted equipment beside them. Whatever killed this person did it years ago. Most of the gear is past saving — but a blade in a rotted sheath has kept its edge.',
    choices: [
      EventChoice(
        label: 'Take the blade',
        outcome: 'Old steel, but sound. Someone kept this sharp their whole life. It deserves to be kept sharp again.',
        effect: EventEffect(goldDelta: 10, weaponRewardId: 'seax'),
      ),
      EventChoice(
        label: 'Move the remains off the path',
        outcome: 'The least anyone deserves. You leave the blade with them. Some things aren\'t yours to take.',
        effect: EventEffect(devotionDelta: 8),
      ),
      EventChoice(
        label: 'Step over and keep moving',
        outcome: 'You\'ve seen worse. You will again.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'td_voice',
    title: 'The Voice in the Rock',
    description: 'Something speaks from inside the rock wall to your left — a flat, even voice, human in cadence but not in register. It says your company\'s number. Just the number. How many of you there are. Then it stops.',
    choices: [
      EventChoice(
        label: 'Answer it',
        outcome: 'There is no response. But something shifts in the air. When you camp that night, everyone dreams of a door they have never seen.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Strike the wall where the voice came from',
        outcome: 'Solid rock. Nothing moves. Nothing answers.',
        effect: EventEffect(partyDamage: 4),
      ),
      EventChoice(
        label: 'Move faster and say nothing',
        outcome: 'The number is right. The voice knows it. There is no value in dwelling on how.',
        effect: EventEffect(),
      ),
    ],
  ),
];

// ─── CASTLE-BOUND EVENTS ─────────────────────────────────────────────────────

const _castleEvents = [
  TravelEvent(
    id: 'tc_survivor',
    title: 'The Survivor',
    description: 'A lone figure is moving toward you at speed on the road — haggard, weapons gone, eyes wide. He slows only slightly when he sees you. "Don\'t," he says. "Turn back. Whatever they told you, it\'s worse."',
    choices: [
      EventChoice(
        label: 'Stop him and listen',
        outcome: 'He spends five minutes telling you things you would have preferred not to know, then continues in the other direction at a run.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Give him food and coin  (–15g)',
        outcome: 'He takes the coin and keeps moving. Over his shoulder: "Third floor. Don\'t open the locked door." You write that down.',
        effect: EventEffect(goldDelta: -15),
      ),
      EventChoice(
        label: 'Keep moving',
        outcome: 'He shouts something after you. You don\'t hear it clearly.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tc_farmstead',
    title: 'The Abandoned Farmstead',
    description: 'A cluster of farmsteads, doors open, goods still inside. The occupants left in a hurry. The fields haven\'t been worked in weeks, but the well looks untouched.',
    choices: [
      EventChoice(
        label: 'Search the buildings',
        outcome: 'Scattered coin, preserved food, a whetstone. Nothing that explains why they left.',
        effect: EventEffect(goldDelta: 35),
      ),
      EventChoice(
        label: 'Take only what you need',
        outcome: 'You fill your water and leave the rest. Maybe someone will come back for it.',
        effect: EventEffect(partyHeal: 10, devotionDelta: 4),
      ),
      EventChoice(
        label: 'Move past without stopping',
        outcome: 'You don\'t need to know why they left. You already know.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tc_raven',
    title: 'The Raven',
    description: 'A raven lands on a broken wall beside the road and watches your company with one orange eye. It doesn\'t move as you approach. It has something in its beak — a ring, you think, or a piece of one.',
    choices: [
      EventChoice(
        label: 'Try to take the ring',
        outcome: 'The bird releases it when you reach out. Cold metal, no inscription. The raven stays until you\'ve walked fifty paces, then is gone.',
        effect: EventEffect(goldDelta: 15),
      ),
      EventChoice(
        label: 'Leave an offering of food',
        outcome: 'The Pale Court watches through all dark things. A small observance costs nothing.',
        effect: EventEffect(devotionDelta: 6, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Move past quickly',
        outcome: 'The bird watches until you\'re around the bend. You don\'t look back.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tc_gatehouse',
    title: 'The Broken Gatehouse',
    description: 'The old outer gatehouse stands across the road, the portcullis long since cut from its chains. Beyond it, the keep is visible on the rise. The gatehouse passage is dark and narrow. Something might be waiting in it.',
    choices: [
      EventChoice(
        label: 'Scout ahead before entering',
        outcome: 'Nothing in the gatehouse — today. The passage opens onto a clear courtyard. You note the blind spots.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Move through fast and low',
        outcome: 'You\'re through before anything can react. If anything was there.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Circle around through the rubble',
        outcome: 'The longer way costs your boots on the broken stone but keeps the gatehouse to your left where you can watch it.',
        effect: EventEffect(partyDamage: 5),
      ),
    ],
  ),

  TravelEvent(
    id: 'tc_banner',
    title: 'The Old Colours',
    description: 'A battle standard still hangs from a rusted bracket over the road — sun-bleached to nothing, but the shape of the device beneath is still readable. A house no one has named in three generations.',
    choices: [
      EventChoice(
        label: 'Cut it down and examine the device',
        outcome: 'The cloth disintegrates in your hands, but not before you trace the design. A soldier in your company goes quiet for the rest of the approach.',
        effect: EventEffect(devotionDelta: 4),
      ),
      EventChoice(
        label: 'Leave it to finish fading',
        outcome: 'Things that lasted this long have earned the right to end in their own time.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Salute and move on',
        outcome: 'Whatever was owed to that house, the road acknowledges the gesture.',
        effect: EventEffect(devotionDelta: 6),
      ),
    ],
  ),

  TravelEvent(
    id: 'tc_letter',
    title: 'The Sealed Letter',
    description: 'A letter is nailed to the gate-post ahead — sealed in black wax with no device. Address on the outside, in a careful hand: "For anyone who comes after." The seal is unbroken.',
    choices: [
      EventChoice(
        label: 'Break the seal and read it',
        outcome: 'Instructions for finding a cache. Written by someone who did not expect to return. You follow the directions. They were good to the last word.',
        effect: EventEffect(goldDelta: 45, partyDamage: 6),
      ),
      EventChoice(
        label: 'Leave it sealed',
        outcome: '"For anyone who comes after." You are, technically, not the right person. You move on.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Take it sealed — someone in town might know the hand',
        outcome: 'Probably nothing. Possibly everything. The mystery keeps you company on the road.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tc_lights',
    title: 'Lights in the Tower',
    description: 'One of the upper tower windows shows a light moving — methodical, room to room, like someone searching with a candle. You are nowhere near the castle yet. The keep is at least a mile ahead.',
    choices: [
      EventChoice(
        label: 'Observe the pattern before approaching',
        outcome: 'The light completes its circuit of the upper rooms and stops at the eastern window, facing you. After a moment, it goes out.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Call out to the light',
        outcome: 'Your voice carries further than you intended. The light does not respond but the movement changes — quicker now, purposeful.',
        effect: EventEffect(partyDamage: 6),
      ),
      EventChoice(
        label: 'Ignore it and advance normally',
        outcome: 'The light is gone when you look again. Drafts. Tricks of distance. You believe this with moderate success.',
        effect: EventEffect(devotionDelta: 3),
      ),
    ],
  ),

  TravelEvent(
    id: 'tc_cache',
    title: 'The Siege Cache',
    description: 'A hidden cache in the wall beside the road — provisioned for a siege that never happened. Sealed clay jars, dry goods, tools, coin in a locked box. Someone planned carefully for a last stand that never came.',
    choices: [
      EventChoice(
        label: 'Take what\'s useful',
        outcome: 'The provisions are good. The coin is old denomination but spends the same. You feel like a grave robber in a house where no one died.',
        effect: EventEffect(goldDelta: 40, partyHeal: 12),
      ),
      EventChoice(
        label: 'Take only the coin and leave the rest',
        outcome: 'Someone packed these supplies with care. The food stays for whoever needs it more.',
        effect: EventEffect(goldDelta: 25, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Leave it sealed and note the location',
        outcome: 'On the return journey, maybe. Or never. The cache has waited this long.',
        effect: EventEffect(),
      ),
    ],
  ),
];

// ─── WILDERNESS-BOUND EVENTS ─────────────────────────────────────────────────

const _wildernessEvents = [
  TravelEvent(
    id: 'tw_tracks',
    title: 'Parallel Tracks',
    description: 'Fresh tracks in the mud beside the path — large, clawed, moving the same direction you are. Your ranger reads them without enthusiasm: "Moving since this morning. Keeping our pace."',
    choices: [
      EventChoice(
        label: 'Follow the tracks off-path',
        outcome: 'You find a den, recently vacated. Whatever made it left in a hurry. Left some things behind too.',
        effect: EventEffect(goldDelta: 25, partyDamage: 8),
      ),
      EventChoice(
        label: 'Make noise to drive it off',
        outcome: 'Your company makes enough sound that something crashes away through the undergrowth to the north. The tracks don\'t reappear.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Keep moving, stay alert',
        outcome: 'You watch the treeline. The tracks continue beside you for another quarter mile, then veer away.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tw_cairn',
    title: 'The Cairn',
    description: 'A cairn of flat stones stands in a clearing off the path — Old Ways construction, deliberate, maintained. Fresh wildflowers at its base. You see no one for a mile in any direction.',
    choices: [
      EventChoice(
        label: 'Leave an offering',
        outcome: 'You place coin and a small branch at the base. A wind moves through the clearing without cause. Nothing hostile in it.',
        effect: EventEffect(goldDelta: -10, devotionDelta: 8, targetFaith: FaithType.oldWays),
      ),
      EventChoice(
        label: 'Rest here awhile',
        outcome: 'The clearing is quiet and the ground is dry. Your company breathes easier for a few minutes\' stillness.',
        effect: EventEffect(partyHeal: 12),
      ),
      EventChoice(
        label: 'Don\'t disturb it',
        outcome: 'You pass at a respectful distance. The flowers don\'t move.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tw_rain',
    title: 'The Downpour',
    description: 'The sky opens without warning. Within minutes the track is ankle-deep in flowing mud. A ruined shepherd\'s hut stands fifty yards off the path. It\'s probably dry inside.',
    choices: [
      EventChoice(
        label: 'Shelter in the hut',
        outcome: 'The roof holds. You wait out the worst of it, arriving later but dry and rested.',
        effect: EventEffect(partyHeal: 15),
      ),
      EventChoice(
        label: 'Push through',
        outcome: 'You are soaked to the skin and the mud is exhausting. You reach your destination, eventually.',
        effect: EventEffect(partyDamage: 8),
      ),
      EventChoice(
        label: 'Search the hut for anything useful',
        outcome: 'Old tools, a rusted knife, a cache of sealed jerky someone thought to hide. Worth the detour.',
        effect: EventEffect(goldDelta: 20, partyHeal: 8),
      ),
    ],
  ),

  TravelEvent(
    id: 'tw_fox',
    title: 'The Watcher',
    description: 'A large fox sits on a boulder at the path\'s edge and watches your company approach, then pass. It doesn\'t move. Its eyes are too steady and too knowing for any ordinary animal.',
    choices: [
      EventChoice(
        label: 'Stop and observe it',
        outcome: 'You watch it. It watches you. After a long minute it drops silently from the boulder and is gone. The path ahead looks clearer somehow.',
        effect: EventEffect(devotionDelta: 5, targetFaith: FaithType.oldWays),
      ),
      EventChoice(
        label: 'Leave food at the boulder',
        outcome: 'An old road-superstition: feed the watcher and the road feeds you back. Three miles on you find a coin purse in the mud.',
        effect: EventEffect(goldDelta: 15),
      ),
      EventChoice(
        label: 'Ignore it and move on',
        outcome: 'The fox is still watching when you look back from the next rise.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tw_stream',
    title: 'The Clear Stream',
    description: 'The path crosses a fast, shallow stream over stepping-stones. The water is very clear — you can see the bottom in perfect detail, including something glinting near the largest stone.',
    choices: [
      EventChoice(
        label: 'Wade in and look',
        outcome: 'A cache of old coin wedged under the stone — someone\'s hiding place, long forgotten. Cold water, good find.',
        effect: EventEffect(goldDelta: 28, partyDamage: 3),
      ),
      EventChoice(
        label: 'Fill your waterskins and rest',
        outcome: 'Clean water is its own reward. Your company crosses refreshed. The glinting thing stays where it was.',
        effect: EventEffect(partyHeal: 15),
      ),
      EventChoice(
        label: 'Cross quickly and keep pace',
        outcome: 'The water is cold enough to wake the slowest member of the party. You make good time.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tw_hollow',
    title: 'The Old Hollow',
    description: 'A massive fallen oak lies across the verge, its hollow visible from the path. Inside the hollow: a small stack of stones, some dried flowers, a folded cloth. A resting place, or an ongoing one.',
    choices: [
      EventChoice(
        label: 'Leave an offering of your own',
        outcome: 'You add to whatever tradition this is. The flowers you leave are fresh. Something about the act feels right in a way you can\'t name.',
        effect: EventEffect(devotionDelta: 7, targetFaith: FaithType.oldWays),
      ),
      EventChoice(
        label: 'Shelter inside and rest',
        outcome: 'The hollow is larger than it looks. You share it with whatever spirits keep it. Neither party minds.',
        effect: EventEffect(partyHeal: 18),
      ),
      EventChoice(
        label: 'Look but don\'t touch',
        outcome: 'Observance without intrusion. The old ways sometimes ask no more than attention.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tw_mushrooms',
    title: 'The Circle of Growth',
    description: 'A perfect ring of large mushrooms encircles a small clearing off the path. Old folk say the rings mark where the fey danced. Older folk say the fey never danced at all, and that\'s worse.',
    choices: [
      EventChoice(
        label: 'Step inside the ring',
        outcome: 'The air inside the ring is warmer by several degrees. Something speaks in the back of your mind in no language you know. You step out carrying a clarity you didn\'t have before.',
        effect: EventEffect(partyHeal: 20, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Collect some of the mushrooms',
        outcome: 'They smell wrong and look wrong but the hedge-witch in your company says they\'re valuable. She doesn\'t say for what.',
        effect: EventEffect(goldDelta: 20, partyDamage: 5),
      ),
      EventChoice(
        label: 'Give the ring a wide berth',
        outcome: 'The oldest rule. The fey don\'t chase. They wait.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tw_fire',
    title: 'The Cold Camp',
    description: 'A camp fire in the forest clearing, dead cold but built within the last day — laid out by someone who knew what they were doing. Bedroll marks in the dirt. Three of them, maybe four. They left in a hurry.',
    choices: [
      EventChoice(
        label: 'Search what they left behind',
        outcome: 'A cooking pot, an abandoned pack, coin scattered in the leaves. Whatever made them run left this behind.',
        effect: EventEffect(goldDelta: 22, partyDamage: 5),
      ),
      EventChoice(
        label: 'Relight the fire and rest',
        outcome: 'Whatever spooked the last camp, it didn\'t return. You take the rest.',
        effect: EventEffect(partyHeal: 18),
      ),
      EventChoice(
        label: 'Note it and keep moving',
        outcome: 'Four experienced campers don\'t abandon a site without reason. You factor that into your approach.',
        effect: EventEffect(),
      ),
    ],
  ),
];

// ─── RUINS-BOUND EVENTS ──────────────────────────────────────────────────────

const _ruinsEvents = [
  TravelEvent(
    id: 'tr_shadow',
    title: 'The Moving Shape',
    description: 'Something large moves in the foundations ahead — too slow to be running, too deliberate to be accidental. It passes between two broken walls and is gone. You find no tracks on the stone.',
    choices: [
      EventChoice(
        label: 'Follow it',
        outcome: 'Whatever it was, it doesn\'t want to be followed. It leaves you with a bruised shin and a handful of old coin that wasn\'t there before.',
        effect: EventEffect(goldDelta: 25, partyDamage: 10),
      ),
      EventChoice(
        label: 'Call out to it',
        outcome: 'Nothing answers in words. But the sound that comes back is almost one.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Give the area a wide berth',
        outcome: 'The longer path around adds time but keeps you away from whatever that was.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tr_inscription',
    title: 'The Fresh Inscription',
    description: 'Graffiti on an old stone: names, a date, a rough map. The stone is centuries old. The ink is fresh — dry on the surface, still wet underneath. Carved within the last hour.',
    choices: [
      EventChoice(
        label: 'Study the map carefully',
        outcome: 'It marks something nearby. A crypt entrance, maybe, or a buried cache. You spend time finding it.',
        effect: EventEffect(goldDelta: 40, partyDamage: 5),
      ),
      EventChoice(
        label: 'Look for whoever made it',
        outcome: 'You see no one. Footprints in the dust lead to the stone and end there.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Add your own mark and move on',
        outcome: 'A name and a date. The road likes to know who passed.',
        effect: EventEffect(devotionDelta: 3),
      ),
    ],
  ),

  TravelEvent(
    id: 'tr_smoke',
    title: 'Woodsmoke',
    description: 'The ruins smell of woodsmoke and bread — faint but recent. Something has been burning here in the last few hours. The ruins are silent. Nothing moves. But a hearth-stone is still warm to the touch.',
    choices: [
      EventChoice(
        label: 'Search for what was left behind',
        outcome: 'Someone left in a hurry. They didn\'t take their food stores.',
        effect: EventEffect(goldDelta: 20, partyHeal: 10),
      ),
      EventChoice(
        label: 'Stay quiet and wait',
        outcome: 'Nothing returns. Whatever was here, it\'s gone now. The bread is yours.',
        effect: EventEffect(partyHeal: 15),
      ),
      EventChoice(
        label: 'Keep moving — this isn\'t your business',
        outcome: 'You note it for the return journey and press on.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tr_coin',
    title: 'The Old Coin',
    description: 'Among the rubble, something catches the light — a coin of unfamiliar mint, older than the Church calendar, a face on it that belongs to no dynasty you\'ve heard named. Perfectly preserved.',
    choices: [
      EventChoice(
        label: 'Take it',
        outcome: 'A scholar would pay well for this. Maybe someone in town. You pocket it and move on.',
        effect: EventEffect(goldDelta: 25),
      ),
      EventChoice(
        label: 'Leave it where it was',
        outcome: 'Some things are where they are for a reason. You leave it in the mud.',
        effect: EventEffect(devotionDelta: 4),
      ),
      EventChoice(
        label: 'Look for more',
        outcome: 'An hour of searching turns up three more coins and a badly corroded brooch. Worth the time, mostly.',
        effect: EventEffect(goldDelta: 45, partyDamage: 5),
      ),
    ],
  ),

  TravelEvent(
    id: 'tr_door',
    title: 'The Intact Door',
    description: 'Everything around it is rubble — walls, ceilings, centuries of collapse — but one door stands in its frame, perfectly hung, perfectly intact. Painted blue. Locked. The building it belonged to is long gone.',
    choices: [
      EventChoice(
        label: 'Force the lock',
        outcome: 'The lock is better than the door deserves. Inside: a small space that shouldn\'t exist, with a chest inside that shouldn\'t be here. Coin, and beneath that, a blade wrapped in oiled cloth. Someone expected to return for it.',
        effect: EventEffect(goldDelta: 40, partyDamage: 8, weaponRewardId: 'seax'),
      ),
      EventChoice(
        label: 'Knock',
        outcome: 'Three knocks. Silence. Then, from the other side, three knocks back. You decide not to try the lock.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Walk around it',
        outcome: 'There is nothing on the other side of the door. That makes the three knocks worse somehow.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tr_mural',
    title: 'The Readable Wall',
    description: 'One section of interior wall has survived protected from weather — and on it, a mural, still vivid. A procession of figures in robes you don\'t recognise, walking toward a door that is painted to look exactly like the ruins around you.',
    choices: [
      EventChoice(
        label: 'Study the mural in detail',
        outcome: 'The figures carry things. Offerings, maybe. One of them carries a coin purse painted in gold that the artist made convincing enough to peel. You peel it. Inside is a cavity. Inside is coin.',
        effect: EventEffect(goldDelta: 35, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Sketch or memorise the design',
        outcome: 'A scholar in town would value this. More importantly — the figures in the procession are all wearing your faces. Or close enough to matter.',
        effect: EventEffect(devotionDelta: 6),
      ),
      EventChoice(
        label: 'Move on',
        outcome: 'Art that old makes a certain kind of claim on your attention. You deny it. The mural watches you go.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tr_child_shoe',
    title: 'The Shoe',
    description: 'A child\'s shoe in the rubble — small, well-made, one of a pair. No child. No sign of a child. It sits upright on a flat stone as if placed there, not dropped.',
    choices: [
      EventChoice(
        label: 'Look for the other shoe',
        outcome: 'Two hours. You find it eventually, twenty yards away and one floor down, also upright, also alone. There is nothing to explain either of them.',
        effect: EventEffect(goldDelta: 20, partyDamage: 5),
      ),
      EventChoice(
        label: 'Leave a coin beside it',
        outcome: 'The Pale Court has jurisdiction over things left behind in the world. You observe that quietly.',
        effect: EventEffect(goldDelta: -10, devotionDelta: 7, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Keep moving',
        outcome: 'You have seen ruins before. Ruins contain remains. That\'s the definition.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tr_mason',
    title: 'The Builder\'s Mark',
    description: 'Every large stone in this section bears the same mason\'s mark — a circle bisected by a single vertical line. You\'ve seen that mark on buildings in three different towns. The same hand built all of them. Built something very large, once.',
    choices: [
      EventChoice(
        label: 'Search for a keystone with the mark',
        outcome: 'You find the central stone — the mark carved here is larger, ringed, and set into the floor rather than the wall. Beneath it, a small sealed vault.',
        effect: EventEffect(goldDelta: 55, partyDamage: 7),
      ),
      EventChoice(
        label: 'Note the mark for later research',
        outcome: 'A pattern that spans geography implies purpose. The right scholar would pay for this information.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Press on',
        outcome: 'Old builders and old marks. The road is full of things that meant something to someone.',
        effect: EventEffect(),
      ),
    ],
  ),
];

// ─── MONASTERY-BOUND EVENTS ──────────────────────────────────────────────────

const _monasteryEvents = [
  TravelEvent(
    id: 'tm_monk',
    title: 'The Roadside Monk',
    description: 'A lone monk sits at the roadside reading a volume too large for his small frame. He doesn\'t look up as you approach. His robes are a faith you don\'t recognise. When you are almost past he says, without looking up: "You carry something that wants to come back."',
    choices: [
      EventChoice(
        label: 'Stop and speak with him',
        outcome: 'He talks for ten minutes in careful riddles. Some of it almost makes sense. He blesses you in the name of something you\'ve never heard named.',
        effect: EventEffect(partyHeal: 12, devotionDelta: 6),
      ),
      EventChoice(
        label: 'Ask what he means',
        outcome: '"Ask your dead," he says, and returns to his reading. You don\'t sleep well thinking about it.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Walk past without responding',
        outcome: 'He says nothing else. His page doesn\'t turn.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tm_pilgrim',
    title: 'The Pilgrim\'s Company',
    description: 'A pilgrim on the same road catches up with your company — a woman of middle age carrying a sealed wooden box she will not put down. She asks to travel with you the rest of the way. "Safer," she says. "For both of us."',
    choices: [
      EventChoice(
        label: 'Accept her company',
        outcome: 'She walks with you for an hour and shares her travelling bread without being asked. At the gate she bows and goes her own way.',
        effect: EventEffect(partyHeal: 15, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Ask about the box',
        outcome: '"A relic," she says. "For the brothers." She tells you nothing more but her pace picks up, as if the question helped.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Decline — you travel faster alone',
        outcome: 'She understands. "The road is the road," she says.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tm_shrine',
    title: 'The Wayside Shrine',
    description: 'A shrine at the roadside — a niche carved into an ancient milestone, a small painted saint, a candle burned to a stub. A folded note has been left in the saint\'s niche. Someone left it recently.',
    choices: [
      EventChoice(
        label: 'Leave an offering',
        outcome: 'A coin and a moment of silence. The candle stub relights itself. You decide not to think about that.',
        effect: EventEffect(goldDelta: -10, devotionDelta: 8),
      ),
      EventChoice(
        label: 'Read the note',
        outcome: 'A name and a date and a single word: "Please." You fold it back and leave it.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Light a candle and move on',
        outcome: 'A small gesture. The road notices small gestures.',
        effect: EventEffect(goldDelta: -5, devotionDelta: 4),
      ),
    ],
  ),

  TravelEvent(
    id: 'tm_bells',
    title: 'The Wrong Bell',
    description: 'The monastery bell rings the hour ahead — but the interval is wrong by half a breath, and it has been wrong since you left the last waymarker. Your company has slowed without being asked to.',
    choices: [
      EventChoice(
        label: 'Press on regardless',
        outcome: 'The bell corrects itself at the next ring, as if it noticed you still coming.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Stop and listen until it corrects',
        outcome: 'Seven rings wrong, then silence, then one ring right. Your company breathes out as one.',
        effect: EventEffect(partyHeal: 8, devotionDelta: 4),
      ),
      EventChoice(
        label: 'Pray while you wait',
        outcome: 'Whatever watches the road, you have acknowledged it. It has acknowledged you back.',
        effect: EventEffect(devotionDelta: 10),
      ),
    ],
  ),

  TravelEvent(
    id: 'tm_garden',
    title: 'The Untended Garden',
    description: 'A medicinal garden beside the road — formally planned, once tended, now half-wild. The monastery ahead went quiet long before it was reclaimed. Someone still planted things here within the last season.',
    choices: [
      EventChoice(
        label: 'Harvest what you recognise',
        outcome: 'Yarrow, bitterroot, something your company\'s healer calls "monk\'s grace." All useful. All taken.',
        effect: EventEffect(partyHeal: 20, devotionDelta: 3),
      ),
      EventChoice(
        label: 'Tend it while you rest',
        outcome: 'Half an hour of weeding and pruning. When you leave it looks maintained again. The work itself is the prayer.',
        effect: EventEffect(partyHeal: 12, devotionDelta: 8),
      ),
      EventChoice(
        label: 'Pass it by',
        outcome: 'Someone is still caring for this garden. That person is doing their own road.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tm_brother',
    title: 'The Returned Brother',
    description: 'A man in faded monk\'s robes is walking the same direction you are — not quickly, not praying. He fell into step with your company without being invited. He has the look of someone who left and has spent years deciding whether to return.',
    choices: [
      EventChoice(
        label: 'Walk with him and talk',
        outcome: 'He tells you things about the monastery that the brothers who stayed would not. Information is worth having. His company is worth more.',
        effect: EventEffect(partyHeal: 10, devotionDelta: 7),
      ),
      EventChoice(
        label: 'Ask why he left',
        outcome: '"A question," he says. "And then the answer." He doesn\'t say which question. He doesn\'t say whether the answer was good.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Give him space',
        outcome: 'A man with that posture is already in a conversation with himself. You walk ahead.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tm_vow_post',
    title: 'The Vow Post',
    description: 'A wooden post at the road\'s edge hung with strips of cloth, pressed flowers, knotted cord — the traditional vow-markers of those who made a pledge before this journey. Many of the markers are old. Some are fresh.',
    choices: [
      EventChoice(
        label: 'Tie your own vow',
        outcome: 'You make a vow and tie the marker. The specifics are your own. The road witnesses.',
        effect: EventEffect(devotionDelta: 10),
      ),
      EventChoice(
        label: 'Read the older markers',
        outcome: 'Faded ink, old prayers, names you don\'t know. A litany of hope in a dozen hands.',
        effect: EventEffect(partyHeal: 8, devotionDelta: 4),
      ),
      EventChoice(
        label: 'Move past without stopping',
        outcome: 'Other people\'s vows. Other people\'s roads.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tm_lost_page',
    title: 'The Loose Page',
    description: 'A single manuscript page caught in the hedge beside the road — monastery vellum, clearly copied from something older. The text is dense and annotated in three different hands. You can read perhaps a third of it.',
    choices: [
      EventChoice(
        label: 'Keep the page',
        outcome: 'The annotated portion you can\'t read is more interesting than the portion you can. A scholar at the monastery might complete the picture.',
        effect: EventEffect(devotionDelta: 6),
      ),
      EventChoice(
        label: 'Leave it and note the content',
        outcome: 'What you read stays with you in the way that only certain things do.',
        effect: EventEffect(devotionDelta: 4),
      ),
      EventChoice(
        label: 'Leave it where it fell',
        outcome: 'Manuscripts belong to archives. Archives belong to the brotherhood. This one found its own way out.',
        effect: EventEffect(),
      ),
    ],
  ),
];

// ─── CEMETERY-BOUND EVENTS ───────────────────────────────────────────────────

const _cemeteryEvents = [
  TravelEvent(
    id: 'tce_epitaph',
    title: 'The Fresh Epitaph',
    description: 'A new headstone stands alone at the edge of the road — no grave beneath it, no earth disturbed. The epitaph is carved in crisp letters: your company\'s name. Below it, a date. Tomorrow\'s.',
    choices: [
      EventChoice(
        label: 'Smash the stone',
        outcome: 'You break it apart. Three blows, clean fractures. The pieces feel warm. Nothing else happens — today.',
        effect: EventEffect(partyDamage: 5),
      ),
      EventChoice(
        label: 'Read the epitaph aloud',
        outcome: 'Your voice is steady. So is the road ahead. Whatever the stone wanted from you, naming it was not it.',
        effect: EventEffect(devotionDelta: 4),
      ),
      EventChoice(
        label: 'Leave a coin on it and move on',
        outcome: 'An old custom: coin for the ferryman. The road does not argue with old customs.',
        effect: EventEffect(goldDelta: -10, devotionDelta: 6, targetFaith: FaithType.paleCourt),
      ),
    ],
  ),

  TravelEvent(
    id: 'tce_keeper',
    title: 'The Graveyard Keeper',
    description: 'An old man leans on a long-handled spade at the cemetery gate. He waves you down without urgency. "Help me carry one more," he says. "One more, and I\'ll tell you what I\'ve buried here."',
    choices: [
      EventChoice(
        label: 'Help him  (costs time)',
        outcome: 'The work is hard and the box is heavier than expected. The keeper tells you where the old warlords buried their gold. Some of it is still there.',
        effect: EventEffect(goldDelta: 55, partyDamage: 8),
      ),
      EventChoice(
        label: 'Ask what he\'s already buried',
        outcome: '"Everything worth burning," he says. He doesn\'t elaborate. He doesn\'t need to.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Give him coin and move on  (–20g)',
        outcome: 'He pockets the coin without looking at it. "Same end," he says.',
        effect: EventEffect(goldDelta: -20),
      ),
    ],
  ),

  TravelEvent(
    id: 'tce_mourner',
    title: 'The Mourner',
    description: 'A woman stands motionless at a graveside, not weeping, just standing. She has been there long enough that her dress is wet through from the morning rain. She doesn\'t look up when you approach.',
    choices: [
      EventChoice(
        label: 'Stay with her a moment',
        outcome: 'You stand in silence beside her. She says nothing. After a while she takes a breath and walks away. You feel lighter than you have any right to.',
        effect: EventEffect(partyHeal: 12, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Ask who she mourns',
        outcome: '"Someone who deserved better," she says. "Same as everyone here." She doesn\'t look up.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Leave quietly',
        outcome: 'Grief is a private road. You take the path around.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tce_lantern',
    title: 'The Moving Lantern',
    description: 'A lantern bobs between the headstones ahead — too low for a man carrying it, too steady for wind. It moves in a slow, purposeful arc through the cemetery and comes to rest near the far wall, then goes out.',
    choices: [
      EventChoice(
        label: 'Investigate where it stopped',
        outcome: 'A child\'s grave. A name you don\'t know. Fresh flowers. The lantern is cold iron, unlit, and has been for years by the look of it.',
        effect: EventEffect(goldDelta: 20, devotionDelta: 6, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Follow it as it moves',
        outcome: 'It leads you on a winding path through the grounds and then simply vanishes. You are very thoroughly lost in the cemetery. You find your way out eventually — and find something in the process.',
        effect: EventEffect(goldDelta: 35, partyDamage: 10),
      ),
      EventChoice(
        label: 'Don\'t follow the light',
        outcome: 'The oldest rule on any road: don\'t follow unfamiliar lights. You know this. You keep moving.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tce_digger',
    title: 'The Fresh Digging',
    description: 'A grave has been opened — not recently enough to be fresh burial, not old enough to be vandalism. The soil is mounded cleanly to one side, almost professionally. Whatever was in it was removed with care.',
    choices: [
      EventChoice(
        label: 'Examine what was left behind',
        outcome: 'Grave goods the digger didn\'t want — cloth, broken pottery, a few coins considered too common to take. They left the debt and took what they came for.',
        effect: EventEffect(goldDelta: 15, devotionDelta: -4),
      ),
      EventChoice(
        label: 'Fill it back in',
        outcome: 'Half an hour of work. The dead deserve a sealed grave whether or not they\'re still in it.',
        effect: EventEffect(partyDamage: 5, devotionDelta: 8, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Note it and move on',
        outcome: 'Whoever did this had a reason you may not want to understand.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tce_soldier',
    title: 'The Visiting Soldier',
    description: 'An old soldier stands at a headstone, hat in hand, saying nothing. He has been here a while — the mud has dried on his boots. He looks up when you approach. "My captain," he says. "Twenty years."',
    choices: [
      EventChoice(
        label: 'Stand with him a moment',
        outcome: 'You say nothing useful and that is exactly the right thing. He straightens, puts his hat back, and walks away with a lighter step.',
        effect: EventEffect(partyHeal: 10, devotionDelta: 6),
      ),
      EventChoice(
        label: 'Ask about the captain',
        outcome: '"Good officer. Bad luck." He tells you one story and it is enough for both of you.',
        effect: EventEffect(devotionDelta: 4),
      ),
      EventChoice(
        label: 'Leave him to his visit',
        outcome: 'The dead and the living make their arrangements without needing witnesses.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tce_message',
    title: 'The Scratched Stone',
    description: 'A message scratched into the base of an old headstone — not carved, scratched with something sharp and quick. "THE THIRD PLOT FROM THE OAK IS NOT WHAT IT SAYS." Below it: "DO NOT LOOK."',
    choices: [
      EventChoice(
        label: 'Look',
        outcome: 'The third plot from the oak has a name and dates, like any other. Except the dates are wrong by exactly fifty years. And the name matches a living lord in the next county.',
        effect: EventEffect(goldDelta: 35, partyDamage: 8),
      ),
      EventChoice(
        label: 'Don\'t look',
        outcome: 'Someone went to the trouble of telling you not to. You honour that. The mystery stays sealed.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Leave your own message beneath it',
        outcome: 'You scratch: "SOMEONE READ THIS." The conversation continues without you.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tce_tender',
    title: 'The Cemetery Tender',
    description: 'A woman moves between the headstones with a barrow and tools — cleaning, replanting, maintaining. Not a keeper or a monk, just someone who takes it upon herself. She looks up. "You\'re not visiting anyone," she says. It isn\'t a question.',
    choices: [
      EventChoice(
        label: 'Help her with the work',
        outcome: 'An hour of labour, quietly shared. She tells you nothing and you tell her nothing. The exchange is sufficient.',
        effect: EventEffect(partyDamage: 5, devotionDelta: 9, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Ask what she does this for',
        outcome: '"Someone has to." She turns back to her work. You leave with that in your head for the rest of the day.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Move through quickly',
        outcome: 'She watches you go without judgment. People pass through her cemetery all the time.',
        effect: EventEffect(),
      ),
    ],
  ),
];

// ─── LIBRARY-BOUND EVENTS ────────────────────────────────────────────────────

const _libraryEvents = [
  TravelEvent(
    id: 'tl_archivist',
    title: 'The Archivist on the Road',
    description: 'A thin figure in grey robes walks the path ahead, pulling a small cart loaded with sealed boxes. He stops and turns at your approach. "If you are going where I think you are going," he says, "I have some notes that may help — at a price."',
    choices: [
      EventChoice(
        label: 'Buy his notes  (–30g)',
        outcome: 'The notes are dense and annotated by three different hands. Useful. He bows and continues in the opposite direction.',
        effect: EventEffect(goldDelta: -30, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Offer to carry his cart',
        outcome: 'You push the cart for a mile. He talks the entire time about things you mostly don\'t understand, but one thing sticks. The passage you needed.',
        effect: EventEffect(partyDamage: 5, devotionDelta: 8),
      ),
      EventChoice(
        label: 'Move past without stopping',
        outcome: 'He calls after you: "Second reading room. Don\'t touch the sealed cabinet." You keep walking.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tl_pages',
    title: 'The Scattered Pages',
    description: 'Loose pages line the road ahead — dozens of them, caught in bushes and pressed into the mud. All are covered in careful handwriting. All have the same first line: "By the time you read this, the archive has moved."',
    choices: [
      EventChoice(
        label: 'Gather as many as you can',
        outcome: 'Wet, torn, and in the wrong order. But there\'s information in here — if someone can sort it. Worth money to the right buyer.',
        effect: EventEffect(goldDelta: 30, partyDamage: 5),
      ),
      EventChoice(
        label: 'Read them where they lie',
        outcome: 'You don\'t understand most of it. But a map reference, buried in the third paragraph of the fifteenth page, is legible. You memorise it.',
        effect: EventEffect(devotionDelta: 6),
      ),
      EventChoice(
        label: 'Leave them where they are',
        outcome: '"By the time you read this, the archive has moved." Some messages are for other people.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tl_scholar',
    title: 'The Void Scholar',
    description: 'A man sits cross-legged on the road, reading a book that appears to be reading him back — its pages moving without wind, tracking his eyes. He looks up. "Sit," he says. "You carry a question. Most people on this road do."',
    choices: [
      EventChoice(
        label: 'Sit and ask the question',
        outcome: 'You don\'t know what the question is until you hear yourself ask it. The book stops moving. He answers. You don\'t remember the answer on the other side of it, but your company moves differently afterward.',
        effect: EventEffect(partyHeal: 20, devotionDelta: 8),
      ),
      EventChoice(
        label: 'Ask what the book is',
        outcome: '"An index," he says. "I haven\'t decided of what." He turns back to it. The pages resume.',
        effect: EventEffect(devotionDelta: 4),
      ),
      EventChoice(
        label: 'Step around him and continue',
        outcome: '"The answer was there anyway," he calls after you. "It always was."',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tl_seal',
    title: 'The Sealed Chest',
    description: 'A small iron chest sits in the middle of the road, chained and padlocked. No cart tracks, no footprints. A tag wired to the handle reads: "PROPERTY OF THE PALE COURT ARCHIVE — CONTENTS RESTRICTED".',
    choices: [
      EventChoice(
        label: 'Break the lock',
        outcome: 'Inside: three sealed manuscripts and a velvet bag of coin. No visible curse. You take the coin and leave the manuscripts where they are.',
        effect: EventEffect(goldDelta: 60, partyDamage: 8, devotionDelta: -6, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Carry it to the archive intact  (costs effort)',
        outcome: 'It\'s heavier than it looks. The archivist at the door takes it without ceremony and hands you a receipt that turns out to be redeemable for coin.',
        effect: EventEffect(goldDelta: 25, devotionDelta: 10, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Push it off the road and continue',
        outcome: 'Not your property. Not your problem. Someone will find it.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tl_burned',
    title: 'The Burned Section',
    description: 'The road passes through a section of fallen wall where scorched timbers and ash suggest a fire took part of the library\'s outer structure. Among the ash — recognisable rectangles of compressed char where books burned in stacks.',
    choices: [
      EventChoice(
        label: 'Sift through the ash for survivors',
        outcome: 'One volume at the centre of the largest stack is scorched on the outside but intact within — protected by the books that burned around it. Inside: a copied primer of arcane workings, incomplete but usable. The fire chose it, or it chose the fire.',
        effect: EventEffect(partyDamage: 6, devotionDelta: 5, spellTomeId: 'arcane_missile'),
      ),
      EventChoice(
        label: 'Pay respects to what was lost',
        outcome: 'There is no ritual for burned books. You observe a silence anyway. Preservation is a kind of faith.',
        effect: EventEffect(devotionDelta: 9, targetFaith: FaithType.paleCourt),
      ),
      EventChoice(
        label: 'Keep moving — ash is ash',
        outcome: 'Knowledge finds other forms. You have enough philosophy for one road.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tl_cipher',
    title: 'The Coded Marker',
    description: 'A directional sign beside the road is partly replaced — someone has covered half the text with a panel bearing a cipher. Two directions: one in plain script, one in code. The coded direction points toward the archive.',
    choices: [
      EventChoice(
        label: 'Spend time on the cipher',
        outcome: 'You break it. It reads: "Scholars\' entrance — avoid the queue." The side door it indicates opens to a knock and a password you get from the cipher itself.',
        effect: EventEffect(partyDamage: 5, devotionDelta: 8),
      ),
      EventChoice(
        label: 'Follow the plain-text direction',
        outcome: 'Straightforward. The main entrance is well-used. You join the back of it.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Copy the cipher for later',
        outcome: 'If there\'s a code worth breaking, there\'s a reason it was worth hiding. This one can wait.',
        effect: EventEffect(devotionDelta: 3),
      ),
    ],
  ),

  TravelEvent(
    id: 'tl_student',
    title: 'The Lost Student',
    description: 'A young scholar has been sitting at the road junction for some time with a map that is clearly wrong — the library appears on it twice, in different locations. She looks up with the expression of someone who has been too proud to ask for help for too long.',
    choices: [
      EventChoice(
        label: 'Help her correct the map',
        outcome: 'You show her the right bearing. She is embarrassed but grateful, and presses a coin on you — the last of her road money, probably.',
        effect: EventEffect(goldDelta: 15, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Walk with her to the archive',
        outcome: 'The extra company is pleasant. She asks good questions and has worse answers. The archive is better for her arrival.',
        effect: EventEffect(partyHeal: 10, devotionDelta: 6),
      ),
      EventChoice(
        label: 'Point the direction and keep moving',
        outcome: 'She thanks you with the particular gratitude of someone who has not been thanking themselves.',
        effect: EventEffect(devotionDelta: 3),
      ),
    ],
  ),

  TravelEvent(
    id: 'tl_catalog',
    title: 'The Index Entry',
    description: 'A catalog page has been posted on a board beside the road — a library bulletin, probably meant for scholars. One entry is circled in red ink: "Vol. XII, On The Properties Of The Ashen Road — RESTRICTED. Inquiries addressed to Archivist Maren only."',
    choices: [
      EventChoice(
        label: 'Make a note to inquire',
        outcome: 'Archivist Maren, Volume XII. Whatever\'s in it, someone thought twice about who should read it.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Check the board for other entries',
        outcome: 'Five more restricted titles. Two of them concern things you\'ve encountered on this road. The third concerns things you haven\'t yet.',
        effect: EventEffect(goldDelta: 10, devotionDelta: 7),
      ),
      EventChoice(
        label: 'Keep walking',
        outcome: 'Restricted knowledge has a way of finding people who need it whether they ask or not.',
        effect: EventEffect(),
      ),
    ],
  ),
];

// ─── FORGE-BOUND EVENTS ──────────────────────────────────────────────────────

const _forgeEvents = [
  TravelEvent(
    id: 'tf_exile',
    title: 'The Forge-Exile',
    description: 'A woman sits at a cold camp off the path, her hands wrapped in burned cloth. She has a smith\'s tools and nothing else. "I made something I shouldn\'t," she says. "They took the forge. Left me the debt."',
    choices: [
      EventChoice(
        label: 'Hire her to mend your gear  (–25g)',
        outcome: 'She works fast and well. The repair she does to your equipment is better than new — and she takes nothing extra.',
        effect: EventEffect(goldDelta: -25, partyHeal: 15),
      ),
      EventChoice(
        label: 'Give her coin to start again  (–30g)',
        outcome: 'She looks at the coin a long time. "I\'ll remember this," she says. You believe her.',
        effect: EventEffect(goldDelta: -30, devotionDelta: 8),
      ),
      EventChoice(
        label: 'Ask what she made',
        outcome: '"A blade that remembers every hand it has passed through," she says. "The Church called it profane. I called it accurate." She shows you the burn scars. You don\'t ask more.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tf_guild',
    title: 'The Guild Writ',
    description: 'A courier blocks your path — Church guild livery, a sealed document held out at arm\'s length. "Advance inspection. Smiths\' Compact requires all travellers to declare edged weapons." The fee is listed at the bottom of the form.',
    choices: [
      EventChoice(
        label: 'Pay the inspection fee  (–20g)',
        outcome: 'The courier stamps the writ, hands it back, and leaves without a further word. Legitimate enough, probably.',
        effect: EventEffect(goldDelta: -20),
      ),
      EventChoice(
        label: 'Refuse — no such compact exists',
        outcome: 'You are right. He knows you\'re right. He finds urgent business elsewhere.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Bribe him to go away  (–15g)',
        outcome: 'Less official but faster. The document disappears. So does he.',
        effect: EventEffect(goldDelta: -15),
      ),
    ],
  ),

  TravelEvent(
    id: 'tf_iron_captain',
    title: 'The Iron Captain',
    description: 'A heavyset figure in scarred plate armour stands at a crossroads, arms crossed. No emblem on the armour. No emblem on his face, which is half iron plate held in place by rivets. He watches your company approach. "You\'ll want to know what\'s ahead," he says.',
    choices: [
      EventChoice(
        label: 'Listen to what he knows',
        outcome: '"Hot," he says. "The way ahead is hot. Not fire. Just — iron and bad choices." He steps aside. Your company is more alert for it.',
        effect: EventEffect(devotionDelta: 4),
      ),
      EventChoice(
        label: 'Challenge him for the road',
        outcome: 'He doesn\'t move. "I was here first," he says. "And I\'ll be here after." He means it about the road and about your life. You go around.',
        effect: EventEffect(partyDamage: 10),
      ),
      EventChoice(
        label: 'Offer him work',
        outcome: 'He laughs — a creak of iron and old wound. "I have work. I don\'t need more." He waves you past.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tf_cooling',
    title: 'The Cooling Blade',
    description: 'A blade is embedded in a stone at the roadside — a smith\'s test piece, left where it cooled. The metal still has heat in it. No smith is anywhere nearby. The mark on the tang is unfamiliar to your company\'s soldiers.',
    choices: [
      EventChoice(
        label: 'Wrench it free and take it',
        outcome: 'It comes free cleanly. The balance is extraordinary. The mark on the tang is still warm when you pocket it. A blade worth having.',
        effect: EventEffect(goldDelta: 40),
      ),
      EventChoice(
        label: 'Leave it — someone will return for it',
        outcome: 'Not everything left by the road is abandoned. You walk past.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Mark the stone and press on',
        outcome: 'You note the location. If the forge ahead needs work, the smith who left this might be someone worth knowing.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tf_apprentice',
    title: 'The Runaway',
    description: 'A young person sits at the road\'s edge with a bundle and a set of smith\'s tools far too heavy for them. They\'re going the wrong direction — away from the forge. They look up without apology: "I\'m not going back."',
    choices: [
      EventChoice(
        label: 'Talk them around',
        outcome: 'You don\'t ask what happened. You tell them what the road is like instead. They listen. They turn around. You receive no thanks and want none.',
        effect: EventEffect(devotionDelta: 6),
      ),
      EventChoice(
        label: 'Let them go where they\'re going',
        outcome: 'Not everyone belongs where they were put. You share your road bread and send them on their way.',
        effect: EventEffect(partyDamage: 3, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Ask if they know the forge ahead',
        outcome: 'They know it better than anyone. They tell you what to ask for, who to avoid, and where the master smith keeps the quality stock.',
        effect: EventEffect(goldDelta: 15),
      ),
    ],
  ),

  TravelEvent(
    id: 'tf_metal',
    title: 'The Strange Ingot',
    description: 'Someone has left an ingot of metal on a fence post beside the road — wrapped in cloth, clearly placed with intention. The metal is dark and heavy, denser than iron. It has a faint warmth that isn\'t from the sun.',
    choices: [
      EventChoice(
        label: 'Take it to the forge',
        outcome: 'The smith goes very quiet when they see it. They name a price on the spot that makes your company\'s soldier cough. You sell it.',
        effect: EventEffect(goldDelta: 55),
      ),
      EventChoice(
        label: 'Leave it where it was',
        outcome: 'Someone put it there and someone is probably coming back for it. The warmth makes you walk faster.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Examine it carefully before deciding',
        outcome: 'The cloth wrapping has a mark burned into it — a smith\'s sigil you recognise from old records. This material hasn\'t been refined in two hundred years.',
        effect: EventEffect(goldDelta: 40, devotionDelta: 4),
      ),
    ],
  ),

  TravelEvent(
    id: 'tf_order',
    title: 'The Abandoned Order',
    description: 'A wagon half-loaded with finished weapons sits beside the road, horse gone, driver gone. A ledger is open on the seat to a completed delivery order — paid in advance, with a name and address that no longer exist.',
    choices: [
      EventChoice(
        label: 'Take what\'s useful',
        outcome: 'Good weapons, already paid for, going nowhere. The company\'s sword arm approves.',
        effect: EventEffect(goldDelta: 45, devotionDelta: -3),
      ),
      EventChoice(
        label: 'Deliver the load to the forge',
        outcome: 'You spend time returning the weapons. The smith knows nothing about the order and thanks you awkwardly. A good deed done in the wrong direction still counts.',
        effect: EventEffect(partyDamage: 6, devotionDelta: 8),
      ),
      EventChoice(
        label: 'Report it and move on',
        outcome: 'Not your property, not your problem. You mention it at the next gatehouse. Someone\'s looking for that horse.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tf_name',
    title: 'The Named Anvil',
    description: 'An old anvil stands at the road\'s edge — too heavy to move far, too valuable to abandon, a compromise between both. A name is scratched deep into its face: ELDEN GREY. No inscription. Just the name.',
    choices: [
      EventChoice(
        label: 'Ask at the forge about Elden Grey',
        outcome: 'An old master. Dead twenty years. The forge ahead was his. The current smith doesn\'t say "was" — they say "is." The conversation ends there.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Leave a coin on it',
        outcome: 'An old custom. What you leave on a named stone is remembered.',
        effect: EventEffect(goldDelta: -5, devotionDelta: 6),
      ),
      EventChoice(
        label: 'Keep moving',
        outcome: 'Names and anvils both outlast the hands that shaped them. The road goes on.',
        effect: EventEffect(),
      ),
    ],
  ),
];

// ─── LOOKUP HELPERS ──────────────────────────────────────────────────────────

const _churchEvents = [
  TravelEvent(
    id: 'tch_pilgrim',
    title: 'A Fellow Pilgrim',
    description: 'A lone pilgrim walks the same road, wrapped in a worn cloak bearing a sun-wheel symbol. She greets you with weary eyes. "The church ahead — I have sought it for months. Would you walk with me the last mile?"',
    choices: [
      EventChoice(
        label: 'Walk with her',
        outcome: 'You walk together in companionable silence. At the gate, she presses a small blessing-coin into your hands.',
        effect: EventEffect(goldDelta: 15),
      ),
      EventChoice(
        label: 'Decline and press on',
        outcome: 'You move at your own pace. The pilgrim watches you go without judgment.',
        effect: EventEffect(),
      ),
    ],
  ),
  TravelEvent(
    id: 'tch_toll',
    title: 'The Road Toll',
    description: 'A deacon blocks the road with a chain and a wooden collection box. "A tithe for the upkeep of the sacred road, friends. All who pass must pay."',
    choices: [
      EventChoice(
        label: 'Pay the tithe (15 gold)',
        outcome: 'You pay. The deacon nods, blesses your company, and steps aside. Your devotion is noted.',
        effect: EventEffect(goldDelta: -15, devotionDelta: 3.0),
      ),
      EventChoice(
        label: 'Push past',
        outcome: 'You duck under the chain and ignore the shouted protests behind you.',
        effect: EventEffect(),
      ),
    ],
  ),
  TravelEvent(
    id: 'tch_wounded',
    title: 'A Wounded Priest',
    description: 'A young priest sits against a mile-marker, clutching a gashed leg. "Bandits. They took my relics — everything." He looks up. "I am no fighter, but a blessing is what I can offer."',
    choices: [
      EventChoice(
        label: 'Tend his wounds',
        outcome: 'You bandage the priest\'s leg. He thanks you earnestly and traces a holy symbol on each of your brows.',
        effect: EventEffect(partyHeal: 20, devotionDelta: 4.0),
      ),
      EventChoice(
        label: 'Give him gold and move on',
        outcome: 'You leave him a handful of coin. He calls a quiet blessing after you.',
        effect: EventEffect(goldDelta: -10, devotionDelta: 2.0),
      ),
    ],
  ),
  TravelEvent(
    id: 'tch_relic',
    title: 'A Relic on the Road',
    description: 'A small carved icon lies in the dust — a saint\'s face worn smooth by handling. Dropped by a pilgrim, or abandoned.',
    choices: [
      EventChoice(
        label: 'Leave it where it lies',
        outcome: 'You leave it. Perhaps whoever needs it will find it.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Bring it to the church',
        outcome: 'You pocket the icon, meaning to leave it at the shrine. A quiet warmth settles over the company.',
        effect: EventEffect(devotionDelta: 5.0),
      ),
    ],
  ),
  TravelEvent(
    id: 'tch_confession',
    title: 'The Offering of Confession',
    description: 'A priest is seated in a folding chair at the road\'s edge, a small curtained screen beside him. He is offering confession to travellers — no appointment needed, no coin asked. He has been there since dawn, he says.',
    choices: [
      EventChoice(
        label: 'Confess something',
        outcome: 'The priest listens without interruption. He gives a penance of one good act before nightfall. You feel, obscurely, lighter.',
        effect: EventEffect(partyHeal: 15, devotionDelta: 8, targetFaith: FaithType.luminantChurch),
      ),
      EventChoice(
        label: 'Ask what drives him to do this',
        outcome: '"There is more guilt on this road than any church can hold," he says. "So we bring the church to the guilt." You can\'t argue with the logic.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Move past',
        outcome: 'He doesn\'t call after you. Grace doesn\'t chase.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tch_candles',
    title: 'The Extinguished Candles',
    description: 'The roadside shrine to the Luminant Church has twelve candles in holders — all recently extinguished, all still smoking. No wind. The wax is soft. Someone snuffed these within the last few minutes.',
    choices: [
      EventChoice(
        label: 'Relight all twelve',
        outcome: 'They take flame easily, one from the other. The shrine holds the light. Something about the act has the weight of continuation.',
        effect: EventEffect(devotionDelta: 9, targetFaith: FaithType.luminantChurch),
      ),
      EventChoice(
        label: 'Light just one and move on',
        outcome: 'One candle is enough to say what needs saying.',
        effect: EventEffect(devotionDelta: 5),
      ),
      EventChoice(
        label: 'Leave them as they are',
        outcome: 'Someone put them out for a reason. You don\'t claim to know what it was.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tch_offering_broken',
    title: 'The Broken Collection',
    description: 'The church\'s roadside offering box has been broken into — split at the base, coins scattered in the mud. The perpetrator didn\'t bother to hide it. A young deacon is standing over the mess, not sure what to do.',
    choices: [
      EventChoice(
        label: 'Help collect what remains',
        outcome: 'Between you, you gather most of it back. The deacon thanks you with the particular sincerity of someone whose faith has just been tested and held.',
        effect: EventEffect(partyDamage: 3, devotionDelta: 7, targetFaith: FaithType.luminantChurch),
      ),
      EventChoice(
        label: 'Give the deacon coin to replace it  (–20g)',
        outcome: 'He looks at the coin a long moment. "The Church will remember this," he says. He means it without the usual weight of threat.',
        effect: EventEffect(goldDelta: -20, devotionDelta: 10),
      ),
      EventChoice(
        label: 'Move past — this isn\'t your business',
        outcome: 'The deacon watches you go. Nothing in his expression says he blames you.',
        effect: EventEffect(),
      ),
    ],
  ),
];

const _shrineEvents = [
  TravelEvent(
    id: 'tsh_offering',
    title: 'A Stone Bowl',
    description: 'An old shrine stone stands at the roadside, a bowl carved into its face filled with rainwater and flower petals. A tradition older than the Road itself.',
    choices: [
      EventChoice(
        label: 'Add your own offering',
        outcome: 'You leave a coin and a few words for the old gods. The air seems lighter for a moment.',
        effect: EventEffect(goldDelta: -5, devotionDelta: 5.0),
      ),
      EventChoice(
        label: 'Take the coin already there',
        outcome: 'You pocket the offering left by another. Whatever luck it carried is yours now — or their misfortune.',
        effect: EventEffect(goldDelta: 8),
      ),
    ],
  ),
  TravelEvent(
    id: 'tsh_elder',
    title: 'The Keeper of the Way',
    description: 'An old woman tends the shrine, replacing flowers and muttering old words. She looks up at you with sharp green eyes. "The old ways ask nothing. But they remember everything."',
    choices: [
      EventChoice(
        label: 'Ask for her blessing',
        outcome: 'She places her hands on the foreheads of each hero in turn, whispering old words. The company feels steady, grounded.',
        effect: EventEffect(partyHeal: 15, devotionDelta: 4.0),
      ),
      EventChoice(
        label: 'Pass by',
        outcome: 'She watches you go without a word.',
        effect: EventEffect(),
      ),
    ],
  ),
  TravelEvent(
    id: 'tsh_rain',
    title: 'The Ritual Rain',
    description: 'A brief shower breaks out as you approach the shrine. Local custom holds that rain at a way-marker is a sign of cleansing — a second chance offered by the earth.',
    choices: [
      EventChoice(
        label: 'Stand in the rain',
        outcome: 'You let the water fall on you, standing quietly at the shrine. The walk ahead feels less heavy.',
        effect: EventEffect(partyHeal: 25, devotionDelta: 3.0),
      ),
      EventChoice(
        label: 'Shelter and wait',
        outcome: 'You huddle under a tree until the rain passes. The shrine glistens but you feel no different.',
        effect: EventEffect(),
      ),
    ],
  ),
  TravelEvent(
    id: 'tsh_ask',
    title: 'Something Left Behind',
    description: 'A folded letter is tucked into a crack in the shrine stone. Addressed to no one in particular: "If you read this — please pray for me."',
    choices: [
      EventChoice(
        label: 'Say a prayer',
        outcome: 'You pause and say the words, meaning them. Something about the act settles on you like a held breath let go.',
        effect: EventEffect(devotionDelta: 5.0),
      ),
      EventChoice(
        label: 'Leave it untouched',
        outcome: 'You walk on. The letter remains.',
        effect: EventEffect(),
      ),
    ],
  ),
  TravelEvent(
    id: 'tsh_fresh_flowers',
    title: 'Flowers With No One',
    description: 'Fresh flowers at the shrine — placed today, still carrying water from the stems. No one visible for half a mile in any direction. The road is empty. The flowers are fresh.',
    choices: [
      EventChoice(
        label: 'Add your own offering',
        outcome: 'You add to the arrangement without knowing who placed the first flowers. The act of tending what someone else began feels like its own kind of prayer.',
        effect: EventEffect(devotionDelta: 7, targetFaith: FaithType.oldWays),
      ),
      EventChoice(
        label: 'Wait to see who placed them',
        outcome: 'An hour passes. No one comes. The flowers don\'t wilt. You leave.',
        effect: EventEffect(partyHeal: 10),
      ),
      EventChoice(
        label: 'Leave them and walk on',
        outcome: 'Someone\'s devotion. Not yours to question.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tsh_children',
    title: 'The Children\'s Games',
    description: 'Local children are playing in the approach to the shrine — some kind of elaborate pretend-ritual with stones and chalk marks. They don\'t stop when your company passes. One of them calls out: "You have to pay the toll!"',
    choices: [
      EventChoice(
        label: 'Pay the toll  (–5g)',
        outcome: 'A small coin changes hands. The child announces your company has been "properly blessed" and the game continues. The declaration has more weight than expected.',
        effect: EventEffect(goldDelta: -5, devotionDelta: 5),
      ),
      EventChoice(
        label: 'Play along with the ritual',
        outcome: 'You perform the chalk-circle walk as instructed and receive a daisy chain and a serious nod. Something in the old ways started exactly like this.',
        effect: EventEffect(devotionDelta: 8, targetFaith: FaithType.oldWays),
      ),
      EventChoice(
        label: 'Walk past with a nod',
        outcome: 'The children watch with great solemnity. One of them whispers something to another. You do not find out what.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tsh_circle_fox',
    title: 'The Circling Animal',
    description: 'A fox has been circling the shrine for — judging by the track worn in the grass — several days. It circles as you watch. It does not approach. It does not leave.',
    choices: [
      EventChoice(
        label: 'Leave an offering at the centre',
        outcome: 'You place bread at the shrine stone and step back. The fox stops circling. It approaches, takes the bread, and walks into the trees. The track in the grass fills with morning dew.',
        effect: EventEffect(devotionDelta: 9, targetFaith: FaithType.oldWays),
      ),
      EventChoice(
        label: 'Try to intercept the fox',
        outcome: 'It doesn\'t speed up. It simply isn\'t where you reach. On the fourth attempt you give up and the circling continues.',
        effect: EventEffect(partyDamage: 4),
      ),
      EventChoice(
        label: 'Watch from a respectful distance',
        outcome: 'You observe for ten minutes. The fox completes three full circuits without acknowledging you. Some things have their own business.',
        effect: EventEffect(devotionDelta: 4),
      ),
    ],
  ),
];

const _cultSiteEvents = [
  TravelEvent(
    id: 'tcs_watcher',
    title: 'The Watcher',
    description: 'A hooded figure stands motionless at the road\'s edge, watching your company. No weapon, no greeting, just steady eyes visible beneath the hood.',
    choices: [
      EventChoice(
        label: 'Approach and speak',
        outcome: 'The figure studies you and leaves a small carved token in your path before disappearing into the trees.',
        effect: EventEffect(goldDelta: 10),
      ),
      EventChoice(
        label: 'Ignore them',
        outcome: 'You give the watcher a wide berth. Nothing happens. Nothing visible, anyway.',
        effect: EventEffect(),
      ),
    ],
  ),
  TravelEvent(
    id: 'tcs_burned',
    title: 'Ashes in a Circle',
    description: 'A circle of ash — eight feet across, still warm — sits in a clearing beside the road. Whatever ritual ended here did so recently.',
    choices: [
      EventChoice(
        label: 'Examine the ashes',
        outcome: 'A fragment of bone and a melted copper idol. Whatever this was, it was taken seriously.',
        effect: EventEffect(devotionDelta: 3.0),
      ),
      EventChoice(
        label: 'Walk around it',
        outcome: 'You give the circle a wide berth. Some things are better not understood.',
        effect: EventEffect(),
      ),
    ],
  ),
  TravelEvent(
    id: 'tcs_offer',
    title: 'A Cloaked Figure',
    description: 'Someone steps from the shadow of the trees ahead — young, pale, holding out a wrapped parcel with both hands. "For those on the path. An offering of the Rite."',
    choices: [
      EventChoice(
        label: 'Accept the offering',
        outcome: 'Inside: dried herbs, a small vial, and a coin marked with an unfamiliar symbol. No harm in it.',
        effect: EventEffect(goldDelta: 20, devotionDelta: 2.0),
      ),
      EventChoice(
        label: 'Refuse and move on',
        outcome: 'You shake your head. They nod slowly and fade back into the trees.',
        effect: EventEffect(),
      ),
    ],
  ),
  TravelEvent(
    id: 'tcs_sign',
    title: 'A Mark on the Road',
    description: 'Someone has painted a complex symbol in red on the road stones ahead. Three concentric rings with a void at the centre — the mark of the Ashen Rite.',
    choices: [
      EventChoice(
        label: 'Step through it',
        outcome: 'Your boots cross the symbol. A strange heat passes through the soles of your feet and is gone.',
        effect: EventEffect(devotionDelta: 4.0, targetFaith: FaithType.ashenRite),
      ),
      EventChoice(
        label: 'Go around',
        outcome: 'You step wide. Better not to invite whatever attention this marks.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tcs_painting',
    title: 'The Symbol-Painter',
    description: 'A figure crouches at the road\'s edge, painting slow concentric rings onto the stones with red ochre. They don\'t look up as you approach. Each ring is exactly the same width. The concentration is absolute.',
    choices: [
      EventChoice(
        label: 'Watch them finish',
        outcome: 'They complete three rings and sit back. Then they look at you as if they expected you specifically. "The rite holds until the next rain," they say. "Watch for the dry stretch."',
        effect: EventEffect(devotionDelta: 6, targetFaith: FaithType.ashenRite),
      ),
      EventChoice(
        label: 'Ask what the symbol does',
        outcome: '"Nothing," they say. "That\'s the point." They return to their work. You think about that for the rest of the road.',
        effect: EventEffect(devotionDelta: 4),
      ),
      EventChoice(
        label: 'Step around the wet paint and continue',
        outcome: 'The painter doesn\'t acknowledge you passing. The rings continue behind you.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tcs_gathering_remains',
    title: 'After the Gathering',
    description: 'You arrive at a clearing where something was held recently — torch-marks on the trees, ash in a central circle, a scent of specific incense your company can\'t agree on. Whatever happened here, it concluded hours ago.',
    choices: [
      EventChoice(
        label: 'Search the site',
        outcome: 'Offerings left behind intentionally — not forgotten, placed. Coin wrapped in red thread, a folded message sealed with ash. The coin is real. The message is in cipher.',
        effect: EventEffect(goldDelta: 30, devotionDelta: 4, targetFaith: FaithType.ashenRite),
      ),
      EventChoice(
        label: 'Stand in the central ash and observe',
        outcome: 'The silence of an ended ritual is its own kind of sound. You stand in it long enough to hear what it says. Your company waits without asking why.',
        effect: EventEffect(devotionDelta: 7, targetFaith: FaithType.ashenRite),
      ),
      EventChoice(
        label: 'Move through without stopping',
        outcome: 'You were not invited. You pass without disturbing what remains.',
        effect: EventEffect(),
      ),
    ],
  ),

  TravelEvent(
    id: 'tcs_lost_seeker',
    title: 'The Lost Seeker',
    description: 'Someone is wandering the road in circles — a young man, well-dressed but dishevelled, who appears to have been looking for the cult site for some time and taken several wrong paths. He looks up with desperate relief when he sees you.',
    choices: [
      EventChoice(
        label: 'Guide him to the site',
        outcome: 'You show him the right bearing. He presses coin on you with the intensity of someone who has been walking since yesterday. It\'s more than you expected.',
        effect: EventEffect(goldDelta: 25, devotionDelta: 4),
      ),
      EventChoice(
        label: 'Let him find his own way',
        outcome: 'He had to want it enough to find it. Some roads choose their walkers.',
        effect: EventEffect(),
      ),
      EventChoice(
        label: 'Ask what draws him to the cult',
        outcome: '"A question I can\'t answer," he says, "that the Rite is supposed to ask back at you." He finds his own way eventually. So do most of them.',
        effect: EventEffect(devotionDelta: 3),
      ),
    ],
  ),
];

// ─── CAMPFIRE EVENTS ─────────────────────────────────────────────────────────

const campfireEvents = [
  TravelEvent(
    id: 'cf_warmth',
    title: 'The Campfire',
    description: 'The party calls a halt as dusk settles. A fire is built, rations shared, and for a moment the road feels less bleak. The wounded tend their cuts; the weary sharpen their blades.',
    choices: [
      EventChoice(
        label: 'Rest and recover',
        outcome: 'The warmth does its work. The party rises ready for whatever lies ahead.',
        effect: EventEffect(partyHeal: 15),
      ),
      EventChoice(
        label: 'Keep watch and press on early',
        outcome: 'You catch a few hours\' sleep in rotation. Not comfortable, but you\'re moving again before the dew settles.',
        effect: EventEffect(partyHeal: 5, goldDelta: 10),
      ),
    ],
  ),
  TravelEvent(
    id: 'cf_stories',
    title: 'Tales by the Fire',
    description: 'The fire pops and crackles. Someone begins talking — about the road, about the old world, about why they are here at all. The others find themselves listening.',
    choices: [
      EventChoice(
        label: 'Swap stories and rest',
        outcome: 'There is something in the talking. The party wakes lighter than they slept.',
        effect: EventEffect(partyHeal: 18),
      ),
      EventChoice(
        label: 'Use the quiet to scout ahead',
        outcome: 'You circle the camp perimeter. Nothing threatening — but you find a coin pouch half-buried near a cold fire pit.',
        effect: EventEffect(goldDelta: 25, partyHeal: 5),
      ),
    ],
  ),
  TravelEvent(
    id: 'cf_rain',
    title: 'Rain in the Night',
    description: 'The sky opens without warning. The fire sputters and dies. You huddle under what cover the trees offer, cold and damp, waiting for dawn.',
    choices: [
      EventChoice(
        label: 'Endure it',
        outcome: 'You wait it out. Cold, but intact.',
        effect: EventEffect(partyDamage: 4),
      ),
      EventChoice(
        label: 'Find shelter in the ruins nearby',
        outcome: 'The old walls keep the worst of it off. Dry enough to sleep, but the ruins have a watching quality that keeps rest shallow.',
        effect: EventEffect(partyHeal: 8),
      ),
    ],
  ),
  TravelEvent(
    id: 'cf_visitor',
    title: 'A Lone Traveller',
    description: 'A figure emerges from the dark beyond your fire — no weapon drawn, hands visible. "Room at the fire?" they ask. "I can pay in coin or in news."',
    choices: [
      EventChoice(
        label: 'Let them sit — take the coin',
        outcome: 'They pay well and say little. By morning they are gone.',
        effect: EventEffect(goldDelta: 30),
      ),
      EventChoice(
        label: 'Let them sit — take the news',
        outcome: 'They speak of a cache left by a departed scholar — and draw a rough map on a scrap of cloth.',
        effect: EventEffect(partyHeal: 10, goldDelta: 15),
      ),
      EventChoice(
        label: 'Turn them away',
        outcome: 'They move on without argument. The fire feels quieter for it.',
        effect: EventEffect(),
      ),
    ],
  ),
];

List<TravelEvent> travelEventsFor(LocationType type) => switch (type) {
      LocationType.town       => _townEvents,
      LocationType.dungeon    => _dungeonEvents,
      LocationType.castle     => _castleEvents,
      LocationType.wilderness => _wildernessEvents,
      LocationType.ruins      => _ruinsEvents,
      LocationType.monastery  => _monasteryEvents,
      LocationType.cemetery   => _cemeteryEvents,
      LocationType.library    => _libraryEvents,
      LocationType.forge      => _forgeEvents,
      LocationType.church     => _churchEvents,
      LocationType.shrine     => _shrineEvents,
      LocationType.cultSite   => _cultSiteEvents,
    };

TravelEvent? travelEventById(String id) {
  for (final type in LocationType.values) {
    final found = travelEventsFor(type).where((e) => e.id == id).firstOrNull;
    if (found != null) return found;
  }
  // Check campfire events too
  final cf = campfireEvents.where((e) => e.id == id).firstOrNull;
  if (cf != null) return cf;
  return null;
}
