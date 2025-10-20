import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import 'topic_select_screen.dart' show AppBarThemeToggle;
import '../providers/quiz_provider.dart';
import '../providers/persistence_provider.dart';
import 'quiz_screen.dart';
import 'topic_select_screen.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  final List<Topic> selected;
  const LevelSelectScreen({super.key, required this.selected});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  late Future<int> _unlockedLevelFuture;
  late List<Topic> normalizedTopics;

  @override
  void initState() {
    super.initState();
    normalizedTopics = List<Topic>.from(widget.selected)
      ..sort((a, b) => a.key.compareTo(b.key));
    _loadUnlockedLevel();
  }

  void _loadUnlockedLevel() {
    final name = ref.read(playerNameProvider) ?? 'Player';
    _unlockedLevelFuture = ref
        .read(persistenceProvider)
        .getHighestUnlockedLevel(name, normalizedTopics);
  }

  @override
  Widget build(BuildContext context) {
    ref.read(lastSelectedTopicsProvider.notifier).state = normalizedTopics;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Level'),
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home),
            onPressed: () {
              _goHome(context, ref);
            },
          ),
          const AppBarThemeToggle(),
        ],
      ),
      body: FutureBuilder<int>(
        future: _unlockedLevelFuture,
        builder: (context, snap) {
          final unlocked = snap.data ?? 1;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final level = index + 1;
              final locked = level > unlocked;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: locked
                      ? Theme.of(context).disabledColor.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.secondaryContainer,
                ),
                onPressed: locked
                    ? null
                    : () async {
                        await ref
                            .read(quizProvider.notifier)
                            .startQuiz(topics: normalizedTopics, level: level);
                        ref.read(lastSelectedTopicsProvider.notifier).state =
                            normalizedTopics;
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizScreen()),
                        );
                      },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'L$level',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (locked) const SizedBox(height: 6),
                    if (locked) const Icon(Icons.lock, size: 18),
                  ],
                ),
              );
            },
          );
        },
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
