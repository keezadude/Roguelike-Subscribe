-- src/audio/sound-manager.lua
-- Audio Management System
-- Handles sound effects, music, and audio playback

local SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager:new(options)
    local self = setmetatable({}, SoundManager)
    
    options = options or {}
    
    -- Audio settings
    self.masterVolume = options.masterVolume or 1.0
    self.sfxVolume = options.sfxVolume or 0.8
    self.musicVolume = options.musicVolume or 0.6
    self.enabled = options.enabled ~= false
    
    -- Sound storage
    self.sounds = {}
    self.music = {}
    
    -- Currently playing
    self.currentMusic = nil
    self.activeSounds = {}
    
    -- Base paths
    self.soundPath = "assets/sounds/"
    self.musicPath = "assets/sounds/music/"
    
    -- Sound categories
    self.categories = {
        impact = {},
        explosion = {},
        ui = {},
        engine = {},
        ambient = {}
    }
    
    return self
end

function SoundManager:loadSound(name, filePath, category)
    --[[
        Load a sound file
        
        @param name: Unique name for the sound
        @param filePath: Path to sound file (relative to soundPath)
        @param category: Category (impact, explosion, ui, etc.)
        @return: true if loaded successfully
    ]]
    
    category = category or "impact"
    local fullPath = self.soundPath .. filePath
    
    -- Check if file exists
    if not love.filesystem.getInfo(fullPath) then
        print("⚠ Sound file not found:", fullPath)
        return false
    end
    
    -- Load sound
    local success, sound = pcall(function()
        return love.audio.newSource(fullPath, "static")
    end)
    
    if not success or not sound then
        print("✗ Failed to load sound:", name, "->", fullPath)
        return false
    end
    
    -- Store sound
    self.sounds[name] = sound
    
    -- Add to category
    if not self.categories[category] then
        self.categories[category] = {}
    end
    table.insert(self.categories[category], name)
    
    print("✓ Sound loaded:", name)
    return true
end

function SoundManager:loadMusic(name, filePath)
    --[[
        Load music file
        
        @param name: Unique name for music
        @param filePath: Path to music file
        @return: true if loaded successfully
    ]]
    
    local fullPath = self.musicPath .. filePath
    
    if not love.filesystem.getInfo(fullPath) then
        print("⚠ Music file not found:", fullPath)
        return false
    end
    
    local success, music = pcall(function()
        return love.audio.newSource(fullPath, "stream")
    end)
    
    if not success or not music then
        print("✗ Failed to load music:", name)
        return false
    end
    
    music:setLooping(true)
    self.music[name] = music
    
    print("✓ Music loaded:", name)
    return true
end

function SoundManager:playSound(name, volume, pitch)
    --[[
        Play a sound effect
        
        @param name: Name of sound to play
        @param volume: Optional volume override (0-1)
        @param pitch: Optional pitch adjustment (default 1.0)
        @return: Sound source or nil
    ]]
    
    if not self.enabled then
        return nil
    end
    
    local sound = self.sounds[name]
    if not sound then
        -- Try to play from placeholder system
        return self:playPlaceholderSound()
    end
    
    -- Clone sound for multiple simultaneous plays
    local soundClone = sound:clone()
    
    -- Set volume
    local finalVolume = (volume or 1.0) * self.sfxVolume * self.masterVolume
    soundClone:setVolume(finalVolume)
    
    -- Set pitch
    if pitch then
        soundClone:setPitch(pitch)
    end
    
    -- Play
    soundClone:play()
    
    -- Track active sound
    table.insert(self.activeSounds, {
        source = soundClone,
        name = name,
        time = love.timer.getTime()
    })
    
    return soundClone
end

