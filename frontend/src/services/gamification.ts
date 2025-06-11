import { supabase } from '../supabaseClient';
import { ActivityType, UserTitle, XPReward, UserLevel } from '../config/gamification';

export class GamificationService {
    /**
     * Gets a user's current level and title
     */
    static async getUserLevel(userId: string): Promise<{
        level: UserLevel;
        title: UserTitle;
    }> {
        // Try to get existing record
        let { data, error } = await supabase
            .from('user_levels')
            .select('*')
            .eq('user_id', userId)
            .single();

        // If no record exists, create one
        if (error?.code === 'PGRST116') {
            const { data: newData, error: insertError } = await supabase
                .from('user_levels')
                .insert([{
                    user_id: userId,
                    current_level: 1,
                    xp_overflow: 0,
                    prestige_level: 0,
                    prestige_multiplier: 1.0,
                    total_xp_earned: 0
                }])
                .select()
                .single();

            if (insertError) {
                console.error('Error creating user level:', insertError);
                throw insertError;
            }

            data = newData;
        } else if (error) {
            console.error('Error fetching user level:', error);
            throw error;
        }

        const level: UserLevel = {
            userId: data.user_id,
            currentLevel: BigInt(data.current_level),
            xpOverflow: BigInt(data.xp_overflow),
            prestigeLevel: data.prestige_level,
            prestigeMultiplier: data.prestige_multiplier,
            totalXpEarned: BigInt(data.total_xp_earned),
            createdAt: new Date(data.created_at),
            updatedAt: new Date(data.updated_at)
        };

        return {
            level,
            title: this.calculateTitle(Number(level.currentLevel))
        };
    }

    /**
     * Gets a user's XP reward history
     */
    static async getRewardHistory(userId: string, limit = 10): Promise<XPReward[]> {
        const { data, error } = await supabase
            .from('xp_rewards')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false })
            .limit(limit);

        if (error) {
            console.error('Error fetching reward history:', error);
            throw error;
        }

        return data.map(reward => ({
            id: reward.id,
            userId: reward.user_id,
            activityType: reward.activity_type as ActivityType,
            baseXp: BigInt(reward.base_xp),
            chaosMultiplier: reward.chaos_multiplier,
            critMultiplier: reward.crit_multiplier,
            totalXpEarned: BigInt(reward.total_xp_earned),
            levelsGained: BigInt(reward.levels_gained),
            createdAt: new Date(reward.created_at)
        }));
    }

    /**
     * Calculates the user's title based on their level
     */
    private static calculateTitle(level: number): UserTitle {
        const TITLES = [
            {
                min: 1,
                max: 49,
                name: "Ceiling Fan",
                description: "Just discovered what music is",
                color: "text-gray-400"
            },
            {
                min: 50,
                max: 499,
                name: "Bassline Baddie",
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
        ] as const;

        return TITLES.find(
            title => level >= title.min && (!title.max || level <= title.max)
        ) || TITLES[0];
    }
} 