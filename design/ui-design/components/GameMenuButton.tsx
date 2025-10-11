import * as React from "react"
import { motion, useReducedMotion } from "framer-motion"
import { cn } from "@/lib/utils"

interface GameMenuButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "accent"
  size?: "sm" | "md" | "lg"
  children: React.ReactNode
}

const GameMenuButton = React.forwardRef<HTMLButtonElement, GameMenuButtonProps>(
  ({ className, variant = "primary", size = "md", children, ...props }, ref) => {
    const shouldReduceMotion = useReducedMotion()
    const [isHovered, setIsHovered] = React.useState(false)

    const sizeClasses = {
      sm: "h-10 px-6 text-sm",
      md: "h-12 px-8 text-base",
      lg: "h-14 px-10 text-lg",
    }

    const variantColors = {
      primary: {
        gradient: "from-amber-500/20 via-orange-500/20 to-red-500/20",
        border: "border-amber-500/50",
        glow: "rgba(251, 191, 36, 0.4)",
        text: "text-amber-100",
        hoverGlow: "rgba(251, 191, 36, 0.6)",
      },
      secondary: {
        gradient: "from-cyan-500/20 via-blue-500/20 to-indigo-500/20",
        border: "border-cyan-500/50",
        glow: "rgba(6, 182, 212, 0.4)",
        text: "text-cyan-100",
        hoverGlow: "rgba(6, 182, 212, 0.6)",
      },
      accent: {
        gradient: "from-purple-500/20 via-pink-500/20 to-rose-500/20",
        border: "border-purple-500/50",
        glow: "rgba(168, 85, 247, 0.4)",
        text: "text-purple-100",
        hoverGlow: "rgba(168, 85, 247, 0.6)",
      },
    }

    const colors = variantColors[variant]

    const buttonVariants = {
      initial: { scale: 1, y: 0 },
      hover: {
        scale: 1.02,
        y: -2,
        transition: { type: "spring", stiffness: 400, damping: 25 },
      },
      tap: {
        scale: 0.98,
        y: 0,
        transition: { type: "spring", stiffness: 500, damping: 30 },
      },
    }

    const glowVariants = {
      initial: { opacity: 0.3, scale: 0.95 },
      hover: {
        opacity: 0.8,
        scale: 1.05,
        transition: { type: "spring", stiffness: 300, damping: 20 },
      },
    }

    const texturePattern = `data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.05'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E`

    return (
      <motion.button
        ref={ref}
        className={cn(
          "relative overflow-hidden rounded-lg font-semibold tracking-wide uppercase",
          "transform-gpu cursor-pointer select-none",
          "border-2 transition-colors",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          sizeClasses[size],
          colors.border,
          colors.text,
          className
        )}
        variants={shouldReduceMotion ? {} : buttonVariants}
        initial="initial"
        whileHover="hover"
        whileTap="tap"
        onHoverStart={() => setIsHovered(true)}
        onHoverEnd={() => setIsHovered(false)}
        {...props}
      >
        {/* Textured background */}
        <div
          className="absolute inset-0 opacity-30"
          style={{ backgroundImage: `url("${texturePattern}")`, backgroundRepeat: "repeat" }}
        />

        {/* Gradient background */}
        <div className={cn("absolute inset-0 bg-gradient-to-br opacity-40", colors.gradient)} />

        {/* Glow effect */}
        <motion.div
          className="absolute inset-0 rounded-lg"
          style={{
            background: `radial-gradient(circle at center, ${colors.glow} 0%, transparent 70%)`,
            filter: "blur(20px)",
          }}
          variants={shouldReduceMotion ? {} : glowVariants}
          initial="initial"
          animate={isHovered ? "hover" : "initial"}
        />

        {/* Border glow on hover */}
        <motion.div
          className="absolute inset-0 rounded-lg"
          style={{ boxShadow: `0 0 20px ${colors.hoverGlow}, inset 0 0 20px ${colors.glow}` }}
          initial={{ opacity: 0 }}
          animate={{ opacity: isHovered ? 1 : 0 }}
          transition={{ duration: 0.3 }}
        />

        {/* Corner accents */}
        <svg className="absolute top-0 left-0 w-6 h-6 opacity-60" viewBox="0 0 24 24" fill="none">
          <path d="M0 0H8V2H2V8H0V0Z" fill="currentColor" className={colors.text} />
        </svg>
        <svg className="absolute top-0 right-0 w-6 h-6 opacity-60" viewBox="0 0 24 24" fill="none">
          <path d="M24 0H16V2H22V8H24V0Z" fill="currentColor" className={colors.text} />
        </svg>
        <svg className="absolute bottom-0 left-0 w-6 h-6 opacity-60" viewBox="0 0 24 24" fill="none">
          <path d="M0 24H8V22H2V16H0V24Z" fill="currentColor" className={colors.text} />
        </svg>
        <svg className="absolute bottom-0 right-0 w-6 h-6 opacity-60" viewBox="0 0 24 24" fill="none">
          <path d="M24 24H16V22H22V16H24V24Z" fill="currentColor" className={colors.text} />
        </svg>

        {/* Content */}
        <span className="relative z-10 flex items-center justify-center gap-2 drop-shadow-lg">
          {children}
        </span>
      </motion.button>
    )
  }
)

GameMenuButton.displayName = "GameMenuButton"

export { GameMenuButton }
export type { GameMenuButtonProps }
