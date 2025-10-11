"use client";

import React from 'react';
import { cn } from '@/lib/utils';
import { motion } from 'framer-motion';
import { Trophy, Lock } from 'lucide-react';

interface AchievementCardProps {
  title: string;
  description: string;
  unlocked?: boolean;
  icon?: React.ReactNode;
  progress?: number;
  className?: string;
}

const AchievementCard: React.FC<AchievementCardProps> = ({
  title,
  description,
  unlocked = false,
  icon,
  progress = 0,
  className,
}) => {
  return (
    <motion.div
      className={cn(
        "relative overflow-hidden rounded-lg border-2 p-4",
        unlocked
          ? "bg-gradient-to-br from-amber-900/30 via-slate-900 to-slate-950 border-amber-500/50"
          : "bg-slate-950/50 border-slate-700/30",
        className
      )}
      whileHover={{ scale: 1.02 }}
      transition={{ duration: 0.2 }}
    >
      {/* Glow effect for unlocked */}
      {unlocked && (
        <motion.div
          className="absolute inset-0 bg-amber-500/10 rounded-lg"
          animate={{ opacity: [0.3, 0.6, 0.3] }}
          transition={{ duration: 2, repeat: Infinity }}
        />
      )}

      <div className="relative flex items-start gap-4">
        <div className={cn(
          "flex-shrink-0 w-12 h-12 rounded-lg flex items-center justify-center",
          unlocked ? "bg-amber-500/20 text-amber-400" : "bg-slate-800/50 text-slate-600"
        )}>
          {unlocked ? (icon || <Trophy className="w-6 h-6" />) : <Lock className="w-6 h-6" />}
        </div>

        <div className="flex-1">
          <h3 className={cn(
            "font-bold text-lg mb-1",
            unlocked ? "text-amber-300" : "text-slate-500"
          )}>
            {title}
          </h3>
          <p className={cn(
            "text-sm",
            unlocked ? "text-slate-300" : "text-slate-600"
          )}>
            {description}
          </p>

          {!unlocked && progress > 0 && (
            <div className="mt-3">
              <div className="flex justify-between text-xs text-slate-500 mb-1">
                <span>Progress</span>
                <span>{progress}%</span>
              </div>
              <div className="h-1.5 bg-slate-800 rounded-full overflow-hidden">
                <motion.div
                  className="h-full bg-gradient-to-r from-cyan-500 to-blue-500"
                  initial={{ width: 0 }}
                  animate={{ width: `${progress}%` }}
                  transition={{ duration: 1 }}
                />
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Corner decoration */}
      {unlocked && (
        <svg className="absolute top-2 right-2 w-8 h-8 text-amber-400 opacity-30" viewBox="0 0 24 24">
          <path fill="currentColor" d="M12,2L15.09,8.26L22,9.27L17,14.14L18.18,21.02L12,17.77L5.82,21.02L7,14.14L2,9.27L8.91,8.26L12,2Z" />
        </svg>
      )}
    </motion.div>
  );
};

export { AchievementCard };
export type { AchievementCardProps };
