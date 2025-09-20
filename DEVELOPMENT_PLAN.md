# Dismount Roguelike - Development Plan "First Form"

## 🎯 Vision Statement

Create a **physics-based ragdoll destruction game** that combines the addictive crash mechanics of Truck Dismount with roguelike progression, featuring both 2D and 3D rendering modes for spectacular visual feedback.

## 📋 Development Phases Overview

### **Phase 1: Core Physics Foundation** (Week 1)
**Goal**: Establish stable physics simulation foundation
- Set up Breezefield physics world with proper scaling
- Implement collision detection and basic physics bodies
- Create debug visualization system
- Establish coordinate system (64 pixels = 1 meter)

### **Phase 2: Basic Ragdoll Implementation** (Week 1-2)
**Goal**: Create functional multi-body ragdoll character
- Implement 5-body simplified ragdoll (head, torso, arms, legs)
- Add revolute joints with realistic constraints
- Prevent self-collision through filtering
- Basic ragdoll spawning and positioning

### **Phase 3: Vehicle Physics and Launch** (Week 2)
**Goal**: Create launchable vehicle with force mechanics
- Implement truck with realistic mass and wheels
- Add adjustable launch force system
- Create launch trajectory mechanics
- Basic truck-ragdoll collision

### **Phase 4: Damage System and Scoring** (Week 2-3)
**Goal**: Implement impact-based damage calculation
- Physics-based damage using kinetic energy
- Body part damage multipliers (head = most damage)
- Sustained damage for continuous contact
- Basic scoring display and accumulation

### **Phase 5: Basic UI and Game Loop** (Week 3)
**Goal**: Create playable game with complete flow
- Main menu and game states
- Launch force adjustment UI
- Score display and session tracking
- Restart/retry functionality

### **Phase 6: 3D Visual Integration** (Week 3-4)
**Goal**: Add spectacular 3D visual representation
- Sync 3D objects with 2D physics bodies
- Create 3D ragdoll and vehicle meshes
- Implement dynamic camera following
- Basic lighting and materials

### **Phase 7: Roguelike Foundation** (Week 4-5)
**Goal**: Add progression and meta-game elements
- Level/run generation system
- Basic upgrade/modifier system
- Persistent progression tracking
- Achievement system foundation

### **Phase 8: Polish and Testing** (Week 5-6)
**Goal**: Create production-ready first release
- Particle effects for impacts
- Sound effects integration
- Performance optimization
- Bug fixing and stability testing

---

## 🔧 Phase 1: Core Physics Foundation

### **1.1 Physics World Setup**
```lua
-- File: src/physics/world.lua
-- Priority: HIGH
-- Dependencies: Breezefield library

function PhysicsWorld:create()
    -- Initialize Breezefield world with gravity
    -- Set up collision categories and filtering
    -- Configure physics iterations for performance
    -- Implement debug drawing system
end
```

### **1.2 Core Physics Bodies**
```lua
-- File: src/physics/bodies.lua
-- Priority: HIGH
-- Dependencies: Physics world

function Bodies:createStatic(x, y, w, h)
    -- Ground, walls, ramps
end

function Bodies:createDynamic(x, y, w, h, mass)
    -- Moveable physics objects
end
```

### **1.3 Debug Visualization**
```lua
-- File: src/debug/physics_debug.lua
-- Priority: MEDIUM
-- Dependencies: Camera system

function PhysicsDebug:draw(world)
    -- Draw collision shapes
    -- Show joint connections
    -- Display velocity vectors
    -- Toggle with F1 key
end
```

### **1.4 Deliverables**
- [ ] Stable physics world with consistent timestep
- [ ] Basic collision detection working
- [ ] Debug visualization functional
- [ ] Performance baseline established (60 FPS target)

---

## 🏃 Phase 2: Basic Ragdoll Implementation

### **2.1 Ragdoll Structure**
```lua
-- File: src/entities/ragdoll.lua
-- Priority: HIGH
-- Dependencies: Physics bodies, tiny-ecs

local RagdollComponent = {
    parts = {
        head = nil,      -- CircleCollider
        torso = nil,     -- RectangleCollider
        leftArm = nil,   -- RectangleCollider
        rightArm = nil,  -- RectangleCollider
        leftLeg = nil,   -- RectangleCollider
        rightLeg = nil   -- RectangleCollider
    },
    joints = {},
    totalMass = 70,      -- kg (realistic human mass)
    health = 100
}
```

