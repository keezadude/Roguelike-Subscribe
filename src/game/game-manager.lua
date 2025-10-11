-- src/game/game-manager.lua
-- Master Game Manager
-- Coordinates all game systems and manages complete game flow

local StateMachine = require('src.game.state-machine')
local SaveManager = require('src.game.save-manager')
local ProgressionManager = require('src.progression.progression-manager')
local PhysicsWorld = require('src.physics.world')
local Vehicle = require('src.entities.vehicle')
local Ragdoll = require('src.entities.ragdoll')
local Wall = require('src.entities.wall')
local DamageCalculator = require('src.systems.damage-calculator')
local ScoreManager = require('src.systems.score-manager')
local SoundManager = require('src.audio.sound-manager')
local ScoreHUD = require('src.ui.score-hud')
local LaunchControl = require('src.ui.launch-control')
local PhysicsRenderer = require('src.debug.physics-renderer')
local CameraSystem = require('src.rendering.camera-system')
local ParticleSystem = require('src.effects.particle-system')
local ScreenEffects = require('src.effects.screen-effects')
local AchievementSystem = require('src.progression.achievement-system')
local AchievementNotification = require('src.ui.achievement-notification')
local ShopUI = require('src.ui.shop-ui')

local GameManager = {}
GameManager.__index = GameManager

function GameManager:new()
    local self = setmetatable({}, GameManager)
    
    print("\n=== Initializing Game Manager ===")
    
    -- Core managers
    self.stateMachine = StateMachine:new()
    self.saveManager = SaveManager:new()
    self.progressionManager = ProgressionManager:new(self.saveManager)
    self.achievementSystem = AchievementSystem:new(self.saveManager)
    
    -- Game systems
    self.physicsWorld = nil
    self.damageCalculator = nil
    self.scoreManager = nil
    self.soundManager = nil
    self.debugRenderer = nil
    
    -- Week 4: Visual systems
    self.camera = nil
    self.particleSystem = nil
    self.screenEffects = nil
    
    -- UI
    self.scoreHUD = nil
    self.launchControl = nil
    self.shopUI = nil
    
    -- Entities
    self.vehicle = nil
    self.ragdolls = {}
    self.walls = {}
    
    -- Current run data
    self.currentRun = {
        score = 0,
        damage = 0,
        hits = 0,
        combo = 0,
        subscribers = 0
    }
    
    -- Settings
    self.debugMode = false
    
    -- Initialize
    self:initializeSystems()
    self:registerStates()
    
    print("✓ Game Manager initialized")
    
    return self
end

function GameManager:initializeSystems()
    --[[
        Initialize all game systems
    ]]
    
    -- Physics
    self.physicsWorld = PhysicsWorld:new(0, 9.81 * 64)
    
    -- Game systems
    self.damageCalculator = DamageCalculator:new()
    self.scoreManager = ScoreManager:new()
    self.soundManager = SoundManager:new()
    
    -- Debug
    self.debugRenderer = PhysicsRenderer:new(self.physicsWorld, {
        showBodies = false,
        showStats = true
    })
    
    -- Week 4: Visual effects
    self.camera = CameraSystem:new({
        followSpeed = 3.0,
        lookahead = 100
    })
    
    self.particleSystem = ParticleSystem:new({
        maxParticles = 1000
    })
    
    self.screenEffects = ScreenEffects:new({
        enabled = true
    })
    
    -- UI
    self.scoreHUD = ScoreHUD:new(self.scoreManager)
    self.launchControl = LaunchControl:new({
        onLaunch = function(power)
            self:launchVehicle(power)
        end
    })
    
    -- Week 5: Achievement UI
    self.achievementNotification = AchievementNotification:new()
    
    -- Week 5: Shop UI
    self.shopUI = ShopUI:new(self.progressionManager, self.saveManager)
    
    print("✓ All systems initialized")
end

