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
local StatisticsUI = require('src.ui.statistics-ui')
local LevelManager = require('src.systems.level-manager')

local GameManager = {}
GameManager.__index = GameManager

function GameManager:new()
    local self = setmetatable({}, GameManager)
    
    local startTime = love.timer.getTime()
    print("\n=== Initializing Game Manager ===")
    
    -- Core managers
    local t1 = love.timer.getTime()
    self.stateMachine = StateMachine:new()
    print(string.format("  ✓ StateMachine: %.3fs", love.timer.getTime() - t1))
    
    local t2 = love.timer.getTime()
    self.saveManager = SaveManager:new()
    print(string.format("  ✓ SaveManager: %.3fs", love.timer.getTime() - t2))
    
    local t3 = love.timer.getTime()
    self.progressionManager = ProgressionManager:new(self.saveManager)
    print(string.format("  ✓ ProgressionManager: %.3fs", love.timer.getTime() - t3))
    
    -- Level Manager
    self.levelManager = LevelManager:new(self.saveManager)
    self.levelManager:setLevel("studio")  -- Default level
    
    local t4 = love.timer.getTime()
    self.achievementSystem = AchievementSystem:new(self.saveManager)
    print(string.format("  ✓ AchievementSystem: %.3fs", love.timer.getTime() - t4))
    
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
    
    -- Automated testing
    self.testRunner = nil
    self.testMode = false
    
    -- Initialize
    self:initializeSystems()
    self:registerStates()
    
    local totalTime = love.timer.getTime() - startTime
    print(string.format("✓ Game Manager initialized in %.3fs", totalTime))
    
    if totalTime > 1.0 then
        print("⚠️  WARNING: Slow initialization detected (>1s)")
    end
    
    return self
end

