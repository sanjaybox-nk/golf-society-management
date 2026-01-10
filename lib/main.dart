import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
     await Firebase.initializeApp(); 
  } catch (e) {
    debugPrint('Firebase init failed (expected if no config): $e');
  }

  runApp(const ProviderScope(child: GolfSocietyApp()));
}

class GolfSocietyApp extends ConsumerWidget {
  const GolfSocietyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Golf Society',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
