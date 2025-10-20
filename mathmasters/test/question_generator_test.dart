import 'package:flutter_test/flutter_test.dart';
import 'package:mathmasters/data/question_generator.dart';
import 'package:mathmasters/models/question.dart';

void main() {
  group('QuestionGenerator', () {
    test('generates division questions with correct answer present', () {
      final gen = QuestionGenerator();
      final qs = gen.generate(topics: [Topic.division], level: 3, needed: 20);
      expect(qs.length, 20);
      for (final q in qs) {
        expect(q.options.length, 4);
        // Parse like "A ÷ B = ?"
        final parts = q.question.split('÷');
        expect(parts.length, 2);
        final a = int.parse(parts[0].trim());
        final right = parts[1].split('=')[0].trim();
        final b = int.parse(right);
        final ans = (a / b).round();
        expect(a % b, 0);
        final ansStr = ans.toString();
        expect(q.options.contains(ansStr), true);
        expect(q.options[q.answerIndex], ansStr);
      }
    });

    test('generates fraction questions with correct answer present', () {
      final gen = QuestionGenerator();
      final qs = gen.generate(topics: [Topic.fractions], level: 4, needed: 20);
      expect(qs.length, 20);
      for (final q in qs) {
        expect(q.options.length, 4);
        // Parse like "What is 1/2 of N?"
        final prefix = 'What is 1/2 of ';
        expect(q.question.startsWith(prefix), true);
        final nStr = q.question.substring(prefix.length, q.question.length - 1);
        final n = int.parse(nStr);
        final ans = n / 2;
        final ansStr = ans % 1 == 0 ? ans.toInt().toString() : ans.toString();
        expect(q.options.contains(ansStr), true);
        expect(q.options[q.answerIndex], ansStr);
      }
    });
  });
}
