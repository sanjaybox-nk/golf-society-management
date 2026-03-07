import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:golf_society/services/storage_service.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../events_provider.dart';

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
          SnackBar(content: Text('Error uploading: $e'), backgroundColor: AppColors.coral500),
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
                      Icon(Icons.photo_library, size: AppShapes.iconMassive, color: AppColors.textSecondary),
                      SizedBox(height: AppSpacing.lg),
                      Text('No photos yet', style: TextStyle(color: AppColors.textSecondary, fontSize: AppTypography.sizeLargeBody)),
                      SizedBox(height: AppSpacing.sm),
                      Text('Be the first to upload!', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ClipRRect(
                        borderRadius: AppShapes.sm,
                        child: Image.network(
                          event.galleryUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, loading) {
                            if (loading == null) return child;
                            return Container(color: AppColors.dark200);
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
              ? const SizedBox(width: AppSpacing.xl, height: AppSpacing.xl, child: CircularProgressIndicator(color: AppColors.pureWhite, strokeWidth: 2)) 
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
