-- src/systems/level-manager.lua
-- Level/Environment Management System
-- Handles different arena configurations, hazards, and environmental effects

local LevelManager = {}
LevelManager.__index = LevelManager

-- Environmental properties for each level theme
LevelManager.THEMES = {
    indoor = {
        gravity = 9.81 * 64,  -- Standard gravity
        windForce = 0,
        backgroundColor = {0.15, 0.15, 0.2},
        floorFriction = 0.8,
        wallBounce = 0.3
    },
    city = {
        gravity = 9.81 * 64,
        windForce = 0.1,  -- Light wind
        backgroundColor = {0.3, 0.4, 0.5},
        floorFriction = 0.9,
        wallBounce = 0.2
    },
    sports = {
        gravity = 9.81 * 64,
        windForce = 0,
        backgroundColor = {0.2, 0.3, 0.25},
        floorFriction = 0.85,
        wallBounce = 0.4
    },
    heights = {
        gravity = 9.81 * 64,
        windForce = 0.3,  -- Strong wind at heights
        backgroundColor = {0.4, 0.5, 0.7},
        floorFriction = 0.7,
        wallBounce = 0.3
    },
    urban = {
        gravity = 9.81 * 64,
        windForce = 0.05,
        backgroundColor = {0.25, 0.25, 0.3},
        floorFriction = 0.95,
        wallBounce = 0.25
    },
    industrial = {
        gravity = 9.81 * 64,
        windForce = 0.15,
        backgroundColor = {0.3, 0.2, 0.15},
        floorFriction = 0.75,
        wallBounce = 0.35
    },
    tropical = {
        gravity = 9.81 * 64,
        windForce = 0.2,
        backgroundColor = {0.5, 0.6, 0.8},
        floorFriction = 0.6,  -- Sand is slippery
        wallBounce = 0.2
    },
    road = {
        gravity = 9.81 * 64,
        windForce = 0.4,  -- Wind from speed
        backgroundColor = {0.35, 0.35, 0.4},
        floorFriction = 1.0,
        wallBounce = 0.15
    },
    extreme = {
        gravity = 9.81 * 50,  -- Lower gravity for dramatic effect
        windForce = 0.5,  -- Intense wind
        backgroundColor = {0.6, 0.2, 0.1},
        floorFriction = 0.5,
        wallBounce = 0.5
    }
}

function LevelManager:new(saveManager)
    local self = setmetatable({}, LevelManager)
    
    self.saveManager = saveManager
    
    -- Current level
    self.currentLevel = "studio"  -- Default starting level
    self.levelData = nil
    self.themeProperties = nil
    
    -- Hazards (future expansion)
    self.hazards = {}
    
    return self
end

function LevelManager:setLevel(levelId)
    --[[
        Set the active level/environment
        
        @param levelId: Level identifier from ProgressionManager.UNLOCKABLES.levels
    ]]
    
    self.currentLevel = levelId
    
    -- Get level data from progression manager
    local ProgressionManager = require('src.progression.progression-manager')
    self.levelData = ProgressionManager.UNLOCKABLES.levels[levelId]
    
    if not self.levelData then
        print(string.format("⚠️  Warning: Level '%s' not found, using default", levelId))
        self.currentLevel = "studio"
        self.levelData = ProgressionManager.UNLOCKABLES.levels.studio
    end
    
    -- Load theme properties
    local theme = self.levelData.theme or "indoor"
    self.themeProperties = self.THEMES[theme] or self.THEMES.indoor
    
    print(string.format("📍 Level loaded: %s (Theme: %s, Difficulty: %d)", 
        self.levelData.name, theme, self.levelData.difficulty or 1))
end

function LevelManager:getCurrentLevel()
    --[[
        Get current level data
        
        @return: Level table with name, theme, difficulty, etc.
    ]]
    
    return self.levelData
end

function LevelManager:getThemeProperties()
    --[[
        Get environmental properties for current theme
        
        @return: Theme properties table
    ]]
    
    return self.themeProperties
end

function LevelManager:getGravity()
    --[[
        Get gravity value for current level
        
        @return: Gravity in pixels/second²
    ]]
    
    return self.themeProperties and self.themeProperties.gravity or (9.81 * 64)
end

function LevelManager:getWindForce()
    --[[
        Get wind force for current level
        
        @return: Wind force multiplier
    ]]
    
    return self.themeProperties and self.themeProperties.windForce or 0
end

function LevelManager:getBackgroundColor()
    --[[
        Get background color for current level
        
        @return: {r, g, b} color table
    ]]
    
    return self.themeProperties and self.themeProperties.backgroundColor or {0.1, 0.1, 0.15}
end

function LevelManager:getDifficultyMultiplier()
    --[[
        Get score multiplier based on level difficulty
        
        @return: Multiplier value
    ]]
    
    local difficulty = self.levelData and self.levelData.difficulty or 1
    return 1 + ((difficulty - 1) * 0.15)  -- +15% per difficulty level
end

function LevelManager:applyEnvironmentalEffects(physicsWorld, dt)
    --[[
        Apply environmental effects like wind to physics bodies
        
        @param physicsWorld: Physics world instance
        @param dt: Delta time
    ]]
    
    local windForce = self:getWindForce()
    
    if windForce > 0 then
        -- Apply wind to dynamic bodies (future expansion)
        -- This would require access to all dynamic bodies in the world
        -- For now, this is a placeholder
    end
end

function LevelManager:getUnlockedLevels()
    --[[
        Get list of unlocked levels
        
        @return: Array of level IDs
    ]]
    
    local unlocked = {}
    local ProgressionManager = require('src.progression.progression-manager')
    
    for levelId, levelData in pairs(ProgressionManager.UNLOCKABLES.levels) do
        if levelData.unlocked or self.saveManager:hasUnlock("level", levelId) then
            table.insert(unlocked, {
                id = levelId,
                name = levelData.name,
                theme = levelData.theme,
                difficulty = levelData.difficulty
            })
        end
    end
    
    return unlocked
end

function LevelManager:selectRandomUnlockedLevel()
    --[[
        Select a random unlocked level
        
        @return: Level ID
    ]]
    
    local unlocked = self:getUnlockedLevels()
    
    if #unlocked == 0 then
        return "studio"  -- Fallback to default
    end
    
    local randomIndex = love.math.random(1, #unlocked)
    return unlocked[randomIndex].id
end

return LevelManager
