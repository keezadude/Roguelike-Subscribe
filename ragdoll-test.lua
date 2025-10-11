-- ragdoll-test.lua
-- Week 2 Ragdoll Physics Test
-- Test multi-body ragdoll with joints and collision

print("=== Week 2 Ragdoll Test Starting ===")

-- Load required modules
local PhysicsWorld = require('src.physics.world')
local PhysicsRenderer = require('src.debug.physics-renderer')
local Ragdoll = require('src.entities.ragdoll')
local Wall = require('src.entities.wall')

-- Game state
local game = {
    physicsWorld = nil,
    debugRenderer = nil,
    ragdolls = {},
    walls = {},
    paused = false,
    debugEnabled = true,
    spawnMode = "single",  -- "single" or "multiple"
    gravity = 9.81 * 64    -- Gravity enabled for ragdolls
}

function love.load()
    print("\n=== Initializing Ragdoll Test ===")
    
    -- Window setup
    love.window.setTitle("Week 2: Ragdoll Physics Test")
    love.window.setMode(1280, 720, {
        vsync = 1,
        resizable = false
    })
    
    -- Create physics world WITH GRAVITY (ragdolls need it)
    game.physicsWorld = PhysicsWorld:new(0, game.gravity, {
        pixelScale = 64,
        timeStep = 1/60
    })
    print("✓ Physics world created with gravity:", game.gravity)
    
    -- Create debug renderer
    game.debugRenderer = PhysicsRenderer:new(game.physicsWorld, {
        showBodies = true,
        showVelocities = false,
        showStats = true,
        showAABB = false,
        showCenterOfMass = false
    })
    game.debugRenderer:setEnabled(true)
    print("✓ Debug renderer created")
    
    -- Create test environment
    createTestEnvironment()
    
    -- Spawn initial ragdoll
    spawnRagdoll(640, 100)
    
    print("\n✓ Ragdoll test initialized successfully!")
    print("\nControls:")
    print("  LEFT CLICK - Spawn ragdoll at cursor")
    print("  RIGHT CLICK - Apply explosion force")
    print("  SPACE - Spawn ragdoll at random position")
    print("  C - Clear all ragdolls")
    print("  F1 - Toggle physics debug")
    print("  F2 - Toggle velocities")
    print("  G - Toggle gravity")
    print("  R - Reset test")
    print("  ESC - Pause/Quit")
    print("\nTarget: Realistic ragdoll physics with joints")
end

