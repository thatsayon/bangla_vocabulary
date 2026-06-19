import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../injection_container.dart';
import '../../../vocabulary/domain/entities/word_entity.dart';
import '../../domain/entities/quiz_question_entity.dart';

// ─── Quiz State ──────────────────────────────────────────────────────────────

class QuizState {
  final List<QuizQuestionEntity> questions;
  final int currentIndex;
  final List<int?> answers; // null = unanswered
  final bool finished;

  const QuizState({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    this.finished = false,
  });

  int get score =>
      answers.asMap().entries.where((e) {
        if (e.value == null) return false;
        return e.value == questions[e.key].correctIndex;
      }).length;

  int get totalAnswered => answers.where((a) => a != null).length;
  QuizQuestionEntity? get current =>
      currentIndex < questions.length ? questions[currentIndex] : null;
  bool get isLastQuestion => currentIndex == questions.length - 1;
}

// ─── Quiz Notifier ────────────────────────────────────────────────────────────

final quizProvider =
    AsyncNotifierProvider<QuizNotifier, QuizState>(QuizNotifier.new);

class QuizNotifier extends AsyncNotifier<QuizState> {
  @override
  Future<QuizState> build() async {
    return _generateQuiz();
  }

  Future<QuizState> _generateQuiz() async {
    final vocabRepo = ref.read(vocabularyRepositoryProvider);
    final quizRepo = ref.read(quizRepositoryProvider);
    final storage = ref.read(storageServiceProvider);

    // Use words of current difficulty level
    final allWords = await vocabRepo.getWordsByDifficulty(storage.difficultyLevel);
    final pool = allWords.isNotEmpty
        ? allWords
        : await vocabRepo.getAllWords(); // Fallback to all words

    final questions = quizRepo.generateQuiz(pool, count: 10);
    return QuizState(
      questions: questions,
      currentIndex: 0,
      answers: List.filled(questions.length, null),
    );
  }

  void submitAnswer(int selectedIndex) {
    final current = state.valueOrNull;
    if (current == null || current.finished) return;

    final newAnswers = List<int?>.from(current.answers);
    newAnswers[current.currentIndex] = selectedIndex;

    final isLast = current.isLastQuestion;
    state = AsyncValue.data(QuizState(
      questions: current.questions,
      currentIndex: isLast
          ? current.currentIndex
          : current.currentIndex + 1,
      answers: newAnswers,
      finished: isLast,
    ));
  }

  void nextQuestion() {
    final current = state.valueOrNull;
    if (current == null || current.finished) return;
    state = AsyncValue.data(QuizState(
      questions: current.questions,
      currentIndex: current.currentIndex + 1,
      answers: current.answers,
      finished: current.isLastQuestion,
    ));
  }

  Future<void> restartQuiz() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_generateQuiz);
  }
}
