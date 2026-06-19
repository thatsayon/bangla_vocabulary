import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../injection_container.dart';
import 'package:bangla_vocabulary/app/router.dart';
import 'theme.dart';

class BanglaVocabularyApp extends ConsumerWidget {
  const BanglaVocabularyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Bangla Vocabulary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
