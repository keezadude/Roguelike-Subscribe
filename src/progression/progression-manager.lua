-- src/progression/progression-manager.lua
-- Progression & Upgrade System
-- Manages roguelike meta-progression with "Subscribe" theme

local ProgressionManager = {}
ProgressionManager.__index = ProgressionManager

-- Upgrade definitions (Subscribe-themed)
ProgressionManager.UPGRADES = {
    -- Truck upgrades
    viral_boost = {
        name = "Viral Boost",
        description = "Increase launch power",
        icon = "🚀",
        maxLevel = 5,
        baseCost = 100,
        costMultiplier = 1.5,
        effect = function(level) return 1 + (level * 0.15) end  -- +15% per level
    },
    
    trending_topic = {
        name = "Trending Topic",
        description = "Increase truck mass for more impact",
        icon = "📈",
        maxLevel = 5,
        baseCost = 150,
        costMultiplier = 1.5,
        effect = function(level) return 1 + (level * 0.10) end  -- +10% per level
    },
    
    algorithm_boost = {
        name = "Algorithm Boost",
        description = "Better suspension, more air time",
        icon = "⚡",
        maxLevel = 3,
        baseCost = 200,
        costMultiplier = 2.0,
        effect = function(level) return 1 + (level * 0.20) end
    },
    
    -- Score multipliers
    monetization = {
        name = "Monetization",
        description = "Earn more subscribers per hit",
        icon = "💰",
        maxLevel = 5,
        baseCost = 120,
        costMultiplier = 1.6,
        effect = function(level) return 1 + (level * 0.25) end  -- +25% per level
    },
    
    engagement_rate = {
        name = "Engagement Rate",
        description = "Longer combo window",
        icon = "🔥",
        maxLevel = 3,
        baseCost = 180,
        costMultiplier = 1.8,
        effect = function(level) return 1 + (level * 0.30) end
    },
    
    verified_badge = {
        name = "Verified Badge",
        description = "Bonus subscribers for high scores",
        icon = "✓",
        maxLevel = 1,
        baseCost = 500,
        costMultiplier = 1.0,
        effect = function(level) return level > 0 and 1.5 or 1.0 end
    }
}

-- Unlockables (Subscribe-themed)
ProgressionManager.UNLOCKABLES = {
    -- Characters (ragdolls)
    characters = {
        default = {name = "Default Creator", cost = 0, unlocked = true},
        streamer = {name = "Live Streamer", cost = 500, description = "Blue hair, energetic"},
        vlogger = {name = "Daily Vlogger", cost = 800, description = "Camera gear visible"},
        gamer = {name = "Pro Gamer", cost = 1000, description = "Gaming headset"},
        influencer = {name = "Mega Influencer", cost = 1500, description = "Stylish outfit"}
    },
    
    -- Trucks
    trucks = {
        default = {name = "Starter Van", cost = 0, unlocked = true},
        pickup = {name = "Pickup Truck", cost = 600, description = "+10% power"},
        semi = {name = "Semi Truck", cost = 1200, description = "+20% mass"},
        monster = {name = "Monster Truck", cost = 2000, description = "Huge wheels, more bounce"}
    },
    
    -- Levels
    levels = {
        arena_01 = {name = "Studio Arena", cost = 0, unlocked = true},
        street = {name = "Street Scene", cost = 400, description = "Urban obstacles"},
        stadium = {name = "Stadium", cost = 800, description = "Big jumps"},
        rooftop = {name = "Rooftop", cost = 1500, description = "Extreme heights"}
    }
}

-- Milestones (achievements that unlock content)
ProgressionManager.MILESTONES = {
    {subscribers = 1000, reward = "streamer_character", name = "1K Subs Milestone"},
    {subscribers = 5000, reward = "pickup_truck", name = "5K Subs Milestone"},
    {subscribers = 10000, reward = "street_level", name = "10K Subs Milestone"},
    {subscribers = 25000, reward = "gamer_character", name = "25K Subs Milestone"},
    {subscribers = 50000, reward = "semi_truck", name = "50K Subs Milestone"},
    {subscribers = 100000, reward = "verified_badge_upgrade", name = "100K Subs - VERIFIED!"}
}

function ProgressionManager:new(saveManager)
    local self = setmetatable({}, ProgressionManager)
    
    self.saveManager = saveManager
    
    -- Current session data
    self.sessionSubscribers = 0
    self.sessionScore = 0
    
    return self
end

function ProgressionManager:getUpgradeCost(upgradeId)
    --[[
        Calculate cost for next level of upgrade
        
        @param upgradeId: Upgrade identifier
        @return: Cost in subscribers
    ]]
    
    local upgrade = self.UPGRADES[upgradeId]
    if not upgrade then
        return 0
    end
    
    local currentLevel = self.saveManager:upgradeLevel(upgradeId)
    
    if currentLevel >= upgrade.maxLevel then
        return nil  -- Max level reached
    end
    
    return math.floor(upgrade.baseCost * (upgrade.costMultiplier ^ currentLevel))
end

function ProgressionManager:purchaseUpgrade(upgradeId)
    --[[
        Purchase upgrade level
        
        @param upgradeId: Upgrade to purchase
        @return: true if successful
    ]]
    
    local cost = self:getUpgradeCost(upgradeId)
    
    if not cost then
        print("Upgrade already at max level")
        return false
    end
    
    if self.saveManager:spendSubscribers(cost) then
        self.saveManager:purchaseUpgrade(upgradeId)
        print(string.format("✓ Purchased %s (Level %d)", 
            self.UPGRADES[upgradeId].name,
            self.saveManager:upgradeLevel(upgradeId)))
        return true
    else
        print("Not enough subscribers")
        return false
    end
