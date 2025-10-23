import 'package:flutter_test/flutter_test.dart';
import 'package:mathmasters/models/game_history.dart';

void main() {
  group('GameHistoryEntry', () {
    test('can serialize and deserialize single player entry', () {
      final entry = GameHistoryEntry(
        player1Name: 'Alice',
        topics: ['addition', 'subtraction'],
        level: 5,
        player1Score: 1500,
        player1TimeRemaining: const Duration(seconds: 120),
        date: DateTime(2024, 1, 1, 12, 0),
        isMultiplayer: false,
      );

      final map = entry.toMap();
      final restored = GameHistoryEntry.fromMap(map);

      expect(restored.player1Name, 'Alice');
      expect(restored.player2Name, null);
      expect(restored.topics, ['addition', 'subtraction']);
      expect(restored.level, 5);
      expect(restored.player1Score, 1500);
      expect(restored.player2Score, null);
      expect(restored.player1TimeRemaining, const Duration(seconds: 120));
      expect(restored.isMultiplayer, false);
    });

    test('can serialize and deserialize multiplayer entry', () {
      final entry = GameHistoryEntry(
        player1Name: 'Alice',
        player2Name: 'Bob',
        topics: ['multiplication', 'division'],
        level: 10,
        player1Score: 1800,
        player2Score: 1600,
        player1TimeRemaining: const Duration(seconds: 90),
        player2TimeRemaining: const Duration(seconds: 100),
        date: DateTime(2024, 1, 1, 14, 30),
        isMultiplayer: true,
      );

      final map = entry.toMap();
      final restored = GameHistoryEntry.fromMap(map);

      expect(restored.player1Name, 'Alice');
      expect(restored.player2Name, 'Bob');
      expect(restored.topics, ['multiplication', 'division']);
      expect(restored.level, 10);
      expect(restored.player1Score, 1800);
      expect(restored.player2Score, 1600);
      expect(restored.player1TimeRemaining, const Duration(seconds: 90));
      expect(restored.player2TimeRemaining, const Duration(seconds: 100));
      expect(restored.isMultiplayer, true);
    });
  });
}
