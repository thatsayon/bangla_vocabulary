import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Onboarding
  bool get onboardingCompleted =>
      _prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(AppConstants.keyOnboardingCompleted, value);

  // Difficulty
  String get difficultyLevel =>
      _prefs.getString(AppConstants.keyDifficultyLevel) ??
      AppConstants.difficultyMedium;
  Future<void> setDifficultyLevel(String value) =>
      _prefs.setString(AppConstants.keyDifficultyLevel, value);

  // Daily Goal
  int get dailyGoal => _prefs.getInt(AppConstants.keyDailyGoal) ?? 10;
  Future<void> setDailyGoal(int value) =>
      _prefs.setInt(AppConstants.keyDailyGoal, value);

  // Reminder
  bool get reminderEnabled =>
      _prefs.getBool(AppConstants.keyReminderEnabled) ?? false;
  Future<void> setReminderEnabled(bool value) =>
      _prefs.setBool(AppConstants.keyReminderEnabled, value);

  int get reminderHour => _prefs.getInt(AppConstants.keyReminderHour) ?? 8;
  Future<void> setReminderHour(int value) =>
      _prefs.setInt(AppConstants.keyReminderHour, value);

  int get reminderMinute =>
      _prefs.getInt(AppConstants.keyReminderMinute) ?? 0;
  Future<void> setReminderMinute(int value) =>
      _prefs.setInt(AppConstants.keyReminderMinute, value);

  Future<void> clearAll() => _prefs.clear();
}
