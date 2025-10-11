-- src/progression/achievement-system.lua
-- Achievement System with Subscribe Theme
-- Tracks and unlocks 30 achievements with Steam integration hooks

local AchievementSystem = {}
AchievementSystem.__index = AchievementSystem

-- Achievement definitions (Subscribe-themed)
AchievementSystem.ACHIEVEMENTS = {
    -- Subscriber Milestones
    {
        id = "first_sub",
        name = "First Subscriber!",
        description = "Earn your first subscriber",
        icon = "👤",
        requirement = {type = "subscribers", value = 1},
        hidden = false
    },
    {
        id = "hundred_subs",
        name = "100 Subscribers",
        description = "Reach 100 total subscribers",
        icon = "📈",
        requirement = {type = "subscribers", value = 100},
        hidden = false
    },
    {
        id = "thousand_subs",
        name = "1K Subs Milestone",
        description = "Hit 1,000 subscribers",
        icon = "🎯",
        requirement = {type = "subscribers", value = 1000},
        hidden = false
    },
    {
        id = "ten_k_subs",
        name = "10K Subs!",
        description = "Reach 10,000 subscribers",
        icon = "⭐",
        requirement = {type = "subscribers", value = 10000},
        hidden = false
    },
    {
        id = "hundred_k_subs",
        name = "VERIFIED",
        description = "Reach 100,000 subscribers - VERIFIED STATUS!",
        icon = "✓",
        requirement = {type = "subscribers", value = 100000},
        hidden = false
    },
    {
        id = "million_subs",
        name = "Mega Influencer",
        description = "Reach 1,000,000 subscribers",
        icon = "👑",
        requirement = {type = "subscribers", value = 1000000},
        hidden = false
    },
    
    -- Score Achievements
    {
        id = "first_blood",
        name = "First Blood",
        description = "Complete your first run",
        icon = "🎬",
        requirement = {type = "runs", value = 1},
        hidden = false
    },
    {
        id = "score_10k",
        name = "Viral Content",
        description = "Score 10,000 points in a single run",
        icon = "🔥",
        requirement = {type = "single_run_score", value = 10000},
        hidden = false
    },
    {
        id = "score_25k",
        name = "Trending Topic",
        description = "Score 25,000 points in a single run",
        icon = "📊",
        requirement = {type = "single_run_score", value = 25000},
        hidden = false
    },
    {
        id = "score_50k",
        name = "Going Viral",
        description = "Score 50,000 points in a single run",
        icon = "💫",
        requirement = {type = "single_run_score", value = 50000},
        hidden = false
    },
    {
        id = "score_100k",
        name = "Internet Famous",
        description = "Score 100,000 points in a single run",
        icon = "🌟",
        requirement = {type = "single_run_score", value = 100000},
        hidden = false
    },
    
    -- Combo Achievements
    {
        id = "combo_5",
        name = "Engagement Rate",
        description = "Hit a 5x combo",
        icon = "⚡",
        requirement = {type = "max_combo", value = 5},
        hidden = false
    },
    {
        id = "combo_10",
        name = "Algorithm Boost",
        description = "Hit a 10x combo",
        icon = "🚀",
        requirement = {type = "max_combo", value = 10},
        hidden = false
    },
    {
        id = "combo_20",
        name = "Going Mainstream",
        description = "Hit a 20x combo",
        icon = "💥",
        requirement = {type = "max_combo", value = 20},
        hidden = false
    },
    
    -- Damage Achievements
    {
        id = "headshot_master",
        name = "Headshot Master",
        description = "Land 100 headshots",
        icon = "🎯",
        requirement = {type = "headshots", value = 100},
        hidden = false
    },
    {
        id = "overkill_king",
        name = "Overkill King",
        description = "Get 50 overkill hits",
        icon = "💀",
        requirement = {type = "overkills", value = 50},
        hidden = false
    },
    {
        id = "airborne_artist",
        name = "Airborne Artist",
        description = "Get 25 airborne hits",
        icon = "🦅",
        requirement = {type = "airborne_hits", value = 25},
        hidden = false
    },
    
    -- Run-Based Achievements
    {
        id = "persistent",
        name = "Persistent Creator",
        description = "Complete 10 runs",
        icon = "📹",
        requirement = {type = "runs", value = 10},
        hidden = false
    },
    {
        id = "dedicated",
        name = "Dedicated Streamer",
        description = "Complete 50 runs",
        icon = "🎮",
        requirement = {type = "runs", value = 50},
        hidden = false
    },
    {
        id = "content_machine",
        name = "Content Machine",
        description = "Complete 100 runs",
        icon = "🎬",
        requirement = {type = "runs", value = 100},
        hidden = false
    },
    
    -- Upgrade Achievements
    {
        id = "first_upgrade",
        name = "First Upgrade",
        description = "Purchase your first upgrade",
        icon = "⬆️",
        requirement = {type = "upgrades_purchased", value = 1},
        hidden = false
    },
    {
        id = "fully_upgraded",
        name = "Max Power",
        description = "Max out any upgrade",
        icon = "💪",
        requirement = {type = "max_upgrade", value = 1},
        hidden = false
    },
    {
        id = "whale",
        name = "Big Spender",
        description = "Spend 10,000 subscribers on upgrades",
        icon = "💰",
        requirement = {type = "total_spent", value = 10000},
        hidden = false
    },
    
    -- Collection Achievements
    {
        id = "character_collector",
        name = "Character Collector",
        description = "Unlock all characters",
        icon = "🎭",
        requirement = {type = "unlock_all_characters", value = 1},
        hidden = false
    },
    {
        id = "truck_enthusiast",
        name = "Truck Enthusiast",
        description = "Unlock all trucks",
        icon = "🚚",
        requirement = {type = "unlock_all_trucks", value = 1},
        hidden = false
    },
    {
        id = "completionist",
        name = "Completionist",
        description = "Unlock everything in the game",
        icon = "🏆",
        requirement = {type = "unlock_everything", value = 1},
        hidden = false
    },
    
    -- Skill Achievements
    {
        id = "perfect_launch",
        name = "Perfect Launch",
        description = "Launch at exactly 100% power",
        icon = "🎯",
        requirement = {type = "perfect_launches", value = 1},
        hidden = false
    },
    {
        id = "one_shot",
        name = "One-Shot Wonder",
        description = "Defeat a ragdoll with a single hit",
        icon = "💫",
        requirement = {type = "one_shot_kills", value = 1},
        hidden = false
    },
    {
        id = "no_damage",
        name = "Untouchable",
        description = "Complete a run without the truck getting damaged",
        icon = "🛡️",
        requirement = {type = "perfect_runs", value = 1},
        hidden = true  -- Hidden achievement
    },
    
    -- Secret Achievements
    {
        id = "secret_speed",
        name = "Speed Demon",
        description = "Reach maximum vehicle speed",
        icon = "⚡",
        requirement = {type = "max_speed_reached", value = 500},
        hidden = true
    },
    {
        id = "secret_dedication",
        name = "True Fan",
        description = "Play for 10 hours total",
        icon = "❤️",
        requirement = {type = "playtime_hours", value = 10},
        hidden = true
    },
    
    -- NEW: Content Expansion Achievements
    {
        id = "world_traveler",
        name = "World Traveler",
        description = "Play on 5 different levels",
        icon = "🌍",
        requirement = {type = "levels_played", value = 5},
        hidden = false
    },
    {
        id = "garage_king",
        name = "Garage King",
        description = "Unlock 5 different vehicles",
        icon = "🚗",
        requirement = {type = "vehicles_unlocked", value = 5},
        hidden = false
    },
    {
        id = "content_creator",
        name = "Content Creator",
        description = "Unlock all characters",
        icon = "🎬",
        requirement = {type = "all_characters", value = 1},
        hidden = false
    },
    {
        id = "fully_upgraded",
        name = "Fully Upgraded",
        description = "Max out any upgrade",
        icon = "⭐",
        requirement = {type = "max_upgrade", value = 1},
        hidden = false
    },
    {
        id = "high_roller",
        name = "High Roller",
        description = "Earn 100,000 subscribers",
        icon = "💰",
        requirement = {type = "subscribers", value = 100000},
        hidden = false
    },
    {
        id = "extreme_sports",
        name = "Extreme Sports",
        description = "Complete a run on the Volcano level",
        icon = "🌋",
        requirement = {type = "volcano_cleared", value = 1},
        hidden = true
    }
}

