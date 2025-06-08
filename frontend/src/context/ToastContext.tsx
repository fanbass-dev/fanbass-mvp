import { createContext, useContext, useState, ReactNode } from 'react';
import { LevelUpToast } from '../components/LevelUpToast';
import { UserTitle } from '../config/gamification';

type ToastData = {
    id: string;
    levelsGained: bigint;
    xpGained: bigint;
    wasCrit: boolean;
    newTitle?: UserTitle;
};

type ToastContextType = {
    showLevelUp: (data: Omit<ToastData, 'id'>) => void;
};

const ToastContext = createContext<ToastContextType | null>(null);

export function useToast() {
    const context = useContext(ToastContext);
    if (!context) {
        throw new Error('useToast must be used within a ToastProvider');
    }
    return context;
}

export function ToastProvider({ children }: { children: ReactNode }) {
    const [toasts, setToasts] = useState<ToastData[]>([]);

    const showLevelUp = (data: Omit<ToastData, 'id'>) => {
        const newToast: ToastData = {
            ...data,
            id: Math.random().toString(36).substring(7)
        };
        setToasts(current => [...current, newToast]);
    };

    const removeToast = (id: string) => {
        setToasts(current => current.filter(toast => toast.id !== id));
    };

    return (
        <ToastContext.Provider value={{ showLevelUp }}>
            {children}
            {/* Render toasts */}
            <div className="fixed bottom-0 right-0 p-4 space-y-4 z-50">
                {toasts.map(toast => (
                    <LevelUpToast
                        key={toast.id}
                        levelsGained={toast.levelsGained}
                        xpGained={toast.xpGained}
                        wasCrit={toast.wasCrit}
                        newTitle={toast.newTitle}
                        onClose={() => removeToast(toast.id)}
                    />
                ))}
            </div>
        </ToastContext.Provider>
    );
} 