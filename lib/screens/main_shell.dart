import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../theme/colors.dart';
import 'road_screen.dart';
import 'party_screen.dart';
import 'inventory_screen.dart';
import 'expedition_screen.dart';
import 'holdings_screen.dart';
import 'settings_screen.dart';
import 'guide_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _tab = 0;

  static const _screens = [
    RoadScreen(),
    PartyScreen(),
    InventoryScreen(),
    ExpeditionScreen(),
    HoldingsScreen(),
  ];

  static const _labels = ['Road', 'Party', 'Inventory', 'Expedition', 'Holdings'];
  static const _icons  = [
    Icons.map_outlined,
    Icons.people_outline,
    Icons.backpack_outlined,
    Icons.explore_outlined,
    Icons.account_balance_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final gold              = ref.watch(goldProvider);
    final day               = ref.watch(inGameDayProvider);
    final needsSubclass     = ref.watch(needsSubclassProvider);
    final devotionPending   = ref.watch(pendingDevotionChoicesProvider).isNotEmpty;
    final devMode           = ref.watch(devModeProvider);

    return Scaffold(
      backgroundColor: AshenColors.background,
      appBar: AppBar(
        backgroundColor: AshenColors.surface,
        elevation: 0,
        title: const Text(
          'THE ASHEN ROAD',
          style: TextStyle(
            color: AshenColors.copper,
            fontSize: 15,
            letterSpacing: 5,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Day $day',
                    style: AshenText.dim.copyWith(fontSize: 11)),
                Text('$gold gold', style: AshenText.gold),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(devModeProvider.notifier).toggle(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: devMode ? const Color(0xFF2A4A1A) : Colors.transparent,
                border: Border.all(
                  color: devMode ? const Color(0xFF5C8A3A) : AshenColors.ashGrey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'DEV',
                style: TextStyle(
                  color: devMode ? const Color(0xFF8BC34A) : AshenColors.ashGrey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline,
                color: AshenColors.ashGrey, size: 20),
            tooltip: 'Guide',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GuideScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AshenColors.ashGrey, size: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AshenColors.inkRed, AshenColors.border, Colors.transparent],
                stops: [0.0, 0.35, 1.0],
              ),
            ),
          ),
        ),
      ),
      body: _screens[_tab],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AshenColors.inkRed.withAlpha(90))),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          backgroundColor: AshenColors.surface,
          selectedItemColor: AshenColors.copper,
          unselectedItemColor: AshenColors.ashGrey,
          selectedLabelStyle:
              const TextStyle(fontSize: 9, letterSpacing: 1),
          unselectedLabelStyle: const TextStyle(fontSize: 9),
          type: BottomNavigationBarType.fixed,
          items: List.generate(
            5,
            (i) => BottomNavigationBarItem(
              icon: i == 1 && (needsSubclass || devotionPending)
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(_icons[i], size: 22),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: devotionPending
                                  ? const Color(0xFF8A5FB0)
                                  : AshenColors.copper,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Icon(_icons[i], size: 22),
              label: _labels[i],
            ),
          ),
        ),
      ),
    );
  }
}
