-- gameplay-test.lua
-- Week 3 Core Gameplay Test
-- Complete truck dismount gameplay loop

print("=== Week 3 Gameplay Test Starting ===")

-- Load required modules
local PhysicsWorld = require('src.physics.world')
local PhysicsRenderer = require('src.debug.physics-renderer')
local Vehicle = require('src.entities.vehicle')
local Ragdoll = require('src.entities.ragdoll')
local Wall = require('src.entities.wall')
local DamageCalculator = require('src.systems.damage-calculator')
local ScoreManager = require('src.systems.score-manager')
local SoundManager = require('src.audio.sound-manager')
local ScoreHUD = require('src.ui.score-hud')
local LaunchControl = require('src.ui.launch-control')

-- Game state
local game = {
    -- Core systems
    physicsWorld = nil,
    debugRenderer = nil,
    damageCalc = nil,
    scoreManager = nil,
    soundManager = nil,
    
    -- UI
    scoreHUD = nil,
    launchControl = nil,
    
    -- Entities
    vehicle = nil,
    ragdolls = {},
    walls = {},
    
    -- Game state
    state = "setup",  -- setup, launch, gameplay, results
    paused = false,
    debugEnabled = false,
    
    -- Settings
    gravity = 9.81 * 64,
    ragdollCount = 3
}

function love.load()
    print("\n=== Initializing Gameplay Test ===")
    
    -- Window setup
    love.window.setTitle("Week 3: Core Gameplay Test - Truck Dismount")
    love.window.setMode(1280, 720, {
        vsync = 1,
        resizable = false
    })
    
    -- Create physics world WITH GRAVITY
    game.physicsWorld = PhysicsWorld:new(0, game.gravity, {
        pixelScale = 64,
        timeStep = 1/60
    })
    print("✓ Physics world created")
    
    -- Create debug renderer
    game.debugRenderer = PhysicsRenderer:new(game.physicsWorld, {
        showBodies = false,  -- Start with debug off
        showVelocities = false,
        showStats = true
    })
    print("✓ Debug renderer created")
    
    -- Create game systems
    game.damageCalc = DamageCalculator:new()
    print("✓ Damage calculator created")
    
    game.scoreManager = ScoreManager:new()
    print("✓ Score manager created")
    
    game.soundManager = SoundManager:new()
    print("✓ Sound manager created")
    
    -- Create UI
    game.scoreHUD = ScoreHUD:new(game.scoreManager)
    print("✓ Score HUD created")
    
    game.launchControl = LaunchControl:new({
        onLaunch = function(power)
            launchVehicle(power)
        end
    })
    print("✓ Launch control created")
    
    -- Create test environment
    createTestEnvironment()
    
    -- Spawn vehicle
    spawnVehicle()
    
    -- Spawn ragdolls
    for i = 1, game.ragdollCount do
        spawnRagdoll(400 + i * 150, 500)
    end
    
    -- Set up collision callbacks
    setupCollisionCallbacks()
    
    print("\n✓ Gameplay test initialized!")
    print("\nControls:")
    print("  SPACE (hold) - Charge launch power")
    print("  SPACE (release) - Launch vehicle")
    print("  R - Reset/Retry")
    print("  F1 - Toggle physics debug")
    print("  ESC - Pause/Quit")
    print("\nObjective: Hit ragdolls with the truck for maximum score!")
end

