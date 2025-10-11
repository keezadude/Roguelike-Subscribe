"use client";

import React from 'react';
import { cn } from '@/lib/utils';
import { motion } from 'framer-motion';
import { ArrowUp, Coins } from 'lucide-react';

interface UpgradeCardProps {
  name: string;
  description: string;
  cost: number;
  level?: number;
  maxLevel?: number;
  icon?: React.ReactNode;
  canAfford?: boolean;
  className?: string;
}

const UpgradeCard: React.FC<UpgradeCardProps> = ({
  name,
  description,
  cost,
  level = 1,
  maxLevel = 5,
  icon,
  canAfford = true,
  className,
}) => {
  const isMaxLevel = level >= maxLevel;

  return (
    <motion.div
      className={cn(
        "relative overflow-hidden rounded-lg border-2 p-5",
        "bg-gradient-to-br from-slate-900 via-slate-950 to-black",
        canAfford && !isMaxLevel ? "border-purple-500/50" : "border-slate-700/30",
        className
      )}
      whileHover={canAfford && !isMaxLevel ? { scale: 1.02, borderColor: "rgba(168, 85, 247, 0.8)" } : {}}
      transition={{ duration: 0.2 }}
    >
      {/* Background pattern */}
      <div className="absolute inset-0 opacity-5"
        style={{
          backgroundImage: 'repeating-linear-gradient(45deg, transparent, transparent 10px, rgba(168, 85, 247, 0.3) 10px, rgba(168, 85, 247, 0.3) 20px)'
        }}
      />

      <div className="relative">
        <div className="flex items-start justify-between mb-3">
          <div className="flex items-center gap-3">
            <div className={cn(
              "w-10 h-10 rounded-lg flex items-center justify-center",
              "bg-purple-500/20 text-purple-400"
            )}>
              {icon || <ArrowUp className="w-5 h-5" />}
            </div>
            <div>
              <h3 className="font-bold text-white text-lg">{name}</h3>
              <div className="flex items-center gap-2 mt-1">
                {[...Array(maxLevel)].map((_, i) => (
                  <div
                    key={i}
                    className={cn(
                      "w-2 h-2 rounded-full",
                      i < level ? "bg-purple-400" : "bg-slate-700"
                    )}
                  />
                ))}
              </div>
            </div>
          </div>

          {isMaxLevel && (
            <div className="bg-amber-500/20 text-amber-400 px-3 py-1 rounded-full text-xs font-bold">
              MAX
            </div>
          )}
        </div>

        <p className="text-slate-400 text-sm mb-4">{description}</p>

        {!isMaxLevel && (
          <div className={cn(
            "flex items-center justify-between p-3 rounded-lg border",
            canAfford
              ? "bg-purple-500/10 border-purple-500/30"
              : "bg-slate-800/30 border-slate-700/30"
          )}>
            <div className="flex items-center gap-2">
              <Coins className={cn("w-4 h-4", canAfford ? "text-amber-400" : "text-slate-600")} />
              <span className={cn("font-bold", canAfford ? "text-white" : "text-slate-500")}>
                {cost.toLocaleString()}
              </span>
            </div>
            <span className={cn("text-xs uppercase tracking-wider", canAfford ? "text-purple-400" : "text-slate-600")}>
              {canAfford ? "Available" : "Locked"}
            </span>
          </div>
        )}
      </div>
    </motion.div>
  );
};

export { UpgradeCard };
export type { UpgradeCardProps };
