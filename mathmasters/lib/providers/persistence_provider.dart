import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';
import '../models/question.dart';

final persistenceProvider = Provider<PersistenceService>(
  (ref) => PersistenceService(),
);

class PersistenceService {
  static const _scoreboardKey = 'scoreboard_entries';

  Future<int> getHighestUnlockedLevel(
    String playerName,
    List<Topic> topics,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _progressKey(playerName, topics);
    final stored = prefs.getInt(key);
    if (stored != null) return stored;
    // Legacy fallback: old key without topics.
    final legacy = prefs.getInt(_legacyProgressKey(playerName));
    return legacy ?? 1;
  }

  Future<void> setHighestUnlockedLevel(
    String playerName,
    List<Topic> topics,
    int level,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_progressKey(playerName, topics), level);
  }

  String _legacyProgressKey(String name) => 'progress_${name.toLowerCase()}';

  String _progressKey(String name, List<Topic> topics) {
    final normalizedName = name.toLowerCase();
    if (topics.isEmpty) {
      return 'progress_${normalizedName}_all';
    }
    final topicIds = topics.map((t) => t.key).toList()..sort();
    final topicKey = topicIds.join('_');
    return 'progress_${normalizedName}_$topicKey';
  }

  Future<void> addScore(ScoreEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_scoreboardKey) ?? <String>[];
    final jsonStr = jsonEncode(entry.toMap());
    list.add(jsonStr);
    await prefs.setStringList(_scoreboardKey, list);
  }

  Future<List<ScoreEntry>> getScores() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_scoreboardKey) ?? <String>[];
    return list
        .map((e) => ScoreEntry.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }
}
