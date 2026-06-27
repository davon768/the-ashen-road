import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state/providers.dart';
import 'screens/main_shell.dart';
import 'screens/character_creator_screen.dart';
import 'services/update_service.dart';
import 'services/changelog_service.dart';

void main() {
  runApp(const ProviderScope(child: AshenRoadApp()));
}

class AshenRoadApp extends StatelessWidget {
  const AshenRoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Ashen Road',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFB87333),       // copper
          secondary: const Color(0xFF8B0000),      // dark red
          surface: const Color(0xFF1A1208),        // near-black parchment
          onSurface: const Color(0xFFD4C5A9),      // aged parchment text
        ),
        scaffoldBackgroundColor: const Color(0xFF0E0C08),
        fontFamily: 'Serif',
      ),
      home: const GameInitializer(),
    );
  }
}

// Loads the save file before showing the game
class GameInitializer extends ConsumerStatefulWidget {
  const GameInitializer({super.key});

  @override
  ConsumerState<GameInitializer> createState() => _GameInitializerState();
}

class _GameInitializerState extends ConsumerState<GameInitializer> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await ref.read(gameProvider.notifier).initialize();
    if (!mounted) return;
    setState(() => _loaded = true);
    // Show "What's New" on first launch of each version, then check for updates.
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) await ChangelogService.checkAndShowWhatsNew(context);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) UpdateService.checkAndPrompt(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'THE ASHEN ROAD',
                style: TextStyle(
                  fontSize: 28,
                  letterSpacing: 6,
                  color: Color(0xFFB87333),
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Color(0xFFB87333)),
            ],
          ),
        ),
      );
    }

    final needsCreation = ref.watch(needsCharacterCreationProvider);
    if (needsCreation) return const CharacterCreatorScreen();
    return const MainShell();
  }
}

