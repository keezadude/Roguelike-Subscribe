"use client"

import { useState } from "react"
import { GameMenuButton } from "@/components/GameMenuButton"
import { GamePanel } from "@/components/GamePanel"
import { ProgressBar } from "@/components/ProgressBar"
import { ScoreDisplay } from "@/components/ScoreDisplay"
import { AchievementCard } from "@/components/AchievementCard"
import { UpgradeCard } from "@/components/UpgradeCard"
import { ModalDialog } from "@/components/ModalDialog"
import { LoadingScreen } from "@/components/LoadingScreen"
import { Gamepad2, Settings, Trophy, ShoppingCart, Zap, Target, Rocket } from "lucide-react"

export default function Home() {
  const [modalOpen, setModalOpen] = useState(false)
  
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 p-8">
      <div className="max-w-6xl mx-auto space-y-12">
        {/* Header */}
        <div className="text-center space-y-4">
          <h1 className="text-5xl font-bold text-white">Roguelike & Subscribe</h1>
          <p className="text-xl text-slate-400">UI Component Showcase - Week 0</p>
          <p className="text-sm text-slate-500">
            Design components here → Export as PNG → Import to Love2D
          </p>
        </div>

        {/* Component Showcase */}
        <div className="space-y-12">
          {/* Main Menu Buttons */}
          <section className="space-y-6">
            <div className="text-center">
              <h2 className="text-3xl font-bold text-amber-400 mb-2">Main Menu Buttons</h2>
              <p className="text-slate-400">Primary variant - Game actions</p>
            </div>
            <div className="flex flex-wrap gap-6 justify-center">
              <GameMenuButton variant="primary" size="sm">
                Quick Play
              </GameMenuButton>
              <GameMenuButton variant="primary" size="md">
                <Gamepad2 className="w-5 h-5" />
                Start Game
              </GameMenuButton>
              <GameMenuButton variant="primary" size="lg">
                Launch Mission
              </GameMenuButton>
            </div>
          </section>

          {/* Secondary Buttons */}
          <section className="space-y-6">
            <div className="text-center">
              <h2 className="text-3xl font-bold text-cyan-400 mb-2">Secondary Actions</h2>
              <p className="text-slate-400">Secondary variant - Settings & Info</p>
            </div>
            <div className="flex flex-wrap gap-6 justify-center">
              <GameMenuButton variant="secondary" size="sm">
                Tutorial
              </GameMenuButton>
              <GameMenuButton variant="secondary" size="md">
                <Settings className="w-5 h-5" />
                Settings
              </GameMenuButton>
              <GameMenuButton variant="secondary" size="lg">
                How to Play
              </GameMenuButton>
            </div>
          </section>

          {/* Accent Buttons */}
          <section className="space-y-6">
            <div className="text-center">
              <h2 className="text-3xl font-bold text-purple-400 mb-2">Premium Features</h2>
              <p className="text-slate-400">Accent variant - Special actions</p>
            </div>
            <div className="flex flex-wrap gap-6 justify-center">
              <GameMenuButton variant="accent" size="sm">
                Daily Bonus
              </GameMenuButton>
              <GameMenuButton variant="accent" size="md">
                <Trophy className="w-5 h-5" />
                Achievements
              </GameMenuButton>
              <GameMenuButton variant="accent" size="lg">
                <ShoppingCart className="w-5 h-5" />
                Shop
              </GameMenuButton>
            </div>
          </section>

          {/* States */}
          <section className="space-y-6">
            <div className="text-center">
              <h2 className="text-3xl font-bold text-slate-400 mb-2">Button States</h2>
              <p className="text-slate-400">Hover over buttons to see animations</p>
            </div>
            <div className="flex flex-wrap gap-6 justify-center">
              <GameMenuButton variant="primary">Normal</GameMenuButton>
              <GameMenuButton variant="primary" disabled>
                Disabled
              </GameMenuButton>
            </div>
          </section>
        </div>

        {/* Export Instructions */}
        <div className="mt-16 p-6 bg-slate-800/50 rounded-lg border border-slate-700">
          <h3 className="text-xl font-bold text-white mb-4">📸 Export Instructions</h3>
          <ol className="space-y-2 text-slate-300">
            <li className="flex items-start gap-2">
              <span className="text-amber-400 font-bold">1.</span>
              <span>Screenshot each button variant at 2x scale (2560x1440)</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-cyan-400 font-bold">2.</span>
              <span>Capture normal, hover, and active states</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-purple-400 font-bold">3.</span>
              <span>Save to <code className="bg-slate-900 px-2 py-1 rounded">design/exports/ui/buttons/</code></span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-green-400 font-bold">4.</span>
              <span>Copy finalized sprites to <code className="bg-slate-900 px-2 py-1 rounded">assets/images/ui/</code></span>
            </li>
          </ol>
        </div>

        {/* Game Panel */}
        <section className="space-y-6">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-cyan-400 mb-2">Game Panel Container</h2>
            <p className="text-slate-400">Sci-fi themed container for content</p>
          </div>
          <GamePanel className="min-h-[300px]">
            <h3 className="text-xl font-bold text-cyan-300 mb-4">Panel Content</h3>
            <p className="text-slate-300">This panel can contain any game UI elements.</p>
          </GamePanel>
        </section>

        {/* Progress Bars */}
        <section className="space-y-6">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-purple-400 mb-2">Progress Bars</h2>
            <p className="text-slate-400">Animated progress indicators</p>
          </div>
          <div className="space-y-4 bg-slate-900/50 p-6 rounded-lg">
            <ProgressBar progress={75} label="Health" variant="green" />
            <ProgressBar progress={45} label="Energy" variant="cyan" />
            <ProgressBar progress={90} label="Experience" variant="purple" />
          </div>
        </section>

        {/* Score Display */}
        <section className="space-y-6">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-yellow-400 mb-2">Score Display (HUD)</h2>
            <p className="text-slate-400">Animated score counter with combo multiplier</p>
          </div>
          <div className="flex justify-center">
            <ScoreDisplay score={12500} comboMultiplier={3} />
          </div>
        </section>

        {/* Achievement Cards */}
        <section className="space-y-6">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-amber-400 mb-2">Achievement Cards</h2>
            <p className="text-slate-400">Unlockable achievements with progress</p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <AchievementCard
              title="First Victory"
              description="Complete your first successful run"
              unlocked={true}
              icon={<Trophy className="w-6 h-6" />}
            />
            <AchievementCard
              title="Speed Demon"
              description="Complete a run in under 2 minutes"
              unlocked={false}
              progress={65}
              icon={<Zap className="w-6 h-6" />}
            />
            <AchievementCard
              title="Perfect Score"
              description="Achieve a flawless run with max combo"
              unlocked={false}
              progress={30}
              icon={<Target className="w-6 h-6" />}
            />
          </div>
        </section>

        {/* Upgrade Cards */}
        <section className="space-y-6">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-purple-400 mb-2">Upgrade Cards</h2>
            <p className="text-slate-400">Purchasable upgrades with levels</p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <UpgradeCard
              name="Boost Power"
              description="Increase launch force by 10%"
              cost={500}
              level={3}
              maxLevel={5}
              canAfford={true}
              icon={<Rocket className="w-5 h-5" />}
            />
            <UpgradeCard
              name="Score Multiplier"
              description="Gain +0.5x score on all actions"
              cost={1200}
              level={2}
              maxLevel={5}
              canAfford={false}
              icon={<Zap className="w-5 h-5" />}
            />
          </div>
        </section>

        {/* Modal Dialog */}
        <section className="space-y-6">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-cyan-400 mb-2">Modal Dialog</h2>
            <p className="text-slate-400">Overlay dialog for important messages</p>
          </div>
          <div className="flex justify-center">
            <GameMenuButton variant="secondary" onClick={() => setModalOpen(true)}>
              Open Modal
            </GameMenuButton>
          </div>
          <ModalDialog
            isOpen={modalOpen}
            onClose={() => setModalOpen(false)}
            title="Game Paused"
          >
            <p className="text-slate-300 mb-4">
              The game has been paused. Choose an option to continue.
            </p>
            <div className="flex gap-4">
              <GameMenuButton variant="primary" size="sm" className="flex-1" onClick={() => setModalOpen(false)}>
                Resume
              </GameMenuButton>
              <GameMenuButton variant="secondary" size="sm" className="flex-1">
                Settings
              </GameMenuButton>
            </div>
          </ModalDialog>
        </section>

        {/* Footer */}
        <div className="text-center text-slate-500 text-sm mt-16">
          <p>Week 0 Day 3 - Component Design & Export</p>
          <p>8 Components Created: Button, Panel, Progress, Score, Achievement, Upgrade, Modal, Loading</p>
          <p className="mt-2 text-xs">Next.js + Tailwind + shadcn/ui → PNG Export → Love2D + Slab UI</p>
        </div>
      </div>
    </div>
  )
}
