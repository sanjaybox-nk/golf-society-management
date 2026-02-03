export interface EventResult {
    memberId: string;
    points: number;
    participationPoints: number;
    holeScores: (number | null)[]; // For eclectic
}

export interface SeasonConfig {
    bestN: number;
    pointsMode: 'position' | 'stableford' | 'combined';
}

/**
 * 1. Calculate Season Standing
 * Logic: Sum top N scores + all participation points
 */
export function calculateSeasonStanding(
    results: EventResult[],
    config: SeasonConfig
): number {
    // Sort by points descending
    const sortedPoints = results
        .map(r => r.points)
        .sort((a, b) => b - a);

    // Take top N
    const topN = sortedPoints.slice(0, config.bestN);
    const pointsSum = topN.reduce((acc, curr) => acc + curr, 0);

    // Add all participation points
    const participationTotal = results.reduce((acc, curr) => acc + curr.participationPoints, 0);

    return pointsSum + participationTotal;
}

/**
 * 2. Calculate Eclectic Best
 * Best score per hole across all events in a season
 */
export function calculateEclectic(
    allEventsHoleScores: (number | null)[][]
): (number | null)[] {
    if (allEventsHoleScores.length === 0) return [];

    const holeCount = allEventsHoleScores[0].length;
    const eclectic: (number | null)[] = new Array(holeCount).fill(null);

    for (let i = 0; i < holeCount; i++) {
        const holeScoresAcrossEvents = allEventsHoleScores
            .map(event => event[i])
            .filter((score): score is number => score !== null && score !== 0);

        if (holeScoresAcrossEvents.length > 0) {
            eclectic[i] = Math.min(...holeScoresAcrossEvents);
        }
    }

    return eclectic;
}
