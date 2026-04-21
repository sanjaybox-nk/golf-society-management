import * as admin from 'firebase-admin';

/**
 * Automating Match Play Reminders Logic
 * This module scans for uncompleted matches 5 days before their deadline.
 */

export async function processMatchPlayReminders() {
    const db = admin.firestore();
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // 1. Query published events with Match Play tournaments
    const eventsSnapshot = await db.collection('golf_events')
        .where('isPublished', '==', true)
        .get();

    for (const eventDoc of eventsSnapshot.docs) {
        const eventData = eventDoc.data();
        const tournamentId = eventData.matchPlayTournamentId;
        const grouping = eventData.grouping || {};
        const roundCutoffs = grouping.roundCutoffs || {};

        if (!tournamentId) continue;

        // 2. Load the tournament details
        const tournamentDoc = await db.collection('match_play_tournaments').doc(tournamentId).get();
        if (!tournamentDoc.exists) continue;

        const tournamentData = tournamentDoc.data();
        if (!tournamentData || !tournamentData.matches) continue;

        const matches = tournamentData.matches;
        const tournamentName = tournamentData.name || 'Tournament';

        for (const match of matches) {
            // Skip completed or byes
            if (match.isCompleted || match.isBye) continue;

            const round = match.round; // MatchRoundType enum/index
            const cutoffStr = roundCutoffs[round];
            if (!cutoffStr) continue;

            const cutoffDate = new Date(cutoffStr);
            cutoffDate.setHours(0, 0, 0, 0);

            // Calculate days remaining
            const timeDiff = cutoffDate.getTime() - today.getTime();
            const daysRemaining = Math.ceil(timeDiff / (1000 * 3600 * 24));

            // Logic: Trigger exactly at 5 days remaining
            if (daysRemaining === 5) {
                const playerIds = [...(match.team1Ids || []), ...(match.team2Ids || [])];
                const deadlineFormatted = cutoffDate.toLocaleDateString('en-GB', { 
                    day: 'numeric', month: 'short' 
                });

                for (const playerId of playerIds) {
                    await db.collection('notifications').add({
                        recipientId: playerId,
                        title: 'Match Play Reminder',
                        message: `Reminder: Your matchplay game in ${tournamentName} must be completed and submitted by ${deadlineFormatted}. Contact your opponent to finalize your tee time!`,
                        timestamp: admin.firestore.FieldValue.serverTimestamp(),
                        category: 'match_play',
                        isRead: false,
                        actionUrl: '/matchplay'
                    });
                }

                console.log(`Sent Match Play reminders for match ${match.id} in tournament ${tournamentName} to ${playerIds.length} players.`);
            }
        }
    }
}
