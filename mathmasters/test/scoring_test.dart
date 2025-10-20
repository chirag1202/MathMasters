import 'package:flutter_test/flutter_test.dart';
import 'package:mathmasters/providers/quiz_provider.dart';

void main() {
  group('Scoring', () {
    test('base + time bonus', () {
      expect(
        calculateScore(
          correctAnswers: 0,
          timeRemaining: const Duration(seconds: 0),
        ),
        0,
      );
      expect(
        calculateScore(
          correctAnswers: 1,
          timeRemaining: const Duration(seconds: 5),
        ),
        101,
      );
      expect(
        calculateScore(
          correctAnswers: 5,
          timeRemaining: const Duration(seconds: 49),
        ),
        5 * 100 + 9,
      );
      expect(
        calculateScore(
          correctAnswers: 20,
          timeRemaining: const Duration(seconds: 600),
        ),
        2000 + 120,
      );
    });
  });
}
