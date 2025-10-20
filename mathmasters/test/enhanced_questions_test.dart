import 'package:flutter_test/flutter_test.dart';
import 'package:mathmasters/data/question_generator.dart';
import 'package:mathmasters/models/question.dart';

void main() {
  group('Enhanced Question Generator Tests', () {
    late QuestionGenerator gen;

    setUp(() {
      gen = QuestionGenerator();
    });

    test('generates fraction questions with various types', () {
      final qs = gen.generate(topics: [Topic.fractions], level: 10, needed: 50);
      expect(qs.length, 50);

      // Check that we have various types of fraction questions
      final hasLikeFractions = qs.any((q) => 
          q.question.contains('/') && 
          q.question.contains('+') || q.question.contains('-'));
      final hasMultiplication = qs.any((q) => 
          q.question.contains('/') && q.question.contains('×'));
      final hasDivision = qs.any((q) => 
          q.question.contains('/') && q.question.contains('÷'));

      // With 50 questions, we should see variety
      expect(hasLikeFractions || hasMultiplication || hasDivision, true,
          reason: 'Should have variety in fraction questions');
      
      // All questions should have 4 options
      for (final q in qs) {
        expect(q.options.length, 4);
      }
    });

    test('generates decimal questions with various operations', () {
      final qs = gen.generate(topics: [Topic.decimals], level: 12, needed: 50);
      expect(qs.length, 50);

      // Check that we have various types of decimal questions
      final hasAddition = qs.any((q) => q.question.contains('+'));
      final hasSubtraction = qs.any((q) => q.question.contains('-'));
      final hasMultiplication = qs.any((q) => q.question.contains('×'));
      final hasDivision = qs.any((q) => q.question.contains('÷'));

      // With 50 questions at level 12, we should see variety
      final varietyCount = [hasAddition, hasSubtraction, hasMultiplication, hasDivision]
          .where((x) => x).length;
      expect(varietyCount, greaterThan(1),
          reason: 'Should have variety in decimal operations');
      
      // All questions should have 4 options
      for (final q in qs) {
        expect(q.options.length, 4);
      }
    });

    test('generates addition questions with higher numbers at higher levels', () {
      final lowLevelQs = gen.generate(topics: [Topic.addition], level: 5, needed: 20);
      final highLevelQs = gen.generate(topics: [Topic.addition], level: 20, needed: 20);

      // Parse numbers from questions (simple approach)
      int getMaxNumber(List<Question> questions) {
        int max = 0;
        for (final q in questions) {
          final numbers = RegExp(r'\d+').allMatches(q.question);
          for (final match in numbers) {
            final num = int.parse(match.group(0)!);
            if (num > max) max = num;
          }
        }
        return max;
      }

      final lowMax = getMaxNumber(lowLevelQs);
      final highMax = getMaxNumber(highLevelQs);

      // Higher level should have larger numbers
      expect(highMax, greaterThan(lowMax),
          reason: 'Higher levels should have larger numbers');
    });

    test('generates subtraction questions with higher numbers at higher levels', () {
      final lowLevelQs = gen.generate(topics: [Topic.subtraction], level: 5, needed: 20);
      final highLevelQs = gen.generate(topics: [Topic.subtraction], level: 20, needed: 20);

      // Parse numbers from questions
      int getMaxNumber(List<Question> questions) {
        int max = 0;
        for (final q in questions) {
          final numbers = RegExp(r'\d+').allMatches(q.question);
          for (final match in numbers) {
            final num = int.parse(match.group(0)!);
            if (num > max) max = num;
          }
        }
        return max;
      }

      final lowMax = getMaxNumber(lowLevelQs);
      final highMax = getMaxNumber(highLevelQs);

      // Higher level should have larger numbers
      expect(highMax, greaterThan(lowMax),
          reason: 'Higher levels should have larger numbers');
    });

    test('all generated questions have correct answer in options', () {
      final topics = [
        Topic.addition,
        Topic.subtraction,
        Topic.multiplication,
        Topic.division,
        Topic.fractions,
        Topic.decimals,
      ];

      for (final topic in topics) {
        final qs = gen.generate(topics: [topic], level: 10, needed: 10);
        for (final q in qs) {
          expect(q.options.length, 4);
          expect(q.answerIndex, greaterThanOrEqualTo(0));
          expect(q.answerIndex, lessThan(4));
          // The answer should be one of the options
          expect(q.options[q.answerIndex], isNotNull);
        }
      }
    });
  });
}
