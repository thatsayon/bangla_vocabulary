import 'package:isar/isar.dart';

part 'streak_model.g.dart';

@collection
class StreakModel {
  Id id = 1; // Singleton

  late int currentStreak;
  late int longestStreak;
  String? lastCompletedDate; // "YYYY-MM-DD"
}
