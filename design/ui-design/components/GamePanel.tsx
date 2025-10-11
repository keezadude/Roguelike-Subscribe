"use client";

import React, { useState, useEffect, useRef } from 'react';
import { cn } from '@/lib/utils';

interface GamePanelProps {
  children?: React.ReactNode;
  className?: string;
  glowColor?: string;
}

const GamePanel: React.FC<GamePanelProps> = ({
  children,
  className = "",
  glowColor = "rgba(100, 200, 255, 0.6)",
}) => {
  const [isHovered, setIsHovered] = useState(false);
  const panelRef = useRef<HTMLDivElement>(null);

  return (
    <div
      ref={panelRef}
      className={cn(
        "relative overflow-hidden rounded-lg",
        "bg-gradient-to-br from-slate-900 via-slate-950 to-black",
        "border-2 border-cyan-500/30",
        className
      )}
      style={{
        boxShadow: isHovered
          ? `0 0 30px ${glowColor}, inset 0 0 20px rgba(0, 0, 0, 0.5)`
          : `0 0 15px rgba(0, 0, 0, 0.8), inset 0 0 20px rgba(0, 0, 0, 0.5)`,
      }}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Grid Pattern */}
      <div className="absolute inset-0 opacity-20 pointer-events-none"
        style={{
          backgroundImage: 'repeating-linear-gradient(0deg, rgba(100, 200, 255, 0.1) 0px, transparent 1px, transparent 2px, rgba(100, 200, 255, 0.1) 3px), repeating-linear-gradient(90deg, rgba(100, 200, 255, 0.1) 0px, transparent 1px, transparent 2px, rgba(100, 200, 255, 0.1) 3px)'
        }}
      />

      {/* Corner Decorations */}
      <svg className="absolute top-0 left-0 w-10 h-10 text-cyan-400 opacity-60" viewBox="0 0 40 40">
        <path d="M0 0 L40 0 L40 2 L2 2 L2 40 L0 40 Z" fill="currentColor" />
        <circle cx="2" cy="2" r="2" fill="currentColor" className="animate-pulse" />
      </svg>
      <svg className="absolute top-0 right-0 w-10 h-10 text-cyan-400 opacity-60" viewBox="0 0 40 40">
        <path d="M40 0 L0 0 L0 2 L38 2 L38 40 L40 40 Z" fill="currentColor" />
        <circle cx="38" cy="2" r="2" fill="currentColor" className="animate-pulse" style={{animationDelay: '0.5s'}} />
      </svg>
      <svg className="absolute bottom-0 left-0 w-10 h-10 text-cyan-400 opacity-60" viewBox="0 0 40 40">
        <path d="M0 40 L40 40 L40 38 L2 38 L2 0 L0 0 Z" fill="currentColor" />
        <circle cx="2" cy="38" r="2" fill="currentColor" className="animate-pulse" style={{animationDelay: '1s'}} />
      </svg>
      <svg className="absolute bottom-0 right-0 w-10 h-10 text-cyan-400 opacity-60" viewBox="0 0 40 40">
        <path d="M40 40 L0 40 L0 38 L38 38 L38 0 L40 0 Z" fill="currentColor" />
        <circle cx="38" cy="38" r="2" fill="currentColor" className="animate-pulse" style={{animationDelay: '1.5s'}} />
      </svg>

      {/* Content */}
      <div className="relative z-10 p-6">
        {children}
      </div>
    </div>
  );
};

export { GamePanel };
export type { GamePanelProps };
