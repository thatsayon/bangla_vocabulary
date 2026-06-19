import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bangla_vocabulary/injection_container.dart';
import 'package:bangla_vocabulary/core/constants/app_constants.dart';
import 'package:bangla_vocabulary/features/streak/data/repositories/streak_repository.dart';
import 'package:bangla_vocabulary/features/vocabulary/domain/entities/word_entity.dart';

// ─── Word Queue ──────────────────────────────────────────────────────────────

final wordQueueProvider =
    AsyncNotifierProvider<WordQueueNotifier, List<WordEntity>>(
  WordQueueNotifier.new,
);

class WordQueueNotifier extends AsyncNotifier<List<WordEntity>> {
  @override
  Future<List<WordEntity>> build() async {
    final repo = ref.read(vocabularyRepositoryProvider);
    final storage = ref.read(storageServiceProvider);
    await repo.seedIfEmpty();
    final difficulty = storage.difficultyLevel;
    return repo.getWordsByDifficulty(difficulty);
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(vocabularyRepositoryProvider);
      final storage = ref.read(storageServiceProvider);
      final difficulty = storage.difficultyLevel;
      return repo.getWordsByDifficulty(difficulty);
    });
  }
}

// ─── Today's Progress ────────────────────────────────────────────────────────

final todayProgressProvider =
    AsyncNotifierProvider<TodayProgressNotifier, TodayProgress>(
  TodayProgressNotifier.new,
);

class TodayProgress {
  final int learned;
  final int goal;
  final bool goalCompleted;

  const TodayProgress({
    required this.learned,
    required this.goal,
    required this.goalCompleted,
  });
}

class TodayProgressNotifier extends AsyncNotifier<TodayProgress> {
  @override
  Future<TodayProgress> build() async {
    return _load();
  }

  Future<TodayProgress> _load() async {
    final repo = ref.read(vocabularyRepositoryProvider);
    final storage = ref.read(storageServiceProvider);
    final learnedIds = await repo.getLearnedTodayIds();
    final goal = storage.dailyGoal;
    return TodayProgress(
      learned: learnedIds.length,
      goal: goal,
      goalCompleted: learnedIds.length >= goal,
    );
  }

  Future<bool> markWordLearned(String wordId) async {
    final previousProgress = state.valueOrNull ?? await _load();
    final wasCompleted = previousProgress.goalCompleted;

    final repo = ref.read(vocabularyRepositoryProvider);
    await repo.markWordLearned(wordId);
    final progress = await _load();
    state = AsyncValue.data(progress);

    final justCompleted = !wasCompleted && progress.goalCompleted;

    // If goal just completed, update streak
    if (justCompleted) {
      final streakRepo = ref.read(streakRepositoryProvider);
      await streakRepo.onDailyGoalCompleted();
      ref.invalidate(streakProvider);
    }
    return justCompleted;
  }

  Future<void> reload() async {
    final progress = await _load();
    state = AsyncValue.data(progress);
  }
}

// ─── Saved Words ─────────────────────────────────────────────────────────────

final savedWordsProvider =
    AsyncNotifierProvider<SavedWordsNotifier, List<WordEntity>>(
  SavedWordsNotifier.new,
);

class SavedWordsNotifier extends AsyncNotifier<List<WordEntity>> {
  @override
  Future<List<WordEntity>> build() async {
    final repo = ref.read(vocabularyRepositoryProvider);
    return repo.getSavedWords();
  }

  Future<void> saveWord(String wordId) async {
    final repo = ref.read(vocabularyRepositoryProvider);
    await repo.saveWord(wordId);
    final saved = await repo.getSavedWords();
    state = AsyncValue.data(saved);
  }

  Future<void> removeWord(String wordId) async {
    final repo = ref.read(vocabularyRepositoryProvider);
    await repo.removeSavedWord(wordId);
    final saved = await repo.getSavedWords();
    state = AsyncValue.data(saved);
  }
}

// ─── Streak ──────────────────────────────────────────────────────────────────

final streakProvider =
    AsyncNotifierProvider<StreakNotifier, StreakState>(StreakNotifier.new);

class StreakState {
  final int current;
  final int longest;
  const StreakState({required this.current, required this.longest});
}

class StreakNotifier extends AsyncNotifier<StreakState> {
  @override
  Future<StreakState> build() async {
    final repo = ref.read(streakRepositoryProvider);
    final entity = await repo.getStreak();
    return StreakState(
      current: entity.currentStreak,
      longest: entity.longestStreak,
    );
  }
}

// ─── Settings ─────────────────────────────────────────────────────────────────

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsState {
  final String difficulty;
  final int dailyGoal;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  const SettingsState({
    required this.difficulty,
    required this.dailyGoal,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
  });
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final storage = ref.read(storageServiceProvider);
    return SettingsState(
      difficulty: storage.difficultyLevel,
      dailyGoal: storage.dailyGoal,
      reminderEnabled: storage.reminderEnabled,
      reminderHour: storage.reminderHour,
      reminderMinute: storage.reminderMinute,
    );
  }

  Future<void> setDifficulty(String value) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setDifficultyLevel(value);
    state = _copyWith(difficulty: value);
    ref.invalidate(wordQueueProvider);
  }

  Future<void> setDailyGoal(int value) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setDailyGoal(value);
    state = _copyWith(dailyGoal: value);
    ref.invalidate(todayProgressProvider);
  }

  Future<void> setReminder(bool enabled, int hour, int minute) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setReminderEnabled(enabled);
    await storage.setReminderHour(hour);
    await storage.setReminderMinute(minute);

    final notif = ref.read(notificationServiceProvider);
    if (enabled) {
      await notif.scheduleDaily(hour, minute);
    } else {
      await notif.cancelAll();
    }

    state = SettingsState(
      difficulty: state.difficulty,
      dailyGoal: state.dailyGoal,
      reminderEnabled: enabled,
      reminderHour: hour,
      reminderMinute: minute,
    );
  }

  SettingsState _copyWith({
    String? difficulty,
    int? dailyGoal,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return SettingsState(
      difficulty: difficulty ?? state.difficulty,
      dailyGoal: dailyGoal ?? state.dailyGoal,
      reminderEnabled: reminderEnabled ?? state.reminderEnabled,
      reminderHour: reminderHour ?? state.reminderHour,
      reminderMinute: reminderMinute ?? state.reminderMinute,
    );
  }
}

// ─── Stats providers ──────────────────────────────────────────────────────────

final totalLearnedCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(vocabularyRepositoryProvider);
  return repo.getTotalLearnedCount();
});

final totalSavedCountProvider = Provider<int>((ref) {
  final saved = ref.watch(savedWordsProvider);
  return saved.valueOrNull?.length ?? 0;
});
