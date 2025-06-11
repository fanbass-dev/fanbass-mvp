import { UserTitle } from '../config/gamification';

// Constants for the guide display
const TITLES: UserTitle[] = [
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
];

const XP_PER_LEVEL = 5000;
const PRESTIGE_LEVEL = 10000;

export function GamificationGuide() {
    return (
        <div className="bg-gray-800 rounded-lg p-6 space-y-6">
            <div>
                <h3 className="text-xl font-bold mb-4">🎮 How FanBass XP Works</h3>
                <p className="text-gray-300 mb-4">
                    Level up by contributing to the community! Every action earns you XP with some fun twists:
                </p>
            </div>

            {/* Base XP Values */}
            <div>
                <h4 className="text-lg font-semibold mb-2 text-brand">Base XP Values</h4>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div className="bg-gray-700 rounded p-3">
                        <div className="flex justify-between items-center">
                            <div className="flex-1">
                                <p className="text-sm text-gray-300">Creating an Event</p>
                            </div>
                            <span className="text-xl font-bold ml-4 tabular-nums">1.2M XP</span>
                        </div>
                    </div>
                    <div className="bg-gray-700 rounded p-3">
                        <div className="flex justify-between items-center">
                            <div className="flex-1">
                                <p className="text-sm text-gray-300">Adding a New Artist</p>
                            </div>
                            <span className="text-xl font-bold ml-4 tabular-nums">350K XP</span>
                        </div>
                    </div>
                    <div className="bg-gray-700 rounded p-3">
                        <div className="flex justify-between items-center">
                            <div className="flex-1">
                                <p className="text-sm text-gray-300">Adding a Set to an Event</p>
                            </div>
                            <span className="text-xl font-bold ml-4 tabular-nums">800K XP</span>
                        </div>
                    </div>
                    <div className="bg-gray-700 rounded p-3">
                        <div className="flex justify-between items-center">
                            <div className="flex-1">
                                <p className="text-sm text-gray-300">Ranking an Artist</p>
                            </div>
                            <span className="text-xl font-bold ml-4 tabular-nums">90K XP</span>
                        </div>
                    </div>
                </div>
            </div>

            {/* Multipliers */}
            <div>
                <h4 className="text-lg font-semibold mb-2 text-yellow-400">XP Multipliers</h4>
                <div className="space-y-3">
                    <div className="bg-gray-700 rounded p-3">
                        <div className="flex justify-between items-center">
                            <div className="flex-1">
                                <h5 className="font-semibold">Chaos Multiplier</h5>
                                <p className="text-sm text-gray-300">Random multiplier between 0.7x and 1.3x</p>
                            </div>
                            <span className="text-lg font-bold text-brand ml-4 whitespace-nowrap tabular-nums">0.7x - 1.3x</span>
                        </div>
                    </div>
                    <div className="bg-gray-700 rounded p-3">
                        <div className="flex justify-between items-center">
                            <div className="flex-1">
                                <h5 className="font-semibold">Critical Hit!</h5>
                                <p className="text-sm text-gray-300">5% chance to double your XP</p>
                            </div>
                            <span className="text-lg font-bold text-yellow-400 ml-4 whitespace-nowrap tabular-nums">2.0x</span>
                        </div>
                    </div>
                    <div className="bg-gray-700 rounded p-3">
                        <div className="flex justify-between items-center">
                            <div className="flex-1">
                                <h5 className="font-semibold">Prestige Bonus</h5>
                                <p className="text-sm text-gray-300">At level 10,000, prestige for permanent multiplier</p>
                            </div>
                            <span className="text-lg font-bold text-purple-400 ml-4 whitespace-nowrap tabular-nums">1.05x per prestige</span>
                        </div>
                    </div>
                </div>
            </div>

            {/* Titles */}
            <div>
                <h4 className="text-lg font-semibold mb-2 text-brand">Fan Titles</h4>
                <div className="space-y-3">
                    {TITLES.map((title, index) => (
                        <div key={index} className="bg-gray-700 rounded p-3">
                            <div className="flex justify-between items-start">
                                <div className="flex-1">
                                    <h5 className={`font-semibold ${title.color}`}>{title.name}</h5>
                                    <p className="text-sm text-gray-300">{title.description}</p>
                                </div>
                                <span className="text-sm font-medium text-gray-400 ml-4 whitespace-nowrap tabular-nums">
                                    Level {title.min}
                                    {title.max ? ` - ${title.max}` : '+'}
                                </span>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            {/* Fun Facts */}
            <div className="bg-gray-700 rounded p-4 mt-6">
                <h4 className="text-lg font-semibold mb-2 text-brand">💡 Fun Facts</h4>
                <ul className="list-disc list-inside space-y-2 text-gray-300">
                    <li>Each level requires <span className="font-semibold tabular-nums">{XP_PER_LEVEL.toLocaleString()}</span> XP</li>
                    <li>Creating a single event can earn you up to <span className="font-semibold tabular-nums">3.12M</span> XP with perfect multipliers!</li>
                    <li>Prestige at level <span className="font-semibold tabular-nums">{PRESTIGE_LEVEL.toLocaleString()}</span> to earn permanent multipliers</li>
                    <li>Your XP is never lost - it carries over between levels</li>
                </ul>
            </div>
        </div>
    );
} 