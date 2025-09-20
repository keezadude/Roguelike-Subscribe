# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Love2D (LÖVE) game project implementing a Truck Dismount-style physics destruction game with roguelike progression elements. The game features ragdoll physics, vehicle dynamics, damage calculation systems, and extensible scoring mechanics designed for long-term player engagement.

## Development Commands

### Running the Game
```bash
# Run the game directly with Love2D
love .

# Or if love is not in PATH on Windows
"C:\Program Files\LOVE\love.exe" .

# Run with console output (useful for debugging)
love . --console
```

### Development Tools
```bash
# Install Love2D dependencies (if using package manager)
# Note: Love2D is typically installed system-wide, not per-project

# For debugging physics, use the integrated debug renderer
# Toggle with F1 key in-game (as per tutorial architecture)
```

### Project Structure Commands
```bash
# Create main Love2D files
touch main.lua conf.lua

# Create core game directories
mkdir src lib assets assets/images assets/sounds assets/fonts

# Create source subdirectories following the tutorial architecture
mkdir src/systems src/entities src/components src/states src/utils
```

## Core Architecture

### Physics-Based Design
The game is built around Love2D's Box2D physics integration with these key systems:

- **Ragdoll Physics**: Complex multi-body character with 10-15 interconnected rigid bodies using revolute joints with realistic constraints
- **Vehicle Dynamics**: Realistic truck physics with mass-based force application and wheel systems
- **Damage System**: Physics-based damage calculation using kinetic energy formulas with body part multipliers
- **Environmental Interaction**: Static and dynamic obstacles with collision-based scoring

### Entity-Component System (ECS)
Uses tiny-ecs library with these core systems:
- `PhysicsSystem`: Handles Box2D world updates and collision detection
- `DamageSystem`: Calculates impact and sustained damage scoring
- `CameraSystem`: Dynamic camera following with shake effects and smooth interpolation
- `ParticleSystem`: Visual effects for impacts and destruction feedback

### State Management
Game uses a modular state system:
- `GameState`: Main gameplay with physics simulation
- `MenuState`: UI navigation and game setup
- `ReplayState`: Playback system for crashes
- `ProgressionState`: Roguelike upgrade and achievement management

### Roguelike Architecture
Extensible progression system designed for complex mechanics:

- **Modular Scoring Engine**: Base scorers with multiplier support for upgrades
- **Persistent Progression**: Save/load system for unlocks, achievements, and meta-progression
- **Achievement System**: Complex condition-based unlocks with rewards
- **Upgrade Framework**: Runtime modifiers that alter core game mechanics

## Key Dependencies

### Required Love2D Libraries
- **Windfield**: Box2D physics wrapper (simplifies physics setup)
- **tiny-ecs**: Entity-component system for game object management
- **Gamera/Camera**: Camera system for following action
- **Json.lua**: Save/load system for progression data

### Physics Configuration
- World scale: 64 pixels = 1 meter for realistic physics calculations
- Gravity: 9.81 * 64 (scaled for pixel coordinates)
- Collision categories used for ragdoll self-collision prevention
- Optimized iteration counts: 6 velocity, 2 position iterations

## Performance Considerations

### Critical Optimizations
- **Collision Filtering**: Aggressive filtering prevents expensive ragdoll self-collisions
- **Object Pooling**: Reuse physics bodies for debris and particle effects
- **Incremental GC**: Run garbage collection every 2 seconds during gameplay
- **Physics Iterations**: Reduced from defaults (8/3 to 6/2) for better performance

### Memory Management
- Monitor memory usage with `collectgarbage("count")`
- Use object pools for frequently created/destroyed physics bodies
- Limit particle systems to 500 active particles maximum

## Debug Features

### Physics Debugging
Toggle debug rendering with F1 key to visualize:
- All physics body shapes and boundaries
- Joint connection points and constraints
- Collision contact points and normals
- Velocity vectors and force applications

### Configuration System
Centralized config table in `src/config.lua` for easy tuning:
- Physics parameters (gravity, damping, mass values)
- Gameplay settings (damage multipliers, combo rates)
- Performance limits (particle counts, iteration limits)

## File Organization

### Core Game Files
- `main.lua`: Love2D entry point with basic game loop
- `conf.lua`: Love2D configuration (window size, physics modules)
- `src/gamestate.lua`: Main game state with physics world setup
- `src/ragdoll.lua`: Advanced ragdoll creation with joint networks
- `src/vehicle.lua`: Truck physics and launch mechanics
- `src/damage.lua`: Impact and sustained damage calculation

### System Files
- `src/systems/physics.lua`: Box2D world management and collision callbacks
- `src/systems/camera.lua`: Dynamic camera following with effects
- `src/systems/scoring.lua`: Extensible scoring engine with modifiers
- `src/systems/progression.lua`: Persistent save/load and achievement tracking

### Roguelike Components
- `src/roguelike/upgrades.lua`: Runtime modifier system for scoring changes
- `src/roguelike/achievements.lua`: Complex condition-based unlock system
- `src/roguelike/progression.lua`: Meta-progression and currency management

## Development Guidelines

### Physics Implementation
- Always use consistent units (64 pixels = 1 meter)
- Set proper collision categories to prevent performance issues
- Use realistic mass ratios (ragdoll ~80kg, truck ~2000kg)
- Test joint limits with realistic human movement ranges

### Code Organization
- Use ECS pattern for all game entities with physics bodies
- Separate physics logic from rendering/UI code
- Keep configuration values in centralized config tables
- Use object pooling for any frequently created objects

### Performance Testing
- Monitor frame rate during complex multi-body physics scenarios
- Test with maximum expected particle counts (crashes generate many particles)
- Verify memory usage doesn't grow during extended play sessions
- Profile physics iteration counts for stable 60fps gameplay