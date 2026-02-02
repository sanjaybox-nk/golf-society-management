import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/golf_event.dart';

class EventSliverAppBar extends StatelessWidget {
  final GolfEvent event;
  final String title;
  final String? subtitle;
  final bool isPreview;
  final VoidCallback? onCancel;

  const EventSliverAppBar({
    super.key,
    required this.event,
    required this.title,
    this.subtitle,
    this.isPreview = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (isPreview) {
      return SliverAppBar(
        backgroundColor: Theme.of(context).primaryColor,
        toolbarHeight: 100.0,
        pinned: true,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leadingWidth: 70,
        leading: Center(
          child: TextButton(
            onPressed: () => context.canPop() ? context.pop() : context.go('/admin/events'),
            child: const Text('Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
          ],
        ),
        actions: [
          if (event.isRegistrationClosed == false) ...[
            // Show edit button if needed
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => context.push('/admin/events/${event.id}/edit'),
            ),
            const SizedBox(width: 8),
          ]
        ],
      );
    }

    return SliverAppBar(
      expandedHeight: 100.0, 
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.home, color: Colors.white),
        onPressed: () => context.go('/home'),
      ),
      actions: const [
         SizedBox(width: 8),
      ],
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title, 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
              )
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
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