function AchievementSystem:new(saveManager)
    local self = setmetatable({}, AchievementSystem)
    
    self.saveManager = saveManager
    
    -- Initialize achievements in save data if not present
    if not self.saveManager:getData("achievements") then
        local achievementData = {}
        for _, achievement in ipairs(self.ACHIEVEMENTS) do
            achievementData[achievement.id] = {
                unlocked = false,
                unlockedAt = nil,
                progress = 0
            }
        end
        self.saveManager:setData("achievements", achievementData)
    end
    
    -- Recently unlocked achievements (for notifications)
    self.recentlyUnlocked = {}
    
    -- Steam integration hook
    self.steamAvailable = false
    
    return self
end

function AchievementSystem:checkAchievements(stats)
    --[[
        Check and unlock achievements based on current stats
        
        @param stats: Table of statistics to check against
        @return: Array of newly unlocked achievements
    ]]
    
    local newlyUnlocked = {}
    
    for _, achievement in ipairs(self.ACHIEVEMENTS) do
        if not self:isUnlocked(achievement.id) then
            if self:checkRequirement(achievement, stats) then
                self:unlock(achievement.id)
                table.insert(newlyUnlocked, achievement)
            end
        end
    end
    
    return newlyUnlocked
end

function AchievementSystem:checkRequirement(achievement, stats)
    --[[
        Check if achievement requirement is met
        
        @param achievement: Achievement definition
        @param stats: Current statistics
        @return: true if requirement met
    ]]
    
    local req = achievement.requirement
    local value = stats[req.type] or 0
    
    return value >= req.value
