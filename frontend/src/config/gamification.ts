export type ActivityType = 
    | 'create_event'
    | 'create_artist'
    | 'add_artist_to_lineup'
    | 'rank_artist';

export type UserTitle = {
    min: number;
    max?: number;
    name: string;
    description: string;
    color: string; // Tailwind color class
};

export type XPReward = {
    id: string;
    userId: string;
    activityType: ActivityType;
    baseXp: bigint;
    chaosMultiplier: number;
    critMultiplier: number;
    totalXpEarned: bigint;
    levelsGained: bigint;
    createdAt: Date;
};

export type UserLevel = {
    userId: string;
    currentLevel: bigint;
    xpOverflow: bigint;
    prestigeLevel: number;
    prestigeMultiplier: number;
    totalXpEarned: bigint;
    createdAt: Date;
    updatedAt: Date;
}; 