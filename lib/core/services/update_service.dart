import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

final updateServiceProvider = Provider((ref) => UpdateService());

class UpdateService {
  static const String _repoUrl =
      'https://api.github.com/repos/godzyken/bat_track_v1/releases/latest';

  Future<void> checkForUpdates(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      final response = await http
          .get(
            Uri.parse(_repoUrl),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String?;
      if (tagName == null) return;

      final assets = data['assets'] as List<dynamic>?;
      if (assets == null || assets.isEmpty) return;

      String? downloadUrl;
      for (var asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          downloadUrl = asset['browser_download_url'] as String?;
          break;
        }
      }
      downloadUrl ??= assets[0]['browser_download_url'] as String?;
      if (downloadUrl == null) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // ex: "1.1.0"

      final remoteVersion = tagName.startsWith('v')
          ? tagName.substring(1)
          : tagName;

      if (_isNewerVersion(remoteVersion, currentVersion)) {
        if (!context.mounted) return;
        _showUpdateDialog(context, tagName, downloadUrl);
      }
    } catch (e) {
      // Ignore silencieusement toute erreur réseau (hors-ligne, timeout, etc.)
      debugPrint('🔇 Update check skipped or failed: $e');
    }
  }

  bool _isNewerVersion(String remote, String current) {
    try {
      final remoteParts = remote
          .split('+')[0]
          .split('.')
          .map(int.parse)
          .toList();
      final currentParts = current
          .split('+')[0]
          .split('.')
          .map(int.parse)
          .toList();

      for (int i = 0; i < remoteParts.length; i++) {
        final r = i < remoteParts.length ? remoteParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        if (r > c) return true;
        if (r < c) return false;
      }
    } catch (_) {}
    return remote != current;
  }

  void _showUpdateDialog(
    BuildContext context,
    String tagName,
    String downloadUrl,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text('Mise à jour disponible ($tagName)'),
        content: const Text(
          'Une nouvelle version de BatTrack est disponible. Souhaitez-vous la télécharger et l\'installer dès maintenant ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _downloadAndInstall(context, downloadUrl);
            },
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstall(
    BuildContext context,
    String downloadUrl,
  ) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Téléchargement de la mise à jour...')),
      );
    }

    try {
      final dir =
          await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/bat_track_update.apk';

      final request = await http.get(Uri.parse(downloadUrl));
      if (request.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(request.bodyBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Téléchargement terminé. Lancement de l\'installation...',
              ),
            ),
          );
        }

        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Impossible d\'ouvrir l\'installateur : ${result.message}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Update download/install error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
        );
      }
    }
  }
}
