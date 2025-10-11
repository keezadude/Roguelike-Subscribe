"use client";

import React, { useState, useEffect } from "react";
import { cn } from "@/lib/utils";
import { motion, AnimatePresence } from "framer-motion";
import { Zap, TrendingUp } from "lucide-react";

type ScoreDisplayProps = {
  score?: number;
  comboMultiplier?: number;
  className?: string;
};

const AnimatedCounter = ({ value }: { value: number }) => {
  return (
    <motion.span
      key={value}
      initial={{ scale: 1.2, color: "#fbbf24" }}
      animate={{ scale: 1, color: "#ffffff" }}
      transition={{ duration: 0.3 }}
      className="font-bold"
    >
      {Math.floor(value).toLocaleString()}
    </motion.span>
  );
};

const ComboMultiplierBadge = ({ multiplier }: { multiplier: number }) => {
  if (multiplier <= 1) return null;

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.5, rotate: -10 }}
      animate={{ opacity: 1, scale: 1, rotate: 0 }}
      exit={{ opacity: 0, scale: 0.5 }}
      className="relative"
    >
      <motion.div
        animate={{
          boxShadow: [
            "0 0 20px rgba(251, 191, 36, 0.5)",
            "0 0 40px rgba(251, 191, 36, 0.8)",
            "0 0 20px rgba(251, 191, 36, 0.5)",
          ],
        }}
        transition={{ duration: 1.5, repeat: Infinity, ease: "easeInOut" }}
        className="bg-gradient-to-r from-yellow-500 to-orange-500 text-white px-4 py-2 rounded-xl font-bold text-sm inline-flex items-center gap-2 shadow-lg"
      >
        <Zap className="w-4 h-4" />
        <span>x{multiplier} COMBO</span>
        <TrendingUp className="w-4 h-4" />
      </motion.div>
    </motion.div>
  );
};

const ScoreDisplay = ({ score = 0, comboMultiplier = 1, className }: ScoreDisplayProps) => {
  return (
    <div className={cn("relative inline-block", className)}>
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="relative bg-slate-900/80 backdrop-blur-xl border-2 border-purple-500/30 rounded-2xl px-8 py-6 shadow-2xl"
      >
        <div className="flex flex-col gap-4">
          <div className="flex items-center justify-between gap-6">
            <div className="flex flex-col">
              <div className="text-xs font-medium text-slate-400 uppercase tracking-wider mb-1">
                Score
              </div>
              <div className="text-5xl font-black text-white tracking-tight">
                <AnimatedCounter value={score} />
              </div>
            </div>
            <Zap className="w-12 h-12 text-yellow-400" fill="currentColor" />
          </div>

          <AnimatePresence>
            {comboMultiplier > 1 && (
              <ComboMultiplierBadge multiplier={comboMultiplier} />
            )}
          </AnimatePresence>
        </div>

        <motion.div
          className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-purple-500 via-blue-500 to-cyan-500 rounded-t-2xl"
          animate={{ opacity: [0.5, 1, 0.5] }}
          transition={{ duration: 1.5, repeat: Infinity, ease: "easeInOut" }}
        />
      </motion.div>
    </div>
  );
};

export { ScoreDisplay };
export type { ScoreDisplayProps };
