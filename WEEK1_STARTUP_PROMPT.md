# Week 1 Startup Prompt - Physics Foundation

## 🎯 Directive

Begin **Week 1: Physics Foundation** for "Roguelike & Subscribe" following DEVELOPMENT_PLAN_V3.md. Execute autonomously with minimal prompts. Week 0 is complete - all UI systems are ready. Focus on physics implementation using Breezefield library.

---

## 📋 Project Context

**Project**: Roguelike & Subscribe  
**Engine**: Love2D 11.x (Lua)  
**Genre**: Top-down roguelike with physics-based combat  
**Development Stage**: Week 1 of 7-week plan  
**Goal**: Physics-based roguelike with YouTube subscriber mechanics

**Key Files to Review**:
- `DEVELOPMENT_PLAN_V3.md` - Main development roadmap (Week 1 section)
- `WEEK0_COMPLETE.md` - Week 0 summary and accomplishments
- `WEEK0_STATUS.md` - Detailed Week 0 progress

---

## ✅ Week 0 Complete (Context)

**All UI foundation systems ready**:
- ✅ Slab UI + flux animation libraries integrated
- ✅ 8 React UI components designed (GameMenuButton, ScoreDisplay, etc.)
- ✅ Animation system (`src/ui/animations.lua`) - 15 patterns, 20+ easings
- ✅ Menu manager (`src/ui/menu-manager.lua`) - State machine
- ✅ Main menu (`src/ui/main-menu.lua`) - Working with placeholders
- ✅ Asset loader (`src/ui/assets-loader.lua`) - Sprite management
- ✅ Next.js showcase at http://localhost:3000 (may need restart)
- ✅ Performance: 60 FPS confirmed

**Current File Structure**:
```
lib/
  ├── Slab/          (UI library - working)
  ├── flux.lua       (Animation library - working)
  ├── breezefield/   (Physics library - READY TO USE)
  ├── 3DreamEngine/  (3D engine - for later weeks)
  └── astray/        (Dungeon generation - for later weeks)

src/ui/            (Week 0 - COMPLETE)
  ├── animations.lua
  ├── menu-manager.lua
  ├── main-menu.lua
  └── assets-loader.lua

src/physics/       (Week 1 - TO CREATE)
src/entities/      (Week 1-2 - TO CREATE)
src/systems/       (Week 2+ - Future)
```

---

## 🎯 Week 1 Objectives (from DEVELOPMENT_PLAN_V3.md)

### Primary Deliverable:
**"Working physics with a player that can move and collide with walls"**

### Tasks to Complete:

**Day 1: Physics World Setup**
1. Create `src/physics/world.lua` - Breezefield physics world manager
2. Initialize physics world (gravity: 9.81 * 64 for pixel scale)
3. Set up collision categories (player, enemy, projectile, wall, pickup)
4. Implement collision callbacks
5. Create update/draw methods
6. Test with basic static bodies

**Day 2: Debug Visualization**
1. Create `src/debug/physics-renderer.lua` - Visual debugging
2. Draw collision shapes (boxes, circles, polygons)
3. Draw velocity vectors
4. Draw contact points
5. Add F1 toggle for debug overlay
6. Color-code collision categories

**Day 3: Player Physics**
1. Create `src/entities/player.lua` - Player entity
2. Add dynamic physics body (circular)
3. Implement WASD movement (top-down)
4. Add friction and damping
5. Velocity capping (max speed)
6. Basic sprite placeholder

**Day 4: Collision Testing**
1. Create `src/entities/wall.lua` - Static wall entity
2. Create test arena with walls
3. Implement proper collision response
4. Test player-wall collisions
5. Add pause menu (using Week 0 menu system)
6. Performance testing (target: 60 FPS with 100+ bodies)

---

## 🔧 Technical Requirements

### Breezefield Physics Setup:
```lua
-- lib/breezefield/ is already installed
-- Key modules to use:
local World = require('lib.breezefield.World')
local Body = require('lib.breezefield.Body')
local Shape = require('lib.breezefield.Shape')

-- Initialize world
world = World(0, 9.81 * 64) -- gravity in pixels/sec²

-- Collision categories (bitwise flags)
COLLISION_CATEGORIES = {
    PLAYER = 1,
    ENEMY = 2,
    PROJECTILE = 4,
    WALL = 8,
    PICKUP = 16,
}
```

### Performance Targets:
- 60 FPS minimum
- Support 100+ physics bodies
- Sub-1ms physics update time
- Spatial partitioning for optimization

### Debug Controls:
- `F1` - Toggle physics debug overlay
- `F2` - Toggle FPS/performance stats
- `F3` - Toggle entity info
- `ESC` - Pause menu

---

## 📐 Architecture Guidelines

### Code Style:
- Modular OOP-style Lua (metatables)
- Clear separation of concerns
- Comprehensive error handling
- Extensive inline comments
- Follow existing patterns from `src/ui/` files

