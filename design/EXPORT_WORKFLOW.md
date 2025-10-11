# UI Component Export Workflow

## Overview
This workflow converts React/shadcn components (designed with Magic MCP) into high-resolution PNG sprites for use in Love2D with Slab UI.

---

## Directory Structure

```
design/
├── ui-design/              # Next.js project
│   ├── app/
│   │   └── page.tsx       # Component showcase
│   ├── components/
│   │   ├── GameMenuButton.tsx
│   │   └── [other components].tsx
│   └── lib/
│       └── utils.ts
├── exports/               # Exported PNG sprites
│   └── ui/
│       ├── buttons/       # Button components
│       ├── panels/        # Panel backgrounds
│       ├── hud/          # HUD elements
│       └── modals/       # Modal dialogs
└── GSAP_TO_FLUX_MAPPING.md

assets/
└── images/
    └── ui/               # Final sprites for game
```

---

## Export Process

### Step 1: Design Component in Next.js

1. Use Magic/21st.dev MCP to generate component
2. Save to `design/ui-design/components/[ComponentName].tsx`
3. Add to showcase in `app/page.tsx`

```tsx
// app/page.tsx
import { GameMenuButton } from "@/components/GameMenuButton"

export default function Page() {
  return (
    <div className="min-h-screen bg-slate-950 p-8">
      <GameMenuButton variant="primary" size="lg">
        Start Game
      </GameMenuButton>
    </div>
  )
}
```

### Step 2: Run Dev Server

```bash
cd design/ui-design
npm run dev
```

Open http://localhost:3000

### Step 3: Capture Screenshots

**Method A: Browser DevTools**
1. Open DevTools (F12)
2. Set device to "Responsive"
3. Set viewport to 2560x1440 (2x scale)
4. Use browser screenshot tool or Windows Snipping Tool
5. Crop to component bounds

**Method B: Puppeteer Script (Automated)**
```bash
# TODO: Create automated screenshot script
# npm run export-components
```

### Step 4: Save to Exports

File naming convention:
```
[component-name]-[variant]-[state].png

Examples:
- button-primary-normal.png
- button-primary-hover.png
- button-secondary-active.png
- panel-background-dark.png
- score-display-animated-frame1.png
```

Save to appropriate category:
- `design/exports/ui/buttons/`
- `design/exports/ui/panels/`
- `design/exports/ui/hud/`
- `design/exports/ui/modals/`

### Step 5: Copy to Game Assets

Once finalized, copy to:
```
assets/images/ui/[component-name].png
```

---

## Screenshot Specifications

### Resolution
- **Design Resolution**: 2560x1440 (2x scale)
- **Game Resolution**: 1280x720 (native)
- **Export Scale**: 2x for crispy rendering

### Format
- **Format**: PNG
- **Bit Depth**: 32-bit RGBA
- **Compression**: Maximum quality

### Component States

Capture multiple states for interactive elements:

**Buttons:**
- Normal (default)
- Hover (mouse over)
- Active (pressed)
- Disabled (grayed out)

**Panels:**
- Default state
- With content (if dynamic)

**HUD Elements:**
- Default
- Animated frames (if needed)

---

## Love2D Integration

### Loading Sprites in Love2D

```lua
-- src/ui/assets.lua
local ui = {
    button_primary = love.graphics.newImage("assets/images/ui/button-primary-normal.png"),
    button_primary_hover = love.graphics.newImage("assets/images/ui/button-primary-hover.png"),
    button_primary_active = love.graphics.newImage("assets/images/ui/button-primary-active.png"),
    -- ... etc
}

return ui
```

### Rendering with Slab

```lua
-- src/ui/menu.lua
local ui = require('src.ui.assets')

function MenuState:draw()
    Slab.BeginWindow('MainMenu', {Title = "", X = 100, Y = 100})
    
    -- Draw button sprite
    if Slab.BeginImageButton(ui.button_primary, {W = 200, H = 50}) then
        print("Button clicked!")
    end
    
    Slab.EndWindow()
end
```

### Animating with flux

```lua
-- src/ui/animations.lua
local flux = require('lib.flux')

function animateButton(button)
    -- Fade in
    flux.to(button, 0.3, {opacity = 1}):ease("quadout")
    
    -- Scale pop on hover
    flux.to(button, 0.2, {scale = 1.05}):ease("backout")
end
```

---

## Component Checklist (Week 0 Day 3)

### Priority Components (Day 3)
- [x] Main Menu Button (3 variants, 3 sizes) - EXPORTED
- [ ] Panel Background (dark theme)
- [ ] Score Display (HUD element)
- [ ] Achievement Card
- [ ] Upgrade Card
- [ ] Progress Bar
- [ ] Modal Dialog
- [ ] Loading Screen

### Secondary Components (Day 4)
- [ ] Navigation Header
- [ ] Footer Actions
- [ ] Tab Switcher
- [ ] Combo Badge
- [ ] Launch Meter
- [ ] Status Bar
- [ ] Mini-Map
- [ ] Stat Card
- [ ] Tooltip

---

## Quality Checklist

Before exporting, verify:
- ✅ Component renders correctly at 2x scale
- ✅ Colors match design intent
- ✅ Transparency (if any) is preserved
- ✅ Text is crisp and readable
- ✅ Animations previewed (timing noted)
- ✅ All states captured (normal, hover, active)
- ✅ File size is reasonable (<500KB per sprite)

---

## Automation Ideas (Future)

### Puppeteer Screenshot Script
```javascript
// scripts/export-components.js
const puppeteer = require('puppeteer');

async function captureComponent(page, selector, filename) {
  const element = await page.$(selector);
  await element.screenshot({path: `exports/ui/${filename}.png`, scale: 2});
}

// Usage:
// node scripts/export-components.js
```

### Batch Export
```bash
# Export all components at once
npm run export-all
```

---

## Notes

**Why Export as PNG instead of using React in-game?**
- Love2D doesn't run JavaScript/React
- Slab UI expects image assets for custom styling
- Better performance (pre-rendered vs runtime)
- Full control over pixel-perfect rendering
- Easy to iterate (redesign → re-export)

**Workflow Benefits:**
- Design with modern tools (React, Tailwind, shadcn/ui)
- Preview animations with Framer Motion
- Export static sprites for game
- Best of both worlds!

---

**Last Updated**: 2025-10-10
**Status**: Workflow Documented
**Next**: Day 3 - Design & Export 10-15 Components
