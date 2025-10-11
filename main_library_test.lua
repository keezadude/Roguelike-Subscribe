-- main.lua
-- Dismount Roguelike - Library Test (Minimal Version)

print("Starting Dismount Roguelike Library Test...")

-- Global game state
local game = {
    libs = {},
    loadedCount = 0
}

-- Safe require function with detailed error reporting
local function safeRequire(path, name)
    print(string.format("Attempting to load %s from '%s'...", name, path))
    local success, result = pcall(require, path)
    if success then
        print("✓ Successfully loaded:", name)
        game.loadedCount = game.loadedCount + 1
        return result
    else
        print("✗ Failed to load", name)
        print("  Error:", result)
        return nil
    end
end

print("\n=== Loading Core Libraries ===")

-- Test tiny-ecs first (most important for architecture)
game.libs.tiny = safeRequire('lib.tiny-ecs.tiny', 'tiny-ecs')

-- Test Hump utilities
game.libs.vector = safeRequire('lib.hump.vector', 'hump.vector')
game.libs.timer = safeRequire('lib.hump.timer', 'hump.timer')
game.libs.camera = safeRequire('lib.hump.camera', 'hump.camera')

-- Test Breezefield physics
game.libs.breezefield = safeRequire('lib.breezefield', 'breezefield')

print("\n=== Loading UI & Animation Libraries ===")

-- Week 0 Day 1: UI Foundation
game.libs.slab = safeRequire('lib.Slab', 'Slab UI')
game.libs.flux = safeRequire('lib.flux', 'flux animation')

print("\n=== Loading Additional Libraries ===")

-- Test other libraries with corrected paths
game.libs.rot = safeRequire('lib.rotLove.src.rot', 'rotLove')
game.libs.astray = safeRequire('lib.astray.astray', 'astray')
game.libs.loveblobs = safeRequire('lib.loveblobs', 'loveblobs')  -- Use wrapper
game.libs.andross = safeRequire('lib.andross', 'andross')        -- Use wrapper

print("\n=== Loading 3D Engine ===")

-- 3D rendering engine for advanced 3D ragdoll physics
game.libs.dream3d = safeRequire('lib.3DreamEngine', '3DreamEngine')

print(string.format("\n=== Load Summary: %d libraries loaded ===", game.loadedCount))

-- Love2D functions
function love.load()
    print("\n=== Love2D Initialization ===")

    -- Initialize Slab UI (Week 0 Day 1)
    if game.libs.slab then
        game.libs.slab.Initialize()
        print("✓ Slab UI initialized")
    end

    -- Initialize flux animation test (Week 0 Day 1)
    if game.libs.flux then
        game.testAnim = {value = 0}
        game.libs.flux.to(game.testAnim, 2.0, {value = 100}):ease("quadinout")
        print("✓ flux test animation started")
    end

    -- Initialize systems based on what loaded successfully
    if game.libs.breezefield then
        game.world = game.libs.breezefield.newWorld(0, 9.81 * 64)
        print("✓ Physics world created")
    end

    if game.libs.tiny then
        game.ecsWorld = game.libs.tiny.world()
        print("✓ ECS world created")
    end

    if game.libs.camera then
        game.camera = game.libs.camera(640, 360)
        print("✓ Camera created")
    end

    -- Initialize 3D engine if available
    if game.libs.dream3d then
        print("✓ 3DreamEngine ready for 3D rendering")
        game.is3D = true
    else
        print("✗ 3DreamEngine not available - staying in 2D mode")
        game.is3D = false
    end

    print("✓ Initialization complete")
    print("Mode:", game.is3D and "3D" or "2D")
end

function love.update(dt)
    -- Update Slab UI (Week 0 Day 1)
    if game.libs.slab then
        game.libs.slab.Update(dt)
    end

    -- Update flux animations (Week 0 Day 1)
    if game.libs.flux then
        game.libs.flux.update(dt)
    end

    -- Update systems if available
    if game.world and game.world.update then
        game.world:update(dt)
    end

    if game.ecsWorld and game.ecsWorld.update then
        game.ecsWorld:update(dt)
    end
end

function love.draw()
    -- Clear screen
    love.graphics.clear(0.1, 0.1, 0.2)

    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Dismount Roguelike - Library Test", 10, 10)
    love.graphics.print(string.format("Loaded: %d libraries", game.loadedCount), 10, 30)

    -- Show library status
    local y = 60
    local libraries = {
        {"Slab UI", game.libs.slab},
        {"flux animation", game.libs.flux},
        {"tiny-ecs", game.libs.tiny},
        {"hump.vector", game.libs.vector},
        {"hump.timer", game.libs.timer},
        {"hump.camera", game.libs.camera},
        {"breezefield", game.libs.breezefield},
        {"rotLove", game.libs.rot},
        {"astray", game.libs.astray},
        {"loveblobs", game.libs.loveblobs},
        {"andross", game.libs.andross},
        {"3DreamEngine", game.libs.dream3d}
    }

    for _, lib in ipairs(libraries) do
        local name, loaded = lib[1], lib[2]
        if loaded then
            love.graphics.setColor(0, 1, 0) -- Green for success
            love.graphics.print("✓ " .. name, 10, y)
        else
            love.graphics.setColor(1, 0, 0) -- Red for failure
            love.graphics.print("✗ " .. name, 10, y)
        end
        y = y + 20
    end

    -- Week 0 flux animation test
    if game.libs.flux and game.testAnim then
        love.graphics.setColor(0.5, 0.8, 1)
        love.graphics.print(string.format("flux test: %.1f/100", game.testAnim.value), 10, y + 20)
        love.graphics.rectangle("fill", 10, y + 40, game.testAnim.value * 2, 10)
    end

    -- Instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Press F1 for debug info, ESC to quit", 10, y + 60)

    -- Draw physics debug if available
    if game.camera then
        game.camera:attach()

        if game.world and game.world.draw then
            love.graphics.setColor(0, 1, 0, 0.3)
            game.world:draw('line')
        end

        game.camera:detach()
    end

    -- Draw Slab UI (Week 0 Day 1)
    if game.libs.slab then
        game.libs.slab.Draw()
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f1" then
        print("\n=== Debug Info ===")
        print("Total libraries loaded:", game.loadedCount)
        for name, lib in pairs(game.libs) do
            print(string.format("  %s: %s", name, lib and "loaded" or "failed"))
        end

        -- Test basic functionality
        if game.libs.tiny then
            print("  tiny-ecs type:", type(game.libs.tiny))
        end
        if game.libs.breezefield then
            print("  breezefield type:", type(game.libs.breezefield))
        end
    end
end

-- Export game for debugging
_G.game = game

print("Main.lua loaded successfully!")
return game