### File Organization:
```lua
-- src/physics/world.lua
local PhysicsWorld = {}
PhysicsWorld.__index = PhysicsWorld

function PhysicsWorld:new()
    -- Constructor
end

function PhysicsWorld:update(dt)
    -- Physics step
end

function PhysicsWorld:draw()
    -- Optional physics debug
end

return PhysicsWorld
```

### Entity Pattern (from Week 0):
```lua
-- src/entities/[entity-name].lua
local Entity = {}
Entity.__index = Entity

function Entity:new(world, x, y, options)
    local self = setmetatable({}, Entity)
    self.body = world:addBody(...)
    return self
end

function Entity:update(dt)
    -- Entity logic
end

function Entity:draw()
    -- Render entity
end

return Entity
```

---

## 🚀 Development Approach

### Execution Style:
- **Autonomous**: Proceed with minimal prompts
- **Incremental**: Test each system before moving on
- **Documented**: Update WEEK1_STATUS.md after each day
- **Efficient**: Reuse Week 0 patterns where applicable

### Testing Strategy:
1. Create test files (like `main-menu-test.lua` pattern)
2. Test each day's deliverables independently
3. Integrate into main game loop progressively
4. Confirm 60 FPS at each milestone

### Documentation:
- Create `WEEK1_STATUS.md` (mirror WEEK0_STATUS.md format)
- Update after each day's completion
- Document physics parameters and tuning
- Create `WEEK1_DAY[X]_README.md` as needed

---

## 📦 Deliverable Checklist

By end of Week 1, these files should exist:

**Core Systems**:
- [ ] `src/physics/world.lua` - Physics world manager
- [ ] `src/debug/physics-renderer.lua` - Debug visualization
- [ ] `src/entities/player.lua` - Player entity
- [ ] `src/entities/wall.lua` - Wall entity

**Testing**:
- [ ] `physics-test.lua` - Standalone physics test
- [ ] `player-test.lua` - Player movement test
- [ ] Integration into main.lua

**Documentation**:
- [ ] `WEEK1_STATUS.md` - Progress tracker
- [ ] `WEEK1_COMPLETE.md` - Week summary
- [ ] Inline code documentation

**Quality Checks**:
- [ ] 60 FPS with physics running
- [ ] Player moves smoothly with WASD
- [ ] Collisions work correctly
- [ ] Debug overlay functional (F1)
- [ ] Pause menu integrated

---

## 🎮 Integration with Week 0

### Menu System Integration:
```lua
-- Use existing menu manager for pause menu
local MenuManager = require('src.ui.menu-manager')

-- Add new pause menu state
MenuManager.States.PAUSE = "pause"

-- In game loop
if key == "escape" and gameState == "playing" then
    menuManager:setState(MenuManager.States.PAUSE)
end
```

### Animation System:
```lua
-- Use for player movement feedback
local Animations = require('src.ui.animations')

-- Smooth camera follow
Animations.patterns.smoothFollow(camera, player)
```

---

## 🔍 Key Resources

**Breezefield Documentation**:
- Located in: `lib/breezefield/`
- Reference: Check source files for API
- Similar to: Box2D physics (rigid body dynamics)

**Week 0 Patterns**:
- Review: `src/ui/menu-manager.lua` for state machine pattern
- Review: `src/ui/animations.lua` for module structure
- Review: `main-menu-test.lua` for test file pattern

**Development Plan**:
- Main guide: `DEVELOPMENT_PLAN_V3.md` (Week 1 section)
- Context: `WEEK0_COMPLETE.md` for what's already done

---

## ⚡ Success Criteria

**Week 1 is complete when**:
1. Physics world is running at 60 FPS
2. Player can move with WASD in all directions
3. Player collides with walls correctly
4. Debug overlay shows physics bodies (F1)
5. Pause menu works (ESC)
6. Code is modular and well-documented
7. Test files demonstrate all features
8. `WEEK1_STATUS.md` and `WEEK1_COMPLETE.md` created

---

## 🎯 First Steps (Suggested)

1. Read `DEVELOPMENT_PLAN_V3.md` Week 1 section
2. Create `src/physics/world.lua` with Breezefield initialization
3. Create simple test with 1 dynamic body
4. Confirm physics runs at 60 FPS
5. Add collision categories
6. Create debug renderer
7. Proceed through Day 1-4 tasks autonomously

---

## 📝 Ready to Begin

**Status**: Week 0 complete, Week 1 ready to start  
**Approach**: Autonomous development, minimal prompts  
**Timeline**: 4 days (estimated 2-3 hours total)  
**Focus**: Physics world → Debug → Player → Collision testing  

**Execute Week 1 following DEVELOPMENT_PLAN_V3.md. Create all physics systems, player entity, and collision testing. Update documentation as you progress. Proceed autonomously.**

---

**End of Startup Prompt**  
*Created: 2025-10-10*  
*For: Week 1 - Physics Foundation*  
*Previous: Week 0 - UI Foundation (Complete)*
