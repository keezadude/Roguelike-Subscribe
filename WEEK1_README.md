# Week 1: Physics Foundation - Quick Reference

## ✅ Status: COMPLETE

All Week 1 objectives achieved. Physics foundation ready for Week 2 ragdoll implementation.

---

## 🎮 How to Test

### Run Physics Test:
```batch
run-physics-test.bat
```

### Controls:
- **WASD/Arrows** - Move player
- **F1** - Toggle physics debug overlay
- **F2** - Toggle velocity vectors
- **F3** - Toggle AABB boxes
- **R** - Reset player position
- **ESC** - Pause/Resume

### Expected Results:
- 60 FPS stable
- Smooth player movement
- Accurate wall collisions
- Player slides along walls
- Debug overlay shows physics bodies

---

## 📁 Files Created (Week 1)

### Core Systems
```
src/physics/world.lua          (340 lines) - Physics world manager
src/debug/physics-renderer.lua (380 lines) - Debug visualization
src/entities/player.lua        (370 lines) - Player with WASD movement
src/entities/wall.lua          (200 lines) - Static wall obstacles
```

### Testing
```
physics-test.lua               (280 lines) - Standalone test
run-physics-test.bat           (45 lines)  - Test runner
```

### Documentation
```
WEEK1_STATUS.md                - Progress tracking
WEEK1_COMPLETE.md              - Completion summary
WEEK1_README.md                - This file
```

---

## 🔧 API Quick Reference

### Physics World
```lua
local PhysicsWorld = require('src.physics.world')

-- Create world
world = PhysicsWorld:new(gravityX, gravityY, {
    pixelScale = 64,
    timeStep = 1/60
})

-- Create body
body = world:createBody("dynamic", x, y, {
    shape = "circle",      -- or "rectangle", "polygon"
    radius = 16,           -- for circle
    category = "PLAYER",
    friction = 0.8,
    restitution = 0.1,
    fixedRotation = true,
    linearDamping = 5.0
})

-- Update
world:update(dt)

-- Queries
bodies = world:queryArea(x, y, radius)
stats = world:getStats()
```

### Player Entity
```lua
local Player = require('src.entities.player')

-- Create player
player = Player:new(physicsWorld, x, y, {
    moveSpeed = 300,
    maxSpeed = 200,
    radius = 16,
    health = 100
})

-- Update & Draw
player:update(dt)
player:draw()

-- Control
x, y = player:getPosition()
player:setPosition(x, y)
player:takeDamage(amount)
player:heal(amount)
```

### Wall Entity
```lua
local Wall = require('src.entities.wall')

-- Create wall
wall = Wall:new(physicsWorld, x, y, width, height, {
    color = {0.4, 0.4, 0.4},
    pattern = "brick"  -- or "solid", "stone"
})

wall:draw()
```

### Debug Renderer
```lua
local PhysicsRenderer = require('src.debug.physics-renderer')

-- Create renderer
debugRenderer = PhysicsRenderer:new(physicsWorld, {
    showBodies = true,
    showVelocities = true,
    showStats = true
})

-- Toggle
debugRenderer:toggle()
debugRenderer:toggleOption("velocities")

-- Draw
debugRenderer:draw()
```

---

## 🎯 Collision Categories

Defined in `PhysicsWorld.CATEGORIES`:
- **PLAYER** = 1
- **ENEMY** = 2
- **PROJECTILE** = 4
- **WALL** = 8
- **PICKUP** = 16
- **SENSOR** = 32

Usage:
```lua
body = world:createBody("dynamic", x, y, {
    category = "PLAYER"
})
```

---

## 🎨 Debug Color Scheme

- **PLAYER**: Cyan `(0.2, 0.8, 1.0)`
- **ENEMY**: Red `(1.0, 0.2, 0.2)`
- **PROJECTILE**: Yellow `(1.0, 1.0, 0.2)`
- **WALL**: Gray `(0.5, 0.5, 0.5)`
- **PICKUP**: Green `(0.2, 1.0, 0.2)`
- **SENSOR**: Pink `(1.0, 0.5, 1.0)`

---

## 📊 Performance Metrics

**Current Stats** (physics-test.lua):
- Bodies: 10 (1 player + 9 walls)
- FPS: 60 (stable)
- Physics Update: <1ms
- Memory: Minimal

**Target Capacity**:
- 100+ bodies at 60 FPS
- Sub-2ms physics updates
- Scalable architecture

---

## 🚀 Week 2 Preview

**Objective**: Ragdoll physics with 3D visuals

**Key Tasks**:
1. Multi-body ragdoll (5 bodies: head, torso, 2 arms, 2 legs)
2. Joint system (ball-and-socket, hinge joints)
3. 3DreamEngine integration
4. 2D physics → 3D rendering sync
5. 3D asset loading (Quaternius models)

**New Files to Create**:
- `src/entities/ragdoll.lua`
- `src/rendering/model-loader.lua`
- `src/rendering/physics-3d-sync.lua`

**Foundation Ready**:
- ✅ Physics world working
- ✅ Entity pattern established
- ✅ Debug tools available
- ✅ Test environment template

---

## 💡 Development Notes

### Best Practices from Week 1:
1. **Use options tables** for flexible configuration
2. **Document everything** with docstring comments
3. **Test standalone** before integrating
4. **Debug early** with visualization tools
5. **Follow entity pattern** for consistency

### Physics Tuning Tips:
- **Top-down games**: Use gravity (0, 0)
- **Smooth movement**: High linear damping (5.0+)
- **No spinning**: Set `fixedRotation = true`
- **Natural feel**: Force-based > velocity-based
- **Max speed**: Always cap velocity

### Common Patterns:
```lua
-- Options with defaults
options = options or {}
self.property = options.property or defaultValue

-- Safe cleanup
if self.body then
    self.body:destroy()
    self.body = nil
end

-- Normalized movement
if dx ~= 0 and dy ~= 0 then
    local mag = math.sqrt(dx*dx + dy*dy)
    dx, dy = dx/mag, dy/mag
end
```

---

## 🔍 Troubleshooting

### Player not moving?
- Check WASD/Arrow keys in `player:handleInput()`
- Verify `player:update(dt)` is called
- Check if physics world is updating
- Use F2 to see velocity vectors

### Falling through walls?
- Ensure walls are created before player moves
- Check wall body type is "static"
- Verify collision categories set
- Use F1 to see physics bodies

### Low FPS?
- Check body count (target <100)
- Verify fixed timestep (1/60)
- Monitor physics update time
- Use debug stats panel

### Physics acting weird?
- Reset with R key
- Check gravity settings (0,0 for top-down)
- Verify damping values
- Check for NaN in positions

---

## 📖 Documentation Files

- **DEVELOPMENT_PLAN_V3.md** - Overall 7-week plan
- **WEEK0_COMPLETE.md** - UI foundation (previous week)
- **WEEK1_STATUS.md** - Detailed progress
- **WEEK1_COMPLETE.md** - Completion summary
- **WEEK1_README.md** - This quick reference

---

**Week 1 Complete** ✅  
**Physics Foundation** ✅  
**Ready for Week 2** ✅

*Run `run-physics-test.bat` to see it in action!*
