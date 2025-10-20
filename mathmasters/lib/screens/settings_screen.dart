import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import 'topic_select_screen.dart' show AppBarThemeToggle;
import '../providers/quiz_provider.dart' show lastSelectedTopicsProvider;
import 'level_select_screen.dart' show LevelSelectScreen;
import 'topic_select_screen.dart' show TopicSelectScreen;
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home),
            onPressed: () => _goHome(context, ref),
          ),
          const AppBarThemeToggle(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(mode.name),
            trailing: DropdownButton<ThemeMode>(
              value: mode,
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(val);
                }
              },
              items: ThemeMode.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: settings.soundEnabled,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setSoundEnabled(v),
            title: const Text('Sound effects'),
            subtitle: const Text('Play sounds on correct/wrong answers'),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Text size'),
            subtitle: Text(settings.textScale.toStringAsFixed(2)),
            trailing: SizedBox(
              width: 160,
              child: Slider(
                min: 0.8,
                max: 1.4,
                divisions: 6,
                value: settings.textScale,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).setTextScale(v),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _goHome(BuildContext context, WidgetRef ref) {
  final topics = ref.read(lastSelectedTopicsProvider);
  if (topics != null && topics.isNotEmpty) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LevelSelectScreen(selected: topics)),
      (route) => false,
    );
  } else {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TopicSelectScreen()),
      (route) => false,
    );
  }
}