function SoundManager:playRandomFromCategory(category, volume)
    --[[
        Play a random sound from a category
        
        @param category: Category name
        @param volume: Optional volume
        @return: Sound source or nil
    ]]
    
    local sounds = self.categories[category]
    if not sounds or #sounds == 0 then
        return nil
    end
    
    local randomIndex = love.math.random(1, #sounds)
    local soundName = sounds[randomIndex]
    
    return self:playSound(soundName, volume)
end

function SoundManager:playImpactSound(impactType, damage)
    --[[
        Play an impact sound based on impact type and damage
        
        @param impactType: Type of impact (soft, medium, hard, massive)
        @param damage: Damage amount (used to select appropriate sound)
    ]]
    
    -- Select impact type based on damage
    local soundCategory = "impact"
    local volume = 0.5
    local pitch = 1.0
    
    if damage >= 100 then
        -- Massive impact
        volume = 1.0
        pitch = 0.8
    elseif damage >= 50 then
        -- Hard impact
        volume = 0.8
        pitch = 0.9
    elseif damage >= 20 then
        -- Medium impact
        volume = 0.6
        pitch = 1.0
    else
        -- Soft impact
        volume = 0.4
        pitch = 1.1
    end
    
    -- Add some random variation
    pitch = pitch + (love.math.random() * 0.2 - 0.1)
    
    return self:playRandomFromCategory(soundCategory, volume)
end

function SoundManager:playMusic(name, fadeIn)
    --[[
        Play background music
        
        @param name: Name of music track
        @param fadeIn: Optional fade-in duration (seconds)
    ]]
    
    if not self.enabled then
        return
    end
    
    local music = self.music[name]
    if not music then
        print("⚠ Music not found:", name)
        return
    end
    
    -- Stop current music
    if self.currentMusic then
        self.currentMusic:stop()
    end
    
    -- Set volume
    music:setVolume(self.musicVolume * self.masterVolume)
    
    -- Play
    music:play()
    self.currentMusic = music
    
    print("♪ Playing music:", name)
end

function SoundManager:stopMusic(fadeOut)
    --[[
        Stop current music
        
        @param fadeOut: Optional fade-out duration (seconds)
    ]]
    
    if self.currentMusic then
        self.currentMusic:stop()
        self.currentMusic = nil
    end
end

function SoundManager:setMasterVolume(volume)
    --[[
        Set master volume
        
        @param volume: Volume level (0-1)
    ]]
    
    self.masterVolume = math.max(0, math.min(1, volume))
    
    -- Update current music volume
    if self.currentMusic then
        self.currentMusic:setVolume(self.musicVolume * self.masterVolume)
    end
end

function SoundManager:setSFXVolume(volume)
    --[[
        Set sound effects volume
        
        @param volume: Volume level (0-1)
    ]]
    
    self.sfxVolume = math.max(0, math.min(1, volume))
end

function SoundManager:setMusicVolume(volume)
    --[[
        Set music volume
        
        @param volume: Volume level (0-1)
    ]]
    
    self.musicVolume = math.max(0, math.min(1, volume))
    
    if self.currentMusic then
        self.currentMusic:setVolume(self.musicVolume * self.masterVolume)
    end
end

function SoundManager:setEnabled(enabled)
    --[[
        Enable or disable all audio
        
        @param enabled: true/false
    ]]
    
    self.enabled = enabled
    
    if not enabled then
        self:stopMusic()
        self:stopAllSounds()
    end
end

function SoundManager:stopAllSounds()
    --[[
        Stop all currently playing sounds
    ]]
    
    for _, soundData in ipairs(self.activeSounds) do
        if soundData.source then
            soundData.source:stop()
        end
    end
    
    self.activeSounds = {}
end

function SoundManager:update(dt)
    --[[
        Update audio system (cleanup finished sounds)
        
        @param dt: Delta time
    ]]
    
    -- Remove finished sounds
    for i = #self.activeSounds, 1, -1 do
        local soundData = self.activeSounds[i]
        if not soundData.source:isPlaying() then
            table.remove(self.activeSounds, i)
        end
    end
end

function SoundManager:playPlaceholderSound()
    --[[
        Play a placeholder beep when actual sound not available
        
        @return: nil (placeholder system)
    ]]
    
    -- Could generate a simple beep using love.audio.newSource with SoundData
    -- For now, just return nil silently
    return nil
end

function SoundManager:getStats()
    --[[
        Get audio system statistics
        
        @return: Stats table
    ]]
    
    return {
        loadedSounds = #self.sounds,
        loadedMusic = #self.music,
        activeSounds = #self.activeSounds,
        masterVolume = self.masterVolume,
        sfxVolume = self.sfxVolume,
        musicVolume = self.musicVolume,
        enabled = self.enabled
    }
end

return SoundManager
