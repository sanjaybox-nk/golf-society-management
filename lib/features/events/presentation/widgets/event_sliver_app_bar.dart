import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/golf_event.dart';

class EventSliverAppBar extends StatelessWidget {
  final GolfEvent event;
  final String title;

  const EventSliverAppBar({
    super.key,
    required this.event,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 88, 
      actions: [
        IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ],
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title, 
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
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
