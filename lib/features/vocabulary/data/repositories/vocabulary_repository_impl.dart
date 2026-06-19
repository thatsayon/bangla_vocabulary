import '../../domain/entities/word_entity.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../datasources/vocabulary_local_datasource.dart';

class VocabularyRepositoryImpl implements IVocabularyRepository {
  final VocabularyLocalDatasource _datasource;

  VocabularyRepositoryImpl(this._datasource);

  @override
  Future<void> seedIfEmpty() => _datasource.seedIfEmpty();

  @override
  Future<List<WordEntity>> getWordsByDifficulty(String difficulty) =>
      _datasource.getWordsByDifficulty(difficulty);

  @override
  Future<List<WordEntity>> getAllWords() => _datasource.getAllWords();

  @override
  Future<List<WordEntity>> getSavedWords() => _datasource.getSavedWords();

  @override
  Future<List<String>> getLearnedTodayIds() =>
      _datasource.getLearnedTodayIds();

  @override
  Future<void> markWordLearned(String wordId) =>
      _datasource.markWordLearned(wordId);

  @override
  Future<void> saveWord(String wordId) => _datasource.saveWord(wordId);

  @override
  Future<void> removeSavedWord(String wordId) =>
      _datasource.removeSavedWord(wordId);

  @override
  Future<int> getTotalLearnedCount() => _datasource.getTotalLearnedCount();

  @override
  Future<void> resetProgress() => _datasource.resetProgress();
}
