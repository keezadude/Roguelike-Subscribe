"use client";

import React from 'react';
import { cn } from '@/lib/utils';
import { motion, AnimatePresence } from 'framer-motion';
import { X } from 'lucide-react';

interface ModalDialogProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
  className?: string;
}

const ModalDialog: React.FC<ModalDialogProps> = ({
  isOpen,
  onClose,
  title,
  children,
  className,
}) => {
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
          />

          {/* Modal */}
          <div className="fixed inset-0 flex items-center justify-center z-50 p-4">
            <motion.div
              className={cn(
                "relative w-full max-w-2xl",
                "bg-gradient-to-br from-slate-900 via-slate-950 to-black",
                "border-2 border-cyan-500/30 rounded-xl shadow-2xl",
                "overflow-hidden",
                className
              )}
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              transition={{ type: "spring", damping: 25, stiffness: 300 }}
            >
              {/* Glow effect */}
              <div className="absolute inset-0 bg-cyan-500/5 rounded-xl" />
              
              {/* Header */}
              <div className="relative border-b border-cyan-500/20 px-6 py-4">
                <div className="flex items-center justify-between">
                  <h2 className="text-2xl font-bold text-cyan-400">{title}</h2>
                  <button
                    onClick={onClose}
                    className="w-8 h-8 flex items-center justify-center rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-400 hover:text-white transition-colors"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>
                
                {/* Top accent line */}
                <motion.div
                  className="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-transparent via-cyan-500 to-transparent"
                  animate={{ opacity: [0.5, 1, 0.5] }}
                  transition={{ duration: 2, repeat: Infinity }}
                />
              </div>

              {/* Content */}
              <div className="relative px-6 py-6">
                {children}
              </div>

              {/* Corner decorations */}
              <svg className="absolute top-0 left-0 w-8 h-8 text-cyan-400 opacity-30" viewBox="0 0 32 32">
                <path d="M0 0 L32 0 L32 2 L2 2 L2 32 L0 32 Z" fill="currentColor" />
              </svg>
              <svg className="absolute top-0 right-0 w-8 h-8 text-cyan-400 opacity-30" viewBox="0 0 32 32">
                <path d="M32 0 L0 0 L0 2 L30 2 L30 32 L32 32 Z" fill="currentColor" />
              </svg>
            </motion.div>
          </div>
        </>
      )}
    </AnimatePresence>
  );
};

export { ModalDialog };
export type { ModalDialogProps };
