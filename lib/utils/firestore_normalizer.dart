class FirestoreNormalizer {
  FirestoreNormalizer._();

  /// Resolves the canonical member ID from a Firestore result document.
  /// Handles historical inconsistency where the same field was stored as
  /// memberId, userId, or playerId across different app versions.
  static String resolveMemberId(Map<String, dynamic> record) =>
      (record['memberId'] ?? record['userId'] ?? record['playerId'] ?? 'unknown')
          .toString();
}
