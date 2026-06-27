import '../models/hero.dart';
import '../models/enums.dart';

String buildPortraitPrompt(Hero hero, {String? appearanceHint}) {
  final genderWord = hero.isFemale ? 'woman' : 'man';
  final classDesc  = _classDescription(hero.heroClass, hero.isFemale);
  final faithDesc  = _faithDescription(hero.faith);
  final tone       = _toneForClass(hero.heroClass);

  final hint = appearanceHint?.trim();
  final appearancePart = (hint != null && hint.isNotEmpty) ? ', $hint,' : ',';

  return 'full body $genderWord $classDesc$appearancePart '
      'head to feet entirely visible, boots on ground, '
      'fantasy RPG character art, $faithDesc, $tone, '
      'medieval dark fantasy, full length standing pose, '
      'dramatic lighting, dark background, '
      'no cropping, no cut-off, entire figure in frame, feet visible';
}

String _classDescription(HeroClass c, bool female) {
  if (female) {
    return switch (c) {
      HeroClass.knight =>
        'battle-worn female knight in dented plate armor, sword at hip, scarred fierce face, cloak torn at edges',
      HeroClass.ranger =>
        'weathered female ranger in dark leather armor, longbow in hand, hood partially down, alert stance',
      HeroClass.priest =>
        'stern priestess in dark robes, holy symbol held aloft, piercing gaze, worn travelling sandals',
      HeroClass.mage =>
        'female mage in ornate layered robes, staff in hand, arcane runes glowing on skin, intense expression',
      HeroClass.rogue =>
        'shadowy female rogue in dark fitted clothing, twin daggers drawn, dangerous smirk, hood up',
      HeroClass.necromancer =>
        'pale female necromancer in burial shroud robes, skeletal hand raised, hollow eyes, bone staff',
      HeroClass.warlock =>
        'gaunt female warlock with dark brand marks on face, void energy crackling at hands, forbidden sigils on robes',
    };
  }
  return switch (c) {
    HeroClass.knight =>
      'battle-worn knight in dented plate armor, sword at hip, scarred determined face, cloak torn at edges',
    HeroClass.ranger =>
      'weathered ranger in dark leather armor, longbow in hand, hood partially down, alert watchful stance',
    HeroClass.priest =>
      'stern medieval priest in dark robes, holy symbol held aloft, piercing gaze, worn travelling sandals',
    HeroClass.mage =>
      'elderly mage in ornate layered robes, gnarled staff in hand, long beard, arcane runes glowing on skin',
    HeroClass.rogue =>
      'shadowy rogue in dark fitted clothing, twin daggers drawn, smirking expression, hood up',
    HeroClass.necromancer =>
      'pale necromancer in burial shroud robes, skeletal hand raised, hollow eyes, bone staff in other hand',
    HeroClass.warlock =>
      'gaunt warlock with dark brand marks on face, void energy crackling at hands, forbidden sigils on robes',
  };
}

String _faithDescription(FaithType? f) => switch (f) {
      FaithType.luminantChurch =>
        'golden holy light emanating from behind, crusader cross on tabard, flame motifs on armor',
      FaithType.oldWays =>
        'runic tattoos visible on arms and face, animal bones worn as decoration, storm clouds in background',
      FaithType.paleCourt =>
        'pale skin like marble, dark circles under eyes, skull and bone motifs on clothing',
      FaithType.compactOfSaints =>
        'worn pilgrim tokens and saint medals around neck, humble expression, candlelight glow from nearby',
      FaithType.ashenRite =>
        'ash and void markings burned into skin, faint purple void energy swirling around hands and eyes',
      null => 'no religious symbols, hardened neutral expression',
    };

String _toneForClass(HeroClass c) => switch (c) {
      HeroClass.knight     => 'heroic but weary tone, battle-scarred veteran',
      HeroClass.ranger     => 'solitary watchful tone, survivor of the wilderness',
      HeroClass.priest     => 'zealous and intense tone, unwavering conviction',
      HeroClass.mage       => 'wise and otherworldly tone, ancient power barely contained',
      HeroClass.rogue      => 'cunning and dangerous tone, coiled like a spring',
      HeroClass.necromancer=> 'eerie and unsettling tone, death made comfortable',
      HeroClass.warlock    => 'dark and corrupted tone, power at terrible cost',
    };
