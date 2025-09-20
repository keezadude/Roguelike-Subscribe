-- setup.lua
-- Configuration and setup functions for the Dismount Roguelike library stack
-- Provides integration helpers for the tutorial's advanced ragdoll examples

local setup = {}

-- Import required libraries (ensure main.lua is loaded first)
local game = _G.game or require('main')

-- Configuration constants
local CONFIG = {
    -- Physics settings (compatible with tutorial examples)
    PHYSICS = {
        GRAVITY = 9.81 * 64, -- 64 pixels = 1 meter (tutorial standard)
        WORLD_SCALE = 64,    -- pixels per meter
        VELOCITY_ITERATIONS = 6,
        POSITION_ITERATIONS = 2
    },

    -- Ragdoll settings for tutorial integration
    RAGDOLL = {
        MASS_SCALE = 0.1,    -- Scaling factor for realistic masses
        RESTITUTION = 0.2,   -- Bounciness
        FRICTION = 0.7,      -- Surface friction
        JOINT_LIMITS = {
            NECK = {-math.pi/3, math.pi/3},      -- ±60 degrees
            SHOULDER = {-math.pi, math.pi},       -- Full rotation
            ELBOW = {0, math.pi * 0.8},          -- Natural elbow range
            HIP = {-math.pi/2, math.pi/3},       -- Walking range
            KNEE = {-math.pi * 0.8, 0}           -- Knee bend
        }
    },

    -- Collision categories for ragdoll self-collision prevention
    COLLISION_CATEGORIES = {
        RAGDOLL = 1,
        ENVIRONMENT = 2,
        VEHICLE = 4,
        DEBRIS = 8
    }
}

-- Initialize physics world with Breezefield (tutorial compatible)
function setup.initPhysicsWorld()
    local world = game.libs.breezefield.newWorld(0, CONFIG.PHYSICS.GRAVITY)

    -- Set physics iterations for performance (from tutorial)
    world:setVelocityIterations(CONFIG.PHYSICS.VELOCITY_ITERATIONS)
    world:setPositionIterations(CONFIG.PHYSICS.POSITION_ITERATIONS)

    -- Set collision callbacks for damage calculation
    world:setCallbacks(
        setup.beginContact,
        setup.endContact,
        nil, -- pre-solve
        nil  -- post-solve
    )

    return world
end

-- Collision callbacks for damage system integration
function setup.beginContact(a, b, collision)
    -- This will integrate with the tutorial's damage calculation system
    local userDataA = a:getUserData()
    local userDataB = b:getUserData()

    -- Example: Detect ragdoll-environment collisions for damage
    if (userDataA and string.match(userDataA, "ragdoll_")) or
       (userDataB and string.match(userDataB, "ragdoll_")) then
        -- Calculate impact damage (from tutorial)
        -- local damage = DamageSystem:calculateImpactDamage(a:getBody(), b:getBody(), collision)
        print("Ragdoll collision detected - ready for damage calculation")
    end
end

function setup.endContact(a, b, collision)
    -- Handle collision end events
end

-- Enhanced ragdoll creation using Breezefield + Loveblobs
-- Integrates with tutorial's createAdvancedRagdoll function
function setup.createEnhancedRagdoll(x, y, world)
    local ragdoll = {
        parts = {},
        joints = {},
        softBodies = {} -- For Loveblobs integration
    }

    -- Body part definitions (from tutorial)
    local partDefs = {
        head = {w=24, h=24, mass=4.5, type="circle"},
        torso = {w=30, h=50, mass=25, type="rect"},
        upperArm_L = {w=12, h=25, mass=3.5, type="rect"},
        upperArm_R = {w=12, h=25, mass=3.5, type="rect"},
        lowerArm_L = {w=10, h=20, mass=2.5, type="rect"},
        lowerArm_R = {w=10, h=20, mass=2.5, type="rect"},
        upperLeg_L = {w=15, h=30, mass=8, type="rect"},
        upperLeg_R = {w=15, h=30, mass=8, type="rect"},
        lowerLeg_L = {w=12, h=28, mass=6, type="rect"},
        lowerLeg_R = {w=12, h=28, mass=6, type="rect"}
    }

    -- Create rigid body parts using Breezefield
    for name, def in pairs(partDefs) do
        local part = {}

        if def.type == "circle" then
            part = world:newCircleCollider(x, y, def.w/2)
        else
            part = world:newRectangleCollider(x, y, def.w, def.h)
        end

        part:setType("dynamic")
        part:setMass(def.mass * CONFIG.RAGDOLL.MASS_SCALE)
        part:setRestitution(CONFIG.RAGDOLL.RESTITUTION)
        part:setFriction(CONFIG.RAGDOLL.FRICTION)
        part:setUserData("ragdoll_" .. name)

        -- Set collision filtering to prevent self-collision
        part:setCollisionClass("ragdoll")

        ragdoll.parts[name] = part
    end

    -- Position body parts anatomically (from tutorial)
    ragdoll.parts.head:setPosition(x, y - 35)
    ragdoll.parts.torso:setPosition(x, y)
    ragdoll.parts.upperArm_L:setPosition(x - 20, y - 15)
    ragdoll.parts.upperArm_R:setPosition(x + 20, y - 15)
    -- ... continue positioning other parts

    -- Create joints with realistic constraints (from tutorial)
    setup.connectRagdollJoints(ragdoll, world)

    -- Add soft body enhancements using Loveblobs
    -- ragdoll.softBodies = setup.addSoftBodyFeatures(ragdoll)

    return ragdoll
