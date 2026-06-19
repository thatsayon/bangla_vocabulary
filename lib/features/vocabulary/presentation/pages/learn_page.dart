import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/vocabulary_card.dart';
import '../widgets/daily_progress_widget.dart';
import '../widgets/celebration_modal.dart';
import 'package:bangla_vocabulary/features/vocabulary/domain/entities/word_entity.dart';

class LearnPage extends ConsumerStatefulWidget {
  const LearnPage({super.key});

  @override
  ConsumerState<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends ConsumerState<LearnPage> {
  int _currentIndex = 0;
  bool _showingCelebration = false;

  void _onNext(List<WordEntity> wordList) async {
    if (wordList.isEmpty) return;

    final word = wordList[_currentIndex % wordList.length];

    // Mark as learned
    final justCompleted = await ref
        .read(todayProgressProvider.notifier)
        .markWordLearned(word.id);

    // Show celebration if goal was just completed
    if (justCompleted && !_showingCelebration && mounted) {
      setState(() => _showingCelebration = true);
      await _showCelebration();
      setState(() => _showingCelebration = false);
    }

    // Advance to next word
    setState(() {
      _currentIndex = (_currentIndex + 1) % wordList.length;
    });
  }

  void _onSave(String wordId) {
    final savedAsync = ref.read(savedWordsProvider);
    final isSaved =
        savedAsync.valueOrNull?.any((w) => w.id == wordId) ?? false;
    if (isSaved) {
      ref.read(savedWordsProvider.notifier).removeWord(wordId);
    } else {
      ref.read(savedWordsProvider.notifier).saveWord(wordId);
    }
  }

  Future<void> _showCelebration() async {
    final streak = ref.read(streakProvider).valueOrNull?.current ?? 0;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CelebrationModal(
        streak: streak,
        onContinue: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(wordQueueProvider);
    final progressAsync = ref.watch(todayProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/logo/bp_logo.png'),
          ),
        ),
        title: const Text(AppStrings.learnPageTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ref.watch(streakProvider).maybeWhen(
                  data: (streak) => Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(
                        '${streak.current}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFFEB5757),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
          ),
        ],
      ),
      body: wordsAsync.when(
        data: (words) {
          if (words.isEmpty) {
            return _AllDoneState(
              onReload: () =>
                  ref.read(wordQueueProvider.notifier).reload(),
            );
          }

          final word = words[_currentIndex % words.length];

          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0).abs() > 200) {
                _onNext(words);
              }
            },
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              children: [
                // Progress Bar
                progressAsync.when(
                  data: (p) => DailyProgressWidget(
                    current: p.learned,
                    total: p.goal,
                  ),
                  loading: () => const SizedBox(height: 52),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 20),

                // Vocabulary Card
                VocabularyCard(
                  word: word,
                  onSave: () => _onSave(word.id),
                  onNext: () => _onNext(words),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AllDoneState extends StatelessWidget {
  const _AllDoneState({required this.onReload});
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✅', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              'All done for today!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ve learned all words in this difficulty level.\nCome back tomorrow for new words!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onReload,
              child: const Text('Reload'),
            ),
          ],
        ),
      ),
    );
  }
}