### **2.2 Joint System**
```lua
-- File: src/physics/joints.lua
-- Priority: HIGH
-- Dependencies: Ragdoll components

function Joints:createRagdollJoints(ragdoll)
    -- Neck: head to torso (±45 degrees)
    -- Shoulders: arms to torso (full rotation)
    -- Hips: legs to torso (walking range)
    -- All joints with realistic limits
end
```

### **2.3 Ragdoll Factory**
```lua
-- File: src/factories/ragdoll_factory.lua
-- Priority: HIGH
-- Dependencies: ECS, Physics

function RagdollFactory:create(x, y)
    local entity = tiny.entity()
    entity.ragdoll = RagdollComponent:new()
    entity.transform = {x = x, y = y, angle = 0}
    entity.physics = true
    return entity
end
```

### **2.4 Deliverables**
- [ ] 5-body ragdoll with proper mass distribution
- [ ] Realistic joint constraints and limits
- [ ] No self-collision (collision filtering working)
- [ ] Ragdoll responds naturally to forces

---

## 🚛 Phase 3: Vehicle Physics and Launch

### **3.1 Truck Implementation**
```lua
-- File: src/entities/truck.lua
-- Priority: HIGH
-- Dependencies: Physics bodies

local TruckComponent = {
    body = nil,          -- Main chassis
    wheels = {},         -- 4 wheels
    mass = 2000,         -- kg (2-ton truck)
    maxSpeed = 400,      -- pixels/second
    launchForce = 0,     -- Adjustable 0-100%
    launched = false
}
```

### **3.2 Launch Mechanics**
```lua
-- File: src/systems/launch_system.lua
-- Priority: HIGH
-- Dependencies: Input, Physics

function LaunchSystem:calculateForce(percentage)
    -- Convert percentage to actual force
    -- Apply impulse to truck body
    -- Trigger launch sequence
end

function LaunchSystem:update(dt)
    -- Handle pre-launch truck movement
    -- Apply acceleration and speed limits
    -- Detect ragdoll collision
end
```

### **3.3 Collision Detection**
```lua
-- File: src/systems/collision_system.lua
-- Priority: HIGH
-- Dependencies: Physics callbacks

function CollisionSystem:onBeginContact(a, b, collision)
    -- Detect truck-ragdoll collision
    -- Calculate impact force
    -- Trigger damage calculation
end
```

### **3.4 Deliverables**
- [ ] Truck with realistic physics behavior
- [ ] Adjustable launch force (0-100%)
- [ ] Smooth truck movement and acceleration
- [ ] Accurate collision detection with ragdoll

---

## 💥 Phase 4: Damage System and Scoring

### **4.1 Damage Calculation**
```lua
-- File: src/systems/damage_system.lua
-- Priority: HIGH
-- Dependencies: Physics, Collision system

local DAMAGE_MULTIPLIERS = {
    head = 15.0,        -- Most valuable target
    torso = 8.0,        -- Core body
    leftArm = 5.0,      -- Limbs
    rightArm = 5.0,
    leftLeg = 6.0,
    rightLeg = 6.0
}

function DamageSystem:calculateImpactDamage(body, collision)
    -- Get collision velocity and normal
    -- Calculate kinetic energy
    -- Apply body part multiplier
    -- Return damage score
end
```

### **4.2 Scoring Engine**
```lua
-- File: src/systems/scoring_system.lua
-- Priority: HIGH
-- Dependencies: Damage system, ECS

function ScoringSystem:addScore(amount, reason, position)
    -- Accumulate total score
    -- Create floating score text
    -- Track score sources for statistics
end

function ScoringSystem:calculateBonus(events)
    -- Distance bonus
    -- Air time bonus
    -- Style bonus (multiple hits, etc.)
end
```

