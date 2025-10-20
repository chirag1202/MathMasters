import 'dart:math' as m;

import '../models/question.dart';

class QuestionGenerator {
  final m.Random _rand = m.Random();

  List<Question> generate({
    required List<Topic> topics,
    required int level,
    required int needed,
    Set<String>? existingPrompts,
  }) {
    final prompts = existingPrompts ?? <String>{};
    final List<Question> out = [];
    int guard = 0;
    while (out.length < needed && guard < needed * 50) {
      guard++;
      final t = topics[_rand.nextInt(topics.length)];
      final q = _generateForTopic(t, level);
      if (q == null) continue;
      if (prompts.add(q.question)) {
        out.add(q);
      }
    }
    return out;
  }

  Question? _generateForTopic(Topic topic, int level) {
    switch (topic) {
      case Topic.addition:
        return _genAddition(level);
      case Topic.subtraction:
        return _genSubtraction(level);
      case Topic.multiplication:
        return _genMultiplication(level);
      case Topic.division:
        return _genDivision(level);
      case Topic.decimals:
        return _genDecimals(level);
      case Topic.fractions:
        return _genFractions(level);
    }
  }

  int _rangeMax(int level, {int base = 10, int step = 10, int cap = 200}) {
    return m.min(cap, base + (level - 1) * step);
  }

  Question _genAddition(int level) {
    // Increase operands and add more addends with level
    if (level >= 15) {
      final lim = _rangeMax(level, base: 50, step: 25, cap: 500);
      final a = _rand.nextInt(lim + 1);
      final b = _rand.nextInt(lim + 1);
      final c = _rand.nextInt(lim + 1);
      final ans = a + b + c;
      final q = '$a + $b + $c = ?';
      final options = _shuffleOptions(
        ans,
        () => ans + (_rand.nextInt(41) - 20),
      );
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    } else if (level >= 8) {
      final lim = _rangeMax(level, base: 20, step: 15, cap: 300);
      final a = _rand.nextInt(lim + 1);
      final b = _rand.nextInt(lim + 1);
      final c = _rand.nextInt(20);
      final ans = a + b + c;
      final q = '$a + $b + $c = ?';
      final options = _shuffleOptions(
        ans,
        () => ans + (_rand.nextInt(21) - 10),
      );
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    } else {
      final lim = _rangeMax(level, base: 10, step: 10, cap: 200);
      final a = _rand.nextInt(lim + 1);
      final b = _rand.nextInt(lim + 1);
      final ans = a + b;
      final q = '$a + $b = ?';
      final options = _shuffleOptions(ans, () => ans + _rand.nextInt(9) - 4);
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    }
  }

  Question _genSubtraction(int level) {
    if (level >= 12) {
      final lim = _rangeMax(level, base: 50, step: 25, cap: 500);
      final a = _rand.nextInt(lim + 1);
      final b = _rand.nextInt(lim + 1);
      final c = _rand.nextInt(20);
      final x = a + b + c;
      final pick = _rand.nextInt(2) == 0 ? a : b;
      final ans = x - pick;
      final q = '$x - $pick = ?';
      final options = _shuffleOptions(
        ans,
        () => ans + (_rand.nextInt(41) - 20),
      );
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    } else {
      final lim = _rangeMax(level, base: 10, step: 10, cap: 200);
      final a = _rand.nextInt(lim + 1);
      final b = _rand.nextInt(a + 1); // ensure non-negative
      final ans = a - b;
      final q = '$a - $b = ?';
      final options = _shuffleOptions(ans, () => ans + _rand.nextInt(9) - 4);
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    }
  }

  Question _genMultiplication(int level) {
    if (level >= 13) {
      final a = 10 + _rand.nextInt(90); // 2-digit
      final b = 10 + _rand.nextInt(90); // 2-digit
      final ans = a * b;
      final q = '$a × $b = ?';
      final options = _shuffleOptions(
        ans,
        () => ans + (a * (_rand.nextInt(5) - 2)),
      );
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    } else if (level >= 7) {
      final a = 10 + _rand.nextInt(90); // 2-digit
      final b = 1 + _rand.nextInt(12); // up to 12
      final ans = a * b;
      final q = '$a × $b = ?';
      final options = _shuffleOptions(
        ans,
        () => ans + (a * (_rand.nextInt(5) - 2)),
      );
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    } else {
      final lim = m.max(5, m.min(12, 5 + level));
      final a = 1 + _rand.nextInt(lim);
      final b = 1 + _rand.nextInt(lim);
      final ans = a * b;
      final q = '$a × $b = ?';
      final options = _shuffleOptions(
        ans,
        () => ans + (_rand.nextInt(5) - 2) * a,
      );
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    }
  }

