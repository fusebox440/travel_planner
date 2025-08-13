import 'package:hive_flutter/hive_flutter.dart';
import 'package:travel_planner/core/theme/app_theme.dart';

class SettingsService {
  SettingsService._privateConstructor();
  static final SettingsService _instance = SettingsService._privateConstructor();
  factory SettingsService() => _instance;

  static const _boxName = 'settings';
  static const _themeModeKey = 'appThemeMode';
  static const _reducedMotionKey = 'reducedMotion';
  static const _batterySaverKey = 'batterySaver'; // <-- New Key

  late final Box _settingsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox(_boxName);
  }

  // --- Theme ---
  AppThemeMode getThemeMode() {
    final themeIndex = _settingsBox.get(_themeModeKey, defaultValue: AppThemeMode.light.index) as int;
    return AppThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _settingsBox.put(_themeModeKey, mode.index);
  }

  // --- Motion ---
  bool getReducedMotion() {
    return _settingsBox.get(_reducedMotionKey, defaultValue: false) as bool;
  }

  Future<void> setReducedMotion(bool isEnabled) async {
    await _settingsBox.put(_reducedMotionKey, isEnabled);
  }

  // --- Battery Saver ---
  bool getBatterySaver() {
    return _settingsBox.get(_batterySaverKey, defaultValue: false) as bool;
  }

  Future<void> setBatterySaver(bool isEnabled) async {
    await _settingsBox.put(_batterySaverKey, isEnabled);
  }
}