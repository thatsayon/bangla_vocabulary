import 'dart:math';
import '../../domain/entities/quiz_question_entity.dart';
import '../../../vocabulary/domain/entities/word_entity.dart';

class QuizRepository {
  final Random _random = Random();

  /// Generate [count] quiz questions from [pool].
  /// Requires at least 4 words to generate meaningful multiple choice.
  List<QuizQuestionEntity> generateQuiz(List<WordEntity> pool, {int count = 10}) {
    if (pool.length < 4) return [];

    final shuffled = List<WordEntity>.from(pool)..shuffle(_random);
    final testWords = shuffled.take(count.clamp(1, pool.length)).toList();

    return testWords.map((word) {
      // Pick 3 unique wrong answers from pool
      final distractors = pool
          .where((w) => w.id != word.id)
          .toList()
        ..shuffle(_random);
      final wrongOptions = distractors.take(3).map((w) => w.bangla).toList();

      // Insert correct answer at random position
      final correctIndex = _random.nextInt(4);
      final options = List<String>.from(wrongOptions)
        ..insert(correctIndex, word.bangla);

      return QuizQuestionEntity(
        word: word,
        options: options,
        correctIndex: correctIndex,
      );
    }).toList();
  }
}
