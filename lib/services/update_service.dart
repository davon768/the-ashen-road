import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_version.dart';
import '../theme/colors.dart';

// ─── CONFIGURATION ───────────────────────────────────────────────────────────
// Fill these in after creating your GitHub repo.
// Example: owner = 'davon768', repo = 'the-ashen-road'
const _githubOwner = 'davon768';
const _githubRepo  = 'the-ashen-road';
// ─────────────────────────────────────────────────────────────────────────────

class UpdateService {
  static const _apiUrl =
      'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest';

  /// Checks GitHub for a newer release and shows a dialog if one exists.
  /// Safe to call fire-and-forget; never throws.
  static Future<void> checkAndPrompt(BuildContext context) async {
    if (_githubOwner == 'YOUR_GITHUB_USERNAME') return; // not configured yet

    try {
      final response = await http
          .get(Uri.parse(_apiUrl), headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final remoteTag = (data['tag_name'] as String? ?? '').replaceFirst('v', '');
      final releaseUrl = data['html_url'] as String? ?? '';
      final assetUrl   = _findInstallerAsset(data);

      if (!_isNewer(remoteTag, kAppVersion)) return;
      if (!context.mounted) return;

      _showUpdateDialog(context, remoteTag, assetUrl.isNotEmpty ? assetUrl : releaseUrl);
    } catch (_) {
      // Network unavailable or rate limited — silently ignore.
    }
  }

  // Find the first .exe asset (the installer) or fall back to release page URL.
  static String _findInstallerAsset(Map<String, dynamic> data) {
    final assets = data['assets'] as List<dynamic>? ?? [];
    for (final asset in assets) {
      final url = asset['browser_download_url'] as String? ?? '';
      if (url.endsWith('.exe')) return url;
    }
    return '';
  }

  // Returns true if remote version string is newer than local.
  static bool _isNewer(String remote, String local) {
    final r = _parts(remote);
    final l = _parts(local);
    for (var i = 0; i < r.length && i < l.length; i++) {
      if (r[i] > l[i]) return true;
      if (r[i] < l[i]) return false;
    }
    return r.length > l.length;
  }

  static List<int> _parts(String v) =>
      v.split('.').map((s) => int.tryParse(s) ?? 0).toList();

  static void _showUpdateDialog(
      BuildContext context, String newVersion, String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _UpdateDialog(newVersion: newVersion, downloadUrl: downloadUrl),
    );
  }
}

// ─── UPDATE DIALOG ────────────────────────────────────────────────────────────

class _UpdateDialog extends StatelessWidget {
  final String newVersion;
  final String downloadUrl;
  const _UpdateDialog({required this.newVersion, required this.downloadUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AshenColors.surface,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AshenColors.copper, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UPDATE AVAILABLE',
              style: AshenText.heading.copyWith(color: AshenColors.copper, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            Text(
              'Version $newVersion is available. You are running $kAppVersion.',
              style: AshenText.body,
            ),
            const SizedBox(height: 6),
            Text(
              'Download and run the new installer to update.',
              style: AshenText.dim,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('LATER', style: AshenText.dim),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AshenColors.copper,
                    foregroundColor: const Color(0xFF0E0C08),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openUrl(downloadUrl);
                  },
                  child: const Text(
                    'DOWNLOAD',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _openUrl(String url) {
    // Windows: open URL in default browser.
    Process.run('cmd', ['/c', 'start', '', url]);
  }
}
