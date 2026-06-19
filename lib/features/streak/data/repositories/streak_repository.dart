import 'package:isar/isar.dart';
import '../../domain/entities/streak_entity.dart';
import '../models/streak_model.dart';

class StreakRepository {
  final Isar _isar;

  StreakRepository(this._isar);

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<StreakEntity> getStreak() async {
    final model = await _isar.streakModels.get(1);
    if (model == null) {
      return const StreakEntity(currentStreak: 0, longestStreak: 0);
    }
    return StreakEntity(
      currentStreak: model.currentStreak,
      longestStreak: model.longestStreak,
      lastCompletedDate: model.lastCompletedDate,
    );
  }

  /// Called when the user completes their daily goal.
  /// Returns the new StreakEntity.
  Future<StreakEntity> onDailyGoalCompleted() async {
    final today = _todayKey;
    var model = await _isar.streakModels.get(1);
    model ??= StreakModel()
      ..currentStreak = 0
      ..longestStreak = 0
      ..lastCompletedDate = null;

    // Already completed today — no change
    if (model.lastCompletedDate == today) {
      return StreakEntity(
        currentStreak: model.currentStreak,
        longestStreak: model.longestStreak,
        lastCompletedDate: model.lastCompletedDate,
      );
    }

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final wasYesterday = model.lastCompletedDate == yesterday;

    if (wasYesterday) {
      model.currentStreak += 1;
    } else {
      model.currentStreak = 1; // Reset or start
    }

    if (model.currentStreak > model.longestStreak) {
      model.longestStreak = model.currentStreak;
    }

    model.lastCompletedDate = today;

    await _isar.writeTxn(() async {
      await _isar.streakModels.put(model!);
    });

    return StreakEntity(
      currentStreak: model.currentStreak,
      longestStreak: model.longestStreak,
      lastCompletedDate: model.lastCompletedDate,
    );
  }

  Future<void> resetStreak() async {
    await _isar.writeTxn(() async {
      final model = StreakModel()
        ..currentStreak = 0
        ..longestStreak = 0
        ..lastCompletedDate = null;
      await _isar.streakModels.put(model);
    });
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
