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

    let grossTotal = 0;
    let netTotal = 0;
    let pointsTotal = 0;

    const normalizedScores = holeScores.map((score, index) => {
        if (score === null || score === 0) return null;

        const hole = holes[index];

        // 1. Normalize based on format (e.g., Max Score)
        let processedScore = score;
        if (rules.format === 'maxScore' && rules.maxScoreConfig) {
            processedScore = normalizeMaxScore(score, hole.par, rules.maxScoreConfig);
        }

        // 2. Allocate strokes per hole based on SI
        const baseStrokes = Math.floor(playingHandicap / holeCount);
        const extraStrokeThreshold = playingHandicap % holeCount;
        const holeStrokes = baseStrokes + (hole.strokeIndex <= extraStrokeThreshold ? 1 : 0);

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
