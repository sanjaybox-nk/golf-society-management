const _guestSuffix = '_guest';

class GuestIdHelper {
  GuestIdHelper._();

  /// Returns the effective player ID, appending '_guest' for guest players if not already present.
  /// Handles both the isGuest flag and the legacy _guest suffix pattern.
  static String resolveEffectiveId(Map<String, dynamic> player) {
    final rawId = (player['id'] ?? player['memberId'] ?? player['userId'] ?? '').toString();
    final isGuest = player['isGuest'] == true || rawId.endsWith(_guestSuffix);
    if (!isGuest) return rawId;
    return rawId.endsWith(_guestSuffix) ? rawId : '$rawId$_guestSuffix';
  }

  static bool isGuest(Map<String, dynamic> player) {
    final rawId = (player['id'] ?? '').toString();
    return player['isGuest'] == true || rawId.endsWith(_guestSuffix);
  }

  /// Strips the _guest suffix to get the underlying member ID.
  static String stripGuestSuffix(String id) =>
      id.endsWith(_guestSuffix) ? id.substring(0, id.length - _guestSuffix.length) : id;
}
