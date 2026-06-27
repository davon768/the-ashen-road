import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'main_shell.dart';

const _cards = [
  _NarrationCard(
    label: 'THE OPENING',
    text:
        'Three decades ago, something happened to the eastern sky.\n\n'
        'The scholars call it The Opening. The priests call it a sign. '
        'Most people call it the end of the world — though the world, '
        'stubbornly, has not yet ended. It bleeds wrong colours at dawn. '
        'Sounds carry from it that have no source. It grows, slowly, '
        'the way a wound grows when left unclean.',
  ),
  _NarrationCard(
    label: 'WHAT LIES EAST',
    text:
        'Travellers who cross the old borders return with things they '
        'cannot explain — strange relics, strange wounds, strange silences '
        'where memory should be.\n\n'
        'Some do not return at all. The faiths argue endlessly about what '
        'waits beyond The Opening. No one has reached it. No one who has '
        'tried has come back with an answer.',
  ),
  _NarrationCard(
    label: 'THE ASHEN ROAD',
    text:
        'One road runs east through what remains of the old kingdoms. '
        'The ash that gives it its name falls from the direction of The '
        'Opening — grey, weightless, faintly warm.\n\n'
        'It has been falling for thirty years. No one has found where it '
        'comes from. Merchants travel it. Pilgrims travel it. Soldiers '
        'travel it. So do the desperate, the curious, and the damned.',
  ),
  _NarrationCard(
    label: 'THE FAITHS',
    text:
        'Five faiths have survived the age of The Opening. Each offers a '
        'different answer to the same question: why did the sky break?\n\n'
        'The Church blames heresy. The Old Ways blame the Church. The '
        'Pale Court says it was always going to happen. The Compact of '
        'Saints lights candles and hopes. The Ashen Rite does not speak '
        'of what it knows. They do not agree. They have never agreed.',
  ),
  _NarrationCard(
    label: 'YOU',
    text:
        'You are not a hero in any story you have heard.\n\n'
        'You are someone who walks the Ashen Road when others will not. '
        'Why you do this is your own business. What the road makes of '
        'you is another matter entirely.\n\n'
        'Go east. See what finds you.',
  ),
];

class OpeningNarrationScreen extends StatefulWidget {
  const OpeningNarrationScreen({super.key});

  @override
  State<OpeningNarrationScreen> createState() => _OpeningNarrationScreenState();
}

class _OpeningNarrationScreenState extends State<OpeningNarrationScreen>
    with SingleTickerProviderStateMixin {
  int _page = 0;
  late final AnimationController _fade;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _opacity = CurvedAnimation(parent: _fade, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  void _advance() {
    if (_page < _cards.length - 1) {
      _fade.reverse().then((_) {
        setState(() => _page++);
        _fade.forward();
      });
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards[_page];
    final isLast = _page == _cards.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: SafeArea(
        child: FadeTransition(
          opacity: _opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // page dots
                Row(
                  children: List.generate(_cards.length, (i) => Container(
                    width: i == _page ? 18 : 6,
                    height: 2,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AshenColors.copper
                          : AshenColors.border,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  )),
                ),
                const Spacer(),

                // label
                Text(
                  card.label,
                  style: const TextStyle(
                    color: AshenColors.copper,
                    fontSize: 10,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // body
                Container(
                  width: 2,
                  height: 40,
                  color: AshenColors.inkRed,
                  margin: const EdgeInsets.only(bottom: 20),
                ),
                Text(
                  card.text,
                  style: const TextStyle(
                    color: AshenColors.parchment,
                    fontSize: 15,
                    height: 1.7,
                    fontFamily: 'serif',
                  ),
                ),

                const Spacer(flex: 2),

                // navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_page > 0)
                      TextButton(
                        onPressed: () => _fade.reverse().then((_) {
                          setState(() => _page--);
                          _fade.forward();
                        }),
                        style: TextButton.styleFrom(
                          foregroundColor: AshenColors.ashGrey,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          '← BACK',
                          style: TextStyle(fontSize: 11, letterSpacing: 2),
                        ),
                      )
                    else
                      const SizedBox(),
                    ElevatedButton(
                      onPressed: _advance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLast
                            ? AshenColors.darkRed
                            : AshenColors.surface,
                        foregroundColor: AshenColors.parchment,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Text(
                        isLast ? 'BEGIN  →' : 'CONTINUE  →',
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NarrationCard {
  final String label;
  final String text;
  const _NarrationCard({required this.label, required this.text});
}
