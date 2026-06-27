// ─── CHANGELOG ───────────────────────────────────────────────────────────────
// Add a new ChangelogEntry at the TOP of the list every time you ship a build.
// Keep entries concise — players read these, not engineers.

class ChangelogEntry {
  final String version;
  final String date;        // "Month YYYY" is fine
  final List<ChangelogSection> sections;

  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.sections,
  });
}

class ChangelogSection {
  final ChangelogCategory category;
  final List<String> items;
  const ChangelogSection(this.category, this.items);
}

enum ChangelogCategory { added, changed, fixed }

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG — newest version FIRST
// ─────────────────────────────────────────────────────────────────────────────

const allChangelogs = <ChangelogEntry>[

  // ── v1.0.0 ─────────────────────────────────────────────────────────────────
  ChangelogEntry(
    version: '1.0.0',
    date: 'June 2026',
    sections: [
      ChangelogSection(ChangelogCategory.added, [
        'First playtest release. The Ashen Road is open.',
        '143 spells across four caster classes — Mage, Warlock, Necromancer, Priest.',
        'Spell theorycraft: each class has three subclass archetypes unlocked through tomes.',
        'Expanded world map: seven depth tiers from Ashenvale to the Void Spire.',
        '18 new named locations in the Far Waste (depths 6–7) with full lore.',
        'Level gating: deeper areas require your party to reach the appropriate level.',
        'XP diminishing returns: farming low-depth content below your level is less efficient.',
        'Pre-expedition supplies (healing kit, lantern) selected before departure.',
        'Rations displayed on the Road screen with red warning below three days.',
        'Expedition complete banner when your party finishes a run.',
        'Trader now correctly filters spells your party already knows.',
        'Spell auto-learn on level-up is now randomized within appropriate tier.',
        'In-game guide accessible from the AppBar.',
        'Changelog shown on first launch after each update.',
        'Installer and auto-update system for future builds.',
      ]),
    ],
  ),

];
