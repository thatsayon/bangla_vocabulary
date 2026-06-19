import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/word_entity.dart';
import '../models/word_model.dart';
import '../../../../core/constants/app_assets.dart';

class VocabularyLocalDatasource {
  final Isar _isar;

  VocabularyLocalDatasource(this._isar);

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> seedIfEmpty() async {
    final count = await _isar.wordModels.count();
    if (count > 0) return;

    final jsonString =
        await rootBundle.loadString(AppAssets.vocabularyJson);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    final words = jsonList
        .map((e) => WordModel.fromJson(e as Map<String, dynamic>))
        .toList();

    await _isar.writeTxn(() async {
      await _isar.wordModels.putAll(words);
    });
  }

  Future<List<WordEntity>> getWordsByDifficulty(String difficulty) async {
    final today = _todayKey;
    final models = await _isar.wordModels
        .filter()
        .difficultyEqualTo(difficulty)
        .and()
        .not()
        .learnedDateEqualTo(today)
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<List<WordEntity>> getAllWords() async {
    final models = await _isar.wordModels.where().findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<List<WordEntity>> getSavedWords() async {
    final models =
        await _isar.wordModels.filter().isSavedEqualTo(true).findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<List<String>> getLearnedTodayIds() async {
    final today = _todayKey;
    final models = await _isar.wordModels
        .filter()
        .learnedDateEqualTo(today)
        .findAll();
    return models.map((m) => m.id).toList();
  }

  Future<void> markWordLearned(String wordId) async {
    final model = await _isar.wordModels.get(fastHash(wordId));
    if (model == null) return;
    await _isar.writeTxn(() async {
      model.isLearned = true;
      model.learnedDate = _todayKey;
      await _isar.wordModels.put(model);
    });
  }

  Future<void> saveWord(String wordId) async {
    final model = await _isar.wordModels.get(fastHash(wordId));
    if (model == null) return;
    await _isar.writeTxn(() async {
      model.isSaved = true;
      await _isar.wordModels.put(model);
    });
  }

  Future<void> removeSavedWord(String wordId) async {
    final model = await _isar.wordModels.get(fastHash(wordId));
    if (model == null) return;
    await _isar.writeTxn(() async {
      model.isSaved = false;
      await _isar.wordModels.put(model);
    });
  }

  Future<int> getTotalLearnedCount() async {
    return _isar.wordModels.filter().isLearnedEqualTo(true).count();
  }

  Future<void> resetProgress() async {
    await _isar.writeTxn(() async {
      final all = await _isar.wordModels.where().findAll();
      for (final m in all) {
        m.isLearned = false;
        m.isSaved = false;
        m.learnedDate = null;
      }
      await _isar.wordModels.putAll(all);
    });
  }
}
