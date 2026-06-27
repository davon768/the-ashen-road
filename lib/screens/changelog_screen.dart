import 'package:flutter/material.dart';
import '../data/changelog_data.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  static const _bg        = Color(0xFF100E08);
  static const _parchment = Color(0xFF1A1610);
  static const _copper    = Color(0xFFB87333);
  static const _text      = Color(0xFFD4C5A9);
  static const _dimText   = Color(0xFF7A6E58);
  static const _border    = Color(0xFF3A3020);
  static const _divider   = Color(0xFF2A2418);

  Color _categoryColor(ChangelogCategory cat) => switch (cat) {
    ChangelogCategory.added   => const Color(0xFF6B8B5A),
    ChangelogCategory.changed => const Color(0xFF8B7A3A),
    ChangelogCategory.fixed   => const Color(0xFF6A5A9A),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _parchment,
        foregroundColor: _copper,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Changelog',
          style: TextStyle(
            color: _copper,
            fontSize: 15,
            letterSpacing: 1.4,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: allChangelogs.length,
        itemBuilder: (context, i) {
          final entry = allChangelogs[i];
          return _EntryCard(entry: entry, categoryColor: _categoryColor, isLatest: i == 0);
        },
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final ChangelogEntry entry;
  final Color Function(ChangelogCategory) categoryColor;
  final bool isLatest;

  const _EntryCard({
    required this.entry,
    required this.categoryColor,
    required this.isLatest,
  });

  static const _parchment = Color(0xFF1A1610);
  static const _copper    = Color(0xFFB87333);
  static const _text      = Color(0xFFD4C5A9);
  static const _dimText   = Color(0xFF7A6E58);
  static const _border    = Color(0xFF3A3020);
  static const _divider   = Color(0xFF2A2418);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _parchment,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isLatest ? _copper.withOpacity(0.5) : _border,
          width: isLatest ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Version header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'v${entry.version}',
                  style: const TextStyle(
                    color: _copper,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                if (isLatest) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _copper.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: _copper.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'CURRENT',
                      style: TextStyle(color: _copper, fontSize: 9, letterSpacing: 1.2),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  entry.date,
                  style: const TextStyle(color: _dimText, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(height: 1, color: _divider),

          // Sections
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final section in entry.sections) ...[
                  _SectionBlock(section: section, color: categoryColor(section.category)),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final ChangelogSection section;
  final Color color;
  const _SectionBlock({required this.section, required this.color});

  static const _text    = Color(0xFFD4C5A9);
  static const _copper  = Color(0xFFB87333);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 12,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Text(
              section.category.name.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 10,
                letterSpacing: 1.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        for (final item in section.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('–  ', style: TextStyle(color: color.withOpacity(0.7), fontSize: 13)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(color: _text, fontSize: 13, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
