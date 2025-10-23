import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import 'level_select_screen.dart';
import 'topic_select_icons.dart';
import '../providers/theme_provider.dart';

class TopicSelectScreen extends ConsumerStatefulWidget {
  const TopicSelectScreen({super.key});

  @override
  ConsumerState<TopicSelectScreen> createState() => _TopicSelectScreenState();
}

class _TopicSelectScreenState extends ConsumerState<TopicSelectScreen> {
  final Set<Topic> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Topics'),
        actions: [
          IconButton(
            tooltip: 'Game History',
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home),
            onPressed: () {
              // Home from here resets the stack to Topic Select (root).
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const TopicSelectScreen()),
                (route) => false,
              );
            },
          ),
          const AppBarThemeToggle(),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C2FF), Color(0xFFFF7A59), Color(0xFFFFD166)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: Topic.values
                      .map(
                        (t) => FilterChip(
                          avatar: Icon(topicIcon(t)),
                          label: Text(t.label),
                          selected: _selected.contains(t),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selected.add(t);
                              } else {
                                _selected.remove(t);
                              }
                            });
                          },
                          showCheckmark: false,
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LevelSelectScreen(
                                selected: _selected.toList(),
                              ),
                            ),
                          );
                        },
                  child: const Text('Choose Level'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBarThemeToggle extends ConsumerWidget {
  const AppBarThemeToggle({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark;
    return IconButton(
      tooltip: isDark ? 'Light theme' : 'Dark theme',
      icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
      onPressed: () {
        ref
            .read(themeModeProvider.notifier)
            .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
      },
    );
  }
}
