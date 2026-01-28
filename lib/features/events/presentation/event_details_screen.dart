import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/boxy_art_widgets.dart';
import '../../../models/golf_event.dart';
import 'events_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

class EventDetailsScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider); // Or a specific provider for one event
    
    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        return _EventDetailsContent(event: event);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

class _EventDetailsContent extends StatelessWidget {
  final GolfEvent event;

  const _EventDetailsContent({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRegistrationSection(context),
                  const SizedBox(height: 24),
                  _buildDetailsSection(context),
                  const SizedBox(height: 24),
                  _buildCourseDetailsSection(context),
                  const SizedBox(height: 24),
                  _buildCostsSection(context),
                  const SizedBox(height: 24),
                  _buildDinnerLocationSection(context),
                  const SizedBox(height: 24),
                  _buildNotesSection(context),
                  const SizedBox(height: 24),
                  _buildGallerySection(context),
                  const SizedBox(height: 24),
                  _buildNotificationsSection(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 90, // Reduced from 120 (25% reduction approx)
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          event.title, 
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )
        ),
        background: event.imageUrl != null 
          ? Image.network(event.imageUrl!, fit: BoxFit.cover)
          : Container(
              color: Theme.of(context).primaryColor,
              // Icon removed as requested
            ),
      ),
    );
  }

  Widget _buildRegistrationSection(BuildContext context) {
    // For now, we'll assume the user is a mock member
    const currentMemberId = 'current-user-id';
    
    final myRegistration = event.registrations.where((r) => r.memberId == currentMemberId).firstOrNull;
    final isRegistered = myRegistration != null;
    
    final isPastDeadline = event.registrationDeadline != null && 
                          DateTime.now().isAfter(event.registrationDeadline!);
    final isRegistrationDisabled = isPastDeadline || !event.showRegistrationButton;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Registration'),
        BoxyArtFloatingCard(
          child: Column(
            children: [
              if (!isRegistered) ...[
                Column(
                  children: [
                    Text(
                      isPastDeadline 
                        ? 'Registration Closed'
                        : 'Secure your spot',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isPastDeadline && event.registrationDeadline != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Closes: ${DateFormat.yMMMd().format(event.registrationDeadline!)} @ ${DateFormat('h:mm a').format(event.registrationDeadline!)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ] else if (!isPastDeadline) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Register below to join the event',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: myRegistration.hasPaid ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      myRegistration.hasPaid ? 'Confirmed (Paid)' : 'Registered (Pending)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                const Text(
                  'YOUR SELECTION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryIcon(Icons.golf_course, 'Golf', myRegistration.attendingGolf),
                    _buildSummaryIcon(Icons.electric_rickshaw, 'Buggy', myRegistration.needsBuggy),
                    _buildSummaryIcon(Icons.restaurant, 'Dinner', myRegistration.attendingDinner),
                    _buildSummaryIcon(Icons.person_add, 'Guest', myRegistration.guestName != null),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              
              BoxyArtButton(
                title: isPastDeadline 
                    ? 'Registration closed' 
                    : (isRegistered ? 'Edit Registration' : 'Register Now'),
                onTap: isRegistrationDisabled 
                    ? null 
                    : () {
                        context.push('/events/${event.id}/register');
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryIcon(IconData icon, String label, bool active) {
    return Column(
      children: [
        Icon(
          icon, 
          size: 20, 
          color: active ? Colors.green : Colors.grey.shade300,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: active ? Colors.black87 : Colors.grey.shade400,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Event Details'),
        BoxyArtFloatingCard(
          child: Column(
            children: [
              _buildDetailRow(
                'Course',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailValue(event.courseName ?? 'TBA'),
                    if (event.courseDetails != null && event.courseDetails!.isNotEmpty)
                      Text(
                        event.courseDetails!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
              _buildDetailRow(
                'Tee-off',
                _buildDetailValue(DateFormat('h:mm a').format(event.teeOffTime ?? event.date)),
              ),
              _buildDetailRow(
              'Registration',
              _buildDetailValue(event.regTime != null 
                ? DateFormat('h:mm a').format(event.regTime!)
                : 'TBA'),
            ),
              if (event.description != null && event.description!.isNotEmpty) ...[
                const Divider(height: 32),
                Center(
                  child: Text(
                    event.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Course Details'),
        BoxyArtFloatingCard(
          child: Column(
            children: [
              _buildDetailRow(
                'Dress Code',
                _buildDetailValue(event.dressCode ?? 'Standard Golf Attire'),
              ),
              if (event.facilities.isNotEmpty)
                _buildDetailRow(
                  'Facilities',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: event.facilities.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: _buildDetailValue(f),
                    )).toList(),
                  ),
                ),
              if (event.availableBuggies != null)
                _buildDetailRow(
                  'Buggies',
                  _buildDetailValue('${event.availableBuggies} available'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Fixed width for consistent alignment across cards
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }


  Widget _buildDetailValue(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0), // Reduced vertical padding for multi-line values
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    if (event.notes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Notes & Content'),
        ...event.notes.map((note) => _buildNoteCard(context, note)),
      ],
    );
  }

  Widget _buildNoteCard(BuildContext context, EventNote note) {
    QuillController? quillController;
    try {
      if (note.content.isNotEmpty) {
        quillController = QuillController(
          document: Document.fromJson(jsonDecode(note.content)),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: BoxyArtFloatingCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title != null && note.title!.isNotEmpty) ...[
              Text(
                note.title!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
            ],
            if (note.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  note.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (quillController != null)
              QuillEditor.basic(
                controller: quillController,
                config: QuillEditorConfig(
                  padding: EdgeInsets.zero,
                  autoFocus: false,
                  expands: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Costs'),
        BoxyArtFloatingCard(
          child: Column(
            children: [
              _buildCostRow('Member Golf', event.memberCost),
              _buildCostRow('Guest Golf', event.guestCost),
              _buildCostRow('Dinner', event.dinnerCost),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDinnerLocationSection(BuildContext context) {
    if (event.dinnerLocation == null || event.dinnerLocation!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Dinner Location'),
        BoxyArtFloatingCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Top aligned, not middle aligned
            children: [
              const Icon(Icons.restaurant, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.dinnerLocation!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildGallerySection(BuildContext context) {
    if (event.galleryUrls.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Event Gallery'),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: event.galleryUrls.length,
            itemBuilder: (context, index) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Image.network(event.galleryUrls[index], width: 120, height: 120, fit: BoxFit.cover),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    if (event.flashUpdates.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Updates'),
        ...event.flashUpdates.map((update) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: BoxyArtFloatingCard(
            child: Row(
              children: [
                const Icon(Icons.campaign, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(child: Text(update)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
      ),
    );
  }

  Widget _buildCostRow(String label, double? cost) {
    if (cost == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text('£${cost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
