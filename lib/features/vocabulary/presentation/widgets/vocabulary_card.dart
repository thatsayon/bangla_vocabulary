import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/word_entity.dart';
import '../providers/vocabulary_provider.dart';

class VocabularyCard extends ConsumerStatefulWidget {
  const VocabularyCard({
    super.key,
    required this.word,
    required this.onSave,
    required this.onNext,
  });

  final WordEntity word;
  final VoidCallback onSave;
  final VoidCallback onNext;

  @override
  ConsumerState<VocabularyCard> createState() => _VocabularyCardState();
}

class _VocabularyCardState extends ConsumerState<VocabularyCard>
    with SingleTickerProviderStateMixin {
  bool _playingEn = false;
  bool _playingBn = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _playEnglish() async {
    if (_playingEn) return;
    setState(() => _playingEn = true);
    final tts = ref.read(ttsServiceProvider);
    await tts.speakEnglish(widget.word.english);
    if (mounted) setState(() => _playingEn = false);
  }

  Future<void> _playBangla() async {
    if (_playingBn) return;
    setState(() => _playingBn = true);
    final tts = ref.read(ttsServiceProvider);
    await tts.speakBangla(widget.word.bangla);
    if (mounted) setState(() => _playingBn = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savedAsync = ref.watch(savedWordsProvider);
    final isSaved =
        savedAsync.valueOrNull?.any((w) => w.id == widget.word.id) ?? false;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE7E2DA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────────────────
              Row(
                children: [
                  _DifficultyBadge(difficulty: widget.word.difficulty),
                  const Spacer(),
                  _IconBtn(
                    icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved
                        ? const Color(0xFF2F80ED)
                        : const Color(0xFF666666),
                    onTap: widget.onSave,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── English Word ─────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.word.english,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  _AudioBtn(
                    isPlaying: _playingEn,
                    onTap: _playEnglish,
                    label: 'EN',
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ── Pronunciation ────────────────────────────────────────────
              Text(
                widget.word.pronunciation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF2F80ED),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // ── Bangla Meaning ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'বাংলা অর্থ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.word.bangla,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFF222222),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _AudioBtn(
                    isPlaying: _playingBn,
                    onTap: _playBangla,
                    label: 'বাং',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Example ──────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.exampleLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF666666),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.word.exampleEnglish,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.word.exampleBangla,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Next Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onNext,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Next Word'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  AppStrings.swipeHint,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioBtn extends StatelessWidget {
  const _AudioBtn({
    required this.isPlaying,
    required this.onTap,
    required this.label,
  });
  final bool isPlaying;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isPlaying
              ? const Color(0xFF2F80ED).withOpacity(0.12)
              : const Color(0xFFF7F5F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaying
                ? const Color(0xFF2F80ED).withOpacity(0.4)
                : const Color(0xFFE7E2DA),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
              size: 18,
              color: isPlaying
                  ? const Color(0xFF2F80ED)
                  : const Color(0xFF666666),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isPlaying
                    ? const Color(0xFF2F80ED)
                    : const Color(0xFF666666),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (difficulty) {
      case 'easy':
        color = const Color(0xFF27AE60);
        break;
      case 'hard':
        color = const Color(0xFFEB5757);
        break;
      default:
        color = const Color(0xFF2F80ED);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty[0].toUpperCase() + difficulty.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: 26),
    );
  }
}
