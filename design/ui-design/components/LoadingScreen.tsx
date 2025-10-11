"use client";

import React from 'react';
import { cn } from '@/lib/utils';
import { motion } from 'framer-motion';

interface LoadingScreenProps {
  message?: string;
  progress?: number;
  className?: string;
}

const LoadingScreen: React.FC<LoadingScreenProps> = ({
  message = "Loading...",
  progress,
  className,
}) => {
  return (
    <div className={cn(
      "fixed inset-0 bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950",
      "flex items-center justify-center z-50",
      className
    )}>
      <div className="relative">
        {/* Spinning circles */}
        <motion.div
          className="w-32 h-32"
          animate={{ rotate: 360 }}
          transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
        >
          <div className="absolute inset-0 border-4 border-cyan-500/20 rounded-full" />
          <div className="absolute inset-2 border-4 border-purple-500/20 rounded-full" />
          <div className="absolute inset-4 border-4 border-pink-500/20 rounded-full" />
          
          <motion.div
            className="absolute inset-0 border-4 border-transparent border-t-cyan-400 rounded-full"
            animate={{ rotate: 360 }}
            transition={{ duration: 1.5, repeat: Infinity, ease: "linear" }}
          />
          <motion.div
            className="absolute inset-2 border-4 border-transparent border-t-purple-400 rounded-full"
            animate={{ rotate: -360 }}
            transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
          />
        </motion.div>

        {/* Center glow */}
        <motion.div
          className="absolute inset-8 bg-gradient-to-br from-cyan-500/30 to-purple-500/30 rounded-full blur-2xl"
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.3, 0.6, 0.3],
          }}
          transition={{ duration: 2, repeat: Infinity }}
        />

        {/* Message */}
        <div className="absolute -bottom-16 left-1/2 -translate-x-1/2 whitespace-nowrap">
          <motion.p
            className="text-cyan-400 font-medium text-lg"
            animate={{ opacity: [0.5, 1, 0.5] }}
            transition={{ duration: 1.5, repeat: Infinity }}
          >
            {message}
          </motion.p>
        </div>

        {/* Progress bar */}
        {progress !== undefined && (
          <div className="absolute -bottom-10 left-1/2 -translate-x-1/2 w-64">
            <div className="h-1 bg-slate-800 rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-gradient-to-r from-cyan-400 to-purple-400"
                initial={{ width: 0 }}
                animate={{ width: `${progress}%` }}
                transition={{ duration: 0.5 }}
              />
            </div>
            <p className="text-center text-slate-500 text-sm mt-2">{Math.round(progress)}%</p>
          </div>
        )}
      </div>

      {/* Background particles */}
      {[...Array(20)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute w-1 h-1 bg-cyan-400 rounded-full"
          style={{
            left: `${Math.random() * 100}%`,
            top: `${Math.random() * 100}%`,
          }}
          animate={{
            opacity: [0, 1, 0],
            scale: [0, 1, 0],
          }}
          transition={{
            duration: 2 + Math.random() * 2,
            repeat: Infinity,
            delay: Math.random() * 2,
          }}
        />
      ))}
    </div>
  );
};

export { LoadingScreen };
export type { LoadingScreenProps };
