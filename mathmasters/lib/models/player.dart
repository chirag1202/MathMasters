class Player {
  final String name;
  final int highestUnlockedLevel;

  const Player({required this.name, this.highestUnlockedLevel = 1});

  Player copyWith({String? name, int? highestUnlockedLevel}) => Player(
    name: name ?? this.name,
    highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'highestUnlockedLevel': highestUnlockedLevel,
  };

  factory Player.fromMap(Map<String, dynamic> map) => Player(
    name: (map['name'] ?? '') as String,
    highestUnlockedLevel: (map['highestUnlockedLevel'] ?? 1) as int,
  );
}

class ScoreEntry {
  final String playerName;
  final List<String> topics; // stored as topic keys
  final int level;
  final int score;
  final DateTime date;

  const ScoreEntry({
    required this.playerName,
    required this.topics,
    required this.level,
    required this.score,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'playerName': playerName,
    'topics': topics,
    'level': level,
    'score': score,
    'date': date.toIso8601String(),
  };

  factory ScoreEntry.fromMap(Map<String, dynamic> map) => ScoreEntry(
    playerName: map['playerName'] as String,
    topics: List<String>.from(map['topics'] as List),
    level: map['level'] as int,
    score: map['score'] as int,
    date: DateTime.parse(map['date'] as String),
  );
}
