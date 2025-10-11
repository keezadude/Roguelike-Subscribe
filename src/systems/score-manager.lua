-- src/systems/score-manager.lua
-- Score Management and Combo System
-- Tracks score, combos, achievements, and bonuses

local ScoreManager = {}
ScoreManager.__index = ScoreManager

-- Score multipliers and bonuses
ScoreManager.MULTIPLIERS = {
    -- Body part bonuses
    headshot = 3.0,
    torso = 1.5,
    limb = 1.0,
    
    -- Collision type bonuses
    head_on = 1.5,
    side_impact = 1.2,
    glancing = 0.8,
    
    -- Special bonuses
    airborne = 2.0,      -- Hit while vehicle is airborne
    multihit = 1.5,      -- Multiple ragdolls in one collision
    overkill = 2.0,      -- Massive damage in one hit
    
    -- Combo multipliers
    combo2 = 1.2,
    combo3 = 1.5,
    combo4 = 2.0,
    combo5plus = 3.0
}

-- Score thresholds for achievements
ScoreManager.THRESHOLDS = {
    overkillDamage = 100,  -- Damage for overkill bonus
    comboWindow = 2.0,     -- Seconds between hits for combo
    maxCombo = 999         -- Maximum combo counter
}

function ScoreManager:new(options)
    local self = setmetatable({}, ScoreManager)
    
    options = options or {}
    
    -- Score state
    self.score = 0
    self.highScore = 0
    
    -- Combo system
    self.combo = 0
    self.comboTimer = 0
    self.maxCombo = 0
    
    -- Hit tracking
    self.totalHits = 0
    self.totalDamage = 0
    
    -- Special achievements
    self.achievements = {
        headshots = 0,
        overkills = 0,
        airborneHits = 0,
        multiHits = 0,
        perfectLaunch = false
    }
    
    -- Recent hits for analysis
    self.recentHits = {}
    
    -- Score breakdown (for display)
    self.scoreBreakdown = {
        baseDamage = 0,
        bonuses = 0,
        combos = 0,
        special = 0
    }
    
    return self
end

function ScoreManager:addHit(damageData, vehicle, ragdoll)
    --[[
        Add a hit and calculate score
        
        @param damageData: Damage calculation result
        @param vehicle: Vehicle entity (for checking airborne)
        @param ragdoll: Ragdoll entity that was hit
        
        @return: Score earned from this hit
    ]]
    
    local damage = damageData.damage or 0
    local bodyPart = damageData.bodyPart or "torso"
    local impactType = damageData.impactType or "head_on"
    
    -- Base score from damage
    local baseScore = damage * 10  -- 10 points per damage
    
    -- Body part multiplier
    local bodyMultiplier = 1.0
    if bodyPart == "head" then
        bodyMultiplier = self.MULTIPLIERS.headshot
        self.achievements.headshots = self.achievements.headshots + 1
    elseif bodyPart == "torso" then
        bodyMultiplier = self.MULTIPLIERS.torso
    else
        bodyMultiplier = self.MULTIPLIERS.limb
    end
    
    -- Impact type multiplier
    local impactMultiplier = self.MULTIPLIERS[impactType] or 1.0
    
    -- Check for special bonuses
    local specialMultiplier = 1.0
    local bonusText = {}
    
    -- Airborne bonus
    if vehicle and not vehicle.onGround then
        specialMultiplier = specialMultiplier * self.MULTIPLIERS.airborne
        self.achievements.airborneHits = self.achievements.airborneHits + 1
        table.insert(bonusText, "AIRBORNE!")
    end
    
    -- Overkill bonus (massive damage)
    if damage >= self.THRESHOLDS.overkillDamage then
        specialMultiplier = specialMultiplier * self.MULTIPLIERS.overkill
        self.achievements.overkills = self.achievements.overkills + 1
        table.insert(bonusText, "OVERKILL!")
    end
    
    -- Combo multiplier
    local comboMultiplier = self:getComboMultiplier()
    
    -- Calculate total score for this hit
    local hitScore = baseScore * bodyMultiplier * impactMultiplier * specialMultiplier * comboMultiplier
    
    -- Round to integer
    hitScore = math.floor(hitScore)
    
    -- Add to total score
    self.score = self.score + hitScore
    
    -- Update high score
    if self.score > self.highScore then
        self.highScore = self.score
    end
    
    -- Increment combo
    self:incrementCombo()
    
    -- Update statistics
    self.totalHits = self.totalHits + 1
    self.totalDamage = self.totalDamage + damage
    
    -- Update score breakdown
    self.scoreBreakdown.baseDamage = self.scoreBreakdown.baseDamage + baseScore
    self.scoreBreakdown.bonuses = self.scoreBreakdown.bonuses + (baseScore * (bodyMultiplier - 1))
    self.scoreBreakdown.combos = self.scoreBreakdown.combos + (baseScore * (comboMultiplier - 1))
    self.scoreBreakdown.special = self.scoreBreakdown.special + (baseScore * (specialMultiplier - 1))
    
    -- Store recent hit
    table.insert(self.recentHits, {
        score = hitScore,
        damage = damage,
        bodyPart = bodyPart,
        combo = self.combo,
        bonuses = bonusText,
        time = love.timer.getTime()
    })
    
    -- Keep only last 10 hits
    if #self.recentHits > 10 then
        table.remove(self.recentHits, 1)
    end
    
    print(string.format("HIT! +%d points (Combo x%d) %s", hitScore, self.combo, table.concat(bonusText, " ")))
    
    return hitScore
