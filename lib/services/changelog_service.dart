import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_version.dart';
import '../data/changelog_data.dart';

class ChangelogService {
  static const _fileName = 'ashen_road_meta.json';

  static Future<File> _metaFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<String?> _lastSeenVersion() async {
    try {
      final file = await _metaFile();
      if (!file.existsSync()) return null;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return json['lastSeenVersion'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveSeenVersion(String version) async {
    try {
      final file = await _metaFile();
      Map<String, dynamic> data = {};
      if (file.existsSync()) {
        try {
          data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        } catch (_) {}
      }
      data['lastSeenVersion'] = version;
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  /// Shows the "What's New" dialog on first launch of a new version.
  /// Call after the game loads. Safe to call every launch — no-ops if nothing new.
  static Future<void> checkAndShowWhatsNew(BuildContext context) async {
    final last = await _lastSeenVersion();
    if (last == kAppVersion) return;

    await _saveSeenVersion(kAppVersion);

    if (!context.mounted) return;

    // Collect entries the user hasn't seen yet.
    // If they have no saved version, show only the most recent entry.
    final entries = last == null
        ? allChangelogs.take(1).toList()
        : allChangelogs.takeWhile((e) => e.version != last).toList();

    if (entries.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (_) => _WhatsNewDialog(entries: entries),
    );
  }
}

// ─── "What's New" dialog ─────────────────────────────────────────────────────

class _WhatsNewDialog extends StatelessWidget {
  final List<ChangelogEntry> entries;
  const _WhatsNewDialog({required this.entries});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parchment = isDark ? const Color(0xFF1E1A12) : const Color(0xFFF5EDD6);
    final textColor = isDark ? const Color(0xFFD4C5A9) : const Color(0xFF2A1F0E);
    final copper = const Color(0xFFB87333);
    final dimText = isDark ? const Color(0xFF8A7A60) : const Color(0xFF6A5A3A);

    return Dialog(
      backgroundColor: parchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: copper.withOpacity(0.5), width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 540),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: copper.withOpacity(0.3))),
              ),
              child: Row(
                children: [
                  Text(
                    "What's New  —  v${entries.first.version}",
                    style: TextStyle(
                      color: copper,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    entries.first.date,
                    style: TextStyle(color: dimText, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Scrollable body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in entries) ...[
                      if (entries.length > 1) ...[
                        Text(
                          'v${entry.version}  —  ${entry.date}',
                          style: TextStyle(
                            color: copper,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      for (final section in entry.sections) ...[
                        Text(
                          section.category.name.toUpperCase(),
                          style: TextStyle(
                            color: dimText,
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        for (final item in section.items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('•  ', style: TextStyle(color: copper, fontSize: 13)),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: copper.withOpacity(0.3))),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: copper,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    side: BorderSide(color: copper.withOpacity(0.4)),
                  ),
                  child: const Text('Continue', style: TextStyle(letterSpacing: 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
