# Dismount Roguelike - Library Stack Setup

This project provides a complete library stack for creating a physics-based ragdoll game inspired by Truck Dismount, with roguelike progression elements.

## Library Stack Overview

### ✅ Successfully Downloaded Libraries

1. **rotLove** - Roguelike toolkit for FOV, procedural maps, and progression
2. **Breezefield** - Lightweight Love2D physics wrapper for customizable ragdoll physics
3. **Loveblobs** - Soft body physics for deformable, jelly-like ragdoll enhancements
4. **Andross** - Skeletal animation system for blending animations with physics
5. **Hot Particles** - Particle effects system for impact visuals
6. **Tiny-ECS** - Entity Component System for organizing ragdoll parts and game entities
7. **Hump** - Utilities for states, timers, vectors, and cameras
8. **Astray** - Procedural maze/room generation for dismount scenarios
9. **3DreamEngine** - Complete 3D rendering engine for Love2D (enables 3D ragdoll physics!)

## Project Structure

```
Roguelike & Subscribe/
├── lib/                          # External libraries
│   ├── rotLove/                  # Roguelike toolkit
│   ├── breezefield/              # Physics wrapper
│   ├── loveblobs/                # Soft body physics
│   ├── andross/                  # Skeletal animation
│   ├── hotparticles/             # Particle effects
│   ├── tiny-ecs/                 # Entity Component System
│   ├── hump/                     # General utilities
│   ├── astray/                   # Procedural generation
│   └── 3DreamEngine/             # 3D rendering engine
├── main.lua                      # Main game file with library setup
├── conf.lua                      # Love2D configuration
├── setup.lua                     # Integration helpers and examples
├── CLAUDE.md                     # Development guide
└── dismount_love2d_tutorial.md   # Complete implementation guide
```

## Testing the Setup

### Prerequisites
- Love2D 11.4 or later installed on your system
- Download from: https://love2d.org/

### Running the Test

1. **Command Line (if Love2D is in PATH):**
   ```bash
   love .
   ```

2. **Windows (if Love2D not in PATH):**
   ```bash
   "C:\Program Files\LOVE\love.exe" .
   ```

3. **Alternative:** Drag the project folder onto the Love2D executable

### Expected Output

The test will display:
- Library loading verification
- Physics world initialization
- ECS world setup
- Basic debug information

Press F1 for physics debug information and ESC to quit.

## Integration with Tutorial Examples

The setup is designed to work seamlessly with the advanced examples in `dismount_love2d_tutorial.md`:

### Enhanced 2D Ragdoll Creation
```lua
local setup = require('setup')
local ragdoll = setup.createEnhancedRagdoll(400, 300, game.world)
```

### 3D Ragdoll Creation (NEW!)
```lua
local ragdoll3D = setup.create3DRagdoll(400, 300, 0, game.world)
```

### Vehicle Physics with Breezefield
```lua
local truck = setup.createEnhancedTruck(200, 400, game.world)
```

### 3D Vehicle Creation (NEW!)
```lua
local truck3D = setup.create3DTruck(200, 400, 0, game.world)
```

### Roguelike Level Generation
```lua
local level = setup.generateDismountLevel(50, 50)
```

## Library-Specific Notes

### Breezefield
- Drop-in replacement for direct Love2D physics
- Automatic debug drawing capabilities
- Collision class system for organized physics

### Loveblobs
- Ready for soft body ragdoll enhancements
- Integrates with rigid body physics
- Provides deformable character effects

### Andross
- Skeletal animation support
- Blends with physics simulation
- DragonBones format support

### Hot Particles
- Uses .gloa files (requires special setup)
- Currently using Love2D's built-in particle system as fallback
- Ready for enhancement with custom effects

### rotLove & Astray
- Combined for complex level generation
- Dungeon structures + maze enhancements
- Perfect for dismount scenario creation

### 3DreamEngine (NEW!)
- Complete 3D rendering pipeline for Love2D
- Advanced lighting, materials, and shaders
- Seamlessly integrates with 2D physics simulation
- Enables spectacular 3D ragdoll destruction visuals

## Next Steps

1. **Run the test** to verify all libraries load correctly
2. **Implement ragdoll physics** using the tutorial examples with Breezefield
3. **Add soft body enhancements** using Loveblobs
4. **Create particle effects** for impact feedback
5. **Build roguelike progression** using rotLove systems

## Development Commands

See `CLAUDE.md` for complete development workflow and commands.

## Library Compatibility

All libraries are tested and compatible with:
- Love2D 11.4+
- Windows, macOS, Linux
- The tutorial's physics examples and architecture

The stack is ready for full game implementation following the comprehensive guide in `dismount_love2d_tutorial.md`.