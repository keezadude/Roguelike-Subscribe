"use client";

import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';

interface ProgressBarProps {
  progress?: number;
  label?: string;
  showPercentage?: boolean;
  variant?: 'cyan' | 'purple' | 'green' | 'orange';
}

const ProgressBar: React.FC<ProgressBarProps> = ({
  progress = 65,
  label,
  showPercentage = true,
  variant = 'cyan',
}) => {
  const [currentProgress, setCurrentProgress] = useState(0);

  useEffect(() => {
    const timer = setTimeout(() => {
      setCurrentProgress(progress);
    }, 100);
    return () => clearTimeout(timer);
  }, [progress]);

  const variantColors = {
    cyan: {
      gradient: 'from-cyan-400 via-cyan-500 to-cyan-600',
      glow: 'shadow-[0_0_20px_rgba(34,211,238,0.6)]',
      border: 'border-cyan-500/50',
      text: 'text-cyan-400',
    },
    purple: {
      gradient: 'from-purple-400 via-purple-500 to-purple-600',
      glow: 'shadow-[0_0_20px_rgba(168,85,247,0.6)]',
      border: 'border-purple-500/50',
      text: 'text-purple-400',
    },
    green: {
      gradient: 'from-green-400 via-green-500 to-green-600',
      glow: 'shadow-[0_0_20px_rgba(34,197,94,0.6)]',
      border: 'border-green-500/50',
      text: 'text-green-400',
    },
    orange: {
      gradient: 'from-orange-400 via-orange-500 to-orange-600',
      glow: 'shadow-[0_0_20px_rgba(251,146,60,0.6)]',
      border: 'border-orange-500/50',
      text: 'text-orange-400',
    },
  };

  const colors = variantColors[variant];

  return (
    <div className="w-full space-y-2">
      {label && (
        <div className="flex justify-between items-center">
          <span className={`text-sm font-medium ${colors.text} tracking-wider uppercase`}>
            {label}
          </span>
          {showPercentage && (
            <span className={`text-sm font-bold ${colors.text} tabular-nums`}>
              {Math.round(currentProgress)}%
            </span>
          )}
        </div>
      )}
      
      <div className="relative h-10 w-full bg-slate-950/40 backdrop-blur-sm border ${colors.border} rounded-full overflow-hidden"
        style={{ boxShadow: '0 0 10px rgba(0,0,0,0.5), inset 0 2px 4px rgba(0,0,0,0.3)' }}>
        
        <motion.div
          className={`relative h-full bg-gradient-to-r ${colors.gradient} ${colors.glow} rounded-full`}
          initial={{ width: 0 }}
          animate={{ width: `${currentProgress}%` }}
          transition={{ duration: 1.5, ease: [0.4, 0, 0.2, 1] }}
        >
          <div className="absolute top-0 left-0 right-0 h-1/2 bg-gradient-to-b from-white/20 to-transparent rounded-full" />
        </motion.div>

        {showPercentage && !label && (
          <div className="absolute inset-0 flex items-center justify-center">
            <span className={`text-xs font-bold ${colors.text} drop-shadow-[0_0_8px_rgba(0,0,0,0.8)]`}>
              {Math.round(currentProgress)}%
            </span>
          </div>
        )}
      </div>
    </div>
  );
};

export { ProgressBar };
export type { ProgressBarProps };
