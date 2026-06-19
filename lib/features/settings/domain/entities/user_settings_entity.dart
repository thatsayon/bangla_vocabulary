class UserSettingsEntity {
  final String difficultyLevel;
  final int dailyGoal;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  const UserSettingsEntity({
    required this.difficultyLevel,
    required this.dailyGoal,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
  });

  UserSettingsEntity copyWith({
    String? difficultyLevel,
    int? dailyGoal,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return UserSettingsEntity(
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }
}
