import '../entities/word_entity.dart';

abstract class IVocabularyRepository {
  /// Load all words from the local JSON asset and seed Isar on first run
  Future<void> seedIfEmpty();

  /// Get words filtered by difficulty, excluding already-learned words
  Future<List<WordEntity>> getWordsByDifficulty(String difficulty);

  /// Get all words (for quiz pool)
  Future<List<WordEntity>> getAllWords();

  /// Get all saved words
  Future<List<WordEntity>> getSavedWords();

  /// Get IDs of words learned today
  Future<List<String>> getLearnedTodayIds();

  /// Mark a word as learned (today)
  Future<void> markWordLearned(String wordId);

  /// Save / unsave a word
  Future<void> saveWord(String wordId);
  Future<void> removeSavedWord(String wordId);

  /// Get total count of learned words across all time
  Future<int> getTotalLearnedCount();

  /// Reset all progress (learned + saved words)
  Future<void> resetProgress();
}
