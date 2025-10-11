# Component Export Checklist - Week 0 Day 3/4

## Components to Export

### ✅ Designed (8/8)
1. **GameMenuButton** - 3 variants × 3 sizes = 9 states
2. **GamePanel** - Background container
3. **ProgressBar** - 4 color variants
4. **ScoreDisplay** - With combo multiplier
5. **AchievementCard** - Locked/unlocked states
6. **UpgradeCard** - Available/locked states  
7. **ModalDialog** - Backdrop + content
8. **LoadingScreen** - Animated spinner

### 📸 Export Status (0/8)

#### Priority 1 - Core Game UI
- [ ] **GameMenuButton** (Primary variant, all sizes)
  - [ ] Normal state
  - [ ] Hover state
  - [ ] Active state
  - Files: `button-primary-{sm/md/lg}-{normal/hover/active}.png`

- [ ] **ScoreDisplay** 
  - [ ] Normal (no combo)
  - [ ] With combo multiplier
  - Files: `score-display-{normal/combo}.png`

- [ ] **ProgressBar**
  - [ ] Cyan variant (Health)
  - [ ] Green variant (Energy)
  - [ ] Purple variant (XP)
  - Files: `progress-bar-{cyan/green/purple}.png`

#### Priority 2 - Menu/Progression UI
- [ ] **GamePanel**
  - [ ] Normal state
  - [ ] Empty (just background)
  - Files: `panel-background.png`

- [ ] **AchievementCard**
  - [ ] Unlocked state
  - [ ] Locked with progress
  - Files: `achievement-{unlocked/locked}.png`

- [ ] **UpgradeCard**
  - [ ] Available (can afford)
  - [ ] Locked (can't afford)
  - Files: `upgrade-{available/locked}.png`

#### Priority 3 - System UI
- [ ] **ModalDialog**
  - [ ] Full modal with content
  - Files: `modal-dialog.png`

- [ ] **LoadingScreen**
  - [ ] Spinner animation (capture 4 frames)
  - Files: `loading-{frame1-4}.png`

---

## Export Settings

**Resolution**: 2560×1440 (2x scale for 1280×720 native)
**Format**: PNG with alpha channel
**Quality**: Maximum (no compression)
**Method**: Browser screenshot or automated

---

## Export Workflow

### Manual Export (Browser)
1. Open http://localhost:3000
2. Set browser zoom to 200% (for crisp 2x)
3. Use Snipping Tool or browser DevTools screenshot
4. Crop to component bounds
5. Save to `design/exports/ui/[category]/[filename].png`

### Automated Export (Future)
```bash
# TODO: Create Puppeteer script
npm run export-components
```

---

## File Organization

```
design/exports/ui/
├── buttons/
│   ├── button-primary-sm-normal.png
│   ├── button-primary-sm-hover.png
│   ├── button-primary-md-normal.png
│   └── ... (9 total)
├── hud/
│   ├── score-display-normal.png
│   ├── score-display-combo.png
│   ├── progress-bar-cyan.png
│   ├── progress-bar-green.png
│   └── progress-bar-purple.png
├── panels/
│   └── panel-background.png
├── cards/
│   ├── achievement-unlocked.png
│   ├── achievement-locked.png
│   ├── upgrade-available.png
│   └── upgrade-locked.png
└── modals/
    ├── modal-dialog.png
    └── loading-frame1-4.png
```

---

## Implementation Priority

After export, implement in this order:

### Day 4 Morning - Core UI
1. GameMenuButton (main menu)
2. ModalDialog (pause menu)

### Day 4 Afternoon - HUD
3. ScoreDisplay
4. ProgressBar

### Day 4 (Optional if time)
5. GamePanel
6. AchievementCard
7. UpgradeCard
8. LoadingScreen

---

**Status**: Components designed, ready for export
**Next**: Screenshot export workflow
**Timeline**: Export Day 4 morning, implement Day 4 afternoon
