import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../models/golf_event.dart';
import '../events_provider.dart';
import '../../../../core/shared_ui/headless_scaffold.dart';

class EventGalleryUserTab extends ConsumerStatefulWidget {
  final String eventId;

  const EventGalleryUserTab({super.key, required this.eventId});

  @override
  ConsumerState<EventGalleryUserTab> createState() => _EventGalleryUserTabState();
}

class _EventGalleryUserTabState extends ConsumerState<EventGalleryUserTab> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(GolfEvent event) async {
    final storage = ref.read(storageServiceProvider);
    
    try {
      // 1. Pick Image (StorageService handles downscaling to 800x800)
      final File? file = await storage.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      setState(() => _isUploading = true);

      // 2. Upload to Storage
      final String downloadUrl = await storage.uploadImage(
        path: 'events/${event.id}/gallery',
        file: file,
      );

      // 3. Update Event in Firestore
      final repo = ref.read(eventsRepositoryProvider);
      final updatedList = List<String>.from(event.galleryUrls)..add(downloadUrl);
      final updatedEvent = event.copyWith(galleryUrls: updatedList);
      
      await repo.updateEvent(updatedEvent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == widget.eventId);
        if (event == null) {
          return const Scaffold(
            body: Center(
              child: Text('Gallery data no longer available'),
            ),
          );
        }
        return HeadlessScaffold(
          title: event.title,
          subtitle: 'Photos',
          showBack: true,
          onBack: () => context.go('/events'),
          slivers: [
            if (event.galleryUrls.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No photos yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Be the first to upload!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          event.galleryUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, loading) {
                            if (loading == null) return child;
                            return Container(color: Colors.grey.shade200);
                          },
                        ),
                      );
                    },
                    childCount: event.galleryUrls.length,
                  ),
                ),
              ),
          ],
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isUploading ? null : () => _pickAndUploadImage(event),
            icon: _isUploading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Icon(Icons.add_a_photo),
            label: Text(_isUploading ? 'Uploading...' : 'Add Photo'),
            backgroundColor: Colors.black,
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
