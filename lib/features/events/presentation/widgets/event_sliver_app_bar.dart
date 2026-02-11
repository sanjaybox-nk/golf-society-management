import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';


import '../../../../models/golf_event.dart';


class EventSliverAppBar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {




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
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (isPreview)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    iconSize: 20,
                    color: Colors.white,
                    onPressed: () => context.push('/admin/events/manage/${event.id}/event'),
                    padding: EdgeInsets.zero,
                    tooltip: 'Edit Event',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
