import 'package:flutter_test/flutter_test.dart';
import 'package:mathmasters/providers/game_mode_provider.dart';

void main() {
  group('GameModeProvider', () {
    test('initial state is single player', () {
      final notifier = GameModeNotifier();
      expect(notifier.state.mode, GameMode.singlePlayer);
      expect(notifier.state.isPlayer1Turn, true);
    });

    test('can set to multiplayer', () {
      final notifier = GameModeNotifier();
      notifier.setMultiplayer();
      expect(notifier.state.mode, GameMode.multiplayer);
    });

    test('can set player names', () {
      final notifier = GameModeNotifier();
      notifier.setPlayer1Name('Alice');
      notifier.setPlayer2Name('Bob');
      expect(notifier.state.player1Name, 'Alice');
      expect(notifier.state.player2Name, 'Bob');
    });

    test('can set player results', () {
      final notifier = GameModeNotifier();
      notifier.setPlayer1Result(1500, const Duration(seconds: 120));
      expect(notifier.state.player1Score, 1500);
      expect(notifier.state.player1Time, const Duration(seconds: 120));
      expect(notifier.state.isPlayer1Turn, false);
    });

    test('can reset state', () {
      final notifier = GameModeNotifier();
      notifier.setMultiplayer();
      notifier.setPlayer1Name('Alice');
      notifier.setPlayer2Name('Bob');
      notifier.reset();
      expect(notifier.state.mode, GameMode.singlePlayer);
      expect(notifier.state.player1Name, null);
      expect(notifier.state.player2Name, null);
    });
  });
}
