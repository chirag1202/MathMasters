import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/question.dart';
import '../models/game_history.dart';
import '../providers/persistence_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/game_mode_provider.dart';
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
    
    // Handle multiplayer state updates after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(quizProvider);
      if (s == null) return;
      
      final gameMode = ref.read(gameModeProvider);
      final isMultiplayer = gameMode.mode == GameMode.multiplayer;
      final total = s.questions.length;
      final correct = s.correctCount;
      final score = calculateScore(
        correctAnswers: correct,
        timeRemaining: s.timeRemaining,
      );
      final pass = total == 0 ? false : (correct / total) >= 0.8;
      
      if (isMultiplayer && gameMode.isPlayer1Turn) {
        // Player 1 just finished
        ref.read(gameModeProvider.notifier).setPlayer1Result(score, s.timeRemaining);
        if (pass) _confetti.play();
        _showPlayer1CompleteDialog(context, ref, s, score);
      } else if (isMultiplayer && !gameMode.isPlayer1Turn) {
        // Player 2 just finished
        ref.read(gameModeProvider.notifier).setPlayer2Result(score, s.timeRemaining);
        if (pass) _confetti.play();
      } else if (pass) {
        _confetti.play();
      }
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(quizProvider)!;
    final gameMode = ref.watch(gameModeProvider);
    final isMultiplayer = gameMode.mode == GameMode.multiplayer;
    
    final total = s.questions.length;
    final correct = s.correctCount;
    final score = calculateScore(
      correctAnswers: correct,
      timeRemaining: s.timeRemaining,
    );
    final pass = total == 0 ? false : (correct / total) >= 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMultiplayer && !gameMode.isPlayer1Turn
            ? 'Multiplayer Results'
            : 'Level Summary'),
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
            onPressed: () => _goHome(context, ref),
          ),
          const AppBarThemeToggle(),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isMultiplayer && !gameMode.isPlayer1Turn
                ? _buildMultiplayerResults(context, ref, s, gameMode, pass)
                : _buildSinglePlayerResults(context, ref, s, score, pass),
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

  Widget _buildSinglePlayerResults(
    BuildContext context,
    WidgetRef ref,
    QuizState s,
    int score,
    bool pass,
  ) {
    final total = s.questions.length;
    final correct = s.correctCount;

    return Column(
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
                onPressed: () => _handleSinglePlayerContinue(context, ref, s, score, pass),
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
    );
  }

  Widget _buildMultiplayerResults(
    BuildContext context,
    WidgetRef ref,
    QuizState s,
    GameModeState gameMode,
    bool player2Pass,
  ) {
    final player1Score = gameMode.player1Score!;
    final player2Score = calculateScore(
      correctAnswers: s.correctCount,
      timeRemaining: s.timeRemaining,
    );
    final player1Name = gameMode.player1Name!;
    final player2Name = gameMode.player2Name!;

    String winner = '';
    if (player1Score > player2Score) {
      winner = '$player1Name wins! 🏆';
    } else if (player2Score > player1Score) {
      winner = '$player2Name wins! 🏆';
    } else {
      winner = 'It\'s a tie! 🤝';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Level ${s.level} Complete',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player1Name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Score: $player1Score'),
                          Text('Time: ${gameMode.player1Time!.inSeconds}s'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player2Name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Score: $player2Score'),
                          Text('Time: ${s.timeRemaining.inSeconds}s'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  winner,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _handleMultiplayerContinue(
              context,
              ref,
              s,
              player1Name,
              player2Name,
              player1Score,
              player2Score,
              gameMode.player1Time!,
              s.timeRemaining,
            ),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  void _showPlayer1CompleteDialog(
    BuildContext context,
    WidgetRef ref,
    QuizState s,
    int score,
  ) {
    final gameMode = ref.read(gameModeProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('${gameMode.player1Name} finished!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: $score'),
            Text('Time remaining: ${s.timeRemaining.inSeconds}s'),
            const SizedBox(height: 16),
            Text('Now it\'s ${gameMode.player2Name}\'s turn!'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Start quiz for player 2
              ref.read(quizProvider.notifier).startQuiz(
                topics: s.selectedTopics,
                level: s.level,
              );
            },
            child: const Text('Start Player 2'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSinglePlayerContinue(
    BuildContext context,
    WidgetRef ref,
    QuizState s,
    int score,
    bool pass,
  ) async {
    final name = ref.read(playerNameProvider) ?? 'Player';
    final topics = s.selectedTopics.map((t) => t.key).toList();
    
    // Save to scoreboard
    await ref.read(persistenceProvider).addScore(
      ScoreEntry(
        playerName: name,
        topics: topics,
        level: s.level,
        score: score,
        date: DateTime.now(),
      ),
    );

    // Save to game history
    await ref.read(persistenceProvider).addGameHistory(
      GameHistoryEntry(
        player1Name: name,
        topics: topics,
        level: s.level,
        player1Score: score,
        player1TimeRemaining: s.timeRemaining,
        date: DateTime.now(),
        isMultiplayer: false,
      ),
    );

    if (pass) {
      // unlock next level
      final p = ref.read(persistenceProvider);
      final currentUnlocked = await p.getHighestUnlockedLevel(
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
        builder: (_) => LevelSelectScreen(selected: s.selectedTopics),
      ),
    );
  }

  Future<void> _handleMultiplayerContinue(
    BuildContext context,
    WidgetRef ref,
    QuizState s,
    String player1Name,
    String player2Name,
    int player1Score,
    int player2Score,
    Duration player1Time,
    Duration player2Time,
  ) async {
    final topics = s.selectedTopics.map((t) => t.key).toList();

    // Save both players' scores to scoreboard
    await ref.read(persistenceProvider).addScore(
      ScoreEntry(
        playerName: player1Name,
        topics: topics,
        level: s.level,
        score: player1Score,
        date: DateTime.now(),
      ),
    );
    await ref.read(persistenceProvider).addScore(
      ScoreEntry(
        playerName: player2Name,
        topics: topics,
        level: s.level,
        score: player2Score,
        date: DateTime.now(),
      ),
    );

    // Save game history
    await ref.read(persistenceProvider).addGameHistory(
      GameHistoryEntry(
        player1Name: player1Name,
        player2Name: player2Name,
        topics: topics,
        level: s.level,
        player1Score: player1Score,
        player2Score: player2Score,
        player1TimeRemaining: player1Time,
        player2TimeRemaining: player2Time,
        date: DateTime.now(),
        isMultiplayer: true,
      ),
    );

    // Reset game mode
    ref.read(gameModeProvider.notifier).reset();

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LevelSelectScreen(selected: s.selectedTopics),
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
