import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';

final persistenceProvider = Provider<PersistenceService>(
  (ref) => PersistenceService(),
);

class PersistenceService {
  static const _scoreboardKey = 'scoreboard_entries';

  Future<int> getHighestUnlockedLevel(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_progressKey(playerName)) ?? 1;
  }

  Future<void> setHighestUnlockedLevel(String playerName, int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_progressKey(playerName), level);
  }

  String _progressKey(String name) => 'progress_${name.toLowerCase()}';

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
