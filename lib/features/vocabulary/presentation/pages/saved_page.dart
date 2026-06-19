import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../injection_container.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/saved_word_tile.dart';
import 'package:bangla_vocabulary/features/vocabulary/domain/entities/word_entity.dart';

class SavedPage extends ConsumerStatefulWidget {
  const SavedPage({super.key});

  @override
  ConsumerState<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends ConsumerState<SavedPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedAsync = ref.watch(savedWordsProvider);
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
        title: const Text(AppStrings.savedPageTitle),
      ),
      body: savedAsync.when(
        data: (words) {
          final filtered = _query.isEmpty
              ? words
              : words
                  .where((w) =>
                      w.english
                          .toLowerCase()
                          .contains(_query.toLowerCase()) ||
                      w.bangla.contains(_query))
                  .toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchHint,
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF666666), size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),

              if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔖',
                              style: TextStyle(fontSize: 56)),
                          const SizedBox(height: 16),
                          Text(
                            _query.isEmpty
                                ? AppStrings.savedEmptyTitle
                                : 'No results for "$_query"',
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          if (_query.isEmpty)
                            Text(
                              AppStrings.savedEmptyDesc,
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final word = filtered[i];
                      return SavedWordTile(
                        word: word,
                        onRemove: () => ref
                            .read(savedWordsProvider.notifier)
                            .removeWord(word.id),
                      );
                    },
                  ),
                ),

              // Banner Ad placeholder
              _BannerAdPlaceholder(),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _BannerAdPlaceholder extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 52,
      color: const Color(0xFFF7F5F2),
      alignment: Alignment.center,
      child: const Text(
        'Ad',
        style: TextStyle(color: Color(0xFFCCC8C0), fontSize: 12),
      ),
    );
  }
}