### **4.3 Visual Feedback**
```lua
-- File: src/effects/damage_effects.lua
-- Priority: MEDIUM
-- Dependencies: Particle system

function DamageEffects:createImpactEffect(x, y, damage)
    -- Particle burst on impact
    -- Screen shake intensity
    -- Floating damage numbers
end
```

### **4.4 Deliverables**
- [ ] Physics-accurate damage calculation
- [ ] Body part damage multipliers working
- [ ] Score accumulation and display
- [ ] Visual feedback for impacts

---

## 🎮 Phase 5: Basic UI and Game Loop

### **5.1 Game States**
```lua
-- File: src/states/
-- Priority: HIGH
-- Dependencies: Hump gamestate

states/
├── menu_state.lua          -- Main menu
├── setup_state.lua         -- Pre-launch adjustment
├── gameplay_state.lua      -- Active physics simulation
├── results_state.lua       -- Score display and retry
└── pause_state.lua         -- Pause functionality
```

### **5.2 Launch Control UI**
```lua
-- File: src/ui/launch_control.lua
-- Priority: HIGH
-- Dependencies: Input system

function LaunchControl:update(dt)
    -- Mouse/keyboard input for force adjustment
    -- Visual force meter (0-100%)
    -- Launch button/key detection
end

function LaunchControl:draw()
    -- Force meter bar
    -- Launch instructions
    -- Current force percentage
end
```

### **5.3 HUD System**
```lua
-- File: src/ui/hud.lua
-- Priority: MEDIUM
-- Dependencies: Scoring system

function HUD:draw()
    -- Current score display
    -- Distance traveled
    -- Air time counter
    -- Speed indicator
end
```

### **5.4 Deliverables**
- [ ] Complete game flow from menu to results
- [ ] Intuitive launch force control
- [ ] Score and statistics display
- [ ] Restart/retry functionality

---

## 🎨 Phase 6: 3D Visual Integration

### **6.1 3D Object Synchronization**
```lua
-- File: src/rendering/sync_3d.lua
-- Priority: MEDIUM
-- Dependencies: 3DreamEngine

function Sync3D:updateRagdoll(ragdoll2D, ragdoll3D)
    -- Sync 3D object positions with 2D physics
    -- Update rotations and scales
    -- Handle joint visual connections
end

function Sync3D:updateTruck(truck2D, truck3D)
    -- Sync truck body and wheels
    -- Update material properties on damage
end
```

### **6.2 Dynamic Camera System**
```lua
-- File: src/rendering/camera_3d.lua
-- Priority: MEDIUM
-- Dependencies: 3DreamEngine, Camera tracking

function Camera3D:followAction(ragdoll, truck)
    -- Smooth camera following
    -- Cinematic angles during crashes
    -- Automatic zoom adjustment
    -- Shake effects on impact
end
```

### **6.3 Material and Lighting**
```lua
-- File: src/rendering/materials.lua
-- Priority: LOW
-- Dependencies: 3DreamEngine

function Materials:setupScene()
    -- Realistic lighting setup
    -- Material properties for different objects
    -- Environmental atmosphere
end
```

### **6.4 Deliverables**
- [ ] Seamless 2D physics to 3D visual sync
- [ ] Dynamic camera following the action
- [ ] Appealing 3D materials and lighting
- [ ] Smooth 60 FPS rendering in 3D mode

---

## 🎲 Phase 7: Roguelike Foundation

### **7.1 Run-Based Progression**
```lua
-- File: src/progression/run_manager.lua
-- Priority: MEDIUM
-- Dependencies: Save system

local RunData = {
    runNumber = 1,
    startTime = 0,
    bestScore = 0,
    upgradesActive = {},
    achievementsUnlocked = {},
    totalDamage = 0
}
```

### **7.2 Basic Upgrade System**
```lua
-- File: src/progression/upgrades.lua
-- Priority: MEDIUM
-- Dependencies: Scoring system

local UPGRADES = {
    headHunter = {
        name = "Head Hunter",
        description = "Double head damage",
        effect = function(scoring)
            scoring.multipliers.head = 2.0
        end
    },

    heavyTruck = {
        name = "Heavy Truck",
        description = "+50% truck mass",
        effect = function(truck)
            truck.mass = truck.mass * 1.5
        end
    }
}
```

