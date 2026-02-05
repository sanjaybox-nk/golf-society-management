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
      backgroundColor: Theme.of(context).primaryColor,
      toolbarHeight: 100.0,
      pinned: true,
      automaticallyImplyLeading: false,
      centerTitle: true,
      leadingWidth: 70,
      leading: Center(
        child: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
