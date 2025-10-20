import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  static const _key = 'theme_mode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

ThemeData buildLightTheme() {
  const lemon = Color(0xFFFFD166); // lemon yellow
  const orange = Color(0xFFFF9F1C); // bright orange
  const coral = Color(0xFFFF7A59); // coral
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: orange,
      onPrimary: Colors.white,
      secondary: coral,
      onSecondary: Colors.white,
      tertiary: lemon,
      onTertiary: Colors.black,
      error: const Color(0xFFB00020),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black87,
      surfaceContainerHigh: const Color(0xFFFFF3CC),
      onSurfaceVariant: Colors.black87,
      outline: const Color(0xFFEEB96A),
      primaryContainer: const Color(0xFFFFB347),
      onPrimaryContainer: Colors.black,
      secondaryContainer: const Color(0xFFFFC8B4),
      onSecondaryContainer: Colors.black,
      tertiaryContainer: const Color(0xFFFFE49B),
      onTertiaryContainer: Colors.black,
      inverseSurface: const Color(0xFF232020),
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFFFFD166),
      surfaceTint: orange,
      scrim: Colors.black45,
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF8E1),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: orange,
    ),
    useMaterial3: true,
    visualDensity: VisualDensity.comfortable,
  );
}

ThemeData buildDarkTheme() {
  // Keep a colorful dark theme (avoid pure black surfaces)
  const darkBg = Color(0xFF2A2230); // deep plum
  const neonOrange = Color(0xFFFF9F1C);
  const neonPink = Color(0xFFFF4D9A);
  const neonLemon = Color(0xFFFFE066);
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: neonOrange,
      onPrimary: Colors.black,
      secondary: neonPink,
      onSecondary: Colors.black,
      tertiary: neonLemon,
      onTertiary: Colors.black,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      surface: const Color(0xFF33283A),
      onSurface: Colors.white,
      surfaceContainerHigh: const Color(0xFF3C2F45),
      onSurfaceVariant: Colors.white,
      outline: const Color(0xFF6A4B7A),
      primaryContainer: const Color(0xFFFFB347),
      onPrimaryContainer: Colors.black,
      secondaryContainer: const Color(0xFFFF7AB2),
      onSecondaryContainer: Colors.black,
      tertiaryContainer: const Color(0xFFFFE49B),
      onTertiaryContainer: Colors.black,
      inverseSurface: const Color(0xFFFFF8E1),
      onInverseSurface: Colors.black87,
      inversePrimary: neonLemon,
      surfaceTint: neonOrange,
      scrim: Colors.black54,
    ),
    scaffoldBackgroundColor: darkBg,
    appBarTheme: const AppBarTheme(foregroundColor: Colors.white),
    useMaterial3: true,
    visualDensity: VisualDensity.comfortable,
  );
}
