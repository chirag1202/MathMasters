import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/theme_provider.dart';
import 'screens/mode_select_screen.dart';
import 'screens/name_entry_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/scoreboard_screen.dart';
import 'screens/history_screen.dart';
import 'providers/settings_provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/topic_select_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final light = buildLightTheme().copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
    final dark = buildDarkTheme().copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    );

    final settings = ref.watch(settingsProvider);
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(settings.textScale)),
      child: MaterialApp(
        title: 'MathQuest Kids',
        theme: light,
        darkTheme: dark,
        themeMode: mode,
        home: _StartRouter(),
        routes: {
          '/settings': (_) => const SettingsScreen(),
          '/scoreboard': (_) => const ScoreboardScreen(),
          '/history': (_) => const HistoryScreen(),
        },
      ),
    );
  }
}

class _StartRouter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(playerNameProvider);
    if (name == null) {
      // Still loading from SharedPreferences
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Always start with mode selection screen
    return const ModeSelectScreen();
  }
}
