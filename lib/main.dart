import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/ads_service.dart';
import 'core/services/notification_service.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init shared preferences
  final prefs = await SharedPreferences.getInstance();

  // Init Isar
  final isar = await openIsar();

  // Init AdMob
  await AdsService.init();

  // Init notifications
  final notifService = NotificationService();
  await notifService.init();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const BanglaVocabularyApp(),
    ),
  );
}