function createTestEnvironment()
    --[[
        Create test environment with ground and platforms
    ]]
    
    print("\n=== Creating Test Environment ===")
    
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Ground
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        screenWidth / 2, screenHeight - 20, 
        screenWidth, 40, 
        {color = {0.3, 0.5, 0.3}, pattern = "solid"}))
    
    -- Left wall
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        20, screenHeight / 2, 
        40, screenHeight, 
        {color = {0.5, 0.5, 0.5}, pattern = "brick"}))
    
    -- Right wall
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        screenWidth - 20, screenHeight / 2, 
        40, screenHeight, 
        {color = {0.5, 0.5, 0.5}, pattern = "brick"}))
    
    -- Platform 1 (left)
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        200, 400, 
        150, 20, 
        {color = {0.6, 0.4, 0.2}, pattern = "solid"}))
    
    -- Platform 2 (right)
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        screenWidth - 200, 400, 
        150, 20, 
        {color = {0.6, 0.4, 0.2}, pattern = "solid"}))
    
    -- Platform 3 (center, lower)
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        screenWidth / 2, 550, 
        200, 20, 
        {color = {0.6, 0.4, 0.2}, pattern = "solid"}))
    
    print(string.format("✓ Created %d environmental objects", #game.walls))
end

function spawnRagdoll(x, y)
    --[[
        Spawn a new ragdoll at position
    ]]
    
    local ragdoll = Ragdoll:new(game.physicsWorld, x, y, {
        health = 100
    })
    
    table.insert(game.ragdolls, ragdoll)
    
    print(string.format("Spawned ragdoll #%d at (%.0f, %.0f)", #game.ragdolls, x, y))
end

function clearRagdolls()
    --[[
        Remove all ragdolls
    ]]
    
    for _, ragdoll in ipairs(game.ragdolls) do
        ragdoll:destroy()
    end
    
    game.ragdolls = {}
    print("Cleared all ragdolls")
end

function applyExplosion(x, y, force)
    --[[
        Apply explosive force to all ragdolls
        
        @param x, y: Explosion center
        @param force: Force magnitude
    ]]
    
    for _, ragdoll in ipairs(game.ragdolls) do
        for partName, body in pairs(ragdoll.parts) do
            local bx, by = body:getPosition()
            local dx = bx - x
            local dy = by - y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < 300 then  -- Explosion radius
                local magnitude = force * (1 - distance / 300)
                local angle = math.atan2(dy, dx)
                
                local fx = math.cos(angle) * magnitude
                local fy = math.sin(angle) * magnitude
                
                body:applyLinearImpulse(fx, fy)
            end
        end
    end
    
    print(string.format("Explosion at (%.0f, %.0f) with force %.0f", x, y, force))
end

function love.update(dt)
    if game.paused then
        return
    end
    
    -- Update physics world
    game.physicsWorld:update(dt)
    
    -- Update ragdolls
    for i = #game.ragdolls, 1, -1 do
        local ragdoll = game.ragdolls[i]
        ragdoll:update(dt)
        
        -- Remove dead ragdolls after a delay
        if not ragdoll.alive then
            -- Keep for visual feedback, remove later
        end
    end
    
    -- Update walls
    for _, wall in ipairs(game.walls) do
        wall:update(dt)
    end
end

function love.draw()
    -- Clear screen
    love.graphics.clear(0.15, 0.15, 0.2)
    
    -- Draw grid background
    drawGrid()
    
    -- Draw walls
    for _, wall in ipairs(game.walls) do
        wall:draw()
    end
    
    -- Draw ragdolls
    for _, ragdoll in ipairs(game.ragdolls) do
        ragdoll:draw()
    end
    
    -- Draw physics debug overlay
    if game.debugRenderer then
        game.debugRenderer:draw()
    end
    
    -- Draw UI
    drawUI()
    
    -- Draw pause overlay
    if game.paused then
        drawPauseOverlay()
    end
end

function drawGrid()
    --[[
        Draw background grid
    ]]
    
    love.graphics.setColor(0.2, 0.2, 0.25, 0.3)
    love.graphics.setLineWidth(1)
    
    local gridSize = 64
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    for x = 0, width, gridSize do
        love.graphics.line(x, 0, x, height)
    end
    
    for y = 0, height, gridSize do
        love.graphics.line(0, y, width, y)
    end
end

function drawUI()
    --[[
        Draw test UI information
    ]]
    
    local y = love.graphics.getHeight() - 100
    
    -- Background panel
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 10, y, 300, 90)
    
    -- Info text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Ragdolls: %d", #game.ragdolls), 20, y + 10)
    love.graphics.print(string.format("Bodies: %d", game.physicsWorld:getStats().bodies), 20, y + 30)
    love.graphics.print(string.format("Gravity: %.0f", game.gravity), 20, y + 50)
    
    -- Instructions
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Click to spawn | Space = random | C = clear", 20, y + 70)
end

function drawPauseOverlay()
    --[[
        Draw pause screen
    ]]
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    local pauseText = "PAUSED"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(pauseText)
    local x = (love.graphics.getWidth() - textWidth) / 2
    local y = love.graphics.getHeight() / 2
    
    love.graphics.print(pauseText, x, y)
    love.graphics.print("Press ESC to resume or Q to quit", x - 50, y + 30)
end

function love.keypressed(key)
    if key == "escape" then
        if game.paused then
            game.paused = false
        else
            game.paused = true
        end
    elseif key == "q" and game.paused then
        love.event.quit()
    elseif key == "f1" then
        game.debugRenderer:toggle()
    elseif key == "f2" then
        game.debugRenderer:toggleOption("velocities")
    elseif key == "f3" then
        game.debugRenderer:toggleOption("aabb")
    elseif key == "space" then
        -- Spawn ragdoll at random position
        local x = love.math.random(200, love.graphics.getWidth() - 200)
        local y = love.math.random(50, 200)
        spawnRagdoll(x, y)
    elseif key == "c" then
        -- Clear all ragdolls
        clearRagdolls()
    elseif key == "g" then
        -- Toggle gravity
        if game.gravity > 0 then
            game.gravity = 0
        else
            game.gravity = 9.81 * 64
        end
        game.physicsWorld:setGravity(0, game.gravity)
        print("Gravity:", game.gravity)
    elseif key == "r" then
        -- Reset test
        clearRagdolls()
        spawnRagdoll(640, 100)
        print("Test reset")
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        -- Left click - spawn ragdoll
        spawnRagdoll(x, y)
    elseif button == 2 then
        -- Right click - explosion
        applyExplosion(x, y, 5000)
    end
end

print("\nragdoll-test.lua loaded successfully!")
print("Run with: love . (after renaming to main.lua)")
