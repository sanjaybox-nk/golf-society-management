class PlatformContent {
  final String scorecardUnlockedPlayer;
  final String scorecardUnlockedMarker;
  final String scorecardVerified;
  final String markerVerified;
  final String membershipRenewalDue;
  final String membershipPaymentDue;
  final String membershipNudge;
  final String teeTimePromotion;

  const PlatformContent({
    this.scorecardUnlockedPlayer =
        'An admin has unlocked your scorecard. Please review your scores and re-verify.',
    this.scorecardUnlockedMarker =
        "An admin has unlocked {playerName}'s scorecard. Please re-verify their scores.",
    this.scorecardVerified =
        'Your scorecard for {eventName} has been verified.',
    this.markerVerified =
        '{markerName} has confirmed your scores — please review and submit your card.',
    this.membershipRenewalDue =
        'Hi {firstName}, your annual membership is due for renewal. Please visit your profile to confirm and update details.',
    this.membershipPaymentDue =
        'Hi {firstName}, your annual membership renewal is confirmed! Please finalise your payment via your profile to secure your spot for the new season.',
    this.membershipNudge =
        "Hi {firstName}, we haven't heard from you yet regarding the new season! Please submit your preference by {deadline} to stay in the game.",
    this.teeTimePromotion =
        'You have been promoted from the waitlist to Group {groupNumber} for {eventName}.',
  });

  String resolve(String template, Map<String, String> vars) {
    var out = template;
    vars.forEach((k, v) => out = out.replaceAll('{$k}', v));
    return out;
  }

  PlatformContent copyWith({
    String? scorecardUnlockedPlayer,
    String? scorecardUnlockedMarker,
    String? scorecardVerified,
    String? markerVerified,
    String? membershipRenewalDue,
    String? membershipPaymentDue,
    String? membershipNudge,
    String? teeTimePromotion,
  }) =>
      PlatformContent(
        scorecardUnlockedPlayer:
            scorecardUnlockedPlayer ?? this.scorecardUnlockedPlayer,
        scorecardUnlockedMarker:
            scorecardUnlockedMarker ?? this.scorecardUnlockedMarker,
        scorecardVerified: scorecardVerified ?? this.scorecardVerified,
        markerVerified: markerVerified ?? this.markerVerified,
        membershipRenewalDue: membershipRenewalDue ?? this.membershipRenewalDue,
        membershipPaymentDue: membershipPaymentDue ?? this.membershipPaymentDue,
        membershipNudge: membershipNudge ?? this.membershipNudge,
        teeTimePromotion: teeTimePromotion ?? this.teeTimePromotion,
      );

  factory PlatformContent.fromJson(Map<String, dynamic> json) =>
      PlatformContent(
        scorecardUnlockedPlayer: json['scorecardUnlockedPlayer'] as String? ??
            'An admin has unlocked your scorecard. Please review your scores and re-verify.',
        scorecardUnlockedMarker: json['scorecardUnlockedMarker'] as String? ??
            "An admin has unlocked {playerName}'s scorecard. Please re-verify their scores.",
        scorecardVerified: json['scorecardVerified'] as String? ??
            'Your scorecard for {eventName} has been verified.',
        markerVerified: json['markerVerified'] as String? ??
            '{markerName} has confirmed your scores — please review and submit your card.',
        membershipRenewalDue: json['membershipRenewalDue'] as String? ??
            'Hi {firstName}, your annual membership is due for renewal. Please visit your profile to confirm and update details.',
        membershipPaymentDue: json['membershipPaymentDue'] as String? ??
            'Hi {firstName}, your annual membership renewal is confirmed! Please finalise your payment via your profile to secure your spot for the new season.',
        membershipNudge: json['membershipNudge'] as String? ??
            "Hi {firstName}, we haven't heard from you yet regarding the new season! Please submit your preference by {deadline} to stay in the game.",
        teeTimePromotion: json['teeTimePromotion'] as String? ??
            'You have been promoted from the waitlist to Group {groupNumber} for {eventName}.',
      );

  Map<String, dynamic> toJson() => {
        'scorecardUnlockedPlayer': scorecardUnlockedPlayer,
        'scorecardUnlockedMarker': scorecardUnlockedMarker,
        'scorecardVerified': scorecardVerified,
        'markerVerified': markerVerified,
        'membershipRenewalDue': membershipRenewalDue,
        'membershipPaymentDue': membershipPaymentDue,
        'membershipNudge': membershipNudge,
        'teeTimePromotion': teeTimePromotion,
      };
}