function GameManager:registerStates()
    --[[
        Register all game states with state machine
    ]]
    
    local sm = self.stateMachine
    
    -- MAIN MENU
    sm:registerState(sm.STATES.MAIN_MENU, {
        enter = function()
            print("Entered: MAIN MENU")
        end,
        update = function(dt)
            -- Menu updates
        end,
        draw = function()
            self:drawMainMenu()
        end,
        keypressed = function(key)
            if key == "space" or key == "return" then
                sm:setState(sm.STATES.SETUP)
            elseif key == "s" then
                sm:setState(sm.STATES.SHOP)
            end
        end
    })
    
    -- SHOP
    sm:registerState(sm.STATES.SHOP, {
        enter = function()
            print("Entered: SHOP")
        end,
        update = function(dt)
            local mx, my = love.mouse.getPosition()
            self.shopUI:update(dt, mx, my)
        end,
        draw = function()
            self:drawShop()
        end,
        keypressed = function(key)
            if key == "escape" then
                sm:setState(sm.STATES.MAIN_MENU)
            end
        end,
        mousepressed = function(x, y, button)
            self.shopUI:mousepressed(x, y, button)
        end
    })
    
    -- SETUP (pre-launch)
    sm:registerState(sm.STATES.SETUP, {
        enter = function()
            print("Entered: SETUP")
            self:setupRun()
        end,
        update = function(dt)
            self.physicsWorld:update(dt)
            if self.vehicle then
                self.vehicle:update(dt)
            end
            self.launchControl:update(dt)
        end,
        draw = function()
            self:drawGameWorld()
            self.launchControl:draw()
        end,
        keypressed = function(key)
            if key == "space" then
                self.launchControl:startCharging()
            end
        end,
        keyreleased = function(key)
            if key == "space" and self.launchControl.charging then
                self.launchControl:launch()
            end
        end
    })
    
    -- GAMEPLAY
    sm:registerState(sm.STATES.GAMEPLAY, {
        enter = function()
            print("Entered: GAMEPLAY")
            -- Set camera to follow vehicle
            if self.vehicle then
                self.camera:setTarget(self.vehicle)
            end
        end,
        update = function(dt)
            -- Get scaled dt for slow motion
            local scaledDT = self.screenEffects:getScaledDT(dt)
            
            self.physicsWorld:update(scaledDT)
            
            if self.vehicle then
                self.vehicle:update(scaledDT)
            end
            
            for _, ragdoll in ipairs(self.ragdolls) do
                ragdoll:update(scaledDT)
            end
            
            self.scoreManager:update(scaledDT)
            self.scoreHUD:update(scaledDT)
            
            -- Week 4: Update visual systems
            self.camera:update(dt)  -- Camera uses real dt
            self.particleSystem:update(scaledDT)
            self.screenEffects:update(dt)  -- Screen effects use real dt
            
            self:checkCollisions()
            self:checkRunEnd()
        end,
        draw = function()
            self:drawGameWorld()
            self.scoreHUD:draw(self.camera)
        end,
        keypressed = function(key)
            if key == "escape" then
                sm:setState(sm.STATES.PAUSE)
            end
        end
    })
    
    -- RESULTS
    sm:registerState(sm.STATES.RESULTS, {
        enter = function()
            print("Entered: RESULTS")
            self:calculateResults()
        end,
        draw = function()
            self:drawGameWorld()
            self:drawResults()
        end,
        keypressed = function(key)
            if key == "r" or key == "space" then
                sm:setState(sm.STATES.SETUP)
            elseif key == "s" then
                sm:setState(sm.STATES.SHOP)
            elseif key == "escape" then
                sm:setState(sm.STATES.MAIN_MENU)
            end
        end
    })
    
    -- PAUSE
    sm:registerState(sm.STATES.PAUSE, {
        draw = function()
            self:drawGameWorld()
            self.scoreHUD:draw(self.camera)
            self:drawPauseOverlay()
        end,
        keypressed = function(key)
            if key == "escape" then
                sm:setState(sm.previousState or sm.STATES.GAMEPLAY)
            elseif key == "q" then
                sm:setState(sm.STATES.MAIN_MENU)
            end
        end
    })
    
    -- Start in main menu
    sm:setState(sm.STATES.MAIN_MENU)
end

function GameManager:setupRun()
    --[[
        Set up a new run
    ]]
    
    -- Clear existing entities
    for _, ragdoll in ipairs(self.ragdolls) do
        ragdoll:destroy()
    end
    self.ragdolls = {}
    
    -- Reset systems
    self.scoreManager:reset()
    self.damageCalculator:reset()
    self.scoreHUD:reset()
    self.launchControl:reset()
    
    -- Create environment
    self:createEnvironment()
    
    -- Spawn vehicle
    self:spawnVehicle(150, 550)
    
    -- Spawn ragdolls
    for i = 1, 3 do
        self:spawnRagdoll(400 + i * 150, 500)
    end
    
    -- Reset run data
    self.currentRun = {score = 0, damage = 0, hits = 0, combo = 0, subscribers = 0}
