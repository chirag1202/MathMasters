import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool soundEnabled;
  final double textScale;
  const AppSettings({this.soundEnabled = true, this.textScale = 1.0});

  AppSettings copyWith({bool? soundEnabled, double? textScale}) => AppSettings(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    textScale: textScale ?? this.textScale,
  );
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  static const _kSound = 'settings_sound';
  static const _kScale = 'settings_text_scale';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = state.copyWith(
      soundEnabled: p.getBool(_kSound) ?? true,
      textScale: p.getDouble(_kScale) ?? 1.0,
    );
  }

  Future<void> setSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSound, value);
  }

  Future<void> setTextScale(double value) async {
    state = state.copyWith(textScale: value);
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kScale, value);
  }
}
