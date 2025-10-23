import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../providers/persistence_provider.dart';
import 'topic_select_screen.dart' show AppBarThemeToggle;
import '../providers/quiz_provider.dart' show lastSelectedTopicsProvider;
import 'level_select_screen.dart' show LevelSelectScreen;
import 'topic_select_screen.dart' show TopicSelectScreen;

class ScoreboardScreen extends ConsumerWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        actions: [
          IconButton(
            tooltip: 'Game History',
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home),
            onPressed: () => _goHome(context, ref),
          ),
          const AppBarThemeToggle(),
        ],
      ),
      body: FutureBuilder<List<ScoreEntry>>(
        future: ref.read(persistenceProvider).getScores(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final scores = snapshot.data!;
          if (scores.isEmpty) {
            return const Center(child: Text('No scores yet. Play a level!'));
          }

          final recent = [...scores]..sort((a, b) => b.date.compareTo(a.date));
          final top = scores.take(10).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Top Scores', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...top.map((e) => _ScoreTile(entry: e)),
              const SizedBox(height: 16),
              Text(
                'Recent Attempts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...recent.map((e) => _ScoreTile(entry: e)),
            ],
          );
        },
      ),
    );
  }
}

void _goHome(BuildContext context, WidgetRef ref) {
  final topics = ref.read(lastSelectedTopicsProvider);
  if (topics != null && topics.isNotEmpty) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LevelSelectScreen(selected: topics)),
      (route) => false,
    );
  } else {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TopicSelectScreen()),
      (route) => false,
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final ScoreEntry entry;
  const _ScoreTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          '${entry.playerName} — L${entry.level} — ${entry.score} pts',
        ),
        subtitle: Text(
          'Topics: ${entry.topics.join(', ')}\n${entry.date.toLocal()}',
        ),
        isThreeLine: true,
      ),
    );
  }
}