function GameManager:initializeSystems()
    --[[
        Initialize all game systems
    ]]
    
    print("\n  Initializing subsystems...")
    
    -- Physics
    local t1 = love.timer.getTime()
    self.physicsWorld = PhysicsWorld:new(0, 9.81 * 64)
    print(string.format("    • PhysicsWorld: %.3fs", love.timer.getTime() - t1))
    
    -- Game systems
    local t2 = love.timer.getTime()
    self.damageCalculator = DamageCalculator:new()
    self.scoreManager = ScoreManager:new()
    self.soundManager = SoundManager:new()
    print(string.format("    • Game systems: %.3fs", love.timer.getTime() - t2))
    
    -- Debug
    local t3 = love.timer.getTime()
    self.debugRenderer = PhysicsRenderer:new(self.physicsWorld, {
        showBodies = false,
        showStats = true
    })
    print(string.format("    • DebugRenderer: %.3fs", love.timer.getTime() - t3))
    
    -- Week 4: Visual effects
    local t4 = love.timer.getTime()
    self.camera = CameraSystem:new({
        followSpeed = 5.0,  -- Faster camera follow
        lookahead = 150     -- More lookahead for fast-moving vehicle
    })
    
    self.particleSystem = ParticleSystem:new({
        maxParticles = 500  -- Reduced for performance
    })
    
    self.screenEffects = ScreenEffects:new({
        enabled = true
    })
    print(string.format("    • Visual systems: %.3fs", love.timer.getTime() - t4))
    
    -- UI
    local t5 = love.timer.getTime()
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
    
    -- Statistics UI
    self.statisticsUI = StatisticsUI:new(self.saveManager, self.achievementSystem)
    print(string.format("    • UI systems: %.3fs", love.timer.getTime() - t5))
    
    print("  ✓ All subsystems initialized")
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
            elseif key == "tab" then
                sm:setState(sm.STATES.STATISTICS)
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
    
    -- STATISTICS
    sm:registerState(sm.STATES.STATISTICS, {
        enter = function()
            print("Entered: STATISTICS")
        end,
        update = function(dt)
            -- Statistics UI updates if needed
        end,
        draw = function()
            self.statisticsUI:draw()
        end,
        keypressed = function(key)
            if key == "escape" or key == "tab" then
                sm:setState(sm.STATES.MAIN_MENU)
            end
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
            -- Track run time
            self.runTimer = (self.runTimer or 0) + dt
            
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
    
    -- Spawn vehicle (position it properly above ground)
    local screenHeight = love.graphics.getHeight()
    local groundY = screenHeight - 80  -- Position vehicle on ramp
    self:spawnVehicle(100, groundY - 50)
    
    -- Spawn ragdolls in a line in the vehicle's path
    local ragdollY = screenHeight - 100  -- Position ragdolls on ground
    for i = 1, 3 do
        -- Position ragdolls in a line ahead of the vehicle
        self:spawnRagdoll(350 + i * 180, ragdollY)
    end
    
    -- Reset run data
    self.currentRun = {score = 0, damage = 0, hits = 0, combo = 0, subscribers = 0}
    
    -- Reset run timer
    self.runTimer = 0
    self.minRunTime = 5.0  -- Minimum 5 seconds before run can end
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
    
    -- Ground (long enough for the entire run)
    table.insert(self.walls, Wall:new(self.physicsWorld, 
        screenWidth * 2, screenHeight - 20, 
        screenWidth * 4, 40, 
        {color = {0.3, 0.5, 0.3}, pattern = "solid"}))
    
    -- Launch ramp - angled to send vehicle forward and up
    local ramp = Wall:new(self.physicsWorld, 
        150, screenHeight - 80, 
        180, 20, 
        {color = {0.6, 0.4, 0.2}, pattern = "solid"})
    ramp.body:setAngle(-0.3)  -- Steeper angle for better launch
    table.insert(self.walls, ramp)
    
    -- Add some obstacles for variety
    table.insert(self.walls, Wall:new(self.physicsWorld,
        900, screenHeight - 80,
        40, 100,
        {color = {0.5, 0.5, 0.5}, pattern = "solid"}))
end

function GameManager:spawnVehicle(x, y)
    if self.vehicle then
        self.vehicle:destroy()
    end
    
    self.vehicle = Vehicle:new(self.physicsWorld, x, y, {
        chassisColor = {0.8, 0.2, 0.2}
    })
    
    -- Set up collision callbacks for the new vehicle
    self:setupCollisionCallbacks()
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

function GameManager:setupCollisionCallbacks()
    --[[
        Setup Breezefield collision callbacks
        This is the proper way to handle collisions in Breezefield
    ]]
    
    -- Track processed collisions to avoid duplicates
    self.processedCollisions = {}
    self.collisionCooldowns = {}  -- Per-ragdoll cooldowns
    
    -- Register collision callback for vehicle chassis hitting ragdoll parts
    if self.vehicle and self.vehicle.chassis then
        local vehicleCollider = self.vehicle.chassis
        
        -- Set up postSolve callback for collision detection
        vehicleCollider.postSolve = function(this, other, contact, normalImpulse, tangentImpulse)
            -- Check if the other collider is a ragdoll part
            if other.userData and other.userData.type == "ragdoll_part" then
                local ragdoll = other.userData.ragdoll
                local partName = other.userData.partName
                
                -- Check cooldown to prevent spam
                local ragdollId = tostring(ragdoll)
                local now = love.timer.getTime()
                if self.collisionCooldowns[ragdollId] and now - self.collisionCooldowns[ragdollId] < 0.1 then
                    return  -- Skip if hit this ragdoll too recently
                end
                self.collisionCooldowns[ragdollId] = now
                
                -- Process collision
                self:handleVehicleRagdollCollision(ragdoll, partName, contact, normalImpulse or 0)
            end
        end
    end
    
    -- Also set up callbacks for wheels hitting ragdolls
    if self.vehicle and self.vehicle.wheels then
        for wheelName, wheel in pairs(self.vehicle.wheels) do
            wheel.postSolve = function(this, other, contact, normalImpulse, tangentImpulse)
                if other.userData and other.userData.type == "ragdoll_part" then
                    local ragdoll = other.userData.ragdoll
                    local partName = other.userData.partName
                    
                    local ragdollId = tostring(ragdoll)
                    local now = love.timer.getTime()
                    if self.collisionCooldowns[ragdollId] and now - self.collisionCooldowns[ragdollId] < 0.1 then
                        return
                    end
                    self.collisionCooldowns[ragdollId] = now
                    
                    self:handleVehicleRagdollCollision(ragdoll, partName, contact, normalImpulse or 0)
                end
            end
        end
    end
    
    if self.debugMode then
        print("🔍 DEBUG: Setting up collision callbacks for vehicle chassis and wheels")
    end
end

function GameManager:checkCollisions()
    --[[
        Manual collision checking as fallback
        Breezefield callbacks should handle most collisions,
        but we'll also do manual checks to ensure we don't miss hits
    ]]
    
    if not self.vehicle or self.stateMachine:getState() ~= self.stateMachine.STATES.GAMEPLAY then
        return
    end
    
    -- Get vehicle bounds
    local vx, vy = self.vehicle:getPosition()
    local vehicleVelX, vehicleVelY = self.vehicle:getVelocity()
    local vehicleSpeed = math.sqrt(vehicleVelX * vehicleVelX + vehicleVelY * vehicleVelY)
    
    -- Only check if vehicle is moving fast enough
    if vehicleSpeed < 20 then
        return
    end
    
    -- Check proximity to each ragdoll
    for _, ragdoll in ipairs(self.ragdolls) do
        if ragdoll.alive then
            local rx, ry = ragdoll:getPosition()
            local dist = math.sqrt((vx - rx)^2 + (vy - ry)^2)
            
            -- If close enough, check for collision with parts
            if dist < 100 then
                for partName, part in pairs(ragdoll.parts) do
                    local px, py = part:getPosition()
                    local partDist = math.sqrt((vx - px)^2 + (vy - py)^2)
                    
                    -- Collision detected
                    if partDist < 50 then
                        local ragdollId = tostring(ragdoll)
                        local now = love.timer.getTime()
                        
                        -- Cooldown check
                        if not self.collisionCooldowns then
                            self.collisionCooldowns = {}
                        end
                        
                        if not self.collisionCooldowns[ragdollId] or now - self.collisionCooldowns[ragdollId] > 0.15 then
                            self.collisionCooldowns[ragdollId] = now
                            
                            -- Create collision data
                            local partVelX, partVelY = part:getLinearVelocity()
                            local collisionData = {
                                bodyPart = partName,
                                impactPoint = {x = px, y = py},
                                vehicleVelocity = {x = vehicleVelX, y = vehicleVelY},
                                ragdollVelocity = {x = partVelX, y = partVelY},
                                normalImpulse = vehicleSpeed * 10  -- Approximate impulse
                            }
                            
                            self:handleVehicleRagdollCollisionData(ragdoll, collisionData)
                            break  -- Only process one part per ragdoll per frame
                        end
                    end
                end
            end
        end
    end
end

function GameManager:handleVehicleRagdollCollision(ragdoll, partName, contact, normalImpulse)
    --[[
        Handle collision between vehicle and ragdoll part (from Breezefield callback)
        
        @param ragdoll: Ragdoll entity
        @param partName: Which body part was hit
        @param contact: Contact object
        @param normalImpulse: Normal impulse value from collision
    ]]
    
    -- Get velocities
    local vx, vy = self.vehicle:getVelocity()
    local part = ragdoll.parts[partName]
    if not part then 
        return 
    end
    
    local rvx, rvy = part:getLinearVelocity()
    
    -- Get collision point
    local cx, cy
    if contact and contact.getPositions then
        cx, cy = contact:getPositions()
    end
    
    -- Fall back to part position if no contact point
    if not cx then
        cx, cy = part:getPosition()
    end
    
    -- Build collision data
    local collisionData = {
        bodyPart = partName,
        impactPoint = {x = cx, y = cy},
        vehicleVelocity = {x = vx, y = vy},
        ragdollVelocity = {x = rvx, y = rvy},
        normalImpulse = normalImpulse or 0
    }
    
    self:handleVehicleRagdollCollisionData(ragdoll, collisionData)
end

function GameManager:handleVehicleRagdollCollisionData(ragdoll, collisionData)
    --[[
        Process collision data and apply damage/effects
        
        @param ragdoll: Ragdoll entity
        @param collisionData: Collision information
    ]]
    
    local partName = collisionData.bodyPart
    local vx = collisionData.vehicleVelocity.x
    local vy = collisionData.vehicleVelocity.y
    local rvx = collisionData.ragdollVelocity.x
    local rvy = collisionData.ragdollVelocity.y
    local cx = collisionData.impactPoint.x
    local cy = collisionData.impactPoint.y
    local normalImpulse = collisionData.normalImpulse or 0
    
    -- Calculate damage
    if self.debugMode then
        print(string.format("🔍 DEBUG: Calculating damage - Vehicle vel: (%.1f, %.1f), Ragdoll vel: (%.1f, %.1f), Impulse: %.1f", 
            vx, vy, rvx, rvy, normalImpulse))
    end
    
    local damageResult = self.damageCalculator:calculateCollisionDamage(
        self.vehicle, ragdoll, collisionData)
    
    if self.debugMode then
        print(string.format("🔍 DEBUG: Damage calculated: %.1f", damageResult and damageResult.damage or 0))
    end
    
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
    
    -- Don't end run immediately - give it time to play out
    if self.runTimer < self.minRunTime then
        return
    end
    
    local vx, vy = self.vehicle:getVelocity()
    local speed = math.sqrt(vx * vx + vy * vy)
    
    -- End run when vehicle has stopped for a bit
    if speed < 5 and self.vehicle.onGround then
        if not self.stoppedTime then
            self.stoppedTime = 0
        end
        self.stoppedTime = self.stoppedTime + love.timer.getDelta()
        
        if self.stoppedTime > 1.5 then  -- Stopped for 1.5 seconds
            self.stateMachine:setState(self.stateMachine.STATES.RESULTS)
            self.stoppedTime = nil
        end
    else
        self.stoppedTime = nil
    end
    
    -- Auto-end after 30 seconds to prevent infinite runs
    if self.runTimer > 30 then
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
    
    -- Save once after all achievements processed (batch save optimization)
    if #newAchievements > 0 then
        self.saveManager:save()
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
    
    -- Update automated tests if running
    if self.testRunner and self.testMode then
        self.testRunner:update(dt)
    end
end

function GameManager:draw()
    self.stateMachine:draw()
    
    if self.debugMode then
        self.debugRenderer:draw()
    end
    
    -- Week 5: Draw achievement notifications (always on top)
    self.achievementNotification:draw()
    
    -- Draw test overlay if testing
    if self.testRunner and self.testMode then
        self.testRunner:draw()
    end
end

function GameManager:drawGameWorld()
    -- Use level's background color
    local bgColor = self.levelManager:getBackgroundColor()
    love.graphics.clear(bgColor[1], bgColor[2], bgColor[3])
    
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
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    
    -- Background gradient effect
    love.graphics.clear(0.08, 0.08, 0.12)
    
    -- Animated background elements (simple particles)
    love.graphics.setColor(0.15, 0.15, 0.25, 0.3)
    for i = 1, 20 do
        local x = (love.timer.getTime() * 20 + i * 50) % (w + 100) - 50
        local y = 100 + (i * 30) % (h - 200)
        love.graphics.circle("fill", x, y, 3)
    end
    
    -- Title with shadow
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.printf("ROGUELIKE & SUBSCRIBE", 4, 104, w, "center", 0, 1, 1)
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.printf("ROGUELIKE & SUBSCRIBE", 0, 100, w, "center", 0, 1, 1)
    
    -- Subtitle
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.printf("Truck Dismount Meets Meta-Progression", 0, 135, w, "center")
    
    -- Stats box
    local subs = self.saveManager:getData("totalSubscribers")
    local runs = self.saveManager:getData("totalRuns") or 0
    local highScore = self.saveManager:getData("highScore") or 0
    
    love.graphics.setColor(0.15, 0.15, 0.25, 0.8)
    love.graphics.rectangle("fill", w/2 - 150, 200, 300, 120, 10, 10)
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.rectangle("line", w/2 - 150, 200, 300, 120, 10, 10)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("📊 STATISTICS", w/2 - 150, 210, 300, "center")
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf(string.format("Subscribers: %d", subs), w/2 - 140, 240, 280, "left")
    love.graphics.printf(string.format("Runs: %d", runs), w/2 - 140, 260, 280, "left")
    love.graphics.printf(string.format("High Score: %d", highScore), w/2 - 140, 280, 280, "left")
    
    -- Menu options with visual style
    local menuY = 380
    local options = {
        {key = "SPACE", text = "Start New Run", icon = "🎮"},
        {key = "S", text = "Shop & Upgrades", icon = "🛒"},
        {key = "TAB", text = "Statistics", icon = "📈"},
        {key = "ESC", text = "Quit Game", icon = "🚪"}
    }
    
    for i, option in ipairs(options) do
        local y = menuY + (i - 1) * 35
        
        -- Option background
        love.graphics.setColor(0.2, 0.2, 0.3, 0.5)
        love.graphics.rectangle("fill", w/2 - 180, y - 5, 360, 30, 5, 5)
        
        -- Icon
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(option.icon, w/2 - 170, y)
        
        -- Key binding
        love.graphics.setColor(0.3, 0.7, 1)
        love.graphics.print(option.key, w/2 - 140, y)
        
        -- Description
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.print(option.text, w/2 - 80, y)
    end
    
    -- Version footer
    love.graphics.setColor(0.5, 0.5, 0.6)
    love.graphics.print("Week 5 Complete - Roguelike Systems Integrated", 10, h - 25)
end

function GameManager:drawShop()
    -- Use the actual ShopUI system
    self.shopUI:draw()
end

function GameManager:drawResults()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    
    -- Dark overlay
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Results panel
    local panelW, panelH = 600, 500
    local panelX, panelY = w/2 - panelW/2, h/2 - panelH/2
    
    love.graphics.setColor(0.12, 0.12, 0.18)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 15, 15)
    love.graphics.setColor(0.3, 0.5, 1, 0.5)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 15, 15)
    love.graphics.setLineWidth(1)
    
    -- Title
    love.graphics.setColor(0.3, 0.7, 1)
    love.graphics.printf("🎉 RUN COMPLETE!", panelX, panelY + 30, panelW, "center", 0, 1.2, 1.2)
    
    -- Score breakdown
    local stats = {
        {label = "Final Score", value = self.currentRun.score, icon = "🎯"},
        {label = "Max Combo", value = self.currentRun.combo .. "x", icon = "🔥"},
        {label = "Total Hits", value = self.currentRun.hits, icon = "💥"},
        {label = "Total Damage", value = math.floor(self.currentRun.damage), icon = "⚡"}
    }
    
    local statsY = panelY + 100
    for i, stat in ipairs(stats) do
        local y = statsY + (i - 1) * 40
        
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.print(stat.icon, panelX + 50, y)
        love.graphics.print(stat.label, panelX + 80, y)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(tostring(stat.value), panelX, y, panelW - 50, "right")
    end
    
    -- Subscriber rewards
    love.graphics.setColor(0.2, 0.2, 0.3, 0.7)
    love.graphics.rectangle("fill", panelX + 30, statsY + 180, panelW - 60, 80, 8, 8)
    
    love.graphics.setColor(0.3, 0.8, 0.3)
    love.graphics.printf("📈 NEW SUBSCRIBERS", panelX + 30, statsY + 195, panelW - 60, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(string.format("+%d", self.currentRun.subscribers), panelX + 30, statsY + 220, panelW - 60, "center", 0, 1.5, 1.5)
    
    -- Total
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.printf(string.format("Total: %d subscribers", self.currentRun.totalSubscribers), 
        panelX + 30, statsY + 245, panelW - 60, "center")
    
    -- Action prompts
    local promptY = panelY + panelH - 100
    local prompts = {
        {key = "SPACE/R", text = "Play Again"},
        {key = "S", text = "Visit Shop"},
        {key = "ESC", text = "Main Menu"}
    }
    
    for i, prompt in ipairs(prompts) do
        local y = promptY + (i - 1) * 25
        love.graphics.setColor(0.3, 0.6, 1)
        love.graphics.print(prompt.key, panelX + 150, y)
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.print(" - " .. prompt.text, panelX + 230, y)
    end
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
    
    -- Handle test shortcuts
    if key == "f2" then
        self:initializeTestRunner()
        self.testRunner:quickPositionCheck()
    end
    
    if key == "f3" then
        self:runAutomatedTest()
    end
    
    if key == "f4" then
        self:runFullTestSuite()
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

function GameManager:initializeTestRunner()
    --[[
        Initialize test runner (lazy initialization)
    ]]
    
    if not self.testRunner then
        local TestRunner = require('tests.test-runner')
        self.testRunner = TestRunner:new(self)
        print("✅ Test runner initialized")
    end
end

function GameManager:runAutomatedTest()
    --[[
        Run a single automated position test on current setup
        Press F3 to run this during gameplay
    ]]
    
    self:initializeTestRunner()
    self.testMode = true
    
    print("\n🧪 Starting Automated Position Test...")
    print("Test will monitor vehicle for 10 seconds")
    print("Press F3 again to run another test\n")
    
    self.testRunner:runTest("vehiclePosition", "Manual Position Test")
end

function GameManager:runFullTestSuite()
    --[[
        Run complete automated test suite
        Press F4 to run this
    ]]
    
    self:initializeTestRunner()
    self.testMode = true
    
    print("\n🧪 Starting FULL Automated Test Suite...")
    print("This will run multiple tests in sequence\n")
    
    self.testRunner:runAllTests()
end

return GameManager
