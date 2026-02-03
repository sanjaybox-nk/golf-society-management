export interface GovernanceCheck {
    canPublish: boolean;
    reasons: string[];
}

export enum CompetitionFormat {
    stroke = 'stroke',
    stableford = 'stableford',
    maxScore = 'maxScore',
    matchPlay = 'matchPlay',
    scramble = 'scramble'
}

/**
 * Check if a competition is eligible for publication
 * Logic: Block 'Publish' if format requires hole details but only totals are present
 */
export function validateForPublish(
    format: CompetitionFormat,
    scorecards: {
        holeScores: (number | null)[];
        adminOverridePublish?: boolean;
    }[]
): GovernanceCheck {
    const reasons: string[] = [];

    // Specific formats requiring hole-by-hole
    const requiresHoleDetail = [
        CompetitionFormat.stableford,
        CompetitionFormat.maxScore,
        CompetitionFormat.matchPlay
    ];

    if (!requiresHoleDetail.includes(format)) {
        return { canPublish: true, reasons: [] };
    }

    const incompleteCards = scorecards.filter(card => {
        // If admin explicitly set override, ignore incompleteness
        if (card.adminOverridePublish === true) return false;

        // Check if any holes are missing (null or zero)
        return card.holeScores.some(s => s === null || s === 0);
    });

    if (incompleteCards.length > 0) {
        reasons.push(`${incompleteCards.length} scorecard(s) are missing hole-by-hole details required for ${format}.`);
        return { canPublish: false, reasons };
    }

    return { canPublish: true, reasons: [] };
}

/**
 * Audit Trail Helper
 */
export interface AuditLog {
    entryId: string;
    field: string;
    oldValue: any;
    newValue: any;
    editorId: string;
    reason: string;
    timestamp: number;
}

export function createAuditLog(
    entryId: string,
    field: string,
    oldValue: any,
    newValue: any,
    editorId: string,
    reason: string
): AuditLog {
    return {
        entryId,
        field,
        oldValue,
        newValue,
        editorId,
        reason,
        timestamp: Date.now()
    };
}
