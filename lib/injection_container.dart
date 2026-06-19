import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/ads_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/tts_service.dart';
import 'features/quiz/data/repositories/quiz_repository.dart';
import 'features/streak/data/models/streak_model.dart';
import 'features/streak/data/repositories/streak_repository.dart';
import 'features/vocabulary/data/datasources/vocabulary_local_datasource.dart';
import 'features/vocabulary/data/models/word_model.dart';
import 'features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import 'features/vocabulary/domain/repositories/vocabulary_repository.dart';
import 'app/router.dart';

export 'app/router.dart' show routerProvider;

// ─── Isar ───────────────────────────────────────────────────────────────────

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Initialize Isar before using isarProvider');
});

Future<Isar> openIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  if (Isar.instanceNames.isEmpty) {
    return Isar.open(
      [WordModelSchema, StreakModelSchema],
      directory: dir.path,
    );
  }
  return Isar.getInstance()!;
}

// ─── SharedPreferences ───────────────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences first');
});

// ─── Services ───────────────────────────────────────────────────────────────

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.read(sharedPreferencesProvider));
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final adsServiceProvider = Provider<AdsService>((ref) {
  return AdsService();
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

// ─── Vocabulary ──────────────────────────────────────────────────────────────

final vocabularyDatasourceProvider = Provider<VocabularyLocalDatasource>((ref) {
  return VocabularyLocalDatasource(ref.read(isarProvider));
});

final vocabularyRepositoryProvider = Provider<IVocabularyRepository>((ref) {
  return VocabularyRepositoryImpl(ref.read(vocabularyDatasourceProvider));
});

// ─── Streak ──────────────────────────────────────────────────────────────────

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(ref.read(isarProvider));
});

// ─── Quiz ─────────────────────────────────────────────────────────────────────

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository();
});
