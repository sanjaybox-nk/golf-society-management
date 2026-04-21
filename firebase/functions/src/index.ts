import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { processMatchPlayReminders } from './match_play_reminders';

// Initialize Admin SDK once
admin.initializeApp();

/**
 * Scheduled Function: Match Play Reminders
 * Runs every day at 8:00 AM UTC to check for upcoming deadlines (5 days out)
 */
export const matchPlayReminderPulse = functions.pubsub.schedule('0 8 * * *')
    .timeZone('UTC')
    .onRun(async (context) => {
        console.log('Starting automated Match Play reminders scan...');
        try {
            await processMatchPlayReminders();
            console.log('Match Play reminders scan completed successfully.');
        } catch (error) {
            console.error('Error in Match Play reminders scan:', error);
        }
    });

// Placeholder for other functions if they need triggers
// export const syncSeasonStandings = ...
