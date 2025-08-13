import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:travel_planner/core/services/backup_service.dart';
import 'package:travel_planner/core/services/settings_service.dart';
import 'package:travel_planner/core/theme/app_theme.dart';
import 'package:travel_planner/features/trips/presentation/providers/trip_providers.dart';

final reduceMotionProvider = StateNotifierProvider<ReduceMotionNotifier, bool>((ref) {
  return ReduceMotionNotifier();
});

class ReduceMotionNotifier extends StateNotifier<bool> {
  final SettingsService _settingsService = SettingsService();
  ReduceMotionNotifier() : super(false) {
    state = _settingsService.getReducedMotion();
  }
  Future<void> setReducedMotion(bool isEnabled) async {
    await _settingsService.setReducedMotion(isEnabled);
    state = isEnabled;
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _backupData(BuildContext context) async {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Creating backup...')));
    try {
      final backupFile = await BackupService().exportTripsToJson();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      await Share.shareXFiles([XFile(backupFile.path)], text: 'Here is my Travel Planner backup!');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _restoreData(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text('This will merge trips from the backup file. Existing trips with the same ID will not be replaced. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Restore')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final count = await BackupService().importTripsFromJson(filePath);
        ref.invalidate(tripListProvider);

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore successful! $count trips imported.')));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final reduceMotion = ref.watch(reduceMotionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Appearance'),
          ListTile(
            title: const Text('Theme'),
            trailing: SegmentedButton<AppThemeMode>(
              segments: const [
                ButtonSegment(value: AppThemeMode.light, icon: Icon(Icons.wb_sunny_outlined)),
                ButtonSegment(value: AppThemeMode.dark, icon: Icon(Icons.nightlight_round)),
                ButtonSegment(value: AppThemeMode.grey, icon: Icon(Icons.color_lens_outlined)),
              ],
              selected: {themeMode},
              onSelectionChanged: (newSelection) {
                HapticFeedback.lightImpact();
                themeNotifier.setThemeMode(newSelection.first);
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Reduce Motion'),
            subtitle: const Text('Disables shimmer and other animations.'),
            value: reduceMotion,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref.read(reduceMotionProvider.notifier).setReducedMotion(value);
            },
          ),
          const Divider(),
          _SectionHeader(title: 'Data Management'),
          ListTile(
            title: const Text('Backup Now'),
            subtitle: const Text('Export your trips to a JSON file.'),
            onTap: () => _backupData(context),
          ),
          ListTile(
            title: const Text('Restore Data'),
            subtitle: const Text('Import trips from a JSON file.'),
            onTap: () => _restoreData(context, ref),
          ),
          const Divider(),
          _SectionHeader(title: 'About'),
          ListTile(
            title: const Text('About Travel Planner'),
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/settings/about');
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/settings/privacy');
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}