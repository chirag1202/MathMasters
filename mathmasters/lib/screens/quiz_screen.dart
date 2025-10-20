import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_provider.dart';
import '../widgets/option_button.dart';
import '../widgets/question_card.dart';
import '../widgets/timer_circle.dart';
import 'topic_select_icons.dart';
import 'summary_screen.dart';
import 'topic_select_screen.dart' show AppBarThemeToggle, TopicSelectScreen;
import '../providers/quiz_provider.dart' show lastSelectedTopicsProvider;
import '../models/question.dart' show TopicX;
import 'level_select_screen.dart' show LevelSelectScreen;

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? selectedIndex;
  int? correctIndex;
  Timer? _advanceTimer;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  void _handleAnswer(int index) {
    final s = ref.read(quizProvider);
    if (s == null || s.finished) return;
    final q = s.currentQuestion!;

    setState(() {
      selectedIndex = index;
      correctIndex = q.answerIndex;
    });

    ref.read(quizProvider.notifier).answer(index);

    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        selectedIndex = null;
        correctIndex = null;
      });
      ref.read(quizProvider.notifier).nextQuestion();
      final st = ref.read(quizProvider);
      if (st != null && st.finished) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SummaryScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(quizProvider);
    if (s == null) return const SizedBox.shrink();

    final total = s.questions.length;
    final current = s.currentIndex + 1;
    final q = s.currentQuestion;
    final levelTotalSeconds = ((600 - (s.level - 1) * 15).clamp(
      60,
      600,
    )).toInt();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        ref.read(quizProvider.notifier).pause();
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Quit level?'),
            content: const Text('Are you sure you want to quit this level?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Quit'),
              ),
            ],
          ),
        );
        if (confirm == true && context.mounted) Navigator.of(context).pop();
        if (confirm != true) ref.read(quizProvider.notifier).resume();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Level ${s.level}'),
          actions: [
            IconButton(
              tooltip: 'Home',
              icon: const Icon(Icons.home),
              onPressed: () async {
                // Pause and confirm before leaving a running quiz
                ref.read(quizProvider.notifier).pause();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Go Home?'),
                    content: const Text(
                      'You will leave this level and lose progress. Continue?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Home'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  _goHome(context, ref);
                } else {
                  ref.read(quizProvider.notifier).resume();
                }
              },
            ),
            const AppBarThemeToggle(),
            IconButton(
              icon: Icon(s.isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: () {
                if (s.isPaused) {
                  ref.read(quizProvider.notifier).resume();
                } else {
                  ref.read(quizProvider.notifier).pause();
                }
                setState(() {});
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Q $current / $total',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TimerCircle(
                    remaining: s.timeRemaining,
                    total: Duration(seconds: levelTotalSeconds),
                  ),
                  Text(
                    'Score: ${s.correctCount * 100}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Topic badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in s.selectedTopics)
                    Chip(
                      avatar: Icon(
                        topicIcon(t),
                        size: 18,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                      label: Text(t.label),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (q != null)
                QuestionCard(text: q.question)
              else
                const Text('No questions available for this level and topics.'),
              const SizedBox(height: 16),
              if (q != null)
                ...List.generate(q.options.length, (i) {
                  final isC = correctIndex == i;
                  final isW = selectedIndex == i && !isC;
                  return OptionButton(
                    text: q.options[i],
                    isCorrect: isC,
                    isWrong: isW,
                    onTap: selectedIndex == null
                        ? () => _handleAnswer(i)
                        : () {},
                  );
                }),
            ],
          ),
        ),
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
