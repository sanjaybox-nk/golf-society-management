import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/platform_content.dart';
import 'package:golf_society/features/settings/data/platform_content_repository.dart';

class PlatformContentEditorScreen extends ConsumerStatefulWidget {
  const PlatformContentEditorScreen({super.key});

  @override
  ConsumerState<PlatformContentEditorScreen> createState() =>
      _PlatformContentEditorScreenState();
}

class _PlatformContentEditorScreenState
    extends ConsumerState<PlatformContentEditorScreen> {
  bool _initialized = false;
  bool _saving = false;
  bool _isDirty = false;
  PlatformContent? _original;

  final _cScorecardUnlockedPlayer = TextEditingController();
  final _cScorecardUnlockedMarker = TextEditingController();
  final _cScorecardVerified = TextEditingController();
  final _cMarkerVerified = TextEditingController();
  final _cMembershipRenewalDue = TextEditingController();
  final _cMembershipPaymentDue = TextEditingController();
  final _cMembershipNudge = TextEditingController();
  final _cTeeTimePromotion = TextEditingController();

  List<TextEditingController> get _controllers => [
        _cScorecardUnlockedPlayer,
        _cScorecardUnlockedMarker,
        _cScorecardVerified,
        _cMarkerVerified,
        _cMembershipRenewalDue,
        _cMembershipPaymentDue,
        _cMembershipNudge,
        _cTeeTimePromotion,
      ];

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() {
    if (_initialized && mounted) setState(() => _isDirty = true);
  }

  void _loadFromContent(PlatformContent content) {
    if (_initialized) return;
    _cScorecardUnlockedPlayer.text = content.scorecardUnlockedPlayer;
    _cScorecardUnlockedMarker.text = content.scorecardUnlockedMarker;
    _cScorecardVerified.text = content.scorecardVerified;
    _cMarkerVerified.text = content.markerVerified;
    _cMembershipRenewalDue.text = content.membershipRenewalDue;
    _cMembershipPaymentDue.text = content.membershipPaymentDue;
    _cMembershipNudge.text = content.membershipNudge;
    _cTeeTimePromotion.text = content.teeTimePromotion;
    _original = content;
    _initialized = true;
  }

  PlatformContent _buildContent() => PlatformContent(
        scorecardUnlockedPlayer: _cScorecardUnlockedPlayer.text,
        scorecardUnlockedMarker: _cScorecardUnlockedMarker.text,
        scorecardVerified: _cScorecardVerified.text,
        markerVerified: _cMarkerVerified.text,
        membershipRenewalDue: _cMembershipRenewalDue.text,
        membershipPaymentDue: _cMembershipPaymentDue.text,
        membershipNudge: _cMembershipNudge.text,
        teeTimePromotion: _cTeeTimePromotion.text,
      );

  Future<void> _save() async {
    setState(() => _saving = true);
    final content = _buildContent();
    await ref.read(platformContentRepositoryProvider).update(content);
    if (mounted) {
      setState(() {
        _saving = false;
        _isDirty = false;
        _original = content;
      });
    }
  }

  void _discard() {
    if (_original == null) return;
    _initialized = false;
    _cScorecardUnlockedPlayer.text = _original!.scorecardUnlockedPlayer;
    _cScorecardUnlockedMarker.text = _original!.scorecardUnlockedMarker;
    _cScorecardVerified.text = _original!.scorecardVerified;
    _cMarkerVerified.text = _original!.markerVerified;
    _cMembershipRenewalDue.text = _original!.membershipRenewalDue;
    _cMembershipPaymentDue.text = _original!.membershipPaymentDue;
    _cMembershipNudge.text = _original!.membershipNudge;
    _cTeeTimePromotion.text = _original!.teeTimePromotion;
    setState(() {
      _isDirty = false;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(platformContentProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return contentAsync.when(
      data: (content) {
        _loadFromContent(content);
        return _buildScaffold(context, spacing);
      },
      loading: () => const HeadlessScaffold(
        title: 'Platform Content',
        slivers: [
          SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        ],
      ),
      error: (e, _) => HeadlessScaffold(
        title: 'Error',
        slivers: [
          SliverFillRemaining(child: Center(child: Text('$e')))
        ],
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, AppSpacingTokens? spacing) {
    return HeadlessScaffold(
      title: 'Platform Content',
      subtitle: 'Default notification messages',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      pinnedBottom: _isDirty ? _buildSaveBar() : null,
      slivers: [
        // ── Scoring ────────────────────────────────────────────────────────────
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtSectionTitle(title: 'SCORING', isPeeking: true),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildTemplateField(
                    context,
                    label: 'Scorecard Unlocked — Player',
                    description:
                        'Sent to the player when an admin unlocks their scorecard.',
                    vars: const [],
                    controller: _cScorecardUnlockedPlayer,
                    mockVars: const {},
                  ),
                  const BoxyArtDivider(),
                  _buildTemplateField(
                    context,
                    label: 'Scorecard Unlocked — Marker',
                    description:
                        "Sent to the marker when a player's card is unlocked.",
                    vars: const ['{playerName}'],
                    controller: _cScorecardUnlockedMarker,
                    mockVars: const {'playerName': 'James Fry'},
                  ),
                  const BoxyArtDivider(),
                  _buildTemplateField(
                    context,
                    label: 'Scorecard Verified',
                    description:
                        'Sent to a player when their scorecard is approved.',
                    vars: const ['{eventName}'],
                    controller: _cScorecardVerified,
                    mockVars: const {'eventName': 'Monthly Medal'},
                  ),
                  const BoxyArtDivider(),
                  _buildTemplateField(
                    context,
                    label: 'Marker Confirmed',
                    description:
                        "Sent to the player when their marker confirms scores.",
                    vars: const ['{markerName}'],
                    controller: _cMarkerVerified,
                    mockVars: const {'markerName': 'Tom Walker'},
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
            child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section)),

        // ── Membership ────────────────────────────────────────────────────────
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtSectionTitle(title: 'MEMBERSHIP', isPeeking: true),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildTemplateField(
                    context,
                    label: 'Renewal Due',
                    description:
                        'Sent when the membership renewal window opens.',
                    vars: const ['{firstName}'],
                    controller: _cMembershipRenewalDue,
                    mockVars: const {'firstName': 'James'},
                  ),
                  const BoxyArtDivider(),
                  _buildTemplateField(
                    context,
                    label: 'Payment Due',
                    description:
                        'Sent after renewal is confirmed, before payment.',
                    vars: const ['{firstName}'],
                    controller: _cMembershipPaymentDue,
                    mockVars: const {'firstName': 'James'},
                  ),
                  const BoxyArtDivider(),
                  _buildTemplateField(
                    context,
                    label: 'Renewal Nudge',
                    description:
                        "Sent to members who haven't responded to renewal.",
                    vars: const ['{firstName}', '{deadline}'],
                    controller: _cMembershipNudge,
                    mockVars: const {'firstName': 'James', 'deadline': '31 Oct'},
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
            child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section)),

        // ── Events ────────────────────────────────────────────────────────────
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtSectionTitle(title: 'EVENTS', isPeeking: true),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtCard(
              padding: EdgeInsets.zero,
              child: _buildTemplateField(
                context,
                label: 'Tee Time Promotion',
                description:
                    'Sent when a player is promoted from the waitlist to a tee time.',
                vars: const ['{groupNumber}', '{eventName}'],
                controller: _cTeeTimePromotion,
                mockVars: const {
                  'groupNumber': '3',
                  'eventName': 'Club Championship',
                },
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 160)),
      ],
    );
  }

  Widget _buildSaveBar() {
    return Row(
      children: [
        Expanded(
          child: BoxyArtButton(
            title: 'Discard',
            fullWidth: true,
            onTap: _discard,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: BoxyArtButton(
            title: _saving ? 'Saving…' : 'Save Changes',
            isPrimary: true,
            fullWidth: true,
            onTap: _saving ? null : _save,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateField(
    BuildContext context, {
    required String label,
    required String description,
    required List<String> vars,
    required TextEditingController controller,
    required Map<String, String> mockVars,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final shapes = Theme.of(context).extension<AppShapeTokens>();

    var preview = controller.text;
    mockVars.forEach((k, v) => preview = preview.replaceAll('{$k}', v));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.standard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(
              fontWeight: AppTypography.weightBold,
              letterSpacing: AppTypography.lsLabel,
              color: isDark ? AppColors.pureWhite : AppColors.dark900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.dark200 : AppColors.dark400,
            ),
          ),
          if (vars.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: vars
                  .map((v) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: AppColors.opacityLow),
                          borderRadius: shapes?.pill ?? AppShapes.x2l,
                        ),
                        child: Text(
                          v,
                          style: AppTypography.micro.copyWith(
                            color: primary,
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          BoxyArtTextField(
            controller: controller,
            maxLines: null,
            minLines: 2,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: AppSpacing.sm),
          BoxyArtStatusBanner(
            color: AppColors.dark400,
            icon: Icons.visibility_rounded,
            message: preview.isEmpty ? '—' : preview,
            hasBottomMargin: false,
          ),
        ],
      ),
    );
  }
}
