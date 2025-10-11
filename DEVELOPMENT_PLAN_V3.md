# 🎮 ROGUELIKE & SUBSCRIBE - V3 MASTER DEVELOPMENT PLAN
## Professional Steam Release - $10 Indie Game with Modern UI

**Target**: Gold Release Ready for Steam
**Timeline**: 7 Weeks
**Engine**: Love2D (LÖVE) 11.x
**Revenue Goal**: $10 Premium Indie Game

---

## 🎯 EXECUTIVE SUMMARY

**Core Concept**: Truck Dismount-inspired physics destruction game with roguelike progression and modern UI.

**Key Technologies**:
- **Love2D**: 2D game engine with 3D rendering capabilities
- **Breezefield**: Box2D physics wrapper (2D physics engine)
- **3DreamEngine**: 3D visual rendering (synced to 2D physics)
- **Slab**: Immediate mode GUI library
- **flux**: GSAP-style animation library
- **Magic/21st.dev MCP**: UI component design tool
- **GSAP Master MCP**: Animation reference library

**Unique Selling Points**:
1. Satisfying ragdoll physics with spectacular 3D visuals
2. Deep roguelike progression (Balatro-inspired)
3. Professional, modern UI (exported from React/shadcn)
4. Replayability through upgrade combinations
5. Steam achievements integration

---

## 📦 ASSET-DRIVEN DEVELOPMENT PHILOSOPHY

**CORE PRINCIPLE**: Never create complex 3D models or UI components from scratch when quality free alternatives exist.

### Primary Asset Sources

#### **3D Models**
1. **Quaternius** (quaternius.com) - CC0 License
   - Ultimate Modular Men Pack (characters/ragdolls)
   - Ultimate Animated Character Pack (50+ characters)
   - Vehicle packs

2. **Poly Pizza** (poly.pizza) - 10,400+ free models
   - Trucks: https://poly.pizza/search/truck
   - Characters: https://poly.pizza/explore/People-and-Characters

3. **Kenney.nl** (kenney.nl/assets) - 60,000+ assets
   - Racing Kit, Car Kit, Blocky Characters
   - All-in-One Pack available

4. **Sketchfab CC0** - Rigged characters

#### **Audio**
1. **Freesound.org** - CC0 sound effects
2. **Kenney.nl** - Audio packs included

#### **UI Design**
- **Magic/21st.dev MCP** - Generate React/shadcn components
- Export as high-res sprites for Love2D

---

## 🏗️ ARCHITECTURE OVERVIEW

### Physics Architecture
```
2D Physics (Breezefield/Box2D)
    ↓
Drives ALL gameplay logic
    ↓
Synced to →  3D Visuals (3DreamEngine)
```

**CRITICAL**: 3D is PURELY visual. All gameplay runs on 2D physics.

### UI Architecture
```
Design Phase:
  Magic/21st.dev → React Components → High-res Screenshots

Implementation Phase:
  Exported Sprites → Slab UI Library → GSAP-style Animations (flux)
```

---

## 📋 7-WEEK DEVELOPMENT TIMELINE

### **WEEK 0: UI FOUNDATION & SETUP** (4 days)

#### Day 1: Library Integration
- [ ] Download Slab UI library: `git clone https://github.com/flamendless/Slab.git lib/Slab`
- [ ] Download flux: `wget https://raw.githubusercontent.com/rxi/flux/master/flux.lua -O lib/flux.lua`
- [ ] Test Slab with simple window
- [ ] Verify flux tweening

#### Day 2: UI Design Environment
- [ ] Set up Next.js for UI design
- [ ] Validate Magic MCP can generate components
- [ ] Validate GSAP MCP for animations

#### Day 3: Component Design & Export
- [ ] Design 10-15 UI components using Magic MCP
- [ ] Export each as high-res PNG (2x scale)
- [ ] Organize in `game/assets/ui/`

#### Day 4: Animation System & Menu
- [ ] Create `src/ui/animations.lua` (GSAP-inspired)
- [ ] Build `src/ui/menu-manager.lua`
- [ ] Create animated main menu
- [ ] Test button hover/click animations

**Week 0 Deliverable**: ✅ Animated main menu with professional UI

---

### **WEEK 1: PHYSICS FOUNDATION** (7 days)

- [ ] Create `src/physics/world.lua`
- [ ] Initialize Breezefield (gravity: 9.81 * 64)
- [ ] Set up collision categories
- [ ] Implement collision callbacks
- [ ] Create debug visualization (F1 toggle)
- [ ] Test with basic shapes
- [ ] Implement pause menu
- [ ] Create debug stats overlay

**Week 1 Deliverable**: ✅ Stable physics world + pause menu

---

### **WEEK 2: ASSET INTEGRATION & RAGDOLL** (7 days)

- [ ] Download Quaternius Ultimate Modular Men Pack
- [ ] Download Kenney Car Kit
- [ ] Download Poly Pizza trucks
- [ ] Download Freesound impact sounds
- [ ] Implement 5-body ragdoll (head, torso, arms, legs)
- [ ] Create joint system with realistic limits
- [ ] Load first 3D character model
- [ ] Sync 2D physics → 3D visuals
- [ ] Character select screen

**Week 2 Deliverable**: ✅ Ragdoll physics with 3D visuals

---

### **WEEK 3: VEHICLE & DAMAGE SYSTEM** (7 days)