end

function GameManager:createEnvironment()
    --[[
        Create game environment
    ]]
    
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Clear existing walls
    for _, wall in ipairs(self.walls) do
        wall:destroy()
    end
    self.walls = {}
    
    -- Ground
    table.insert(self.walls, Wall:new(self.physicsWorld, 
        screenWidth / 2, screenHeight - 20, 
        screenWidth * 2, 40, 
        {color = {0.3, 0.5, 0.3}, pattern = "solid"}))
    
    -- Ramp
    local ramp = Wall:new(self.physicsWorld, 
        200, screenHeight - 100, 
        200, 20, 
        {color = {0.6, 0.4, 0.2}, pattern = "solid"})
    ramp.body:setAngle(-0.2)
    table.insert(self.walls, ramp)
end

function GameManager:spawnVehicle(x, y)
    if self.vehicle then
        self.vehicle:destroy()
    end
    
    self.vehicle = Vehicle:new(self.physicsWorld, x, y, {
        chassisColor = {0.8, 0.2, 0.2}
    })
end

function GameManager:spawnRagdoll(x, y)
    local ragdoll = Ragdoll:new(self.physicsWorld, x, y, {health = 100})
    table.insert(self.ragdolls, ragdoll)
end

function GameManager:launchVehicle(power)
    if self.vehicle then
        self.vehicle:launch(power)
        self.stateMachine:setState(self.stateMachine.STATES.GAMEPLAY)
    end
end

