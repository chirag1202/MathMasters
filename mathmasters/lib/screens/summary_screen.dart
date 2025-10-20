import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/question.dart';
import '../providers/persistence_provider.dart';
import '../providers/quiz_provider.dart';
import 'level_select_screen.dart';
import 'topic_select_screen.dart' show AppBarThemeToggle;
import '../providers/quiz_provider.dart' show lastSelectedTopicsProvider;
import 'topic_select_screen.dart' show TopicSelectScreen;
import 'scoreboard_screen.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(quizProvider)!;
    final total = s.questions.length;
    final correct = s.correctCount;
    final score = calculateScore(
      correctAnswers: correct,
      timeRemaining: s.timeRemaining,
    );
    final pass = total == 0 ? false : (correct / total) >= 0.8;
    if (pass) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Summary'),
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home),
            onPressed: () => _goHome(context, ref),
          ),
          const AppBarThemeToggle(),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${s.level} Complete',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Correct: $correct / $total'),
                Text('Score: $score'),
                Text(
                  pass
                      ? 'Great job! You passed! 🎉'
                      : 'Keep trying! You can do it! 💪',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final name = ref.read(playerNameProvider) ?? 'Player';
                          final topics = s.selectedTopics
                              .map((t) => t.key)
                              .toList();
                          await ref
                              .read(persistenceProvider)
                              .addScore(
                                ScoreEntry(
                                  playerName: name,
                                  topics: topics,
                                  level: s.level,
                                  score: score,
                                  date: DateTime.now(),
                                ),
                              );

                          if (pass) {
                            // unlock next level
                            final p = ref.read(persistenceProvider);
                            final currentUnlocked = await p
                                .getHighestUnlockedLevel(
                                  name,
                                  s.selectedTopics,
                                );
                            final nextLevel = s.level + 1;
                            if (nextLevel > currentUnlocked) {
                              await p.setHighestUnlockedLevel(
                                name,
                                s.selectedTopics,
                                nextLevel,
                              );
                            }
                          }

                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LevelSelectScreen(selected: s.selectedTopics),
                            ),
                          );
                        },
                        child: Text(pass ? 'Next Level' : 'Retry / Pick Level'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ScoreboardScreen(),
                            ),
                          );
                        },
                        child: const Text('Scoreboard'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
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
