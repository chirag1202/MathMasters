import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_history.dart';
import '../providers/persistence_provider.dart';
import 'topic_select_screen.dart' show AppBarThemeToggle;
import '../providers/quiz_provider.dart' show lastSelectedTopicsProvider;
import 'level_select_screen.dart' show LevelSelectScreen;
import 'topic_select_screen.dart' show TopicSelectScreen;
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home),
            onPressed: () => _goHome(context, ref),
          ),
          const AppBarThemeToggle(),
        ],
      ),
      body: FutureBuilder<List<GameHistoryEntry>>(
        future: ref.read(persistenceProvider).getGameHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data!;
          if (history.isEmpty) {
            return const Center(
              child: Text('No game history yet. Play some levels!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return _HistoryTile(entry: entry);
            },
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

class _HistoryTile extends StatelessWidget {
  final GameHistoryEntry entry;
  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y - HH:mm');
    final isMultiplayer = entry.isMultiplayer;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isMultiplayer ? Icons.people : Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  isMultiplayer ? 'Multiplayer' : 'Single Player',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Date: ${dateFormat.format(entry.date)}'),
            Text('Level: ${entry.level}'),
            Text('Topics: ${entry.topics.join(', ')}'),
            const SizedBox(height: 8),
            if (!isMultiplayer) ...[
              Text(
                '${entry.player1Name}: ${entry.player1Score} pts',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.player1Name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: entry.player1Score >= entry.player2Score!
                                ? Colors.green
                                : null,
                          ),
                        ),
                        Text('Score: ${entry.player1Score}'),
                        if (entry.player1TimeRemaining != null)
                          Text(
                            'Time: ${entry.player1TimeRemaining!.inSeconds}s',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.player2Name!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: entry.player2Score! >= entry.player1Score
                                ? Colors.green
                                : null,
                          ),
                        ),
                        Text('Score: ${entry.player2Score}'),
                        if (entry.player2TimeRemaining != null)
                          Text(
                            'Time: ${entry.player2TimeRemaining!.inSeconds}s',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (entry.player1Score > entry.player2Score!)
                Text(
                  '🏆 ${entry.player1Name} won!',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                )
              else if (entry.player2Score! > entry.player1Score)
                Text(
                  '🏆 ${entry.player2Name} won!',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                )
              else
                const Text(
                  '🤝 It\'s a tie!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
