import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/game_mode_provider.dart';
import 'topic_select_screen.dart';

class NameEntryScreen extends ConsumerStatefulWidget {
  final bool isSinglePlayer;
  
  const NameEntryScreen({super.key, this.isSinglePlayer = true});

  @override
  ConsumerState<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends ConsumerState<NameEntryScreen> {
  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // For single player, navigate away as soon as a saved name is available
    if (widget.isSinglePlayer) {
      ref.listen<String?>(playerNameProvider, (prev, next) {
        if (!_navigated && next != null && next.isNotEmpty && mounted) {
          _navigated = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TopicSelectScreen()),
          );
        }
      });
      // Also handle the case where the value is already present immediately.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final saved = ref.read(playerNameProvider);
        if (!_navigated && saved != null && saved.isNotEmpty && mounted) {
          _navigated = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TopicSelectScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C2FF), Color(0xFFFFD166)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _ThemeToggle(),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MathQuest Kids',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: widget.isSinglePlayer
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'What\'s your name?',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _controller1,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                  filled: true,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () async {
                                  final name = _controller1.text.trim();
                                  if (name.isEmpty) return;
                                  await ref
                                      .read(playerNameProvider.notifier)
                                      .setName(name);
                                  if (!context.mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TopicSelectScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Let\'s go!'),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Enter Player Names',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _controller1,
                                decoration: const InputDecoration(
                                  labelText: 'Player 1',
                                  hintText: 'Enter player 1 name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                  filled: true,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _controller2,
                                decoration: const InputDecoration(
                                  labelText: 'Player 2',
                                  hintText: 'Enter player 2 name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                  filled: true,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () {
                                  final name1 = _controller1.text.trim();
                                  final name2 = _controller2.text.trim();
                                  if (name1.isEmpty || name2.isEmpty) return;
                                  ref.read(gameModeProvider.notifier).setPlayer1Name(name1);
                                  ref.read(gameModeProvider.notifier).setPlayer2Name(name2);
                                  if (!context.mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TopicSelectScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Let\'s go!'),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark;
    return Tooltip(
      message: isDark ? 'Switch to Light' : 'Switch to Dark',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          ref
              .read(themeModeProvider.notifier)
              .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            isDark ? Icons.wb_sunny : Icons.nightlight_round,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
