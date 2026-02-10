import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart'; // [NEW]

import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/persistence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
     await Firebase.initializeApp(); 
     
     // [FIX] Ensure we are authenticated for Storage Rules
     if (FirebaseAuth.instance.currentUser == null) {
       await FirebaseAuth.instance.signInAnonymously();
       debugPrint('✅ Signed in anonymously for development');
     }
  } catch (e) {
    debugPrint('Firebase init failed (expected if no config): $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final persistenceService = PersistenceService(prefs);

  runApp(ProviderScope(
    overrides: [
      persistenceServiceProvider.overrideWithValue(persistenceService),
    ],
    child: const GolfSocietyApp()
  ));
}

class GolfSocietyApp extends ConsumerWidget {
  const GolfSocietyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final societyConfig = ref.watch(themeControllerProvider);
    
    final seedColor = Color(societyConfig.primaryColor);
    final themeModeStr = societyConfig.themeMode;
    
    ThemeMode mode = ThemeMode.system;
    if (themeModeStr == 'light') mode = ThemeMode.light;
    if (themeModeStr == 'dark') mode = ThemeMode.dark;

    return MaterialApp.router(
      title: 'Golf Society',
      theme: AppTheme.generateTheme(seedColor: seedColor, brightness: Brightness.light),
      darkTheme: AppTheme.generateTheme(seedColor: seedColor, brightness: Brightness.dark),
      themeMode: mode,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('en', 'GB'),
      ],
    );
  }
}
