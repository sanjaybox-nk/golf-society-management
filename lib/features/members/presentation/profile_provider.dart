import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/member.dart';

// Mock Provider for the current logged-in user
final currentUserProvider = Provider<Member>((ref) {
  return const Member(
    id: 'user_123',
    firstName: 'Sanjay',
    lastName: 'Patel',
    email: 'sanjay.patel@example.com',
    handicap: 14.2,
    whsNumber: '1234567890',
    role: MemberRole.superAdmin,
    hasPaid: true,
    bio: 'Golf enthusiast looking to break 80 this season.',
    // address: '123 Fairway Lane',
    // phone: '+44 7700 900000',
  );
});

// Mock Provider for user statistics
final userStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return {
    'roundsPlayed': 12,
    'averageScore': 88.5,
    'wins': 2,
    'bestScore': 82,
  };
});
