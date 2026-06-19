class StreakEntity {
  final int currentStreak;
  final int longestStreak;
  final String? lastCompletedDate; // ISO "YYYY-MM-DD"

  const StreakEntity({
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
  });

  StreakEntity copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastCompletedDate,
  }) {
    return StreakEntity(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }
}