function createTestEnvironment()
    print("\n=== Creating Test Environment ===")
    
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Ground
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        screenWidth / 2, screenHeight - 20, 
        screenWidth * 2, 40, 
        {color = {0.3, 0.5, 0.3}, pattern = "solid"}))
    
    -- Ramp for vehicle
    local ramp = Wall:new(game.physicsWorld, 
        200, screenHeight - 100, 
        200, 20, 
        {color = {0.6, 0.4, 0.2}, pattern = "solid"})
    ramp.body:setAngle(-0.2)  -- Slight angle
    table.insert(game.walls, ramp)
    
    -- Landing platforms
    table.insert(game.walls, Wall:new(game.physicsWorld, 
        800, 600, 
        300, 20, 
        {color = {0.6, 0.4, 0.2}, pattern = "solid"}))
    
    print(string.format("✓ Created %d environmental objects", #game.walls))
end

function spawnVehicle()
    game.vehicle = Vehicle:new(game.physicsWorld, 150, 550, {
        chassisColor = {0.8, 0.2, 0.2}
    })
    print("✓ Vehicle spawned")
end

function spawnRagdoll(x, y)
    local ragdoll = Ragdoll:new(game.physicsWorld, x, y, {
        health = 100
    })
    table.insert(game.ragdolls, ragdoll)
    print(string.format("✓ Ragdoll #%d spawned at (%.0f, %.0f)", #game.ragdolls, x, y))
end

function launchVehicle(power)
    if game.vehicle and game.state == "setup" then
        game.vehicle:launch(power)
        game.state = "gameplay"
        print(string.format("Vehicle launched at %.0f%% power", power * 100))
    end
end

function setupCollisionCallbacks()
    -- Set up proper Breezefield collision callbacks
    if game.vehicle and game.vehicle.chassis then
        local vehicleCollider = game.vehicle.chassis
        
        -- Set up postSolve callback for collision detection
        vehicleCollider.postSolve = function(this, other, contact, normalImpulse, tangentImpulse)
            -- Check if the other collider is a ragdoll part
            if other.userData and other.userData.type == "ragdoll_part" then
                local ragdoll = other.userData.ragdoll
                local partName = other.userData.partName
                
                -- Process collision (this will be called automatically by Breezefield)
                handleVehicleRagdollCollision(partName, ragdoll, contact, normalImpulse)
            end
        end
    end
    
    print("✓ Collision callbacks configured")
end

function checkCollisions()
    --[[
        Check for vehicle-ragdoll collisions
    ]]
    
    if not game.vehicle or game.state ~= "gameplay" then
        return
    end
    
    for _, ragdoll in ipairs(game.ragdolls) do
        for partName, ragdollPart in pairs(ragdoll.parts) do
            -- Check collision with vehicle chassis
            local contacts = game.vehicle.chassis:getContacts()
            
            for _, contact in ipairs(contacts) do
                if contact:isTouching() then
                    local f1, f2 = contact:getFixtures()
                    local otherBody = nil
                    
                    if f1 == game.vehicle.chassis.fixture then
                        otherBody = f2:getUserData()
                    else
                        otherBody = f1:getUserData()
                    end
                    
                    -- Check if it's a ragdoll part
                    if otherBody and otherBody.type == "ragdoll_part" and otherBody.ragdoll == ragdoll then
                        handleVehicleRagdollCollision(partName, ragdoll, contact)
                    end
                end
            end
        end
    end
end

function handleVehicleRagdollCollision(partName, ragdoll, contact, normalImpulse)
    --[[
        Handle collision between vehicle and ragdoll part
    ]]
    
    -- Get collision data
    local vx, vy = game.vehicle:getVelocity()
    local rx, ry = ragdoll:getPosition()
    local rvx, rvy = ragdoll.parts[partName]:getLinearVelocity()
    
    -- Get collision point if available
    local cx, cy = contact:getPositions()
    if not cx then
        cx, cy = rx, ry
    end
    
    local collisionData = {
        bodyPart = partName,
        impactPoint = {x = cx or rx, y = cy or ry},
        vehicleVelocity = {x = vx, y = vy},
        ragdollVelocity = {x = rvx, y = rvy},
        normalImpulse = normalImpulse or 0
    }
    
    -- Calculate damage
    local damageResult = game.damageCalc:calculateCollisionDamage(
        game.vehicle, ragdoll, collisionData)
    
    if damageResult.damage > 0 then
        -- Apply damage to ragdoll
        ragdoll:takeDamage(damageResult.damage)
        
        -- Add score
        local scoreEarned = game.scoreManager:addHit(damageResult, game.vehicle, ragdoll)
        
        -- Show damage number
        game.scoreHUD:addDamageNumber(damageResult.damage, cx or rx, cy or ry, {})
        
        -- Flash combo
        game.scoreHUD:flashCombo()
        
        -- Play impact sound
        game.soundManager:playImpactSound("hard", damageResult.damage)
        
        print(string.format("HIT! %s for %.1f damage, +%d score", 
            partName, damageResult.damage, scoreEarned))
    end
end

function love.update(dt)
    if game.paused then
        return
    end
    
    -- Update physics
    game.physicsWorld:update(dt)
    
    -- Update vehicle
    if game.vehicle then
        game.vehicle:update(dt)
    end
    
    -- Update ragdolls
    for _, ragdoll in ipairs(game.ragdolls) do
        ragdoll:update(dt)
    end
    
    -- Update walls
    for _, wall in ipairs(game.walls) do
        wall:update(dt)
    end
    
    -- Clear collision tracking periodically to allow re-collision
    if not game.collisionTimer then
        game.collisionTimer = 0
    end
    
    game.collisionTimer = game.collisionTimer + dt
    if game.collisionTimer > 0.1 then
        game.collisionTimer = 0
    end
    
    -- Update game systems
    game.scoreManager:update(dt)
    game.soundManager:update(dt)
    game.scoreHUD:update(dt)
    game.launchControl:update(dt)
    
    -- Check if gameplay should end
    if game.state == "gameplay" then
        local vx, vy = game.vehicle:getVelocity()
        local speed = math.sqrt(vx * vx + vy * vy)
        
        -- End if vehicle stopped
        if speed < 10 and game.vehicle.onGround then
            game.state = "results"
            print("\n=== Run Complete ===")
            printResults()
        end
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
    
    -- Draw vehicle
    if game.vehicle then
        game.vehicle:draw()
    end
    
    -- Draw physics debug
    if game.debugEnabled and game.debugRenderer then
        game.debugRenderer:draw()
    end
    
    -- Draw UI
    game.scoreHUD:draw()
    
    if game.state == "setup" or game.state == "gameplay" then
        game.launchControl:draw()
    end
    
    -- Draw state overlay
    drawStateOverlay()
    
    -- Draw pause overlay
    if game.paused then
        drawPauseOverlay()
    end
end

function drawGrid()
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

function drawStateOverlay()
    if game.state == "results" then
        local stats = game.scoreManager:getStats()
        local vehicleStats = game.vehicle:getStats()
        
        -- Results panel
        local panelX = love.graphics.getWidth() / 2 - 200
        local panelY = 100
        
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.rectangle("fill", panelX, panelY, 400, 350)
        
        love.graphics.setColor(0.3, 0.8, 1, 1)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", panelX, panelY, 400, 350)
        
        -- Title
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("RUN COMPLETE!", panelX + 120, panelY + 20, 0, 1.5)
        
        -- Stats
        local y = panelY + 60
        love.graphics.setColor(0.8, 0.8, 0.8)
        
        love.graphics.print(string.format("Score: %d", stats.score), panelX + 20, y, 0, 1.2)
        y = y + 30
        
        love.graphics.print(string.format("Grade: %s", stats.grade), panelX + 20, y, 0, 1.2)
        y = y + 30
        
        love.graphics.print(string.format("Total Hits: %d", stats.totalHits), panelX + 20, y)
        y = y + 25
        
        love.graphics.print(string.format("Total Damage: %.0f", stats.totalDamage), panelX + 20, y)
        y = y + 25
        
        love.graphics.print(string.format("Max Combo: x%d", stats.maxCombo), panelX + 20, y)
        y = y + 25
        
        love.graphics.print(string.format("Headshots: %d", stats.achievements.headshots), panelX + 20, y)
        y = y + 25
        
        love.graphics.print(string.format("Max Speed: %.0f px/s", vehicleStats.maxSpeed), panelX + 20, y)
        y = y + 25
        
        love.graphics.print(string.format("Distance: %.0f px", vehicleStats.distance), panelX + 20, y)
        y = y + 40
        
        -- Retry prompt
        love.graphics.setColor(0.3, 1, 0.3)
        love.graphics.print("Press R to retry", panelX + 130, y)
    end
end

function drawPauseOverlay()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    local pauseText = "PAUSED"
    local x = (love.graphics.getWidth() - 80) / 2
    local y = love.graphics.getHeight() / 2
    
    love.graphics.print(pauseText, x, y, 0, 2)
    love.graphics.print("Press ESC to resume", x - 30, y + 40)
end

function printResults()
    local stats = game.scoreManager:getStats()
    print(string.format("Final Score: %d (Grade: %s)", stats.score, stats.grade))
    print(string.format("Total Hits: %d", stats.totalHits))
    print(string.format("Total Damage: %.0f", stats.totalDamage))
    print(string.format("Max Combo: x%d", stats.maxCombo))
end

function resetGame()
    print("\n=== Resetting Game ===")
    
    -- Clear ragdolls
    for _, ragdoll in ipairs(game.ragdolls) do
        ragdoll:destroy()
    end
    game.ragdolls = {}
    
    -- Reset vehicle
    if game.vehicle then
        game.vehicle:reset()
    end
    
    -- Spawn new ragdolls
    for i = 1, game.ragdollCount do
        spawnRagdoll(400 + i * 150, 500)
    end
    
    -- Reset systems
    game.scoreManager:reset()
    game.damageCalc:reset()
    game.scoreHUD:reset()
    game.launchControl:reset()
    
    -- Reset state
    game.state = "setup"
    
    print("✓ Game reset complete")
end

function love.keypressed(key)
    if key == "escape" then
        if game.paused then
            game.paused = false
        else
            game.paused = true
        end
    elseif key == "space" then
        if game.state == "setup" then
            game.launchControl:startCharging()
        end
    elseif key == "f1" then
        game.debugEnabled = not game.debugEnabled
        game.debugRenderer:toggle()
    elseif key == "r" then
        resetGame()
    end
end

function love.keyreleased(key)
    if key == "space" then
        if game.state == "setup" and game.launchControl.charging then
            game.launchControl:launch()
        end
    end
end

print("\ngameplay-test.lua loaded successfully!")
print("Run with: love .")
