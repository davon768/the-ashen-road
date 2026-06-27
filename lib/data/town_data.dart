import 'dart:math';
import '../models/town_visit.dart';
import '../models/enums.dart';
import '../data/weapons_data.dart';
import '../data/armor_data.dart';
import '../data/spells_data.dart';

// ─── NPC POOL ──────────────────────────────────────────────────────────────

const List<TownNpc> _allTownNpcs = [

  // ── INNKEEPERS / LOCALS ──────────────────────────────────────────────────

  TownNpc(
    id: 'marta_ashveil',
    name: 'Marta Ashveil',
    role: 'Innkeeper',
    greeting: 'I\'ve got beds if you\'ve got coin. The soup\'s thin tonight, but it\'s hot. That\'s all I can promise you on this road.',
    questHint: 'A merchant from the south was supposed to arrive three days ago. His regular room is still paid for. I haven\'t told anyone yet.',
  ),

  TownNpc(
    id: 'bram_coldwater',
    name: 'Bram Coldwater',
    role: 'Innkeeper',
    greeting: 'Used to soldier, now I pour ale. Safer work. Mostly. Sit down — you look like the road\'s been chewing on you.',
    questHint: 'We had an Iron Chapter deacon through last week. Wouldn\'t say where he was headed, kept asking about the old road north. No one takes the old road north.',
  ),

  TownNpc(
    id: 'hilda_vane',
    name: 'Hilda Vane',
    role: 'Innkeeper',
    greeting: 'We don\'t ask where you\'ve been or where you\'re going. That\'s the rule here. Coin first, questions never.',
  ),

  // ── MERCHANTS / TRADERS ───────────────────────────────────────────────────

  TownNpc(
    id: 'sera_duskfen',
    name: 'Sera Duskfen',
    role: 'Cloth Merchant',
    greeting: 'From Salthaven, heading north before the passes close. The salt\'s eating through everything faster than it used to. Even the buildings. Even the people.',
    questHint: 'I passed through Millhaven six days ago. The mill is running day and night. Nobody goes near it after dark. The family that owns it hasn\'t been seen in months.',
  ),

  TownNpc(
    id: 'aldous_tarne',
    name: 'Aldous Tarne',
    role: 'General Merchant',
    greeting: 'Forty years on this road, friend. I\'ve seen it all. Well — almost all. Some things I saw once and didn\'t write down because I didn\'t want to remember them.',
    questHint: 'That vault east of the pale moors — the one the Church sealed? Someone\'s been using it again. Fresh torch marks on the outer stone. I don\'t know who. I don\'t want to.',
  ),

  TownNpc(
    id: 'wren_copperholm',
    name: 'Wren Copperholm',
    role: 'Travelling Tinker',
    greeting: 'Pots, knives, small tools. Whatever you need mended, I\'ll mend it. Whatever you need sharpened, sharper than when you bought it.',
  ),

  TownNpc(
    id: 'orlen_dusk',
    name: 'Orlen Dusk',
    role: 'Spice Trader',
    greeting: 'The eastern routes are closed — have been since the ash started falling there in earnest. I source what I can from the west now. It costs more and tastes less interesting.',
    questHint: 'The ash in the east isn\'t just falling anymore. It\'s drifting west. Slowly. My last contact past the Fells stopped writing a season ago.',
  ),

  // ── CHURCH (LUMINANT CHURCH) ─────────────────────────────────────────────

  TownNpc(
    id: 'friar_donet',
    name: 'Friar Donet',
    role: 'Traveling Friar',
    greeting: 'The Light travels with you, friend. Though I confess the Light has been harder to feel in these latitudes. Something in the air here resists blessing. The Church would prefer I not say that.',
    questHint: 'I carry a letter from the High Consistory to the commander at Ironwall. I\'m told it is a matter of urgency. No one has explained to me what the urgency is.',
  ),

  TownNpc(
    id: 'sister_orvyn',
    name: 'Sister Orvyn',
    role: 'Church Hospitaller',
    greeting: 'I administer medicines, not conversations. If you\'re injured, sit down. If you\'re healthy, move along. I have six people to see today and you don\'t look like an emergency.',
    questHint: 'There are cases of something new in the villages east of here. The symptoms don\'t match fever or rot. They match descriptions in documents the Church classified forty years ago.',
  ),

  TownNpc(
    id: 'deacon_hollvast',
    name: 'Deacon Hollvast',
    role: 'Iron Chapter Deacon',
    greeting: 'I am simply passing through. My business is the Church\'s business. I appreciate that you do not ask further.',
    questHint: 'The Charred Cathedral — what was inside it, the night of The Opening. I\'m told you can still see the outline of something in the ash on the floor if you go in. The Church says do not go in.',
  ),

  TownNpc(
    id: 'confessor_maren',
    name: 'Confessor Maren',
    role: 'Church Confessor',
    greeting: 'If you have something to confess, I am here. The Light does not distinguish between the weight of sins — only between those who carry them and those who do not.',
  ),

  // ── OLD WAYS ────────────────────────────────────────────────────────────

  TownNpc(
    id: 'hessa_bracken',
    name: 'Hessa Bracken',
    role: 'Herbalist',
    greeting: 'I sell remedies. Where I learned them is not your business. They work — that\'s your business.',
    questHint: 'The standing stones at Pale Moors are different than they were last season. Some of them have moved. Stone doesn\'t move. I\'m keeping track of which ones.',
  ),

  TownNpc(
    id: 'tal_ashwarden',
    name: 'Tal Ashwarden',
    role: 'Shepherd',
    greeting: 'Long road, long flock. I know every path through these hills that isn\'t on any Church map. Some of them are older than the Church, and they want to stay that way.',
    questHint: 'Ashwood — you know the grey forest east of here? The bark\'s getting darker than grey. And I can hear something moving in there at night that isn\'t animals.',
  ),

  TownNpc(
    id: 'cael_moorwatch',
    name: 'Cael Moorwatch',
    role: 'Wandering Practitioner',
    greeting: 'The old names for things still work even if no one remembers to use them. I remember them. That\'s enough.',
    questHint: 'Stone-Mother is restless under the Black Maw. The Old Ways feel it like a change in weather. Something is pushing up from below. It\'s been pushing for three years.',
  ),

  // ── PALE COURT ──────────────────────────────────────────────────────────

  TownNpc(
    id: 'mortician_gilles',
    name: 'Gilles Pale',
    role: 'Mortician',
    greeting: 'I travel where my work takes me. Death is not particular about location, and neither am I. You look healthy, by the way. I say this professionally.',
    questHint: 'The unclaimed dead from the region east of Grimhaven — the Pale Court is no longer finding them. Something is taking them first. We don\'t know what. We don\'t know why. We find this very concerning.',
  ),

  TownNpc(
    id: 'pale_stranger',
    name: 'A Pale-Eyed Stranger',
    role: 'Pale Court Adherent',
    greeting: 'I speak only of the dead when asked. I was not asked. Good day.',
    questHint: 'Someone opened the Forgotten Tomb. Not fully — just far enough to look inside. We\'ve sent someone to assess what was seen. They haven\'t returned. That is also concerning.',
  ),

  // ── COMPACT OF SAINTS ───────────────────────────────────────────────────

  TownNpc(
    id: 'pilgrim_osla',
    name: 'Osla Brightmantle',
    role: 'Saint\'s Day Pilgrim',
    greeting: 'On my way to Greywater for Saint Aldric\'s feast! Forty years that man carried his crimes before he found grace. Forty years! There\'s hope for anyone, don\'t you think?',
    questHint: 'In Greywater they say a man confessed to the sabotage of the old dam — the one that drowned the village. He confessed a hundred years too late but they wrote it in the ledger. That\'s how Greywater works.',
  ),

  TownNpc(
    id: 'compact_wayfarder',
    name: 'Renn Holloway',
    role: 'Compact Wayfarer',
    greeting: 'Walk with me if you like — the Saints keep better company than most. I carry their names in a book and read one aloud each morning. Today was Aldric. Yesterday was Mira of the Flooded Road.',
  ),

  // ── ASHEN RITE ──────────────────────────────────────────────────────────

  TownNpc(
    id: 'ash_marked',
    name: 'An Ash-Marked Wanderer',
    role: 'Ashen Rite Adherent',
    greeting: 'The Void breathes in the east. We go where it breathes to listen. What it says is not for me to translate — you would need a different kind of ear.',
    questHint: 'At the Salt Maw, where the underground channels stopped opening, we\'ve been listening for thirty years. Last month it started answering back. This is new. The elders say it\'s significant.',
  ),

  TownNpc(
    id: 'rite_archivist',
    name: 'Sable Einvast',
    role: 'Ashen Rite Archivist',
    greeting: 'I document the ash. Where it falls, in what density, on what dates. There are patterns. You would not find them reassuring.',
    questHint: 'The ash at Black Fells is accumulating faster than previous seasons. It has weight now, not just volume. The Void is pressing closer. The Rite believes The Opening was not a single event but the first in a series.',
  ),

  // ── SOLDIERS / MERCENARIES ───────────────────────────────────────────────

  TownNpc(
    id: 'sellsword_dravan',
    name: 'Dravan Korse',
    role: 'Mercenary',
    greeting: 'Looking for work. Good with a blade, better with terrain. Reasonable rates. I don\'t ask what for, you don\'t ask who else I\'ve worked for.',
    questHint: 'Coldstone keep — I did a stint there two winters ago. The Pale Margrave pays well and doesn\'t ask much. But the nights are wrong there. It\'s warm inside even in deep winter and there\'s no fire source I could find.',
  ),

  TownNpc(
    id: 'ex_soldier_reva',
    name: 'Reva Ashworth',
    role: 'Former Soldier',
    greeting: 'I served for twelve years. Mustered out three years ago. The road\'s quieter than a campaign and the food\'s about the same.',
    questHint: 'I was at Ironwall the year the reinforcements stopped coming. The commander wrote the letters himself. I delivered two of them. No one ever answered. We just... kept going.',
  ),

  TownNpc(
    id: 'chapter_deserter',
    name: 'A Quiet Man in Grey',
    role: 'Traveler',
    greeting: 'Just passing through. Don\'t want trouble. Don\'t ask about the chapter mark under my collar. Have a good road.',
    questHint: 'The Iron Chapter brothers at their headquarters — they\'re still drilling every morning. No orders. No one to fight for. They\'re maintaining themselves out of habit and it\'s starting to look like something else. Something that waits.',
  ),

  // ── SCHOLARS / OFFICIALS ─────────────────────────────────────────────────

  TownNpc(
    id: 'cartographer_voss',
    name: 'Voss Kettlewhite',
    role: 'Cartographer',
    greeting: 'The Church maps are wrong. Have been for decades. I\'ve walked every road on the official survey and I find things that aren\'t marked and don\'t find things that are.',
    questHint: 'There\'s a road north that predates everything — older than the Church, older than the Compact, possibly older than settlement in this region. It goes somewhere the new maps refuse to acknowledge.',
  ),

  TownNpc(
    id: 'tax_collector_odo',
    name: 'Odo Millwick',
    role: 'Tax Collector',
    greeting: 'I\'m looking for the village of Sorn\'s Crossing. It should be two days east by any map I have. I\'ve been walking for five days. Please tell me I\'m not going in circles.',
    questHint: 'My ledgers show three villages that haven\'t filed accounts in over a year. When I send runners to check, they come back and report the villages are there but the people don\'t answer doors.',
  ),

  // ── MONKS (for monasteries) ───────────────────────────────────────────────

  TownNpc(
    id: 'brother_aldric',
    name: 'Brother Aldric',
    role: 'Monastery Brother',
    greeting: 'Rest here as long as you need. The monastery asks only a small offering and your honest name. The second is optional.',
    questHint: 'The manuscripts in our lower archive describe The Opening — written before it happened. By two days. We don\'t discuss this with visitors. I have decided to make an exception.',
  ),

  TownNpc(
    id: 'prioress_vorn',
    name: 'Prioress Vorn',
    role: 'Monastery Prioress',
    greeting: 'You carry the road\'s dust on you. Wash before supper — we have water enough. Come to evening prayers if you wish. No obligation. The gods you follow or don\'t follow are your own business.',
    questHint: 'One of our brothers began writing in a script none of us recognize, three weeks ago. He doesn\'t remember doing it. The writing looks like what the Ashen Rite uses for things with no words in any living language.',
  ),

  TownNpc(
    id: 'brother_fael',
    name: 'Brother Fael',
    role: 'Monastery Keeper',
    greeting: 'I tend the crypts here. Most people find that uncomfortable. I find it peaceful. The dead are remarkably consistent.',
  ),
];

