import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/word_entity.dart';

class SavedWordTile extends ConsumerWidget {
  const SavedWordTile({
    super.key,
    required this.word,
    required this.onRemove,
  });

  final WordEntity word;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E2DA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.english,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  word.bangla,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  word.pronunciation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF2F80ED),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Play audio
          IconButton(
            icon: const Icon(Icons.volume_up_outlined,
                color: Color(0xFF2F80ED)),
            onPressed: () async {
              final tts = ref.read(ttsServiceProvider);
              await tts.speakEnglish(word.english);
            },
          ),
          // Remove
          IconButton(
            icon: const Icon(Icons.bookmark,
                color: Color(0xFF2F80ED)),
            onPressed: () => _confirmRemove(context),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Word?'),
        content: Text(
            'Remove "${word.english}" from saved words?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onRemove();
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Color(0xFFEB5757)),
            ),
          ),
        ],
      ),
    );
  }
}
