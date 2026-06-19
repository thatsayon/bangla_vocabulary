// Analytics service placeholder — extend with Firebase Analytics when needed
class AnalyticsService {
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    // TODO: integrate Firebase Analytics
  }

  void logWordLearned(String word) =>
      logEvent('word_learned', parameters: {'word': word});

  void logQuizCompleted(int score, int total) =>
      logEvent('quiz_completed', parameters: {'score': score, 'total': total});

  void logStreakUpdated(int streak) =>
      logEvent('streak_updated', parameters: {'streak': streak});
}
