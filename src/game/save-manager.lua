-- src/game/save-manager.lua
-- Save/Load System
-- Handles game persistence and progress saving

local SaveManager = {}
SaveManager.__index = SaveManager

function SaveManager:new(options)
    local self = setmetatable({}, SaveManager)
    
    options = options or {}
    
    -- Save file path
    self.savePath = options.savePath or "save_data.json"
    
    -- Current save data
    self.data = {
        version = "1.0.0",
        created = os.time(),
        lastPlayed = os.time(),
        
        -- Progression
        totalSubscribers = 0,  -- Currency
        totalRuns = 0,
        totalScore = 0,
        highScore = 0,
        
        -- Unlocks
        unlockedCharacters = {"default"},
        unlockedTrucks = {"default"},
        unlockedLevels = {"arena_01"},
        
        -- Upgrades
        upgrades = {
            truckPower = 0,
            truckArmor = 0,
            subscriberBonus = 0,
            comboBonus = 0
        },
        
        -- Statistics
        stats = {
            totalDamage = 0,
            totalHits = 0,
            maxCombo = 0,
            headshots = 0,
            perfectLaunches = 0
        },
        
        -- Settings
        settings = {
            masterVolume = 0.8,
            sfxVolume = 0.7,
            musicVolume = 0.5,
            debugMode = false
        }
    }
    
    -- Load existing save if present
    self:load()
    
    return self
end

function SaveManager:save()
    --[[
        Save current data to file
        
        @return: true if successful
    ]]
    
    -- Update last played time
    self.data.lastPlayed = os.time()
    
    -- Serialize data to JSON
    local success, jsonData = pcall(function()
        return self:serializeTable(self.data)
    end)
    
    if not success then
        print("✗ Failed to serialize save data:", jsonData)
        return false
    end
    
    -- Write to file
    success = love.filesystem.write(self.savePath, jsonData)
    
    if success then
        print("✓ Game saved successfully")
        return true
    else
        print("✗ Failed to write save file")
        return false
    end
end

function SaveManager:load()
    --[[
        Load data from file
        
        @return: true if successful
    ]]
    
    -- Check if save file exists
    if not love.filesystem.getInfo(self.savePath) then
        print("ℹ No save file found, using defaults")
        return false
    end
    
    -- Read file
    local contents, err = love.filesystem.read(self.savePath)
    
    if not contents then
        print("✗ Failed to read save file:", err)
        return false
    end
    
    -- Deserialize JSON
    local success, loadedData = pcall(function()
        return self:deserializeTable(contents)
    end)
    
    if not success then
        print("✗ Failed to parse save data:", loadedData)
        return false
    end
    
    -- Merge loaded data (preserve structure for new fields)
    self:mergeData(loadedData)
    
    print("✓ Save data loaded successfully")
    return true
end

function SaveManager:mergeData(loadedData)
    --[[
        Merge loaded data with defaults (handles version updates)
    ]]
    
    -- Simple deep merge (preserves new fields in defaults)
    for key, value in pairs(loadedData) do
        if type(value) == "table" and type(self.data[key]) == "table" then
            for subKey, subValue in pairs(value) do
                self.data[key][subKey] = subValue
            end
        else
            self.data[key] = value
        end
    end
end

function SaveManager:deleteSave()
    --[[
        Delete save file
        
        @return: true if successful
    ]]
    
    local success = love.filesystem.remove(self.savePath)
    
    if success then
        print("✓ Save file deleted")
        -- Reset to defaults
        self:new()
        return true
    else
        print("✗ Failed to delete save file")
        return false
    end
end

function SaveManager:getData(key)
    --[[
        Get data value
        
        @param key: Data key (can be nested like "upgrades.truckPower")
        @return: Value or nil
    ]]
    
    local keys = {}
    for k in string.gmatch(key, "[^%.]+") do
        table.insert(keys, k)
    end
    
    local value = self.data
    for _, k in ipairs(keys) do
        if value[k] then
            value = value[k]
        else
            return nil
        end
    end
    
    return value
end