end

function ProgressionManager:getUpgradeEffect(upgradeId)
    --[[
        Get current effect of an upgrade
        
        @param upgradeId: Upgrade identifier
        @return: Effect multiplier
    ]]
    
    local upgrade = self.UPGRADES[upgradeId]
    if not upgrade then
        return 1.0
    end
    
    local level = self.saveManager:upgradeLevel(upgradeId)
    return upgrade.effect(level)
end

function ProgressionManager:canUnlock(type, id)
    --[[
        Check if item can be unlocked
        
        @param type: "character", "truck", or "level"
        @param id: Item ID
        @return: {canUnlock, cost, reason}
    ]]
    
    -- Get unlockable data
    local item
    if type == "characters" then
        item = self.UNLOCKABLES.characters[id]
    elseif type == "trucks" then
        item = self.UNLOCKABLES.trucks[id]
    elseif type == "levels" then
        item = self.UNLOCKABLES.levels[id]
    end
    
    if not item then
        return {canUnlock = false, reason = "Unknown item"}
    end
    
    -- Check if already unlocked
    if self.saveManager:hasUnlock(string.sub(type, 1, -2), id) then  -- Remove 's' from type
        return {canUnlock = false, reason = "Already unlocked"}
    end
    
    -- Check cost
    local subscribers = self.saveManager:getData("totalSubscribers")
    if subscribers < item.cost then
        return {
            canUnlock = false, 
            cost = item.cost,
            reason = string.format("Need %d more subscribers", item.cost - subscribers)
        }
    end
    
    return {canUnlock = true, cost = item.cost}
end

function ProgressionManager:unlock(type, id)
    --[[
        Unlock an item
        
        @param type: "characters", "trucks", or "levels"
        @param id: Item ID
        @return: true if successful
    ]]
    
    local check = self:canUnlock(type, id)
    
    if not check.canUnlock then
        print("Cannot unlock:", check.reason)
        return false
    end
    
    if self.saveManager:spendSubscribers(check.cost) then
        local singularType = string.sub(type, 1, -2)  -- Remove 's'
        
        if singularType == "character" then
            self.saveManager:unlockCharacter(id)
        elseif singularType == "truck" then
            self.saveManager:unlockTruck(id)
        elseif singularType == "level" then
            self.saveManager:setData("unlockedLevels." .. id, true)
        end
        
        print(string.format("✓ Unlocked %s: %s", type, id))
        return true
    end
    
    return false
end

function ProgressionManager:checkMilestones()
    --[[
        Check if any milestones were reached
        
        @return: Array of milestone rewards
    ]]
    
    local totalSubs = self.saveManager:getData("totalSubscribers")
    local rewards = {}
    
    for _, milestone in ipairs(self.MILESTONES) do
        if totalSubs >= milestone.subscribers then
            -- Check if this milestone reward hasn't been claimed
            local claimed = self.saveManager:getData("milestones." .. milestone.reward)
            
            if not claimed then
                table.insert(rewards, milestone)
                self.saveManager:setData("milestones." .. milestone.reward, true)
                print(string.format("🏆 MILESTONE REACHED: %s", milestone.name))
            end
        end
    end
    
    return rewards
end

function ProgressionManager:calculateSubscribers(score, bonuses)
    --[[
        Convert score to subscribers (currency)
        
        @param score: Final score
        @param bonuses: Bonus multipliers
        @return: Subscribers earned
    ]]
    
    -- Base conversion: 10 score = 1 subscriber
    local baseSubscribers = math.floor(score / 10)
    
    -- Apply monetization upgrade
    local monetizationBonus = self:getUpgradeEffect("monetization")
    
    -- Apply verified badge bonus
    local verifiedBonus = self:getUpgradeEffect("verified_badge")
    
    -- Apply bonuses
    local bonusMultiplier = (bonuses and bonuses.multiplier) or 1.0
    
    -- Total calculation
    local totalSubscribers = math.floor(
        baseSubscribers * monetizationBonus * verifiedBonus * bonusMultiplier
    )
    
    return totalSubscribers
end

function ProgressionManager:recordRun(runData)
    --[[
        Record a completed run and award subscribers
        
        @param runData: {score, damage, hits, combo}
        @return: {subscribers, milestones}
    ]]
    
    -- Calculate subscribers earned
    local subscribers = self:calculateSubscribers(runData.score)
    
    -- Add to total
    self.saveManager:addSubscribers(subscribers)
    
    -- Record run stats
    self.saveManager:recordRun({
        score = runData.score,
        damage = runData.damage or 0,
        hits = runData.hits or 0,
        combo = runData.combo or 0,
        subscribers = subscribers
    })
    
    -- Check milestones
    local milestones = self:checkMilestones()
    
    return {
        subscribers = subscribers,
        milestones = milestones,
        totalSubscribers = self.saveManager:getData("totalSubscribers")
    }
end

function ProgressionManager:getProgressionStats()
    --[[
        Get progression statistics for UI display
        
        @return: Stats table
    ]]
    
    return {
        totalSubscribers = self.saveManager:getData("totalSubscribers"),
        totalRuns = self.saveManager:getData("totalRuns"),
        highScore = self.saveManager:getData("highScore"),
        upgrades = self.saveManager:getData("upgrades"),
        unlockedCharacters = #self.saveManager:getData("unlockedCharacters"),
        unlockedTrucks = #self.saveManager:getData("unlockedTrucks"),
        unlockedLevels = #self.saveManager:getData("unlockedLevels")
    }
end

return ProgressionManager
