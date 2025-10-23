import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GameMode {
  singlePlayer,
  multiplayer,
}

class GameModeState {
  final GameMode mode;
  final String? player1Name;
  final String? player2Name;
  final int? player1Score;
  final int? player2Score;
  final Duration? player1Time;
  final Duration? player2Time;
  final bool isPlayer1Turn;

  const GameModeState({
    this.mode = GameMode.singlePlayer,
    this.player1Name,
    this.player2Name,
    this.player1Score,
    this.player2Score,
    this.player1Time,
    this.player2Time,
    this.isPlayer1Turn = true,
  });

  GameModeState copyWith({
    GameMode? mode,
    String? player1Name,
    String? player2Name,
    int? player1Score,
    int? player2Score,
    Duration? player1Time,
    Duration? player2Time,
    bool? isPlayer1Turn,
  }) {
    return GameModeState(
      mode: mode ?? this.mode,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      player1Time: player1Time ?? this.player1Time,
      player2Time: player2Time ?? this.player2Time,
      isPlayer1Turn: isPlayer1Turn ?? this.isPlayer1Turn,
    );
  }
}

final gameModeProvider = StateNotifierProvider<GameModeNotifier, GameModeState>(
  (ref) => GameModeNotifier(),
);

class GameModeNotifier extends StateNotifier<GameModeState> {
  GameModeNotifier() : super(const GameModeState());

  void setSinglePlayer() {
    state = const GameModeState(mode: GameMode.singlePlayer);
  }

  void setMultiplayer() {
    state = const GameModeState(mode: GameMode.multiplayer);
  }

  void setPlayer1Name(String name) {
    state = state.copyWith(player1Name: name);
  }

  void setPlayer2Name(String name) {
    state = state.copyWith(player2Name: name);
  }

  void setPlayer1Result(int score, Duration timeRemaining) {
    state = state.copyWith(
      player1Score: score,
      player1Time: timeRemaining,
      isPlayer1Turn: false,
    );
  }

  void setPlayer2Result(int score, Duration timeRemaining) {
    state = state.copyWith(
      player2Score: score,
      player2Time: timeRemaining,
    );
  }

  void reset() {
    state = const GameModeState();
  }
}
