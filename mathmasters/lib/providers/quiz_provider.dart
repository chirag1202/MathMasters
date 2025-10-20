import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/questions_loader.dart';
import '../models/question.dart';

final questionsRepositoryProvider = Provider<QuestionsRepository>(
  (ref) => QuestionsRepository(),
);
final questionsLoadedProvider = FutureProvider<void>((ref) async {
  await ref.read(questionsRepositoryProvider).load();
});

final playerNameProvider = StateNotifierProvider<PlayerNameNotifier, String?>(
  (ref) => PlayerNameNotifier(),
);

/// Remembers the most recently selected topics so that the Home button can
/// always return to the Level Select screen with a sensible context.
final lastSelectedTopicsProvider = StateProvider<List<Topic>?>((ref) => null);

class PlayerNameNotifier extends StateNotifier<String?> {
  PlayerNameNotifier() : super(null) {
    _load();
  }
  static const _key = 'player_name';
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final stored = p.getString(_key);
    state = (stored == null || stored.isEmpty) ? '' : stored;
  }

  Future<void> setName(String name) async {
    state = name;
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, name);
  }
}

class QuizState {
  final List<Topic> selectedTopics;
  final int level;
  final List<Question> questions;
  final int currentIndex;
  final int correctCount;
  final bool isPaused;
  final Duration timeRemaining;
  final bool finished;

  const QuizState({
    required this.selectedTopics,
    required this.level,
    required this.questions,
    required this.currentIndex,
    required this.correctCount,
    required this.isPaused,
    required this.timeRemaining,
    required this.finished,
  });

  bool get hasQuestion => currentIndex < questions.length;
  Question? get currentQuestion => hasQuestion ? questions[currentIndex] : null;

  QuizState copyWith({
    List<Topic>? selectedTopics,
    int? level,
    List<Question>? questions,
    int? currentIndex,
    int? correctCount,
    bool? isPaused,
    Duration? timeRemaining,
    bool? finished,
  }) => QuizState(
    selectedTopics: selectedTopics ?? this.selectedTopics,
    level: level ?? this.level,
    questions: questions ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    correctCount: correctCount ?? this.correctCount,
    isPaused: isPaused ?? this.isPaused,
    timeRemaining: timeRemaining ?? this.timeRemaining,
    finished: finished ?? this.finished,
  );
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState?>(
  (ref) => QuizNotifier(ref),
);

class QuizNotifier extends StateNotifier<QuizState?> {
  QuizNotifier(this.ref) : super(null);

  final Ref ref;
  Timer? _timer;

  int _timeForLevel(int level) => (300 - (level - 1) * 5).clamp(60, 300);

  Future<void> startQuiz({
    required List<Topic> topics,
    required int level,
  }) async {
    final repo = ref.read(questionsRepositoryProvider);
    await repo.load();
    final qs = repo.getQuestions(topics: topics, level: level, count: 20);
    state = QuizState(
      selectedTopics: topics,
      level: level,
      questions: qs,
      currentIndex: 0,
      correctCount: 0,
      isPaused: false,
      timeRemaining: Duration(seconds: _timeForLevel(level)),
      finished: false,
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final s = state;
      if (s == null || s.isPaused || s.finished) return;
      final next = s.timeRemaining - const Duration(seconds: 1);
      if (next.inSeconds <= 0) {
        finish();
      } else {
        state = s.copyWith(timeRemaining: next);
      }
    });
  }

  void pause() => state = state?.copyWith(isPaused: true);
  void resume() => state = state?.copyWith(isPaused: false);

  void answer(int index) {
    final s = state;
    if (s == null || s.finished || !s.hasQuestion) return;
    final q = s.currentQuestion!;
    final correct = index == q.answerIndex;
    state = s.copyWith(correctCount: s.correctCount + (correct ? 1 : 0));
  }

  void nextQuestion() {
    final s = state;
    if (s == null || s.finished) return;
    final nextIndex = s.currentIndex + 1;
    if (nextIndex >= s.questions.length) {
      finish();
    } else {
      state = s.copyWith(currentIndex: nextIndex);
    }
  }

  void finish() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(finished: true);
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

int calculateScore({
  required int correctAnswers,
  required Duration timeRemaining,
}) {
  final baseScore = correctAnswers * 100;
  final timeBonus = (timeRemaining.inSeconds / 5).floor();
  return baseScore + timeBonus;
}
