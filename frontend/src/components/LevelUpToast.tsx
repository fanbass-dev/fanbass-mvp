import { useEffect, useState } from 'react';
import { UserTitle } from '../config/gamification';

type LevelUpToastProps = {
    levelsGained: bigint;
    xpGained: bigint;
    wasCrit: boolean;
    newTitle?: UserTitle;
    onClose: () => void;
};

export function LevelUpToast({ levelsGained, xpGained, wasCrit, newTitle, onClose }: LevelUpToastProps) {
    const [isVisible, setIsVisible] = useState(true);
    const [isExiting, setIsExiting] = useState(false);

    useEffect(() => {
        // Start exit animation after 5 seconds
        const timeout = setTimeout(() => {
            setIsExiting(true);
        }, 5000);

        // Remove component after exit animation (0.5s)
        const cleanup = setTimeout(() => {
            setIsVisible(false);
            onClose();
        }, 5500);

        return () => {
            clearTimeout(timeout);
            clearTimeout(cleanup);
        };
    }, [onClose]);

    if (!isVisible) return null;

    return (
        <div
            className={`
                fixed bottom-4 right-4 bg-gray-800 rounded-lg p-6 shadow-lg
                transform transition-all duration-500 ease-in-out
                ${isExiting ? 'translate-x-full opacity-0' : 'translate-x-0 opacity-100'}
                ${wasCrit ? 'animate-bounce' : ''}
            `}
        >
            <div className="relative">
                {/* Background particles for crits */}
                {wasCrit && (
                    <div className="absolute inset-0 -z-10">
                        <div className="absolute top-0 left-1/4 w-2 h-2 bg-yellow-400 rounded-full animate-ping" />
                        <div className="absolute top-1/2 right-1/4 w-2 h-2 bg-yellow-400 rounded-full animate-ping delay-100" />
                        <div className="absolute bottom-0 left-1/2 w-2 h-2 bg-yellow-400 rounded-full animate-ping delay-200" />
                    </div>
                )}

                {/* Main content */}
                <div className="text-center">
                    <h3 className="text-2xl font-bold mb-2">
                        {wasCrit ? '⚡ CRITICAL HIT! ⚡' : 'LEVEL UP!'}
                    </h3>
                    <p className="text-4xl font-bold text-brand mb-1">
                        +{levelsGained.toString()} Levels
                    </p>
                    <p className="text-gray-400">
                        {xpGained.toLocaleString()} XP
                    </p>

                    {/* New title announcement */}
                    {newTitle && (
                        <div className="mt-4 pt-4 border-t border-gray-700">
                            <p className="text-sm text-gray-400">New Title Unlocked!</p>
                            <p className={`text-lg font-bold ${newTitle.color}`}>
                                {newTitle.name}
                            </p>
                            <p className="text-sm text-gray-400">
                                {newTitle.description}
                            </p>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
} 