function SaveManager:setData(key, value)
    --[[
        Set data value
        
        @param key: Data key (can be nested)
        @param value: Value to set
    ]]
    
    local keys = {}
    for k in string.gmatch(key, "[^%.]+") do
        table.insert(keys, k)
    end
    
    local data = self.data
    for i = 1, #keys - 1 do
        local k = keys[i]
        if not data[k] then
            data[k] = {}
        end
        data = data[k]
    end
    
    data[keys[#keys]] = value
end

function SaveManager:addSubscribers(amount)
    --[[
        Add subscribers (currency)
        
        @param amount: Subscribers to add
    ]]
    
    self.data.totalSubscribers = self.data.totalSubscribers + amount
    print(string.format("+ %d subscribers (Total: %d)", amount, self.data.totalSubscribers))
end

function SaveManager:spendSubscribers(amount)
    --[[
        Spend subscribers
        
        @param amount: Subscribers to spend
        @return: true if had enough
    ]]
    
    if self.data.totalSubscribers >= amount then
        self.data.totalSubscribers = self.data.totalSubscribers - amount
        return true
    end
    
    return false
end

function SaveManager:unlockCharacter(characterId)
    --[[
        Unlock a character
        
        @param characterId: Character to unlock
    ]]
    
    if not self:hasUnlock("character", characterId) then
        table.insert(self.data.unlockedCharacters, characterId)
        print("✓ Unlocked character:", characterId)
    end
end

function SaveManager:unlockTruck(truckId)
    --[[
        Unlock a truck
        
        @param truckId: Truck to unlock
    ]]
    
    if not self:hasUnlock("truck", truckId) then
        table.insert(self.data.unlockedTrucks, truckId)
        print("✓ Unlocked truck:", truckId)
    end
end

function SaveManager:hasUnlock(type, id)
    --[[
        Check if something is unlocked
        
        @param type: "character", "truck", or "level"
        @param id: Item ID
        @return: true if unlocked
    ]]
    
    local list
    if type == "character" then
        list = self.data.unlockedCharacters
    elseif type == "truck" then
        list = self.data.unlockedTrucks
    elseif type == "level" then
        list = self.data.unlockedLevels
    else
        return false
    end
    
    for _, item in ipairs(list) do
        if item == id then
            return true
        end
    end
    
    return false
end

function SaveManager:upgradeLevel(upgradeId)
    --[[
        Get upgrade level
        
        @param upgradeId: Upgrade ID
        @return: Current level
    ]]
    
    return self.data.upgrades[upgradeId] or 0
end

function SaveManager:purchaseUpgrade(upgradeId)
    --[[
        Purchase an upgrade level
        
        @param upgradeId: Upgrade to purchase
    ]]
    
    self.data.upgrades[upgradeId] = (self.data.upgrades[upgradeId] or 0) + 1
end

function SaveManager:recordRun(runData)
    --[[
        Record a completed run
        
        @param runData: {score, damage, hits, combo, subscribers}
    ]]
    
    self.data.totalRuns = self.data.totalRuns + 1
    self.data.totalScore = self.data.totalScore + runData.score
    
    if runData.score > self.data.highScore then
        self.data.highScore = runData.score
        print("🏆 NEW HIGH SCORE:", runData.score)
    end
    
    -- Update stats
    self.data.stats.totalDamage = self.data.stats.totalDamage + (runData.damage or 0)
    self.data.stats.totalHits = self.data.stats.totalHits + (runData.hits or 0)
    
    if (runData.combo or 0) > self.data.stats.maxCombo then
        self.data.stats.maxCombo = runData.combo
    end
    
    -- Auto-save after run
    self:save()
end

function SaveManager:serializeTable(t, indent)
    --[[
        Simple JSON serialization
    ]]
    
    indent = indent or 0
    local spacing = string.rep("  ", indent)
    local result = "{\n"
    
    local first = true
    for k, v in pairs(t) do
        if not first then
            result = result .. ",\n"
        end
        first = false
        
        result = result .. spacing .. "  \"" .. tostring(k) .. "\": "
        
        if type(v) == "table" then
            result = result .. self:serializeTable(v, indent + 1)
        elseif type(v) == "string" then
            result = result .. "\"" .. v .. "\""
        elseif type(v) == "boolean" then
            result = result .. tostring(v)
        else
            result = result .. tostring(v)
        end
    end
    
    result = result .. "\n" .. spacing .. "}"
    return result
end

function SaveManager:deserializeTable(jsonString)
    --[[
        Simple JSON deserialization (uses built-in if available)
    ]]
    
    -- Try to use built-in JSON library
    if json then
        return json.decode(jsonString)
    end
    
    -- Fallback: very basic parser (not production-ready)
    -- In real game, would use proper JSON library
    local func = load("return " .. jsonString)
    if func then
        return func()
    end
    
    return {}
end

return SaveManager