end

-- Joint creation with tutorial constraints
function setup.connectRagdollJoints(ragdoll, world)
    local joints = ragdoll.joints
    local parts = ragdoll.parts

    -- Neck joint
    joints.neck = love.physics.newRevoluteJoint(
        parts.head:getBody(), parts.torso:getBody(),
        parts.torso:getX(), parts.torso:getY() - 25,
        false
    )
    joints.neck:setLimitsEnabled(true)
    joints.neck:setLimits(unpack(CONFIG.RAGDOLL.JOINT_LIMITS.NECK))

    -- Shoulder joints
    joints.shoulder_L = love.physics.newRevoluteJoint(
        parts.torso:getBody(), parts.upperArm_L:getBody(),
        parts.torso:getX() - 15, parts.torso:getY() - 15,
        false
    )
    joints.shoulder_L:setLimitsEnabled(true)
    joints.shoulder_L:setLimits(unpack(CONFIG.RAGDOLL.JOINT_LIMITS.SHOULDER))

    -- Continue with other joints following tutorial pattern...
end

-- Soft body enhancement using Loveblobs
function setup.addSoftBodyFeatures(ragdoll)
    local softBodies = {}

    -- Create soft body representations for deformable effects
    for name, part in pairs(ragdoll.parts) do
        if name == "torso" then -- Example: make torso deformable
            local x, y = part:getPosition()
            local softBody = game.libs.loveblobs.SoftBody(x, y, 30, 50)
            softBodies[name] = softBody
        end
    end

    return softBodies
end

-- Truck creation using Breezefield (tutorial compatible)
function setup.createEnhancedTruck(x, y, world)
    local truck = {}

    -- Main truck body
    truck.body = world:newRectangleCollider(x, y, 120, 60)
    truck.body:setType("dynamic")
    truck.body:setMass(2000) -- 2-ton truck (from tutorial)
    truck.body:setRestitution(0.3)
    truck.body:setFriction(0.5)
    truck.body:setUserData("truck")
    truck.body:setCollisionClass("vehicle")

    -- Wheels for realistic driving physics
    truck.wheels = {}
    for i = 1, 4 do
        local wheelX = x + (i <= 2 and -40 or 40)
        local wheelY = y + (i % 2 == 1 and -25 or 25)

        truck.wheels[i] = world:newCircleCollider(wheelX, wheelY, 12)
        truck.wheels[i]:setMass(50)
        truck.wheels[i]:setFriction(2.0) -- High grip
        truck.wheels[i]:setUserData("wheel")
        truck.wheels[i]:setCollisionClass("vehicle")
    end

    return truck
end

-- ECS System setup for tutorial integration
function setup.initECSSystems()
    local ecsWorld = game.ecsWorld

    -- Physics system for updating Box2D world
    local PhysicsSystem = game.libs.tiny.processingSystem()
    PhysicsSystem.filter = game.libs.tiny.requireAll("physics")
    function PhysicsSystem:process(entity, dt)
        -- Process physics entities
    end

    -- Damage system for tutorial scoring
    local DamageSystem = game.libs.tiny.processingSystem()
    DamageSystem.filter = game.libs.tiny.requireAll("ragdoll", "damage")
    function DamageSystem:process(entity, dt)
        -- Calculate damage and scoring
    end

    -- Camera system for following action
    local CameraSystem = game.libs.tiny.processingSystem()
    CameraSystem.filter = game.libs.tiny.requireAll("transform", "cameraTarget")
    function CameraSystem:process(entity, dt)
        -- Update camera following
    end

    -- Add systems to ECS world
    ecsWorld:addSystem(PhysicsSystem)
    ecsWorld:addSystem(DamageSystem)
    ecsWorld:addSystem(CameraSystem)

    return ecsWorld
