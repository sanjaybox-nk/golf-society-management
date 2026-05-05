import * as admin from 'firebase-admin';
import { onRequest } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { defineSecret } from 'firebase-functions/params';
import { processMatchPlayReminders } from './match_play_reminders';
import { migrateMemberIds } from './migrate_member_ids';

admin.initializeApp();

const migrationSecret = defineSecret('MIGRATION_SECRET');

export const matchPlayReminderPulse = onSchedule(
    { schedule: '0 8 * * *', timeZone: 'UTC' },
    async (_event) => {
        console.log('Starting automated Match Play reminders scan...');
        try {
            await processMatchPlayReminders();
            console.log('Match Play reminders scan completed successfully.');
        } catch (error) {
            console.error('Error in Match Play reminders scan:', error);
        }
    }
);

export const runMigrateMemberIds = onRequest(
    { secrets: [migrationSecret] },
    async (req, res) => {
        const expectedSecret = migrationSecret.value();
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
    }
);
