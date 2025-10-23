class GameHistoryEntry {
  final String player1Name;
  final String? player2Name;
  final List<String> topics;
  final int level;
  final int player1Score;
  final int? player2Score;
  final Duration? player1TimeRemaining;
  final Duration? player2TimeRemaining;
  final DateTime date;
  final bool isMultiplayer;

  const GameHistoryEntry({
    required this.player1Name,
    this.player2Name,
    required this.topics,
    required this.level,
    required this.player1Score,
    this.player2Score,
    this.player1TimeRemaining,
    this.player2TimeRemaining,
    required this.date,
    required this.isMultiplayer,
  });

  Map<String, dynamic> toMap() => {
    'player1Name': player1Name,
    'player2Name': player2Name,
    'topics': topics,
    'level': level,
    'player1Score': player1Score,
    'player2Score': player2Score,
    'player1TimeRemaining': player1TimeRemaining?.inSeconds,
    'player2TimeRemaining': player2TimeRemaining?.inSeconds,
    'date': date.toIso8601String(),
    'isMultiplayer': isMultiplayer,
  };

  factory GameHistoryEntry.fromMap(Map<String, dynamic> map) {
    return GameHistoryEntry(
      player1Name: map['player1Name'] as String,
      player2Name: map['player2Name'] as String?,
      topics: List<String>.from(map['topics'] as List),
      level: map['level'] as int,
      player1Score: map['player1Score'] as int,
      player2Score: map['player2Score'] as int?,
      player1TimeRemaining: map['player1TimeRemaining'] != null
          ? Duration(seconds: map['player1TimeRemaining'] as int)
          : null,
      player2TimeRemaining: map['player2TimeRemaining'] != null
          ? Duration(seconds: map['player2TimeRemaining'] as int)
          : null,
      date: DateTime.parse(map['date'] as String),
      isMultiplayer: map['isMultiplayer'] as bool? ?? false,
    );
  }
}
