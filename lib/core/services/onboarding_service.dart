import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  OnboardingService._privateConstructor();
  static final OnboardingService _instance = OnboardingService._privateConstructor();
  factory OnboardingService() => _instance;

  static const _key = 'hasSeenOnboarding';
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool hasSeenOnboarding() {
    return _prefs.getBool(_key) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_key, true);
  }
}