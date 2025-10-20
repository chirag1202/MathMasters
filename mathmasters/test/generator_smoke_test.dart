import 'package:test/test.dart';
import 'package:mathmasters/data/question_generator.dart';
import 'package:mathmasters/models/question.dart';

void main() {
  group('Generator smoke', () {
    test('fractions across levels produce valid questions', () {
      final gen = QuestionGenerator();
      for (var level = 1; level <= 20; level++) {
        final qs = gen.generate(
          topics: [Topic.fractions],
          level: level,
          needed: 30,
        );
        expect(qs.length, 30);
        final seen = <String>{};
        for (final q in qs) {
          expect(
            seen.add(q.question),
            isTrue,
            reason: 'duplicate prompt at level $level: ${q.question}',
          );
          expect(q.options.length, 4);
          expect(q.answerIndex, inInclusiveRange(0, 3));
          expect(q.options[q.answerIndex], isNotEmpty);
        }
      }
    });

    test('division across levels produce valid questions', () {
      final gen = QuestionGenerator();
      for (var level = 1; level <= 20; level++) {
        final qs = gen.generate(
          topics: [Topic.division],
          level: level,
          needed: 30,
        );
        expect(qs.length, 30);
        final seen = <String>{};
        for (final q in qs) {
          expect(
            seen.add(q.question),
            isTrue,
            reason: 'duplicate prompt at level $level: ${q.question}',
          );
          expect(q.options.length, 4);
          expect(q.answerIndex, inInclusiveRange(0, 3));
          expect(q.options[q.answerIndex], isNotEmpty);
        }
      }
    });
  });
}
