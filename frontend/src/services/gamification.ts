import { supabase } from '../supabaseClient';
import { XP_CONFIG, ActivityType, UserTitle, XPReward, UserLevel } from '../config/gamification';

export class GamificationService {
    /**
     * Grants XP for an activity and returns the reward details
     */
    static async grantXP(userId: string, activityType: ActivityType): Promise<{
        xpGained: bigint;
        levelsGained: bigint;
        wasCrit: boolean;
        newTitle?: UserTitle;
        totalLevel?: bigint;
    }> {
        const baseXP = XP_CONFIG.ACTIVITIES[activityType];
        
        // Generate multipliers
        const chaos = Math.random() * (XP_CONFIG.CHAOS_MAX - XP_CONFIG.CHAOS_MIN) + XP_CONFIG.CHAOS_MIN;
        const crit = Math.random() < XP_CONFIG.CRIT_CHANCE ? 2.0 : 1.0;
        
        // Get user's current prestige multiplier and XP overflow
        const { data: userData } = await supabase
            .from('user_levels')
            .select('prestige_multiplier, xp_overflow')
            .eq('user_id', userId)
            .single();
            
        const prestigeMultiplier = userData?.prestige_multiplier || 1.0;
        const currentOverflow = BigInt(userData?.xp_overflow || 0);
        
        // Calculate final XP with all multipliers
        const xpGain = BigInt(Math.round(Number(baseXP) * chaos * crit * prestigeMultiplier));
        const totalXP = xpGain + currentOverflow;
        const levelsGained = totalXP / XP_CONFIG.XP_PER_LEVEL;
        const newOverflow = totalXP % XP_CONFIG.XP_PER_LEVEL;
        
        // Update everything atomically using our database function
        const { error } = await supabase.rpc('update_user_xp', {
            p_user_id: userId,
            p_xp_gained: xpGain.toString(),
            p_levels_gained: levelsGained.toString(),
            p_new_overflow: newOverflow.toString(),
            p_activity_type: activityType,
            p_chaos_multi: chaos,
            p_crit_multi: crit
        });

        if (error) {
            console.error('Error granting XP:', error);
            throw error;
        }

        // Get user's new total level for title calculation
        const { data: newLevelData } = await supabase
            .from('user_levels')
            .select('current_level')
            .eq('user_id', userId)
            .single();

        const totalLevel = BigInt(newLevelData?.current_level || 0);
        
        return {
            xpGained: xpGain,
            levelsGained,
            wasCrit: crit > 1,
            newTitle: this.calculateTitle(Number(totalLevel)),
            totalLevel
        };
    }

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
        return XP_CONFIG.TITLES.find(
            title => level >= title.min && (!title.max || level <= title.max)
        ) || XP_CONFIG.TITLES[0];
    }
} 