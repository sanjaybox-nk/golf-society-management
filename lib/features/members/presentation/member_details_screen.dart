import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/members/presentation/member_details_modal.dart';

class MemberDetailsScreen extends ConsumerWidget {
  final String id;
  final bool isAdminContext;

  const MemberDetailsScreen({
    super.key,
    required this.id,
    this.isAdminContext = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == 'new') {
      return MemberDetailsModal(
        isNewMember: true,
        isAdminContext: isAdminContext,
        isModal: false,
      );
    }

    final memberAsync = ref.watch(memberByIdProvider(id));

    return memberAsync.when(
      data: (member) {
        if (member == null) {
          return HeadlessScaffold(
            title: 'Member Details',
            showBack: true,
            slivers: [
              SliverFillRemaining(
                child: BoxyArtEmptyCard(
                  title: 'Member Not Found',
                  message: 'The requested player could not be located in the society roster.',
                  icon: Icons.person_off_rounded,
                ),
              ),
            ],
          );
        }
        return MemberDetailsModal(
          member: member,
          isAdminContext: isAdminContext,
          isModal: false,
        );
      },
      loading: () => const HeadlessScaffold(
        title: 'Member Details',
        showBack: true,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtLoadingCard(useCard: true),
            ),
          ),
        ],
      ),
      error: (err, stack) => HeadlessScaffold(
        title: 'Member Details',
        showBack: true,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtEmptyCard(
                title: 'Loading Failed',
                message: err.toString(),
                icon: Icons.error_outline_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
