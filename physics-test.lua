-- physics-test.lua
-- Week 1 Physics Foundation Test
-- Standalone test for physics world, player, and walls

print("=== Week 1 Physics Test Starting ===")

-- Load required modules
local PhysicsWorld = require('src.physics.world')
local PhysicsRenderer = require('src.debug.physics-renderer')
local Player = require('src.entities.player')
local Wall = require('src.entities.wall')

-- Game state
local game = {
    physicsWorld = nil,
    debugRenderer = nil,
    player = nil,
    walls = {},
    paused = false,
    debugEnabled = true
}

function love.load()
    print("\n=== Initializing Physics Test ===")
    
    -- Window setup
    love.window.setTitle("Week 1: Physics Foundation Test")
    love.window.setMode(1280, 720, {
        vsync = 1,
        resizable = false
    })
    
    -- Create physics world (no gravity for top-down)
    game.physicsWorld = PhysicsWorld:new(0, 0, {
        pixelScale = 64,
        timeStep = 1/60
    })
    print("✓ Physics world created")
    
    -- Create debug renderer
    game.debugRenderer = PhysicsRenderer:new(game.physicsWorld, {
        showBodies = true,
        showVelocities = true,
        showStats = true,
        showAABB = false,
        showCenterOfMass = false
    })
    game.debugRenderer:setEnabled(true)
    print("✓ Debug renderer created")
    
    -- Create player in center
    local centerX = love.graphics.getWidth() / 2
    local centerY = love.graphics.getHeight() / 2
    
    game.player = Player:new(game.physicsWorld, centerX, centerY, {
        moveSpeed = 300,
        maxSpeed = 200,
        radius = 20,
        color = {0.2, 0.8, 1.0}
    })
    print("✓ Player created at", centerX, centerY)
    
    -- Create test arena with walls
    createTestArena()
    
    print("\n✓ Physics test initialized successfully!")
    print("\nControls:")
    print("  WASD/Arrows - Move player")
    print("  F1 - Toggle physics debug")
    print("  F2 - Toggle velocities")
    print("  F3 - Toggle AABB")
    print("  R - Reset player position")
    print("  ESC - Pause/Quit")
    print("\nTarget: 60 FPS with smooth collisions")
end

function createTestArena()
    --[[
        Create a test arena with walls
    ]]
    
    print("\n=== Creating Test Arena ===")
    
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local wallThickness = 32
    
    -- Boundary walls
    -- Top wall
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        screenWidth / 2, wallThickness / 2, 
        screenWidth, wallThickness, 
        {color = {0.5, 0.5, 0.5}, pattern = "brick"}))
    
    -- Bottom wall
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        screenWidth / 2, screenHeight - wallThickness / 2, 
        screenWidth, wallThickness, 
        {color = {0.5, 0.5, 0.5}, pattern = "brick"}))
    
    -- Left wall
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        wallThickness / 2, screenHeight / 2, 
        wallThickness, screenHeight, 
        {color = {0.5, 0.5, 0.5}, pattern = "brick"}))
    
    -- Right wall
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        screenWidth - wallThickness / 2, screenHeight / 2, 
        wallThickness, screenHeight, 
        {color = {0.5, 0.5, 0.5}, pattern = "brick"}))
    
    -- Interior obstacles
    -- Center pillar
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        screenWidth / 2, screenHeight / 2, 
        64, 64, 
        {color = {0.6, 0.3, 0.2}, pattern = "stone"}))
    
    -- Top-left obstacle
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        200, 150, 
        128, 48, 
        {color = {0.4, 0.4, 0.5}, pattern = "solid"}))
    
    -- Top-right obstacle
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        screenWidth - 200, 150, 
        96, 96, 
        {color = {0.4, 0.5, 0.4}, pattern = "brick"}))
    
    -- Bottom-left obstacle
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        200, screenHeight - 150, 
        96, 96, 
        {color = {0.5, 0.4, 0.4}, pattern = "stone"}))
    
    -- Bottom-right obstacle
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        screenWidth - 200, screenHeight - 150, 
        128, 48, 
        {color = {0.4, 0.4, 0.5}, pattern = "solid"}))
    
    print(string.format("✓ Created %d walls", #game.walls))
end

function love.update(dt)
    if game.paused then
        return
    end
    
    -- Update physics world
    game.physicsWorld:update(dt)
    
    -- Update player
    if game.player then
        game.player:update(dt)
    end
    
    -- Update walls (they're static but included for consistency)
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
    
    -- Draw player
    if game.player then
        game.player:draw()
    end
    
    -- Draw physics debug overlay
    if game.debugRenderer then
        game.debugRenderer:draw()
    end
    
    -- Draw pause overlay
    if game.paused then
        drawPauseOverlay()
    end
end

function drawGrid()
    --[[
        Draw background grid for reference
    ]]
    
    love.graphics.setColor(0.2, 0.2, 0.25, 0.5)
    love.graphics.setLineWidth(1)
    
    local gridSize = 64
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Vertical lines
    for x = 0, width, gridSize do
        love.graphics.line(x, 0, x, height)
    end
    
    -- Horizontal lines
    for y = 0, height, gridSize do
        love.graphics.line(0, y, width, y)
    end
end

function drawPauseOverlay()
    --[[
        Draw pause screen overlay
    ]]
    
    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Pause text
    love.graphics.setColor(1, 1, 1, 1)
    local font = love.graphics.getFont()
    local pauseText = "PAUSED"
    local textWidth = font:getWidth(pauseText)
    local textHeight = font:getHeight()
    
    local x = (love.graphics.getWidth() - textWidth) / 2
    local y = (love.graphics.getHeight() - textHeight) / 2
    
    love.graphics.print(pauseText, x, y)
    
    -- Instructions
    local instructText = "Press ESC to resume or Q to quit"
    local instructWidth = font:getWidth(instructText)
    love.graphics.print(instructText, 
        (love.graphics.getWidth() - instructWidth) / 2, 
        y + 30)
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
    elseif key == "r" then
        -- Reset player position
        local centerX = love.graphics.getWidth() / 2
        local centerY = love.graphics.getHeight() / 2
        game.player:setPosition(centerX, centerY)
        print("Player position reset")
    end
end

print("\nphysics-test.lua loaded successfully!")
print("Run with: love .")
