import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
     // Assuming firebase_options.dart is generated later or user has it.
     // If not present, this will fail compile unless we wrap/comment.
     // For this step, I'll attempt generic init and if it fails, I'll print.
     // But standard practice relies on DefaultFirebaseOptions.
     // Since I don't have the config, I will just Init without options for web/backend or just skip if fail.
     // Actually, to ensure it runs now without config, I'll comment out firebase init or wrap it safely.
     // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006400)), // Golf Green
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      routerConfig: router,
    );
  }
}
