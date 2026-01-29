import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../features/members/presentation/members_provider.dart';
import '../../../../features/events/presentation/events_provider.dart';
import '../../../../models/member.dart';
import 'dart:math';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const BoxyArtAppBar(title: 'Settings', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SettingsGroup(
            title: 'ACCESS & PERMISSIONS',
            children: [
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'System Roles',
                subtitle: 'View available administrative roles',
                iconColor: Colors.purple,
                onTap: () => context.push('/admin/settings/roles'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _SettingsGroup(
            title: 'APP CONFIGURATION',
            children: [
              _SettingsTile(
                icon: Icons.tune,
                title: 'General',
                subtitle: 'App basics and display settings',
                iconColor: Colors.grey,
                // onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Society Branding',
                subtitle: 'Customize colors and theme',
                iconColor: Colors.pink,
                onTap: () => context.push('/admin/settings/branding'),
              ),
              _SettingsTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                subtitle: 'Push notification preferences',
                iconColor: Colors.grey,
                // onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.badge_outlined,
                title: 'Committee Roles',
                subtitle: 'Manage society specific titles',
                iconColor: const Color(0xFF1A237E), // Navy
                onTap: () => context.push('/admin/settings/committee-roles'),
              ),
            ],
          ),
          _SettingsGroup(
            title: 'MAINTENANCE',
            children: [
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'Clear Database',
                subtitle: 'Remove all members and registrations',
                iconColor: Colors.red,
                onTap: () => _clearDatabase(context, ref),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _SettingsGroup(
            title: 'DEVELOPMENT',
            children: [
              _SettingsTile(
                icon: Icons.science,
                title: 'Seed Members',
                subtitle: 'Generate 60 dummy members',
                iconColor: Colors.amber,
                onTap: () => _seedMembers(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<void> _seedMembers(BuildContext context, WidgetRef ref) async {
    // Basic confirmation
    final confirm = await showBoxyArtDialog<bool>(
      context: context, 
      title: 'Seed Members?',
      message: 'This will add 60 dummy members to your database. Continue?',
      confirmText: 'Seed',
      onCancel: () => Navigator.of(context).pop(false),
      onConfirm: () => Navigator.of(context).pop(true),
    );
    
    if (confirm != true) return;

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Seeding 60 members...')));

    try {
      final repo = ref.read(membersRepositoryProvider);
      final random = Random();
      
      final firstNames = ['James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Charles', 'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen'];
      final lastNames = ['Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson'];

      for (int i = 0; i < 60; i++) {
        final firstName = firstNames[random.nextInt(firstNames.length)];
        final lastName = lastNames[random.nextInt(lastNames.length)];
        final gender = random.nextBool() ? 'Male' : 'Female';
        final handicap = 5 + random.nextDouble() * 25; // 5 to 30
        
        await repo.addMember(Member(
          id: '', // Auto-generated
          firstName: firstName,
          lastName: lastName,
          email: '${firstName.toLowerCase()}.${lastName.toLowerCase()}$i@example.com',
          phone: '07700 900${random.nextInt(999).toString().padLeft(3, '0')}',
          handicap: double.parse(handicap.toStringAsFixed(1)),
          whsNumber: '100${random.nextInt(90000)}',
          status: MemberStatus.active,
          joinedDate: DateTime.now().subtract(Duration(days: random.nextInt(365 * 5))),
          hasPaid: random.nextBool(),
        ));
      }

      messenger.showSnackBar(const SnackBar(content: Text('✅ Successfully added 60 members!')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _clearDatabase(BuildContext context, WidgetRef ref) async {
    // High-risk confirmation
    final confirm = await showBoxyArtDialog<bool>(
      context: context, 
      title: 'DANGER: Clear Database?',
      message: 'This will PERMANENTLY delete all members and all event registrations. There is no undo. Continue?',
      confirmText: 'DESTRUCTIVE DELETE',
      onCancel: () => Navigator.of(context).pop(false),
      onConfirm: () => Navigator.of(context).pop(true),
    );
    
    if (confirm != true) return;

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Clearing database... 🧹')));

    try {
      final membersRepo = ref.read(membersRepositoryProvider);
      final eventsRepo = ref.read(eventsRepositoryProvider);
      final firestore = FirebaseFirestore.instance;

      // 1. Clear Members
      debugPrint('🧹 Fetching members to delete...');
      final members = await membersRepo.getMembers();
      debugPrint('🧹 Found ${members.length} members.');
      
      if (members.isNotEmpty) {
        // Use batches for efficiency (Firestore limit is 500 per batch)
        final memberChunks = _chunkList(members, 400);
        for (final chunk in memberChunks) {
          final batch = firestore.batch();
          for (final member in chunk) {
            batch.delete(firestore.collection('members').doc(member.id));
          }
          await batch.commit();
          debugPrint('🧹 Deleted batch of ${chunk.length} members.');
        }
      }

      // 2. Delete All Events
      debugPrint('🧹 Fetching events to delete...');
      final events = await eventsRepo.getEvents();
      debugPrint('🧹 Found ${events.length} events.');
      
      if (events.isNotEmpty) {
        final eventChunks = _chunkList(events, 400);
        for (final chunk in eventChunks) {
          final batch = firestore.batch();
          for (final event in chunk) {
            batch.delete(firestore.collection('events').doc(event.id));
          }
          await batch.commit();
          debugPrint('🧹 Deleted batch of ${chunk.length} events.');
        }
      }

      messenger.showSnackBar(const SnackBar(content: Text('✅ Database cleared (Members & Events)!')));
    } catch (e) {
      debugPrint('❌ Error clearing database: $e');
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  List<List<T>> _chunkList<T>(List<T> list, int size) {
    List<List<T>> chunks = [];
    for (int i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast) 
                    Divider(height: 1, indent: 56, color: Theme.of(context).dividerColor),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(subtitle, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade600)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }
}
