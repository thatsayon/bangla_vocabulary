class AppConstants {
  AppConstants._();

  static const String appName = 'Bangla Vocabulary';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyDifficultyLevel = 'difficulty_level';
  static const String keyDailyGoal = 'daily_goal';
  static const String keyReminderEnabled = 'reminder_enabled';
  static const String keyReminderHour = 'reminder_hour';
  static const String keyReminderMinute = 'reminder_minute';

  // Difficulty levels
  static const String difficultyEasy = 'easy';
  static const String difficultyMedium = 'medium';
  static const String difficultyHard = 'hard';

  // Daily goal options
  static const List<int> dailyGoalOptions = [5, 10, 20, 30];

  // Ads
  static const String bannerAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String bannerAdUnitIdIOS =
      'ca-app-pub-3940256099942544/2934735716'; // Test ID
  static const String nativeAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/2247696110'; // Test ID
  static const String rewardedAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/5224354917'; // Test ID

  // Notification
  static const int notificationId = 1001;
  static const String notificationChannelId = 'daily_reminder';
  static const String notificationChannelName = 'Daily Reminder';
  static const String notificationTitle = 'Time to Learn!';
  static const String notificationBody =
      'Your daily vocabulary session is waiting. Keep your streak alive! 🔥';

  // Native ad threshold
  static const int nativeAdAfterWords = 15;
}