end

function AchievementSystem:unlock(achievementId)
    --[[
        Unlock an achievement
        
        @param achievementId: ID of achievement to unlock
    ]]
    
    local achievementData = self.saveManager:getData("achievements")
    
    if achievementData[achievementId] and not achievementData[achievementId].unlocked then
        achievementData[achievementId].unlocked = true
        achievementData[achievementId].unlockedAt = os.time()
        
        -- Update save data
        self.saveManager:setData("achievements." .. achievementId, achievementData[achievementId])
        
        -- Add to recently unlocked
        table.insert(self.recentlyUnlocked, achievementId)
        
        -- Find achievement definition
        local achievement = self:getAchievement(achievementId)
        if achievement then
            print(string.format("🏆 ACHIEVEMENT UNLOCKED: %s - %s", 
                achievement.name, achievement.description))
        end
        
        -- Steam integration hook
        if self.steamAvailable then
            self:unlockSteamAchievement(achievementId)
        end
        
        -- Note: Save is now handled by caller to batch multiple achievements
    end
end

function AchievementSystem:isUnlocked(achievementId)
    --[[
        Check if achievement is unlocked
        
        @param achievementId: ID to check
        @return: true if unlocked
    ]]
    
    local achievementData = self.saveManager:getData("achievements")
    return achievementData[achievementId] and achievementData[achievementId].unlocked or false
end

function AchievementSystem:getAchievement(achievementId)
    --[[
        Get achievement definition by ID
        
        @param achievementId: Achievement ID
        @return: Achievement table or nil
    ]]
    
    for _, achievement in ipairs(self.ACHIEVEMENTS) do
        if achievement.id == achievementId then
            return achievement
        end
    end
    
    return nil
end

function AchievementSystem:getAllAchievements()
    --[[
        Get all achievements with unlock status
        
        @return: Array of achievements with status
    ]]
    
    local achievements = {}
    local achievementData = self.saveManager:getData("achievements")
    
    for _, achievement in ipairs(self.ACHIEVEMENTS) do
        local status = achievementData[achievement.id] or {unlocked = false}
        
        table.insert(achievements, {
            id = achievement.id,
            name = achievement.name,
            description = achievement.description,
            icon = achievement.icon,
            requirement = achievement.requirement,
            hidden = achievement.hidden,
            unlocked = status.unlocked,
            unlockedAt = status.unlockedAt
        })
    end
    
    return achievements
end

function AchievementSystem:getUnlockedCount()
    --[[
        Get number of unlocked achievements
        
        @return: Count of unlocked achievements
    ]]
    
    local count = 0
    local achievementData = self.saveManager:getData("achievements")
    
    for _, achievement in ipairs(self.ACHIEVEMENTS) do
        if achievementData[achievement.id] and achievementData[achievement.id].unlocked then
            count = count + 1
        end
    end
    
    return count
end

function AchievementSystem:getTotalCount()
    --[[
        Get total number of achievements
        
        @return: Total achievement count
    ]]
    
    return #self.ACHIEVEMENTS
end

function AchievementSystem:getCompletionPercentage()
    --[[
        Get achievement completion percentage
        
        @return: Percentage (0-100)
    ]]
    
    return (self:getUnlockedCount() / self:getTotalCount()) * 100
end

function AchievementSystem:getRecentlyUnlocked()
    --[[
        Get recently unlocked achievements (for notifications)
        
        @return: Array of achievement IDs
    ]]
    
    return self.recentlyUnlocked
end

function AchievementSystem:clearRecentlyUnlocked()
    --[[
        Clear recently unlocked list
    ]]
    
    self.recentlyUnlocked = {}
end

function AchievementSystem:unlockSteamAchievement(achievementId)
    --[[
        Hook for Steam achievement unlocking
        
        @param achievementId: Achievement to unlock on Steam
    ]]
    
    -- Placeholder for Steam SDK integration
    -- Will be implemented in Week 6
    print(string.format("[Steam] Achievement unlocked: %s", achievementId))
end

function AchievementSystem:setSteamAvailable(available)
    --[[
        Set Steam availability
        
        @param available: true if Steam SDK is available
    ]]
    
    self.steamAvailable = available
end

return AchievementSystem
