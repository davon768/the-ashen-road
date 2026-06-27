import '../models/property.dart';
import '../models/property_event.dart';

const List<PropertyEventDef> allPropertyEvents = [

  // ─── TAVERN ─────────────────────────────────────────────────────────────────

  PropertyEventDef(
    id: 'tavern_generous_traveler',
    title: 'A Round on the House',
    description: 'A well-dressed traveler bought drinks for the entire common room last night and left without giving a name. Your staff collected the tips.',
    forType: PropertyType.tavern,
    choices: [
      PropertyEventChoice(
        label: 'Keep the tips',
        outcome: 'Eighty gold and no questions asked. The kind of evening that pays for itself.',
        goldDelta: 80,
      ),
      PropertyEventChoice(
        label: 'Donate the windfall',
        outcome: 'You put the coin toward the local poor-box. Word gets around. The tavern gains a reputation for generosity.',
        goldDelta: -10,
        devotionDelta: 8,
      ),
    ],
  ),

  PropertyEventDef(
    id: 'tavern_brawl',
    title: 'Last Night\'s Brawl',
    description: 'A fight broke out over a card game. Two tables are splintered, three chairs are gone, and someone put a boot through the window.',
    forType: PropertyType.tavern,
    choices: [
      PropertyEventChoice(
        label: 'Pay for repairs',
        outcome: 'Sixty gold and a new policy about card games after dark.',
        goldDelta: -60,
      ),
      PropertyEventChoice(
        label: 'Bar the troublemakers and move on',
        outcome: 'The furniture stays broken for now. Customers notice, but they also know who started it.',
        goldDelta: -15,
      ),
    ],
  ),

  PropertyEventDef(
    id: 'tavern_pilgrim_story',
    title: 'The Pilgrim\'s Story',
    description: 'An old pilgrim has been telling a story every evening for three days — something about Grimhaven, heard from a man who walked back. The common room is full each night.',
    forType: PropertyType.tavern,
    choices: [
      PropertyEventChoice(
        label: 'Let him stay as long as he likes',
        outcome: 'Business is up. Whatever he saw at Grimhaven, it tells well.',
        goldDelta: 40,
        devotionDelta: 5,
      ),
      PropertyEventChoice(
        label: 'Charge him for the hospitality',
        outcome: 'He pays without complaint. He has been paying his way since before you were born.',
        goldDelta: 55,
      ),
    ],
  ),

  // ─── BLACKSMITH ─────────────────────────────────────────────────────────────

  PropertyEventDef(
    id: 'blacksmith_unusual_order',
    title: 'The Unusual Commission',
    description: 'A hooded figure wants a specific piece of metalwork — not a weapon, not a tool. Something with unusual dimensions and specific alloy requirements. They have offered good coin.',
    forType: PropertyType.blacksmith,
    choices: [
      PropertyEventChoice(
        label: 'Fill the order',
        outcome: 'You do not ask what it is for. The coin is real.',
        goldDelta: 120,
      ),
      PropertyEventChoice(
        label: 'Refuse — you do not like the look of it',
        outcome: 'The figure leaves without argument. You half-expect to regret the decision. Nothing happens. Maybe that is the regret.',
        devotionDelta: 4,
      ),
    ],
  ),

  PropertyEventDef(
    id: 'blacksmith_quality_iron',
    title: 'Quality Iron',
    description: 'A merchant passing through has surplus iron — very clean stock, unusually consistent. He is selling below market price because he needs to move quickly.',
    forType: PropertyType.blacksmith,
    choices: [
      PropertyEventChoice(
        label: 'Buy the lot',
        outcome: 'Ninety gold and enough iron to last months. Your smith is pleased.',
        goldDelta: -90,
      ),
      PropertyEventChoice(
        label: 'Buy half',
        outcome: 'Forty-five gold. Enough to keep things running well for a while.',
        goldDelta: -45,
      ),
      PropertyEventChoice(
        label: 'Pass',
        outcome: 'Someone else will take it. You have enough iron for now.',
      ),
    ],
  ),

  PropertyEventDef(
    id: 'blacksmith_buried_find',
    title: 'Something in the Floor',
    description: 'Your apprentice was relaying the forge floor and found old metalwork buried beneath — pre-Church, by the look of it. Possibly older. It is intact and finely made.',
    forType: PropertyType.blacksmith,
    choices: [
      PropertyEventChoice(
        label: 'Sell it to a collector',
        outcome: 'A hundred and ten gold from a man who did not explain what he wanted it for.',
        goldDelta: 110,
      ),
      PropertyEventChoice(
        label: 'Report it to the Church',
        outcome: 'They take it and give you a receipt. The receipt is worth nothing. The act is worth something.',
        devotionDelta: 10,
      ),
      PropertyEventChoice(
        label: 'Keep it',
        outcome: 'It goes behind a loose stone in the wall. You are not sure why. It seemed like the right thing to do.',
        goldDelta: 30,
      ),
    ],
  ),

  // ─── APOTHECARY ─────────────────────────────────────────────────────────────

  PropertyEventDef(
    id: 'apothecary_strange_request',
    title: 'The Unusual Request',
    description: 'A hooded buyer wants a large supply of a specific compound — legal, barely. They have not explained the purpose. The order would pay well.',
    forType: PropertyType.apothecary,
    choices: [
      PropertyEventChoice(
        label: 'Sell without questions',
        outcome: 'A hundred and thirty gold. You do not ask. You choose not to think about it.',
        goldDelta: 130,
        devotionDelta: -6,
      ),
      PropertyEventChoice(
        label: 'Refuse the order',
        outcome: 'They leave. You lose the sale but keep the sleep.',
        devotionDelta: 5,
      ),
    ],
  ),

  PropertyEventDef(
    id: 'apothecary_herb_surplus',
    title: 'A Good Season',
    description: 'Unusual weather has yielded a bumper harvest from the herb garden. You have more stock than you can easily move through normal channels.',
    forType: PropertyType.apothecary,
    choices: [
      PropertyEventChoice(
        label: 'Sell the surplus now',
        outcome: 'Seventy gold at slightly below your normal rate. Better than letting it rot.',
        goldDelta: 70,
      ),
      PropertyEventChoice(
        label: 'Dry and store it',
        outcome: 'You spend twenty gold on proper storage. The herbs last through winter and sell at full price.',
        goldDelta: -20,
      ),
    ],
  ),

  PropertyEventDef(
    id: 'apothecary_sick_traveler',
    title: 'The Traveler at the Door',
    description: 'Someone arrived last night in bad condition — not injured, sick. Something from the east, by the look of the symptoms. They cannot pay.',
    forType: PropertyType.apothecary,
    choices: [
      PropertyEventChoice(
        label: 'Treat them for free',
        outcome: 'Forty gold in materials and three days of your attention. They recover. They leave without saying much. The road does not owe you anything back.',
        goldDelta: -40,
        devotionDelta: 12,
      ),
      PropertyEventChoice(
        label: 'Stabilize them and send them on',
        outcome: 'You do what you can at minimal cost. They leave. You tell yourself it was enough.',
        goldDelta: -10,
        devotionDelta: 3,
      ),
      PropertyEventChoice(
        label: 'Turn them away',
        outcome: 'You cannot treat everyone. The road does not owe you anything either.',
      ),
    ],
  ),

  // ─── GENERAL STORE ──────────────────────────────────────────────────────────

  PropertyEventDef(
    id: 'store_missing_stock',
    title: 'Missing Inventory',
    description: 'A full accounting revealed that stock has been quietly disappearing — not much at once, but consistently. Someone has been helping themselves.',
    forType: PropertyType.generalStore,
    choices: [
      PropertyEventChoice(
        label: 'Write it off as shrinkage',
        outcome: 'Sixty gold gone and a note in the ledger. You will watch more carefully going forward.',
        goldDelta: -60,
      ),
      PropertyEventChoice(
        label: 'Investigate properly',
        outcome: 'Twenty gold for the investigation and two days of work. You find the culprit — a supplier, not a customer. You recover most of what was taken.',
        goldDelta: 50,
        devotionDelta: 3,
      ),
    ],
  ),

  PropertyEventDef(
    id: 'store_rare_goods',
    title: 'Unusual Stock',
    description: 'A merchant is offering goods your regular customers would not normally find: unusual spices, pre-Church printed texts, materials with unclear provenance.',
    forType: PropertyType.generalStore,
    choices: [
      PropertyEventChoice(
        label: 'Stock everything',
        outcome: 'A hundred gold spent. The items sell quickly to customers who had not expected to find them here. You turn a profit.',
        goldDelta: 60,
      ),
      PropertyEventChoice(
        label: 'Pick carefully',
        outcome: 'Forty gold on the safest items. A modest profit and no awkward questions.',
        goldDelta: 25,
      ),
      PropertyEventChoice(
        label: 'Pass on the offer',
        outcome: "You don't want the attention. The merchant takes his wares elsewhere.",
      ),
    ],
  ),

  PropertyEventDef(
    id: 'store_loyal_customer',
    title: 'An Old Debt',
    description: 'A long-time customer has hit hard times — a bad season, a failed crop. They are asking for credit, which you do not normally extend.',
    forType: PropertyType.generalStore,
    choices: [
      PropertyEventChoice(
        label: 'Extend the credit',
        outcome: 'Fifty gold extended on good faith. They repay eventually. People remember generosity on the road.',
        goldDelta: -50,
        devotionDelta: 8,
      ),
      PropertyEventChoice(
        label: 'Sell at standard rates',
        outcome: 'Business is business. They understand.',
      ),
    ],
  ),

  // ─── STABLES ────────────────────────────────────────────────────────────────

  PropertyEventDef(
    id: 'stables_sick_horse',
    title: 'The Sick Animal',
    description: 'One of your horses has fallen ill. A stable hand says it can recover with proper care. A buyer is also offering to take it off your hands before it gets worse.',
    forType: PropertyType.stables,
    choices: [
      PropertyEventChoice(
        label: 'Pay for proper treatment',
        outcome: 'Eighty gold for a vet and two weeks of care. The horse recovers fully.',
        goldDelta: -80,
      ),
      PropertyEventChoice(
        label: 'Try home remedies',
        outcome: 'Twenty gold in herbs and effort. The horse recovers, more or less.',
        goldDelta: -20,
      ),
      PropertyEventChoice(
        label: 'Sell it now',
        outcome: 'Forty gold for a sick horse. The buyer knows what they are getting and charges accordingly for the risk.',
        goldDelta: 40,
      ),
    ],
  ),

  PropertyEventDef(
    id: 'stables_lost_mount',
    title: 'The Escaped Horse',
    description: 'A traveler\'s mount broke free overnight and has not been found. The traveler cannot continue without it and has no money for a replacement.',
    forType: PropertyType.stables,
    choices: [
      PropertyEventChoice(
        label: 'Help organize a search',
        outcome: 'Two hours and thirty gold in disrupted work. The horse is found three fields over. The traveler weeps.',
        goldDelta: -30,
        devotionDelta: 7,
      ),
      PropertyEventChoice(
        label: 'Offer them a rental at a fair rate',
        outcome: 'Practical help at a fair price. They accept with relief.',
        goldDelta: 35,
      ),
    ],
  ),

  PropertyEventDef(
    id: 'stables_wild_horse',
    title: 'The Uninvited Guest',
    description: 'A wild horse wandered into the paddock overnight — young, unbroken, and apparently uninterested in leaving. No one has claimed it.',
    forType: PropertyType.stables,
    choices: [
      PropertyEventChoice(
        label: 'Keep it and add it to the stock',
        outcome: 'A week of work to break it properly. A solid animal once it decides to cooperate.',
        goldDelta: -15,
      ),
      PropertyEventChoice(
        label: 'Sell it immediately',
        outcome: 'Sixty gold for an unbroken horse to someone who enjoys that kind of challenge.',
        goldDelta: 60,
      ),
    ],
  ),

  // ─── CASTLE ─────────────────────────────────────────────────────────────────

  PropertyEventDef(
    id: 'castle_tax_dispute',
    title: 'The Competing Claim',
    description: 'A minor lord is contesting your right to the castle through Church legal channels. The claim is weak but annoying. It will cost money to resolve.',
    forType: PropertyType.castle,
    choices: [
      PropertyEventChoice(
        label: 'Fight it through proper channels',
        outcome: 'One hundred and fifty gold in legal fees. The claim is dismissed. The minor lord looks for other grievances.',
        goldDelta: -150,
        devotionDelta: 4,
      ),
      PropertyEventChoice(
        label: 'Buy them off quietly',
        outcome: 'Two hundred gold and a handshake. The claim disappears. So does the lord.',
        goldDelta: -200,
      ),
    ],
  ),

  PropertyEventDef(
    id: 'castle_refugees',
    title: 'The Outer Courtyard',
    description: 'Refugees from somewhere east have been sheltering in the outer courtyard for three days. Word has spread. More are arriving.',
    forType: PropertyType.castle,
    choices: [
      PropertyEventChoice(
        label: 'Let them stay and feed them',
        outcome: 'Eighty gold in food and organization. Your name is spoken well along the road going west.',
        goldDelta: -80,
        devotionDelta: 14,
      ),
      PropertyEventChoice(
        label: 'Charge a small shelter fee',
        outcome: 'Thirty gold recovered. They pay without complaint. They have nothing else left to argue over.',
        goldDelta: 30,
        devotionDelta: -3,
      ),
      PropertyEventChoice(
        label: 'Move them on',
        outcome: 'They leave. The courtyard is clear. You try not to think about where they go.',
        devotionDelta: -8,
      ),
    ],
  ),

  PropertyEventDef(
    id: 'castle_hidden_cache',
    title: 'What Was in the Wall',
    description: 'Workers repointing the north wall found a sealed hollow containing old coin, a sealed letter with no address, and a ring with a crest you do not recognize.',
    forType: PropertyType.castle,
    choices: [
      PropertyEventChoice(
        label: 'Keep it — it is your castle',
        outcome: 'A hundred and forty gold in old coin. The letter is written in a script no one in your party can read. The ring goes in a drawer.',
        goldDelta: 140,
      ),
      PropertyEventChoice(
        label: 'Report it to the Church',
        outcome: 'They take the letter and the ring immediately and seem unsurprised. You receive a formal thanks. The coin you are allowed to keep.',
        goldDelta: 100,
        devotionDelta: 10,
      ),
    ],
  ),
];

PropertyEventDef? propertyEventById(String id) {
  for (final e in allPropertyEvents) {
    if (e.id == id) return e;
  }
  return null;
}

List<PropertyEventDef> eventsForType(PropertyType type) =>
    allPropertyEvents.where((e) => e.forType == type).toList();