  Question _genDivision(int level) {
    if (level >= 13) {
      final b = 2 + _rand.nextInt(19); // 2..20
      final ans = 2 + _rand.nextInt(19); // 2..20
      final a = ans * b;
      final q = '$a ÷ $b = ?';
      final options = _shuffleOptions(
        ans,
        () => m.max(1, ans + _rand.nextInt(9) - 4),
      );
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    } else if (level >= 7) {
      final b = 1 + _rand.nextInt(12);
      final ans = 1 + _rand.nextInt(20);
      final a = ans * b;
      final q = '$a ÷ $b = ?';
      final options = _shuffleOptions(
        ans,
        () => m.max(1, ans + _rand.nextInt(7) - 3),
      );
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    } else {
      final lim = m.max(5, m.min(12, 5 + level));
      final b = 1 + _rand.nextInt(lim);
      final ans = 1 + _rand.nextInt(lim);
      final a = ans * b; // a ÷ b = ans
      final q = '$a ÷ $b = ?';
      final options = _shuffleOptions(
        ans,
        () => m.max(1, ans + _rand.nextInt(5) - 2),
      );
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    }
  }

  Question _genDecimals(int level) {
    if (level <= 5) {
      // 1 decimal place addition
      const places = 1;
      const scale = 10;
      final a = _rand.nextInt(100) / scale;
      final b = _rand.nextInt(100) / scale;
      final ans = ((a + b) * scale).round() / scale;
      final q =
          '${a.toStringAsFixed(places)} + ${b.toStringAsFixed(places)} = ?';
      final opts = <double>{ans};
      while (opts.length < 4) {
        final v = ans + (_rand.nextInt(7) - 3) / scale;
        opts.add(((v) * scale).round() / scale);
      }
      final list = opts.map((e) => e.toStringAsFixed(places)).toList()
        ..shuffle(_rand);
      final idx = list.indexOf(ans.toStringAsFixed(places));
      return Question(question: q, options: list, answerIndex: idx);
    } else if (level <= 10) {
      // 1 decimal place subtraction, non-negative
      const places = 1;
      const scale = 10;
      final a = _rand.nextInt(100) / scale;
      final b = _rand.nextInt((a * scale).toInt() + 1) / scale; // ensure b <= a
      final ans = ((a - b) * scale).round() / scale;
      final q =
          '${a.toStringAsFixed(places)} - ${b.toStringAsFixed(places)} = ?';
      final opts = <double>{ans};
      while (opts.length < 4) {
        final v = ans + (_rand.nextInt(7) - 3) / scale;
        opts.add(((v) * scale).round() / scale);
      }
      final list = opts.map((e) => e.toStringAsFixed(places)).toList()
        ..shuffle(_rand);
      final idx = list.indexOf(ans.toStringAsFixed(places));
      return Question(question: q, options: list, answerIndex: idx);
    } else if (level <= 15) {
      // 2 decimal places addition
      const places = 2;
      const scale = 100;
      final a = _rand.nextInt(1000) / scale;
      final b = _rand.nextInt(1000) / scale;
      final ans = ((a + b) * scale).round() / scale;
      final q =
          '${a.toStringAsFixed(places)} + ${b.toStringAsFixed(places)} = ?';
      final opts = <double>{ans};
      while (opts.length < 4) {
        final v = ans + (_rand.nextInt(7) - 3) / scale;
        opts.add(((v) * scale).round() / scale);
      }
      final list = opts.map((e) => e.toStringAsFixed(places)).toList()
        ..shuffle(_rand);
      final idx = list.indexOf(ans.toStringAsFixed(places));
      return Question(question: q, options: list, answerIndex: idx);
    } else {
      // Multiply decimal by 1-digit integer
      const places = 2;
      const scale = 100;
      final a = _rand.nextInt(1000) / scale;
      final b = 1 + _rand.nextInt(9);
      final ans = ((a * b) * scale).round() / scale;
      final q = '${a.toStringAsFixed(places)} × $b = ?';
      final opts = <double>{ans};
      while (opts.length < 4) {
        final v = ans + (_rand.nextInt(11) - 5) / scale;
        opts.add(((v) * scale).round() / scale);
      }
      final list = opts.map((e) => e.toStringAsFixed(places)).toList()
        ..shuffle(_rand);
      final idx = list.indexOf(ans.toStringAsFixed(places));
      return Question(question: q, options: list, answerIndex: idx);
    }
  }