// ── NPCs that should appear only in monasteries ───────────────────────────
const Set<String> _monasteryOnlyNpcIds = {
  'brother_aldric', 'prioress_vorn', 'brother_fael',
};

// ─── TOWN VISIT GENERATION ────────────────────────────────────────────────

List<TownNpc> generateTownNpcs(Random rng, bool isMonastery, {int count = 3}) {
  final pool = _allTownNpcs.where((n) {
    if (isMonastery) return _monasteryOnlyNpcIds.contains(n.id);
    return !_monasteryOnlyNpcIds.contains(n.id);
  }).toList();
  pool.shuffle(rng);
  return pool.take(count.clamp(1, pool.length)).toList();
}

List<TraderOffer> generateTraderStock(Random rng, int depth, {List<String> knownSpellIds = const []}) {
  // Filter to depth-appropriate rarity
  final allowedRarities = {
    if (depth <= 2) ...[Rarity.common, Rarity.uncommon],
    if (depth == 3) ...[Rarity.uncommon, Rarity.rare],
    if (depth >= 4) ...[Rarity.rare, Rarity.epic],
  };

  final weaponPool = allWeapons
      .where((w) => allowedRarities.contains(w.rarity))
      .toList()
    ..shuffle(rng);
  final armorPool = allArmor
      .where((a) => allowedRarities.contains(a.rarity))
      .toList()
    ..shuffle(rng);

  final offers = <TraderOffer>[];
  int offerIndex = 0;

  // 2–3 weapons
  final weaponCount = 2 + rng.nextInt(2);
  for (final w in weaponPool.take(weaponCount)) {
    final markup = 1.5 + rng.nextDouble() * 0.8;
    offers.add(TraderOffer(
      offerId: 'offer_${offerIndex++}',
      itemId: w.id,
      isWeapon: true,
      displayName: w.name,
      price: (w.value * markup).round().clamp(5, 9999),
    ));
  }

  // 1–2 armor pieces
  final armorCount = 1 + rng.nextInt(2);
  for (final a in armorPool.take(armorCount)) {
    final markup = 1.5 + rng.nextDouble() * 0.8;
    offers.add(TraderOffer(
      offerId: 'offer_${offerIndex++}',
      itemId: a.id,
      isWeapon: false,
      displayName: a.name,
      price: (a.value * markup).round().clamp(5, 9999),
    ));
  }

  // 1–2 spell tomes — T1 always available, T2 at depth 3+, T3 at depth 5+
  final maxTier = depth >= 5 ? 3 : (depth >= 3 ? 2 : 1);
  final tomePool = allSpells
      .where((s) => s.tier <= maxTier && !knownSpellIds.contains(s.id))
      .toList()
    ..shuffle(rng);
  final tomeCount = 1 + rng.nextInt(2);
  final addedTomeSpellIds = <String>{};
  for (final spell in tomePool) {
    if (addedTomeSpellIds.length >= tomeCount) break;
    if (addedTomeSpellIds.contains(spell.id)) continue;
    addedTomeSpellIds.add(spell.id);
    final basePrice = switch (spell.tier) { 1 => 80, 2 => 160, _ => 320 };
    final markup = 1.2 + rng.nextDouble() * 0.6;
    offers.add(TraderOffer(
      offerId: 'offer_${offerIndex++}',
      itemId: spell.id,
      isWeapon: false,
      isTome: true,
      displayName: 'Tome: ${spell.name}',
      price: (basePrice * markup).round(),
    ));
  }

  offers.shuffle(rng);
  return offers;
}

int innCostForDepth(int depth) => (depth * 12).clamp(10, 80);
