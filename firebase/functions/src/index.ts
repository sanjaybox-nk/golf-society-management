import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { processMatchPlayReminders } from './match_play_reminders';
import { migrateMemberIds } from './migrate_member_ids';

// Initialize Admin SDK once
admin.initializeApp();

/**
 * Scheduled Function: Match Play Reminders
 * Runs every day at 8:00 AM UTC to check for upcoming deadlines (5 days out)
 */
export const matchPlayReminderPulse = functions.pubsub.schedule('0 8 * * *')
    .timeZone('UTC')
    .onRun(async (_context) => {
        console.log('Starting automated Match Play reminders scan...');
        try {
            await processMatchPlayReminders();
            console.log('Match Play reminders scan completed successfully.');
        } catch (error) {
            console.error('Error in Match Play reminders scan:', error);
        }
    });

/**
 * One-shot admin migration: normalises result entries in every `events` document
 * so that the player ID is stored under `memberId` only (removes legacy `userId`
 * and `playerId` fields). Safe to re-run — already-normalised docs are skipped.
 *
 * Secured by requiring a shared secret in the `x-admin-secret` request header.
 * Set the secret via: firebase functions:config:set migration.secret="<value>"
 */
export const runMigrateMemberIds = functions.https.onRequest(async (req, res) => {
    const expectedSecret = functions.config().migration?.secret;
    if (!expectedSecret || req.headers['x-admin-secret'] !== expectedSecret) {
        res.status(403).json({ error: 'Forbidden' });
        return;
    }

    try {
        const result = await migrateMemberIds();
        res.status(200).json({ ok: true, ...result });
    } catch (err) {
        console.error('migrateMemberIds failed:', err);
        res.status(500).json({ ok: false, error: String(err) });
    }
});
