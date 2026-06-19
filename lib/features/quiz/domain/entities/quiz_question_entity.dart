import 'package:bangla_vocabulary/features/vocabulary/domain/entities/word_entity.dart';

class QuizQuestionEntity {
  final WordEntity word;
  final List<String> options; // 4 bangla meanings
  final int correctIndex;

  const QuizQuestionEntity({
    required this.word,
    required this.options,
    required this.correctIndex,
  });
}
