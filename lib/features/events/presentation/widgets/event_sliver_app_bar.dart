import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/golf_event.dart';

class EventSliverAppBar extends StatelessWidget {
  final GolfEvent event;
  final String title;
  final bool isPreview;
  final VoidCallback? onCancel;

  const EventSliverAppBar({
    super.key,
    required this.event,
    required this.title,
    this.isPreview = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (isPreview) {
      return SliverAppBar(
        backgroundColor: Theme.of(context).primaryColor,
        toolbarHeight: 120,
        pinned: true,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Top Action (Cancel)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Row 2: Title
              Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverAppBar(
      expandedHeight: 88, 
      automaticallyImplyLeading: !isPreview,
      actions: [
        IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ],
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          title, 
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
          )
        ),
        background: event.imageUrl != null 
          ? Image.network(event.imageUrl!, fit: BoxFit.cover)
          : Container(
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }
}
