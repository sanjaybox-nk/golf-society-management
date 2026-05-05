import * as admin from 'firebase-admin';

/**
 * Resolves the canonical memberId from a result map that may use any of the
 * legacy field names (memberId → userId → playerId).
 * Mirrors the logic in the Flutter FirestoreNormalizer utility.
 */
function resolveMemberId(result: Record<string, unknown>): string | null {
  const raw = result['memberId'] ?? result['userId'] ?? result['playerId'];
  if (raw == null) return null;
  return String(raw);
}

/**
 * Normalises a single result map: ensures 'memberId' is set, and removes the
 * redundant 'userId'/'playerId' fields once migrated.
 * Returns the updated map, or null if no changes were needed.
 */
function normaliseResult(
  result: Record<string, unknown>
): Record<string, unknown> | null {
  const resolved = resolveMemberId(result);
  if (!resolved) return null;

  const hasMemberId = typeof result['memberId'] === 'string' && result['memberId'] !== '';
  const hasLegacyId = 'userId' in result || 'playerId' in result;

  // Nothing to do if memberId already set and no legacy fields present
  if (hasMemberId && !hasLegacyId) return null;

  const updated: Record<string, unknown> = { ...result, memberId: resolved };
  delete updated['userId'];
  delete updated['playerId'];
  return updated;
}

/**
 * One-shot migration: normalises result array entries in every `events` document.
 *
 * Each result map may currently carry the player ID under `memberId`, `userId`,
 * or `playerId`. After migration, all maps use `memberId` exclusively.
 *
 * Safe to re-run — documents already normalised are skipped (no write issued).
 *
 * Returns a JSON summary: { scanned, updated, errors }
 */
export async function migrateMemberIds(): Promise<{
  scanned: number;
  updated: number;
  errors: number;
}> {
  const db = admin.firestore();
  const snapshot = await db.collection('events').get();

  let scanned = 0;
  let updated = 0;
  let errors = 0;

  const batch = db.batch();
  let batchCount = 0;
  const MAX_BATCH = 400; // Firestore batch limit is 500; stay conservative

  const flushBatch = async () => {
    if (batchCount === 0) return;
    await batch.commit();
    batchCount = 0;
  };

  for (const doc of snapshot.docs) {
    scanned++;
    try {
      const data = doc.data();
      const results: Record<string, unknown>[] = Array.isArray(data['results'])
        ? (data['results'] as Record<string, unknown>[])
        : [];

      let dirty = false;
      const normalisedResults = results.map((r) => {
        const updated = normaliseResult(r);
        if (updated) {
          dirty = true;
          return updated;
        }
        return r;
      });

      if (!dirty) continue;

      batch.update(doc.ref, { results: normalisedResults });
      batchCount++;
      updated++;

      if (batchCount >= MAX_BATCH) {
        await flushBatch();
      }
    } catch (err) {
      console.error(`Error processing event ${doc.id}:`, err);
      errors++;
    }
  }

  await flushBatch();

  console.log(`migrateMemberIds complete — scanned: ${scanned}, updated: ${updated}, errors: ${errors}`);
  return { scanned, updated, errors };
}
