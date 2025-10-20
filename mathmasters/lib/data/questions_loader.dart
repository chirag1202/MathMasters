import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';
import 'question_generator.dart';

class QuestionsRepository {
  Map<String, dynamic>? _raw;

  Future<void> load() async {
    final jsonStr = await rootBundle.loadString('assets/questions.json');
    _raw = json.decode(jsonStr) as Map<String, dynamic>;
  }

  /// Returns at most [count] questions for [level] (1..30) merged from given [topics].
  /// If fewer questions exist, returns what is available.
  List<Question> getQuestions({
    required List<Topic> topics,
    required int level,
    int count = 20,
  }) {
    final raw = _raw;
    if (raw == null) throw StateError('Questions not loaded');

    final levelKey = 'level$level';
    final List<Question> aggregated = [];

    for (final t in topics) {
      final topicMap = raw[t.key] as Map<String, dynamic>?;
      if (topicMap == null) continue;
      final levelList = topicMap[levelKey] as List<dynamic>?;
      if (levelList == null) continue;
      aggregated.addAll(
        levelList.map((e) => Question.fromMap(e as Map<String, dynamic>)),
      );
    }

    aggregated.shuffle();
    if (aggregated.length >= count) {
      return aggregated.sublist(0, count);
    }

    // Not enough unique items in the static bank; procedurally generate
    // additional unique questions to reach the desired count.
    final prompts = aggregated.map((e) => e.question).toSet();
    final gen = QuestionGenerator();
    final generated = gen.generate(
      topics: topics,
      level: level,
      needed: count - aggregated.length,
      existingPrompts: prompts,
    );
    aggregated.addAll(generated);
    return aggregated.sublist(0, count);
  }
}
