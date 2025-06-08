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

export const XP_CONFIG = {
    XP_PER_LEVEL: 5000n,
    PRESTIGE_LEVEL: 10000n,
    PRESTIGE_MULTIPLIER: 1.05,
    CRIT_CHANCE: 0.05,
    CHAOS_MIN: 0.7,
    CHAOS_MAX: 1.3,
    
    // Base XP values - using BigInt for massive numbers
    ACTIVITIES: {
        create_event: 1_200_000n,
        create_artist: 350_000n,
        add_artist_to_lineup: 800_000n,
        rank_artist: 90_000n
    } as const,
    
    // Fun titles with increasingly ridiculous names and descriptions
    TITLES: [
        {
            min: 1,
            max: 49,
            name: "Fresh-Ear Fan",
            description: "Just discovered what music is",
            color: "text-gray-400"
        },
        {
            min: 50,
            max: 499,
            name: "Bassline Buff",
            description: "Can tell a kick drum from a snare... sometimes",
            color: "text-blue-400"
        },
        {
            min: 500,
            max: 4999,
            name: "Subwoofer Sage",
            description: "Neighbors hate this one weird trick",
            color: "text-purple-400"
        },
        {
            min: 5000,
            max: 9999,
            name: "Interstellar Raver",
            description: "Has achieved resonance with the cosmic frequencies",
            color: "text-yellow-400"
        },
        {
            min: 10000,
            name: "✶ Trans-Dimensional Fan Deity ✶",
            description: "Has transcended the mortal plane of music appreciation",
            color: "text-red-400"
        }
    ] satisfies UserTitle[],
    
} as const;

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