### **7.3 Achievement System**
```lua
-- File: src/progression/achievements.lua
-- Priority: LOW
-- Dependencies: Game statistics

local ACHIEVEMENTS = {
    firstCrash = {
        condition = function(stats) return stats.totalRuns >= 1 end,
        reward = {coins = 50},
        title = "Welcome to Pain"
    },

    headMaster = {
        condition = function(stats) return stats.headHits >= 50 end,
        reward = {upgrade = "headHunter"},
        title = "Concussion Specialist"
    }
}
```

### **7.4 Deliverables**
- [ ] Run-based progression system
- [ ] Basic upgrade collection and effects
- [ ] Achievement tracking and rewards
- [ ] Persistent save/load functionality

---

## ✨ Phase 8: Polish and Testing

### **8.1 Particle Effects**
```lua
-- File: src/effects/particles.lua
-- Priority: MEDIUM
-- Dependencies: Love2D particles or Hot Particles

function Particles:createImpactBurst(x, y, intensity)
    -- Debris particles on collision
    -- Dust clouds for ground impacts
    -- Sparks for metal-on-metal contact
end
```

### **8.2 Audio Integration**
```lua
-- File: src/audio/sound_manager.lua
-- Priority: LOW
-- Dependencies: Love2D audio

function SoundManager:playImpact(force)
    -- Impact sounds based on collision force
    -- Engine sounds for truck
    -- Ambient environment audio
end
```

### **8.3 Performance Optimization**
```lua
-- File: src/optimization/performance.lua
-- Priority: HIGH
-- Dependencies: All systems

function Performance:optimize()
    -- Object pooling for particles
    -- Collision optimization
    -- 3D rendering optimizations
    -- Memory management
end
```

### **8.4 Bug Testing**
- [ ] Physics stability testing
- [ ] Edge case handling (ragdoll stuck, etc.)
- [ ] Save/load system validation
- [ ] Cross-platform compatibility

### **8.5 Deliverables**
- [ ] Smooth 60 FPS gameplay
- [ ] Audio feedback system
- [ ] Comprehensive bug testing
- [ ] Performance optimization complete

---

## 🎯 Success Metrics

### **MVP Definition (First Form)**
1. **Core Gameplay**: Truck launches ragdoll, physics simulation works
2. **Scoring**: Damage calculation and score display functional
3. **Game Loop**: Complete flow from setup to results to retry
4. **Visual Appeal**: Either 2D or 3D rendering working smoothly
5. **Basic Progression**: Simple upgrade system functional

### **Technical Targets**
- **Performance**: Stable 60 FPS during complex physics simulation
- **Stability**: No crashes during normal gameplay
- **Responsiveness**: Input lag < 16ms for launch controls
- **Visual Quality**: Smooth animations and effects

### **Gameplay Targets**
- **Engagement**: Players want to retry immediately after crash
- **Progression**: Clear sense of advancement through upgrades
- **Satisfaction**: Spectacular crash visuals provide visceral feedback
- **Replayability**: Different upgrade combinations create variety

---

## 📅 Development Timeline

| Phase | Duration | Key Deliverable |
|-------|----------|----------------|
| 1 | Week 1 | Stable physics foundation |
| 2 | Week 1-2 | Working ragdoll character |
| 3 | Week 2 | Launchable truck with collision |
| 4 | Week 2-3 | Damage calculation and scoring |
| 5 | Week 3 | Complete game loop |
| 6 | Week 3-4 | 3D visual integration |
| 7 | Week 4-5 | Roguelike progression |
| 8 | Week 5-6 | Polish and optimization |

**Total Development Time**: 6 weeks to first playable release

---

## 🔄 Development Methodology

### **Iterative Development**
- Each phase produces a playable build
- Regular testing and feedback integration
- Flexible scope adjustment based on progress

### **Quality Gates**
- Each phase must pass stability testing
- Performance benchmarks maintained
- Code review for critical systems

### **Risk Mitigation**
- Fallback options for complex features (2D if 3D fails)
- Modular architecture allows feature postponement
- Regular backup and version control

---

This plan provides a clear roadmap from the current library stack to a fully playable Dismount Roguelike game, with built-in flexibility for scope adjustments and technical challenges.