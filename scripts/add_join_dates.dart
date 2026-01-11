import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script to add random joinedDate to members who don't have one
void main() async {
  print('🔧 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final random = Random();

  print('📋 Fetching members...');
  final snapshot = await firestore.collection('members').get();
  
  int updated = 0;
  int skipped = 0;

  for (final doc in snapshot.docs) {
    final data = doc.data();
    
    // Skip if already has joinedDate
    if (data['joinedDate'] != null) {
      skipped++;
      continue;
    }

    // Generate random date between 2020-2024
    final year = 2020 + random.nextInt(5); // 2020-2024
    final month = 1 + random.nextInt(12); // 1-12
    final day = 1 + random.nextInt(28); // 1-28 (safe for all months)
    
    final joinedDate = DateTime(year, month, day);
    
    print('  ✓ Setting ${data['firstName']} ${data['lastName']} -> ${joinedDate.year}-${joinedDate.month.toString().padLeft(2, '0')}-${joinedDate.day.toString().padLeft(2, '0')}');
    
    await doc.reference.update({
      'joinedDate': Timestamp.fromDate(joinedDate),
    });
    
    updated++;
  }

  print('\n✅ Complete!');
  print('   Updated: $updated members');
  print('   Skipped: $skipped members (already had joinedDate)');
  print('   Total: ${snapshot.docs.length} members');
}