end

-- Roguelike level generation using rotLove + Astray
function setup.generateDismountLevel(width, height)
    -- Use rotLove for basic dungeon structure
    local dungeon = game.libs.rot.Map.Digger(width, height)
    local level = {}

    -- Generate base level structure
    dungeon:create(function(x, y, value)
        if not level[x] then level[x] = {} end
        level[x][y] = value -- 0 = floor, 1 = wall
    end)

    -- Enhance with Astray for maze-like obstacles
    local astrayMap = game.libs.astray.Astray:new(width, height)
    astrayMap:generate()

    -- Combine both generators for complex dismount scenarios
    return {
        dungeon = level,
        maze = astrayMap,
        obstacles = setup.placeObstacles(level, width, height)
    }
end

-- Place physics obstacles for dismount scenarios
function setup.placeObstacles(level, width, height)
    local obstacles = {}
    -- Place ramps, walls, and destructible objects based on level data
    return obstacles
end

-- Particle system setup for impact effects
function setup.initParticleEffects()
    -- Note: Hot Particles uses .gloa files and requires special setup
    -- For now, use Love2D's built-in particle system
    local particleSystems = {}

    -- Impact particles
    local texture = love.graphics.newCanvas(4, 4)
    love.graphics.setCanvas(texture)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 4, 4)
    love.graphics.setCanvas()

    particleSystems.impact = love.graphics.newParticleSystem(texture, 100)
    particleSystems.impact:setParticleLifetime(0.5, 1.0)
    particleSystems.impact:setEmissionRate(50)
    particleSystems.impact:setSpeed(50, 100)
    particleSystems.impact:setColors(1, 0.8, 0.2, 1, 1, 0.2, 0.2, 0)

    return particleSystems
end

-- Animation setup using Andross
function setup.initAnimationSystem()
    -- Andross setup for skeletal animation
    local animationManager = game.libs.andross.AnimationManager()

    -- This would load skeleton data for character animations
    -- that blend with physics simulation

    return animationManager
end

-- 3D Engine Integration Functions
function setup.init3DEngine()
    if not game.libs.dream3d then
        print("3DreamEngine not available - cannot initialize 3D mode")
        return false
    end

    local dream = game.libs.dream3d

    -- Initialize 3DreamEngine with basic settings
    dream:init()

    -- Set up basic 3D scene
    dream:setAmbientLight(0.3, 0.3, 0.4)
    dream:setSun(love.math.normalize(1, 2, 1), {1.0, 0.9, 0.8}, 5.0)

    -- Create basic camera for 3D ragdoll viewing
    game.camera3D = dream:newCamera()
    game.camera3D:translate(0, 5, 10)
    game.camera3D:lookAt(0, 0, 0)

    print("✓ 3DreamEngine initialized successfully")
    return true
end