  Question _genFractions(int level) {
    if (level <= 5) {
      // 1/2 of N with integer result
      // Ensure at least 30 unique prompts: even numbers up to >= 60
      final baseMax = _rangeMax(level, base: 10, step: 10, cap: 200);
      final maxN = m.max(baseMax, 60);
      final k = m.max(1, (maxN / 2).floor());
      final n = 2 * (1 + _rand.nextInt(k));
      final ans = n / 2;
      final q = 'What is 1/2 of $n?';
      final opts = <num>{ans};
      while (opts.length < 4) {
        final v = ans + (_rand.nextInt(9) - 4);
        if (v >= 0) opts.add(v);
      }
      final list =
          opts
              .map((e) => e % 1 == 0 ? e.toInt().toString() : e.toString())
              .toList()
            ..shuffle(_rand);
      final correctStr = ans % 1 == 0 ? ans.toInt().toString() : ans.toString();
      final idx = list.indexOf(correctStr);
      return Question(question: q, options: list, answerIndex: idx);
    } else if (level <= 10) {
      // 1/3 of N with integer result
      // Ensure at least 30 unique prompts: multiples of 3 up to >= 90
      final baseMax = _rangeMax(level, base: 12, step: 12, cap: 240);
      final maxN = m.max(baseMax, 90);
      final k = m.max(1, (maxN / 3).floor());
      final n = 3 * (1 + _rand.nextInt(k));
      final ans = n / 3;
      final q = 'What is 1/3 of $n?';
      final opts = <num>{ans};
      while (opts.length < 4) {
        final v = ans + (_rand.nextInt(9) - 4);
        if (v >= 0) opts.add(v);
      }
      final list =
          opts
              .map((e) => e % 1 == 0 ? e.toInt().toString() : e.toString())
              .toList()
            ..shuffle(_rand);
      final correctStr = ans % 1 == 0 ? ans.toInt().toString() : ans.toString();
      final idx = list.indexOf(correctStr);
      return Question(question: q, options: list, answerIndex: idx);
    } else if (level <= 15) {
      // 1/4 of N with integer result
      // Ensure at least 30 unique prompts: multiples of 4 up to >= 120
      final baseMax = _rangeMax(level, base: 16, step: 16, cap: 320);
      final maxN = m.max(baseMax, 120);
      final k = m.max(1, (maxN / 4).floor());
      final n = 4 * (1 + _rand.nextInt(k));
      final ans = n / 4;
      final q = 'What is 1/4 of $n?';
      final opts = <num>{ans};
      while (opts.length < 4) {
        final v = ans + (_rand.nextInt(9) - 4);
        if (v >= 0) opts.add(v);
      }
      final list =
          opts
              .map((e) => e % 1 == 0 ? e.toInt().toString() : e.toString())
              .toList()
            ..shuffle(_rand);
      final correctStr = ans % 1 == 0 ? ans.toInt().toString() : ans.toString();
      final idx = list.indexOf(correctStr);
      return Question(question: q, options: list, answerIndex: idx);
    } else {
      // Simplify fraction a/b
      final a = 2 + _rand.nextInt(98);
      final b = 2 + _rand.nextInt(98);
      final g = _gcd(a, b);
      final sa = a ~/ g;
      final sb = b ~/ g;
      // Make reducible again by scaling
      final aa = sa * (2 + _rand.nextInt(4));
      final bb = sb * (2 + _rand.nextInt(4));
      final gg = _gcd(aa, bb);
      final ca = aa ~/ gg;
      final cb = bb ~/ gg;
      final q = 'Simplify $aa/$bb';
      final correct = '$ca/$cb';
      final options = _shuffleStringOptions(correct, () {
        // Generate nearby fractions
        final da = m.max(1, ca + (_rand.nextInt(7) - 3));
        final db = m.max(1, cb + (_rand.nextInt(7) - 3));
        return '$da/$db';
      });
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    }
  }

  // returns shuffled options and index of correct answer
  (List<String>, int) _shuffleOptions(
    num answer,
    num Function() distractorGen,
  ) {
    final set = <num>{answer};
    while (set.length < 4) {
      final v = distractorGen();
      set.add(v);
    }
    final list = set.map((e) => e.toString()).toList();
    list.shuffle(_rand);
    final idx = list.indexOf(answer.toString());
    return (list, idx);
  }

  // returns shuffled string options and index of correct answer
  (List<String>, int) _shuffleStringOptions(
    String answer,
    String Function() distractorGen,
  ) {
    final set = <String>{answer};
    while (set.length < 4) {
      final v = distractorGen();
      set.add(v);
    }
    final list = set.toList();
    list.shuffle(_rand);
    final idx = list.indexOf(answer);
    return (list, idx);
  }

  int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }
}