- [ ] Implement truck physics (2000kg mass)
- [ ] Add 4 wheels with friction
- [ ] Create launch force system (0-100%)
- [ ] Truck-ragdoll collision detection
- [ ] Damage calculation (kinetic energy)
- [ ] Body part multipliers (head 15x, torso 8x, etc.)
- [ ] Score accumulation
- [ ] Audio integration (impact sounds)
- [ ] Launch control UI
- [ ] Live score HUD

**Week 3 Deliverable**: ✅ Core gameplay loop working!

---

### **WEEK 4: GAME LOOP & 3D POLISH** (7 days)

- [ ] Game state machine (Menu, Setup, Gameplay, Results, Pause)
- [ ] Results screen with score breakdown
- [ ] Dynamic camera following
- [ ] Camera shake on impacts
- [ ] Particle effects (impacts, debris, dust)
- [ ] Screen effects (flash on big hits)
- [ ] 3D lighting and materials polish

**Week 4 Deliverable**: ✅ Complete playable game loop

---

### **WEEK 5: ROGUELIKE SYSTEMS** (7 days)

- [ ] Modular scoring engine
- [ ] Achievement system (20-30 achievements)
- [ ] Steam achievements prep
- [ ] Upgrade framework
- [ ] Currency system
- [ ] Save/load system (JSON)
- [ ] Achievements gallery UI
- [ ] Upgrade shop interface
- [ ] Progress tracking page

**Week 5 Deliverable**: ✅ Full roguelike progression

---

### **WEEK 6: POLISH & STEAM PREP** (7 days)

- [ ] Background music and ambient sounds
- [ ] UI sound effects
- [ ] Audio settings menu
- [ ] Performance optimization
- [ ] Object pooling
- [ ] Memory leak testing
- [ ] Steam SDK integration
- [ ] Steam achievements hookup
- [ ] Full settings menu (graphics, audio, controls)
- [ ] Controller support
- [ ] Credits screen

**Week 6 Deliverable**: ✅ Steam-ready build

---

### **WEEK 7: LAUNCH PREPARATION** (7 days)

- [ ] Full QA testing
- [ ] Edge case testing
- [ ] Achievement verification
- [ ] Progression testing
- [ ] Balancing (damage, costs, difficulty)
- [ ] Playtesting feedback
- [ ] Steam store assets (screenshots, trailer)
- [ ] Press kit
- [ ] Community setup

**Week 7 Deliverable**: ✅ GOLD MASTER - Ready for Launch!

---

## 🎨 UI COMPONENTS (Design with Magic MCP)

### 20 Components to Create:
1. Main Menu Button (texture variant)
2. Panel Background
3. Tab Switcher
4. Navigation Header
5. Footer Actions
6. Score Display
7. Combo Badge
8. Launch Meter
9. Status Bar
10. Mini-Map
11. Achievement Card
12. Upgrade Card
13. Currency Display
14. Progress Bar
15. Stat Card
16. Modal Dialog
17. Loading Screen
18. Pause Overlay
19. Results Panel
20. Tooltip

---

## 🛠️ TECHNICAL SPECIFICATIONS

### Performance Targets
- **FPS**: Stable 60 FPS minimum
- **Physics Bodies**: 50-100 concurrent max
- **Particles**: 500 active max
- **Memory**: < 500MB resident
- **Build Size**: < 100MB

### File Structure
```
Roguelike & Subscribe/
├── game/
│   ├── lib/           # External libraries
│   ├── src/           # Source code
│   ├── assets/        # Game assets
│   ├── main.lua
│   └── conf.lua
├── design/            # UI design (Next.js)
├── assets-raw/        # Downloaded assets
└── DEVELOPMENT_PLAN_V3.md
```

---

## 📚 REQUIRED DOWNLOADS

### Libraries to Add
- [ ] **Slab**: https://github.com/flamendless/Slab
- [ ] **flux**: https://github.com/rxi/flux

### Asset Sources (Bookmark)
- [ ] Quaternius: https://quaternius.com/
- [ ] Poly Pizza: https://poly.pizza/
- [ ] Kenney: https://kenney.nl/assets
- [ ] Freesound: https://freesound.org/browse/tags/cc0/

---

## 🎯 SUCCESS METRICS

### Weekly Milestones
- Week 0: ✅ Animated main menu
- Week 1: ✅ Physics + pause menu
- Week 2: ✅ Ragdoll with 3D
- Week 3: ✅ Core gameplay
- Week 4: ✅ Complete game flow
- Week 5: ✅ Roguelike progression
- Week 6: ✅ Steam-ready
- Week 7: ✅ GOLD MASTER

---

## 💡 DEVELOPMENT BEST PRACTICES

1. **Asset-Driven**: Search before creating
2. **UI Workflow**: Design in React → Export → Import
3. **Physics-First**: 2D drives gameplay, 3D is cosmetic
4. **Performance**: Profile early and often
5. **Version Control**: Commit after major features

---

## 🗑️ HOUSEKEEPING REMINDER

**IMPORTANT**: Throughout development, DELETE unnecessary .md files to prevent context clogging.

### Files to Keep
- `DEVELOPMENT_PLAN_V3.md` (this file)
- `README.md`
- `ASSET_INVENTORY.md`

### Files to Delete After Use
- Old development plans (V1, V2)
- Temporary research notes
- Obsolete documentation
- Duplicate planning files

**Clean context = Better AI assistance = Faster development**

---

**Last Updated**: 2025-10-10
**Status**: Ready to Execute
**Next Action**: Begin Week 0 - UI Foundation Setup

*Follow the plan. Ship the game.* 🚀