function GameManager:checkCollisions()
    --[[
        Check for vehicle-ragdoll collisions using Breezefield's collision query
        Implements actual collision detection and damage/score
    ]]
    
    if not self.vehicle or self.stateMachine:getState() ~= self.stateMachine.STATES.GAMEPLAY then
        return
    end
    
    -- Track which collisions we've already processed this frame
    if not self.processedCollisions then
        self.processedCollisions = {}
    end
    
    -- Get all colliders in the world
    local world = self.physicsWorld.world
    
    -- Query all colliders that the vehicle chassis is currently colliding with
    local vehicleCollider = self.vehicle.chassis
    
    print(string.format("🔍 DEBUG: Checking collisions via Breezefield"))
    print(string.format("🔍 DEBUG: Vehicle chassis exists: %s", tostring(vehicleCollider ~= nil)))
    
    -- Breezefield approach: Check all colliders in world for overlap with vehicle
    local allColliders = world:getColliders()
    print(string.format("🔍 DEBUG: Total colliders in world: %d", #allColliders))
    
    for _, collider in ipairs(allColliders) do
        -- Skip if it's the vehicle itself or a wheel
        if collider ~= vehicleCollider and collider.userData then
            local userData = collider.userData
            
            -- Check if colliding with vehicle chassis
            if vehicleCollider:isColliding(collider) then
                print(string.format("🔍 DEBUG: Collision detected! UserData type: %s", 
                    userData.type or "nil"))
                
                -- Check if it's a ragdoll part
                if userData.type == "ragdoll_part" then
                    local ragdoll = userData.ragdoll
                    local partName = userData.partName
                    
                    print(string.format("✅ DEBUG: Found ragdoll collision! Part: %s", partName))
                    
                    -- Create unique collision ID
                    local collisionId = string.format("%s_%s_%d", 
                        tostring(ragdoll), partName, math.floor(love.timer.getTime() * 100))
                    
                    -- Only process each collision once per frame
                    if not self.processedCollisions[collisionId] then
                        self.processedCollisions[collisionId] = true
                        
                        -- Handle the collision (no contact object in Breezefield)
                        self:handleVehicleRagdollCollision(ragdoll, partName, nil)
                    else
                        print("⚠️ DEBUG: Collision already processed this frame")
                    end
                end
            end
        end
    end
    
    -- Clear processed collisions after a short delay
    if not self.collisionClearTimer then
        self.collisionClearTimer = 0
    end
    
    self.collisionClearTimer = self.collisionClearTimer + love.timer.getDelta()
    if self.collisionClearTimer > 0.1 then
        self.processedCollisions = {}
        self.collisionClearTimer = 0
    end
end

function GameManager:handleVehicleRagdollCollision(ragdoll, partName, contact)
    --[[
        Handle collision between vehicle and ragdoll part
        
        @param ragdoll: Ragdoll entity
        @param partName: Which body part was hit
        @param contact: Contact object (optional, nil for Breezefield)
    ]]
    
    -- Get velocities
    local vx, vy = self.vehicle:getVelocity()
    local part = ragdoll.parts[partName]
    if not part then 
        print(string.format("⚠️ DEBUG: Part '%s' not found in ragdoll", partName))
        return 
    end
    
    local rvx, rvy = part:getLinearVelocity()
    
    -- Get collision point
    local cx, cy
    if contact and contact.getPositions then
        cx, cy = contact:getPositions()
    end
    
    -- Fall back to ragdoll position if no contact point
    if not cx then
        cx, cy = part:getPosition()
    end
    
    -- Build collision data
    local collisionData = {
        bodyPart = partName,
        impactPoint = {x = cx, y = cy},
        vehicleVelocity = {x = vx, y = vy},
        ragdollVelocity = {x = rvx, y = rvy},
        normalImpulse = 0
    }
    
    -- Calculate damage
    print(string.format("🔍 DEBUG: Calculating damage - Vehicle vel: (%.1f, %.1f), Ragdoll vel: (%.1f, %.1f)", 
        vx, vy, rvx, rvy))
    
    local damageResult = self.damageCalculator:calculateCollisionDamage(
        self.vehicle, ragdoll, collisionData)
    
    print(string.format("🔍 DEBUG: Damage calculated: %.1f", damageResult and damageResult.damage or 0))
    
    if damageResult and damageResult.damage > 0 then
        -- Apply damage to ragdoll
        ragdoll:takeDamage(damageResult.damage)
        
        -- Add score
        local scoreEarned = self.scoreManager:addHit(damageResult, self.vehicle, ragdoll)
        
        -- Show damage number
        self.scoreHUD:addDamageNumber(damageResult.damage, cx, cy, {})
        
        -- Flash combo
        self.scoreHUD:flashCombo()
        
        -- Play impact sound
        self.soundManager:playImpactSound("hard", damageResult.damage)
        
        -- Week 4: Visual effects based on damage
        local intensity = math.min(10, damageResult.damage / 10)
        
        -- Particle effects
        self.particleSystem:createImpactEffect(cx, cy, intensity)
        self.particleSystem:createDebrisEffect(cx, cy, {x = vx * 0.3, y = vy * 0.3}, math.floor(intensity))
        
        if damageResult.damage > 50 then
            self.particleSystem:createDustCloud(cx, cy, 40, 20)
        end
        
        -- Camera shake
        local shakeMagnitude = math.min(15, damageResult.damage / 5)
        self.camera:shake(shakeMagnitude, 0.3)
        
        -- Screen effects
        if damageResult.damage > 80 then
            -- Big hit - flash and brief slowmo
            self.screenEffects:flashImpact(damageResult.damage)
            self.screenEffects:slowMotion(0.3, 0.2)
        elseif damageResult.damage > 40 then
            -- Medium hit - just flash
            self.screenEffects:flashImpact(damageResult.damage)
        end
        
        print(string.format("HIT! %s for %.1f damage, +%d score", 
            partName, damageResult.damage, scoreEarned))
    end
end

function GameManager:checkRunEnd()
    if not self.vehicle then
        return
    end
    
    local vx, vy = self.vehicle:getVelocity()
    local speed = math.sqrt(vx * vx + vy * vy)
    
    if speed < 10 and self.vehicle.onGround then
        self.stateMachine:setState(self.stateMachine.STATES.RESULTS)
    end
end

function GameManager:calculateResults()
    local stats = self.scoreManager:getStats()
    
    -- Record run and award subscribers
    local results = self.progressionManager:recordRun({
        score = stats.score,
        damage = stats.totalDamage,
        hits = stats.totalHits,
        combo = stats.maxCombo
    })
    
    self.currentRun = {
        score = stats.score,
        damage = stats.totalDamage,
        hits = stats.totalHits,
        combo = stats.maxCombo,
        subscribers = results.subscribers,
        totalSubscribers = results.totalSubscribers,
        milestones = results.milestones
    }
    
    -- Week 5: Check achievements
    local achievementStats = {
        subscribers = results.totalSubscribers,
        runs = self.saveManager:getData("totalRuns"),
        single_run_score = stats.score,
        max_combo = stats.maxCombo,
        headshots = stats.achievements.headshots,
        overkills = stats.achievements.overkills,
        airborne_hits = stats.achievements.airborneHits
    }
    
    local newAchievements = self.achievementSystem:checkAchievements(achievementStats)
    
    -- Queue achievement notifications
    for _, achievement in ipairs(newAchievements) do
        self.achievementNotification:notify(achievement)
    end
    
    print(string.format("\nRun Complete! Score: %d, Earned: %d subscribers", 
        stats.score, results.subscribers))
    
    if #newAchievements > 0 then
        print(string.format("Unlocked %d achievements!", #newAchievements))
    end
end

function GameManager:update(dt)
    self.stateMachine:update(dt)
    self.soundManager:update(dt)
    
    -- Week 5: Update achievement notifications
    self.achievementNotification:update(dt)
end

function GameManager:draw()
    self.stateMachine:draw()
    
    if self.debugMode then
        self.debugRenderer:draw()
    end
    
    -- Week 5: Draw achievement notifications (always on top)
    self.achievementNotification:draw()
end

function GameManager:drawGameWorld()
    love.graphics.clear(0.15, 0.15, 0.2)
    
    -- Week 4: Use camera system
    self.camera:attach()
    
    -- Draw world objects
    for _, wall in ipairs(self.walls) do
        wall:draw()
    end
    
    for _, ragdoll in ipairs(self.ragdolls) do
        ragdoll:draw()
    end
    
    if self.vehicle then
        self.vehicle:draw()
    end
    
    -- Draw particles
    self.particleSystem:draw()
    
    self.camera:detach()
    
    -- Draw screen effects (after camera detach - fullscreen)
    self.screenEffects:draw()
end

function GameManager:drawMainMenu()
    love.graphics.clear(0.1, 0.1, 0.15)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("ROGUELIKE & SUBSCRIBE", 400, 200, 0, 2)
    love.graphics.print("Truck Dismount Meets Meta-Progression", 400, 250)
    
    love.graphics.print("SPACE - Start Run", 500, 400)
    love.graphics.print("S - Shop/Upgrades", 500, 430)
    love.graphics.print("ESC - Quit", 500, 460)
    
    local subs = self.saveManager:getData("totalSubscribers")
    love.graphics.print(string.format("Total Subscribers: %d", subs), 500, 550)
end

function GameManager:drawShop()
    -- Use the actual ShopUI system
    self.shopUI:draw()
end

function GameManager:drawResults()
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 340, 100, 600, 500)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("RUN COMPLETE!", 500, 120, 0, 1.5)
    
    love.graphics.print(string.format("Score: %d", self.currentRun.score), 400, 200)
    love.graphics.print(string.format("Subscribers Earned: +%d", self.currentRun.subscribers), 400, 230)
    love.graphics.print(string.format("Total Subscribers: %d", self.currentRun.totalSubscribers), 400, 260)
    
    love.graphics.print("SPACE/R - Retry", 450, 500)
    love.graphics.print("S - Shop", 450, 530)
    love.graphics.print("ESC - Menu", 450, 560)
end

function GameManager:drawPauseOverlay()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("PAUSED", 600, 300, 0, 2)
    love.graphics.print("ESC - Resume", 570, 380)
    love.graphics.print("Q - Quit to Menu", 550, 410)
end

function GameManager:keypressed(key)
    -- Handle debug toggle
    if key == "f1" then
        self.debugMode = not self.debugMode
        self.debugRenderer:toggle()
    end
    
    -- Pass to state machine
    self.stateMachine:keypressed(key)
end

function GameManager:keyreleased(key)
    local state = self.stateMachine:getState()
    if state == self.stateMachine.STATES.SETUP then
        if key == "space" and self.launchControl.charging then
            self.launchControl:launch()
        end
    end
end

function GameManager:mousepressed(x, y, button)
    self.stateMachine:mousepressed(x, y, button)
end

return GameManager
