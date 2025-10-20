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
    // Add variety by randomly choosing different question formats
    final formatChoice = _rand.nextInt(100);
    
    switch (topic) {
      case Topic.addition:
        // 70% standard, 15% comparison, 15% word problem
        if (formatChoice < 70) {
          return _genAddition(level);
        } else if (formatChoice < 85) {
          return _genAdditionComparison(level);
        } else {
          return _genAdditionWordProblem(level);
        }
      case Topic.subtraction:
        // 70% standard, 15% comparison, 15% word problem
        if (formatChoice < 70) {
          return _genSubtraction(level);
        } else if (formatChoice < 85) {
          return _genSubtractionComparison(level);
        } else {
          return _genSubtractionWordProblem(level);
        }
      case Topic.multiplication:
        // 70% standard, 15% comparison, 15% pattern
        if (formatChoice < 70) {
          return _genMultiplication(level);
        } else if (formatChoice < 85) {
          return _genMultiplicationComparison(level);
        } else {
          return _genMultiplicationPattern(level);
        }
      case Topic.division:
        // 70% standard, 30% remainder or word problem
        if (formatChoice < 70) {
          return _genDivision(level);
        } else {
          return _genDivisionWithRemainder(level);
        }
      case Topic.decimals:
        // 80% standard, 20% comparison
        if (formatChoice < 80) {
          return _genDecimals(level);
        } else {
          return _genDecimalsComparison(level);
        }
      case Topic.fractions:
        // 70% standard, 30% comparison
        if (formatChoice < 70) {
          return _genFractions(level);
        } else {
          return _genFractionsComparison(level);
        }
    }
  }

  int _rangeMax(int level, {int base = 10, int step = 10, int cap = 200}) {
    return m.min(cap, base + (level - 1) * step);
  }

  Question _genAddition(int level) {
    // Increase operands and add more addends with level
    // Add variety in question format
    final formatVariant = _rand.nextInt(3);
    
    if (level >= 15) {
      final lim = _rangeMax(level, base: 50, step: 25, cap: 500);
      final a = _rand.nextInt(lim + 1);
      final b = _rand.nextInt(lim + 1);
      final c = _rand.nextInt(lim + 1);
      final ans = a + b + c;
      
      String q;
      if (formatVariant == 0) {
        q = '$a + $b + $c = ?';
      } else if (formatVariant == 1) {
        q = 'What is the sum of $a, $b and $c?';
      } else {
        q = 'Calculate: $a + $b + $c';
      }
      
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
      
      String q;
      if (formatVariant == 0) {
        q = '$a + $b + $c = ?';
      } else if (formatVariant == 1) {
        q = 'Add $a + $b + $c';
      } else {
        q = 'Find the sum: $a + $b + $c';
      }
      
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
      
      String q;
      if (formatVariant == 0) {
        q = '$a + $b = ?';
      } else if (formatVariant == 1) {
        q = 'What is $a plus $b?';
      } else {
        q = 'Add: $a + $b';
      }
      
      final options = _shuffleOptions(ans, () => ans + _rand.nextInt(9) - 4);
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    }
  }

  Question _genSubtraction(int level) {
    final formatVariant = _rand.nextInt(3);
    
    if (level >= 12) {
      final lim = _rangeMax(level, base: 50, step: 25, cap: 500);
      final a = _rand.nextInt(lim + 1);
      final b = _rand.nextInt(lim + 1);
      final c = _rand.nextInt(20);
      final x = a + b + c;
      final pick = _rand.nextInt(2) == 0 ? a : b;
      final ans = x - pick;
      
      String q;
      if (formatVariant == 0) {
        q = '$x - $pick = ?';
      } else if (formatVariant == 1) {
        q = 'What is $x minus $pick?';
      } else {
        q = 'Subtract $pick from $x';
      }
      
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
      
      String q;
      if (formatVariant == 0) {
        q = '$a - $b = ?';
      } else if (formatVariant == 1) {
        q = 'Calculate: $a - $b';
      } else {
        q = 'What is the difference: $a - $b';
      }
      
      final options = _shuffleOptions(ans, () => m.max(0, ans + _rand.nextInt(9) - 4));
      return Question(
        question: q,
        options: options.$1,
        answerIndex: options.$2,
      );
    }
  }

  Question _genMultiplication(int level) {
    final formatVariant = _rand.nextInt(3);
    
    if (level >= 13) {
      final a = 10 + _rand.nextInt(90); // 2-digit
      final b = 10 + _rand.nextInt(90); // 2-digit
      final ans = a * b;
      
      String q;
      if (formatVariant == 0) {
        q = '$a × $b = ?';
      } else if (formatVariant == 1) {
        q = 'Multiply $a by $b';
      } else {
        q = 'What is $a times $b?';
      }
      
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
      
      String q;
      if (formatVariant == 0) {
        q = '$a × $b = ?';
      } else if (formatVariant == 1) {
        q = 'Calculate: $a × $b';
      } else {
        q = 'What is the product of $a and $b?';
      }
      
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
      
      String q;
      if (formatVariant == 0) {
        q = '$a × $b = ?';
      } else if (formatVariant == 1) {
        q = 'Multiply: $a × $b';
      } else {
        q = 'What is $a times $b?';
      }
      
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

  // Addition comparison questions
  Question _genAdditionComparison(int level) {
    final lim = _rangeMax(level, base: 10, step: 10, cap: 200);
    final a = _rand.nextInt(lim + 1);
    final b = _rand.nextInt(lim + 1);
    final c = _rand.nextInt(lim + 1);
    final d = _rand.nextInt(lim + 1);
    final sum1 = a + b;
    final sum2 = c + d;
    final correct = sum1 > sum2 ? '$a + $b' : '$c + $d';
    final q = 'Which is greater: $a + $b or $c + $d?';
    final options = _shuffleStringOptions(correct, () {
      return _rand.nextBool() ? '$a + $b' : '$c + $d';
    });
    return Question(
      question: q,
      options: options.$1,
      answerIndex: options.$2,
    );
  }

  // Addition word problem
  Question _genAdditionWordProblem(int level) {
    final lim = _rangeMax(level, base: 10, step: 10, cap: 100);
    final a = _rand.nextInt(lim + 1);
    final b = _rand.nextInt(lim + 1);
    final ans = a + b;
    final stories = [
      'You have $a apples and get $b more. How many do you have?',
      'There are $a cats and $b dogs. How many animals total?',
      'A book has $a pages and another has $b pages. Total pages?',
      'You collect $a coins and then $b more coins. How many coins?',
    ];
    final q = stories[_rand.nextInt(stories.length)];
    final options = _shuffleOptions(ans, () => ans + _rand.nextInt(9) - 4);
    return Question(
      question: q,
      options: options.$1,
      answerIndex: options.$2,
    );
  }

  // Subtraction comparison questions
  Question _genSubtractionComparison(int level) {
    final lim = _rangeMax(level, base: 10, step: 10, cap: 200);
    final a = _rand.nextInt(lim + 1);
    final b = _rand.nextInt(a + 1);
    final c = _rand.nextInt(lim + 1);
    final d = _rand.nextInt(c + 1);
    final diff1 = a - b;
    final diff2 = c - d;
    final correct = diff1 < diff2 ? '$a - $b' : '$c - $d';
    final q = 'Which is smaller: $a - $b or $c - $d?';
    final options = _shuffleStringOptions(correct, () {
      return _rand.nextBool() ? '$a - $b' : '$c - $d';
    });
    return Question(
      question: q,
      options: options.$1,
      answerIndex: options.$2,
    );
  }

  // Subtraction word problem
  Question _genSubtractionWordProblem(int level) {
    final lim = _rangeMax(level, base: 10, step: 10, cap: 100);
    final a = _rand.nextInt(lim + 1);
    final b = _rand.nextInt(a + 1);
    final ans = a - b;
    final stories = [
      'You have $a candies and eat $b. How many are left?',
      'There are $a birds and $b fly away. How many remain?',
      'A box has $a toys. You give away $b. How many left?',
      'You have \$$a and spend \$$b. How much is left?',
    ];
    final q = stories[_rand.nextInt(stories.length)];
    final options = _shuffleOptions(ans, () => m.max(0, ans + _rand.nextInt(9) - 4));
    return Question(
      question: q,
      options: options.$1,
      answerIndex: options.$2,
    );
  }

  // Multiplication comparison questions
  Question _genMultiplicationComparison(int level) {
    final lim = m.max(5, m.min(12, 5 + level));
    final a = 1 + _rand.nextInt(lim);
    final b = 1 + _rand.nextInt(lim);
    final c = 1 + _rand.nextInt(lim);
    final d = 1 + _rand.nextInt(lim);
    final prod1 = a * b;
    final prod2 = c * d;
    final correct = prod1 > prod2 ? '$a × $b' : '$c × $d';
    final q = 'Which is greater: $a × $b or $c × $d?';
    final options = _shuffleStringOptions(correct, () {
      return _rand.nextBool() ? '$a × $b' : '$c × $d';
    });
    return Question(
      question: q,
      options: options.$1,
      answerIndex: options.$2,
    );
  }

  // Multiplication pattern questions
  Question _genMultiplicationPattern(int level) {
    final base = 1 + _rand.nextInt(12);
    final step = 1 + _rand.nextInt(5);
    final start = base * step;
    final seq = [start, start + base, start + base * 2];
    final ans = start + base * 3;
    final q = 'What comes next: ${seq[0]}, ${seq[1]}, ${seq[2]}, ?';
    final options = _shuffleOptions(ans, () => ans + (_rand.nextInt(11) - 5) * base);
    return Question(
      question: q,
      options: options.$1,
      answerIndex: options.$2,
    );
  }

  // Division with remainder
  Question _genDivisionWithRemainder(int level) {
    final lim = m.max(5, m.min(12, 5 + level));
    final b = 2 + _rand.nextInt(lim);
    final quotient = 1 + _rand.nextInt(lim);
    final remainder = _rand.nextInt(b);
    final a = quotient * b + remainder;
    final ans = remainder;
    final q = 'What is the remainder when $a ÷ $b?';
    final options = _shuffleOptions(ans, () => m.max(0, _rand.nextInt(b)));
    return Question(
      question: q,
      options: options.$1,
      answerIndex: options.$2,
    );
  }

  // Decimals comparison questions
  Question _genDecimalsComparison(int level) {
    const places = level <= 10 ? 1 : 2;
    const scale = level <= 10 ? 10 : 100;
    final a = _rand.nextInt(100) / scale;
    final b = _rand.nextInt(100) / scale;
    final correct = a > b ? a.toStringAsFixed(places) : b.toStringAsFixed(places);
    final q = 'Which is larger: ${a.toStringAsFixed(places)} or ${b.toStringAsFixed(places)}?';
    final options = _shuffleStringOptions(correct, () {
      return _rand.nextBool()
          ? a.toStringAsFixed(places)
          : b.toStringAsFixed(places);
    });
    return Question(
      question: q,
      options: options.$1,
      answerIndex: options.$2,
    );
  }

  // Fractions comparison questions
  Question _genFractionsComparison(int level) {
    final denom = 2 + _rand.nextInt(8);
    final num1 = 1 + _rand.nextInt(denom - 1);
    final num2 = 1 + _rand.nextInt(denom - 1);
    final frac1 = num1 / denom;
    final frac2 = num2 / denom;
    final correct = frac1 > frac2 ? '$num1/$denom' : '$num2/$denom';
    final q = 'Which is larger: $num1/$denom or $num2/$denom?';
    final options = _shuffleStringOptions(correct, () {
      return _rand.nextBool() ? '$num1/$denom' : '$num2/$denom';
    });
    return Question(
      question: q,
      options: options.$1,
      answerIndex: options.$2,
    );
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
