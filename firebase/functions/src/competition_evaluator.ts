import { calculatePlayingHandicap, calculateStablefordPoints, normalizeMaxScore, MaxScoreConfig } from './scoring_engine';

export interface HoleConfig {
    par: number;
    strokeIndex: number;
}

export interface CompetitionRules {
    format: string;
    handicapCap: number;
    handicapAllowance: number;
    maxScoreConfig?: MaxScoreConfig;
}

export interface CompetitionResultRow {
    entryId: string;
    grossTotal: number;
    netTotal: number;
    points: number;
    status: string;
    holeByHole: (number | null)[];
}

/**
 * Aggregate scores for a single round
 */
export function evaluateRound(
    entryId: string,
    holeScores: (number | null)[],
    holes: HoleConfig[],
    handicap: number,
    rules: CompetitionRules
): CompetitionResultRow {
    const playingHandicap = calculatePlayingHandicap(handicap, rules.handicapCap, rules.handicapAllowance);
    const holeCount = holes.length;
    if (holeCount === 0) return {
        entryId,
        grossTotal: 0,
        netTotal: 0,
        points: 0,
        status: 'ERROR: No Holes',
        holeByHole: []
    };

    let grossTotal = 0;
    let netTotal = 0;
    let pointsTotal = 0;

    const normalizedScores = holeScores.map((score, index) => {
        if (score === null || score === 0) return null;

        const hole = holes[index];
        if (!hole) return null;

        // 1. Allocate strokes per hole based on SI (needed for Net Double Bogey cap)
        const baseStrokes = Math.floor(playingHandicap / holeCount);
        const extraStrokeThreshold = playingHandicap % holeCount;
        const holeStrokes = baseStrokes + (hole.strokeIndex <= extraStrokeThreshold ? 1 : 0);

        // 2. Normalize based on format (e.g., Max Score)
        let processedScore = score;
        if (rules.format === 'maxScore' && rules.maxScoreConfig) {
            processedScore = normalizeMaxScore(score, hole.par, holeStrokes, rules.maxScoreConfig);
        }

        grossTotal += processedScore;
        netTotal += (processedScore - holeStrokes);
        pointsTotal += calculateStablefordPoints(processedScore, hole.par, holeStrokes);

        return processedScore;
    });

    return {
        entryId,
        grossTotal,
        netTotal,
        points: pointsTotal,
        status: 'OK',
        holeByHole: normalizedScores
    };
}
