import { useEffect, useState } from 'react';
import { GamificationService } from '../services/gamification';
import { UserLevel, UserTitle, XPReward } from '../config/gamification';
import { useUserContext } from '../context/UserContext';

export function UserStats() {
    const { user } = useUserContext();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [userLevel, setUserLevel] = useState<UserLevel | null>(null);
    const [userTitle, setUserTitle] = useState<UserTitle | null>(null);
    const [recentRewards, setRecentRewards] = useState<XPReward[]>([]);

    useEffect(() => {
        async function loadUserStats() {
            if (!user) return;

            try {
                setLoading(true);
                setError(null);

                // Load user level and title
                const { level, title } = await GamificationService.getUserLevel(user.id);
                setUserLevel(level);
                setUserTitle(title);

                // Load recent rewards
                const rewards = await GamificationService.getRewardHistory(user.id, 5);
                setRecentRewards(rewards);
            } catch (err) {
                console.error('Error loading user stats:', err);
                setError('Failed to load stats');
            } finally {
                setLoading(false);
            }
        }

        loadUserStats();
    }, [user]);

    if (loading) {
        return <div className="animate-pulse">Loading stats...</div>;
    }

    if (error) {
        return <div className="text-red-500">{error}</div>;
    }

    if (!userLevel || !userTitle) {
        return <div>No stats available</div>;
    }

    return (
        <div className="space-y-6">
            {/* Title and Level */}
            <div className="bg-gray-800 rounded-lg p-6 text-center">
                <h2 className={`text-2xl font-bold ${userTitle.color}`}>
                    {userTitle.name}
                </h2>
                <p className="text-gray-400 mt-1">{userTitle.description}</p>
                <div className="mt-4">
                    <span className="text-4xl font-bold text-brand">
                        Level {userLevel.currentLevel.toString()}
                    </span>
                    {userLevel.prestigeLevel > 0 && (
                        <span className="ml-2 text-sm text-yellow-400">
                            Prestige {userLevel.prestigeLevel}
                        </span>
                    )}
                </div>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-2 gap-4">
                <div className="bg-gray-800 rounded-lg p-4">
                    <h3 className="text-gray-400 text-sm">Total XP Earned</h3>
                    <p className="text-xl font-bold text-brand">
                        {userLevel.totalXpEarned.toLocaleString()}
                    </p>
                </div>
                <div className="bg-gray-800 rounded-lg p-4">
                    <h3 className="text-gray-400 text-sm">XP Multiplier</h3>
                    <p className="text-xl font-bold text-brand">
                        {userLevel.prestigeMultiplier.toFixed(2)}x
                    </p>
                </div>
            </div>

            {/* Recent Rewards */}
            {recentRewards.length > 0 && (
                <div className="bg-gray-800 rounded-lg p-6">
                    <h3 className="text-lg font-semibold mb-4">Recent Rewards</h3>
                    <div className="space-y-4">
                        {recentRewards.map(reward => (
                            <div key={reward.id} className="flex justify-between items-center">
                                <div>
                                    <p className="text-brand font-medium">
                                        {reward.activityType.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                                    </p>
                                    <p className="text-sm text-gray-400">
                                        {reward.createdAt.toLocaleDateString()}
                                    </p>
                                </div>
                                <div className="text-right">
                                    <p className="text-lg font-bold">
                                        +{reward.levelsGained.toString()} Levels
                                    </p>
                                    <p className="text-sm text-gray-400">
                                        {reward.totalXpEarned.toLocaleString()} XP
                                        {reward.critMultiplier > 1 && (
                                            <span className="ml-2 text-yellow-400">CRIT!</span>
                                        )}
                                    </p>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
} 