/**
 * Core Golf Scoring & Handicap Logic
 * Authoritative TypeScript implementation for Cloud Functions
 */

export interface ScoringParams {
    par: number;
    strokeIndex: number;
    handicap: number;
    grossScore: number | null;
}

export interface MaxScoreConfig {
    type: 'fixed' | 'parPlusX';
    value: number;
}

/**
 * 1. Handicap Allowance Calculation
 * Logic: Apply Cap FIRST, then Allowance %
 */
export function calculatePlayingHandicap(
    exactHandicap: number,
    cap: number,
    allowance: number
): number {
    const capped = Math.min(exactHandicap, cap);
    return Math.round(capped * allowance);
}

/**
 * 2. Stableford Points Calculation
 * Net Score vs Par
 */
export function calculateStablefordPoints(
    grossScore: number | null,
    par: number,
    strokesReceived: number
): number {
    if (grossScore === null || grossScore === 0) return 0;

    const netScore = grossScore - strokesReceived;
    const vsPar = par - netScore; // e.g., par 4, net 4 -> 0

    // 0 -> 2 pts, -1 -> 1 pt, +1 -> 3 pts
    const points = vsPar + 2;
    return Math.max(0, points);
}

/**
 * 3. Maximum Score Normalization
 */
export function normalizeMaxScore(
    grossScore: number | null,
    par: number,
    config: MaxScoreConfig
): number {
    if (grossScore === null) return 0;

    let capValue: number;
    if (config.type === 'fixed') {
        capValue = config.value;
    } else {
        capValue = par + config.value;
    }

    return Math.min(grossScore, capValue);
}

/**
 * 4. Match Play State Logic
 */
export interface MatchState {
    score: number; // Positive = Player A up, Negative = Player B up
    holesPlayed: number;
    isFinished: boolean;
}

export function updateMatchState(
    currentState: MatchState,
    holeScoreA: number | null,
    holeScoreB: number | null,
    totalHoles: number
): MatchState {
    if (currentState.isFinished || holeScoreA === null || holeScoreB === null) {
        return currentState;
    }

    const newScore = holeScoreA < holeScoreB
        ? currentState.score + 1
        : holeScoreA > holeScoreB
            ? currentState.score - 1
            : currentState.score;

    const holesLeft = totalHoles - (currentState.holesPlayed + 1);
    const isFinished = Math.abs(newScore) > holesLeft;

    return {
        score: newScore,
        holesPlayed: currentState.holesPlayed + 1,
        isFinished: isFinished
    };
}