end

function ScoreManager:incrementCombo()
    --[[
        Increment combo counter
    ]]
    
    self.combo = self.combo + 1
    self.comboTimer = self.THRESHOLDS.comboWindow
    
    if self.combo > self.maxCombo then
        self.maxCombo = self.combo
    end
    
    if self.combo > self.THRESHOLDS.maxCombo then
        self.combo = self.THRESHOLDS.maxCombo
    end
end

function ScoreManager:getComboMultiplier()
    --[[
        Get current combo multiplier
        
        @return: Multiplier value
    ]]
    
    if self.combo >= 5 then
        return self.MULTIPLIERS.combo5plus
    elseif self.combo == 4 then
        return self.MULTIPLIERS.combo4
    elseif self.combo == 3 then
        return self.MULTIPLIERS.combo3
    elseif self.combo == 2 then
        return self.MULTIPLIERS.combo2
    else
        return 1.0
    end
end

function ScoreManager:update(dt)
    --[[
        Update combo timer
        
        @param dt: Delta time
    ]]
    
    if self.comboTimer > 0 then
        self.comboTimer = self.comboTimer - dt
        
        if self.comboTimer <= 0 then
            -- Combo expired
            if self.combo > 0 then
                print(string.format("COMBO BROKEN! (Reached x%d)", self.combo))
            end
            self.combo = 0
        end
    end
end

function ScoreManager:addBonus(bonusName, bonusScore, reason)
    --[[
        Add a special bonus score
        
        @param bonusName: Name of bonus
        @param bonusScore: Score to add
        @param reason: Optional reason text
    ]]
    
    self.score = self.score + bonusScore
    self.scoreBreakdown.special = self.scoreBreakdown.special + bonusScore
    
    print(string.format("BONUS! %s: +%d points (%s)", bonusName, bonusScore, reason or ""))
end

function ScoreManager:getScore()
    --[[
        Get current score
        
        @return: Current score
    ]]
    
    return self.score
end

function ScoreManager:getGrade()
    --[[
        Get performance grade based on score
        
        @return: Grade string (S, A, B, C, D, F)
    ]]
    
    if self.score >= 100000 then
        return "S"
    elseif self.score >= 50000 then
        return "A"
    elseif self.score >= 25000 then
        return "B"
    elseif self.score >= 10000 then
        return "C"
    elseif self.score >= 5000 then
        return "D"
    else
        return "F"
    end
end

function ScoreManager:getStats()
    --[[
        Get detailed statistics
        
        @return: Stats table
    ]]
    
    return {
        score = self.score,
        highScore = self.highScore,
        combo = self.combo,
        maxCombo = self.maxCombo,
        totalHits = self.totalHits,
        totalDamage = self.totalDamage,
        averageDamage = self.totalHits > 0 and (self.totalDamage / self.totalHits) or 0,
        grade = self:getGrade(),
        achievements = self.achievements,
        breakdown = self.scoreBreakdown
    }
end

function ScoreManager:getRecentHits()
    --[[
        Get list of recent hits
        
        @return: Array of recent hit data
    ]]
    
    return self.recentHits
end

function ScoreManager:reset()
    --[[
        Reset score and stats (new run)
    ]]
    
    self.score = 0
    self.combo = 0
    self.comboTimer = 0
    self.maxCombo = 0
    self.totalHits = 0
    self.totalDamage = 0
    
    self.achievements = {
        headshots = 0,
        overkills = 0,
        airborneHits = 0,
        multiHits = 0,
        perfectLaunch = false
    }
    
    self.recentHits = {}
    
    self.scoreBreakdown = {
        baseDamage = 0,
        bonuses = 0,
        combos = 0,
        special = 0
    }
end

return ScoreManager
