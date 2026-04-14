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
      avatarUrl: SeedingData.avatarUrls[1], // Sanjay
      allowSocialEventsOnly: false,
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

    for (int i = 0; i < 74; i++) {
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
        final membershipEnd = DateTime(2026, 1, 1).add(Duration(days: i * 10));
        final hasRequested = i % 15 == 0;
        final isExpired = membershipEnd.isBefore(DateTime.now());
        final currentStatus = isExpired ? MemberStatus.expired : MemberStatus.active;
        
        double initialCredit = 0.0;
        if (i % 5 == 0 && i != 0) {
          initialCredit = -1 * (10.0 + random.nextInt(90).toDouble());
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
          joinedDate: DateTime(2025, 1, 1).add(Duration(days: i * 3)),
          membershipEndDate: membershipEnd,
          renewalStatus: hasRequested ? MemberRenewalStatus.renew : MemberRenewalStatus.none,
          hasPaid: !isExpired,
          gender: isFemale ? 'Female' : 'Male',
          phone: '+44 7${100000000 + i}',
          bio: bio,
          avatarUrl: SeedingData.avatarUrls[i % SeedingData.avatarUrls.length],
          allowSocialEventsOnly: false,
          accountCredit: initialCredit,
        ));
    }
  }
}
