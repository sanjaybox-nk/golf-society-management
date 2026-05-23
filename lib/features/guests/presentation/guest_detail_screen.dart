import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/members/presentation/member_details_modal.dart';
import 'guests_provider.dart';

class GuestDetailScreen extends ConsumerWidget {
  final String guestId;

  const GuestDetailScreen({super.key, required this.guestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guest = ref.watch(guestByIdProvider(guestId));

    if (guest == null) {
      return HeadlessScaffold(
        title: 'Guest Profile',
        showBack: true,
        slivers: [
          SliverFillRemaining(
            child: BoxyArtEmptyCard(
              title: 'Guest Not Found',
              message: 'This guest profile could not be located.',
              icon: Icons.person_off_rounded,
            ),
          ),
        ],
      );
    }

    return MemberDetailsModal(
      guestProfile: guest,
      isAdminContext: true,
      isModal: false,
    );
  }
}
