import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'data_constants.dart';

class MemberSeeder {
  final Ref ref;
  final Random random;

  MemberSeeder(this.ref, this.random);

  Future<void> seed() async {
    final repo = ref.read(membersRepositoryProvider);
    
    // Create Hero Member
    await repo.addMember(Member(
      id: 'demo_hero_sanjay',
      firstName: 'Sanjay',
      lastName: 'Patel',
      email: 'sanjay.patel@demo.com',
      handicap: 14.5,
      handicapId: 'WHS888888',
      role: MemberRole.superAdmin,
      societyRole: 'Admin',
      status: MemberStatus.active,
      joinedDate: DateTime(2025, 1, 1),
      membershipEndDate: DateTime.now().add(const Duration(days: 14)), // Expiring soon for demo
      renewalStatus: MemberRenewalStatus.none,
      hasPaid: true,
      gender: 'Male',
      bio: 'The Society Founder. Passionate about technology and bringing the digital edge to the game of golf.',
      phone: '+44 7700 900000',
      address: 'The Clubhouse, St Andrews, KY16 9XL',
      avatarUrl: SeedingData.maleAvatarUrls[0], // Sanjay (First Male Avatar)
      allowSocialEventsOnly: false,
      handicapHistory: [16.2, 15.8, 15.5, 15.0, 14.8, 14.5],
      isFoundingMember: true,
    ));

    final committeeRoles = {
       0: 'Chairman',
       1: 'Social Secretary',
       20: 'Treasurer',
       21: 'Captain',
       40: 'Handicap Secretary',
    };

    final bios = [
      'Short game specialist. Always finds the bunker on the 18th.',
      'Long hitter with a tendency to find the adjacent fairways.',
      'Putting maestro. Never met a three-putt they didn’t like.',
      'Classic swing, steady temperament. The backbone of the society.',
      'Fierce competitor. Lives for the Sunday singles.',
      'The eternal optimist. Every drive is a potential eagle.',
      'Strategic player. Knows every undulation of the home course.',
      'Social heartbeat of the club. More interested in the 19th hole.',
      'Relative newcomer with a rapidly falling handicap.',
      'Senior statesman. Plays the percentages with deadly accuracy.',
    ];

    int maleCounter = 1; // Start from 1 as Sanjay is 0
    int femaleCounter = 0;

    for (int i = 0; i < 92; i++) {
        bool isFemale = i < 25;
        final fNameList = isFemale ? SeedingData.femaleFirstNames : SeedingData.maleFirstNames;
        final fName = fNameList[i % fNameList.length];
        
        final lName = SeedingData.lastNames[(i + (i ~/ 10)) % SeedingData.lastNames.length];
        
        final role = committeeRoles[i];
        final bio = bios[i % bios.length];
        
        MemberRole systemRole = MemberRole.member;
        if (i == 0 || i == 20) systemRole = MemberRole.admin;
        if (i == 1 || i == 21) systemRole = MemberRole.restrictedAdmin;
        if (i == 36) systemRole = MemberRole.viewer;

        double hc = (i < 10) ? (1.0 + random.nextDouble() * 5) : ((i < 40) ? (6.0 + random.nextDouble() * 14) : (20.0 + random.nextDouble() * 16));
        if (isFemale) hc += 2.0;

        // Date Logic for context
        DateTime joinedDate = DateTime(2025, 1, 1).add(Duration(days: i * 3));
        DateTime membershipEnd = DateTime(2026, 1, 1).add(Duration(days: i * 10));
        
        MemberStatus currentStatus;
        bool hasPaid = true;

        if (i >= 74) {
          // Comprehensive Status Demo Scenario (74-91)
          // Create 3 members for each "Exception" status
          final exceptionIndex = i - 74;
          final statusSet = [
            MemberStatus.pending,     // 74, 75, 76
            MemberStatus.gracePeriod,   // 77, 78, 79
            MemberStatus.suspended,    // 80, 81, 82
            MemberStatus.left,         // 83, 84, 85
            MemberStatus.archived,     // 86, 87, 88
            MemberStatus.expired,      // 89, 90, 91
          ];
          
          currentStatus = statusSet[exceptionIndex ~/ 3];
          hasPaid = currentStatus == MemberStatus.pending ? false : (exceptionIndex % 2 == 0);
          
          if (currentStatus == MemberStatus.left || currentStatus == MemberStatus.archived) {
             joinedDate = DateTime(2024, 1, 1).add(Duration(days: exceptionIndex * 15));
             membershipEnd = DateTime(2024, 12, 31).subtract(Duration(days: exceptionIndex * 2));
             hasPaid = false;
          } else if (currentStatus == MemberStatus.expired || currentStatus == MemberStatus.gracePeriod) {
             membershipEnd = DateTime.now().subtract(const Duration(days: 5));
          }
        } else {
          // Current Market Members
          final isExpired = membershipEnd.isBefore(DateTime.now());
          currentStatus = isExpired ? MemberStatus.expired : MemberStatus.active;
          hasPaid = !isExpired;
        }
        
        final hasRequested = i % 15 == 0 && i < 74;

        double initialCredit = 0.0;
        if (i % 5 == 0 && i != 0 && i < 74) {
          initialCredit = -1 * (10.0 + random.nextInt(90).toDouble());
        }

        String avatarUrl;
        if (isFemale) {
          avatarUrl = SeedingData.femaleAvatarUrls[femaleCounter % SeedingData.femaleAvatarUrls.length];
          femaleCounter++;
        } else {
          avatarUrl = SeedingData.maleAvatarUrls[maleCounter % SeedingData.maleAvatarUrls.length];
          maleCounter++;
        }

        final address = SeedingData.memberAddresses[i % SeedingData.memberAddresses.length];
        
        // Generate a simple handicap history trend
        List<double> history = [];
        double startHC = hc + (random.nextDouble() * 2.0);
        for (int h = 0; h < 5; h++) {
          history.add(double.parse((startHC - (h * 0.4)).toStringAsFixed(1)));
        }

        await repo.addMember(Member(
          id: 'demo_m_$i',
          firstName: fName,
          lastName: lName,
          email: '${fName.toLowerCase()}.${lName.toLowerCase()}$i@demo.org',
          handicap: double.parse(hc.toStringAsFixed(1)),
          handicapId: 'WHS${300000 + i}',
          role: systemRole,
          societyRole: role,
          status: currentStatus,
          joinedDate: joinedDate,
          membershipEndDate: membershipEnd,
          renewalStatus: hasRequested ? MemberRenewalStatus.renew : MemberRenewalStatus.none,
          hasPaid: hasPaid,
          gender: isFemale ? 'Female' : 'Male',
          phone: '+44 7${100000000 + i}',
          address: address,
          bio: i >= 74 ? 'Demo member for ${currentStatus.name} status testing.' : bio,
          avatarUrl: avatarUrl,
          allowSocialEventsOnly: false,
          accountCredit: initialCredit,
          handicapHistory: history,
          isFoundingMember: (i < 5) || (i == 83), // First 5 + one who left
        ));
    }
  }
}