-- Enhanced 3D ragdoll creation (extends 2D version)
function setup.create3DRagdoll(x, y, z, world)
    if not game.libs.dream3d then
        print("Warning: 3DreamEngine not available, falling back to 2D ragdoll")
        return setup.createEnhancedRagdoll(x, y, world)
    end

    local dream = game.libs.dream3d
    local ragdoll = {
        parts3D = {},    -- 3D visual components
        parts2D = {},    -- 2D physics components (for physics simulation)
        joints = {}
    }

    -- For now, we use 2D physics but 3D rendering
    -- Create 2D physics bodies for simulation
    ragdoll.parts2D = setup.createEnhancedRagdoll(x, y, world)

    -- Create 3D visual representation
    local partDefs = {
        head = {w=0.24, h=0.24, d=0.24, mesh="sphere"},
        torso = {w=0.30, h=0.50, d=0.20, mesh="box"},
        upperArm_L = {w=0.12, h=0.25, d=0.12, mesh="capsule"},
        upperArm_R = {w=0.12, h=0.25, d=0.12, mesh="capsule"},
        lowerArm_L = {w=0.10, h=0.20, d=0.10, mesh="capsule"},
        lowerArm_R = {w=0.10, h=0.20, d=0.10, mesh="capsule"},
        upperLeg_L = {w=0.15, h=0.30, d=0.15, mesh="capsule"},
        upperLeg_R = {w=0.15, h=0.30, d=0.15, mesh="capsule"},
        lowerLeg_L = {w=0.12, h=0.28, d=0.12, mesh="capsule"},
        lowerLeg_R = {w=0.12, h=0.28, d=0.12, mesh="capsule"}
    }

    -- Create 3D objects for each body part
    for name, def in pairs(partDefs) do
        local object3D = dream:newObject()

        -- Create appropriate mesh
        if def.mesh == "sphere" then
            object3D:setMesh(dream:newSphere(def.w/2, 16))
        elseif def.mesh == "box" then
            object3D:setMesh(dream:newBox(def.w, def.h, def.d))
        elseif def.mesh == "capsule" then
            object3D:setMesh(dream:newCapsule(def.w/2, def.h, 8))
        end

        -- Set basic material
        local material = dream:newMaterial()
        material:setAlbedo(0.8, 0.6, 0.4) -- Skin-like color
        material:setRoughness(0.7)
        object3D:setMaterial(material)

        ragdoll.parts3D[name] = object3D
    end

    return ragdoll
end

-- 3D vehicle creation
function setup.create3DTruck(x, y, z, world)
    if not game.libs.dream3d then
        print("Warning: 3DreamEngine not available, falling back to 2D truck")
        return setup.createEnhancedTruck(x, y, world)
    end

    local dream = game.libs.dream3d
    local truck = {
        body3D = nil,     -- 3D visual
        body2D = nil,     -- 2D physics
        wheels3D = {},
        wheels2D = {}
    }

    -- Create 2D physics for simulation
    truck.body2D = setup.createEnhancedTruck(x, y, world)

    -- Create 3D visual representation
    truck.body3D = dream:newObject()
    truck.body3D:setMesh(dream:newBox(1.2, 0.6, 0.8)) -- Truck body

    local truckMaterial = dream:newMaterial()
    truckMaterial:setAlbedo(0.8, 0.2, 0.2) -- Red truck
    truckMaterial:setMetallic(0.9)
    truck.body3D:setMaterial(truckMaterial)

    -- Create 3D wheels
    for i = 1, 4 do
        local wheel3D = dream:newObject()
        wheel3D:setMesh(dream:newCylinder(0.12, 0.08, 12))

        local wheelMaterial = dream:newMaterial()
        wheelMaterial:setAlbedo(0.1, 0.1, 0.1) -- Black wheels
        wheelMaterial:setRoughness(0.9)
        wheel3D:setMaterial(wheelMaterial)

        truck.wheels3D[i] = wheel3D
    end

    return truck
end

-- 3D-specific update function
function setup.update3DObjects(dt)
    if not game.is3D or not game.libs.dream3d then return end

    -- Sync 3D visual objects with 2D physics bodies
    -- This would update 3D object positions based on 2D physics simulation

    -- Update 3DreamEngine
    game.libs.dream3d:update(dt)
end

-- 3D rendering function
function setup.render3D()
    if not game.is3D or not game.libs.dream3d then return end

    local dream = game.libs.dream3d

    -- Set camera
    if game.camera3D then
        dream:setCamera(game.camera3D)
    end

    -- Render 3D scene
    dream:draw()
end

-- Export configuration and functions
setup.CONFIG = CONFIG

-- Setup functions for easy integration
setup.init = function()
    -- Initialize all systems
    game.world = setup.initPhysicsWorld()
    game.ecsWorld = setup.initECSSystems()
    game.particles = setup.initParticleEffects()
    game.animations = setup.initAnimationSystem()

    -- Initialize 3D engine if available
    if game.libs.dream3d then
        setup.init3DEngine()
    end

    -- Set up collision classes for Breezefield
    if game.world then
        game.world:addCollisionClass("ragdoll")
        game.world:addCollisionClass("vehicle")
        game.world:addCollisionClass("environment")
        game.world:addCollisionClass("debris")

        -- Configure collision rules
        game.world:setCollisionClass("ragdoll", {ignores = {"ragdoll"}}) -- Prevent self-collision
    end

    print("Setup complete - all systems initialized!")
    print("3D Mode:", game.is3D and "Enabled" or "Disabled")
end

return setup