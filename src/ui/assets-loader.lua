-- src/ui/assets-loader.lua
-- UI asset management
-- Week 0 Day 4

local AssetsLoader = {}

-- Asset paths
AssetsLoader.paths = {
    ui = "assets/images/ui/",
}

-- Loaded assets
AssetsLoader.ui = {
    -- Buttons
    buttonPrimarySmall = {
        normal = nil,
        hover = nil,
        active = nil,
    },
    buttonPrimaryMedium = {
        normal = nil,
        hover = nil,
        active = nil,
    },
    buttonPrimaryLarge = {
        normal = nil,
        hover = nil,
        active = nil,
    },
    
    -- HUD
    scoreDisplay = {
        normal = nil,
        combo = nil,
    },
    progressBar = {
        cyan = nil,
        green = nil,
        purple = nil,
        orange = nil,
    },
    
    -- Panels
    panelBackground = nil,
    
    -- Cards
    achievementUnlocked = nil,
    achievementLocked = nil,
    upgradeAvailable = nil,
    upgradeLocked = nil,
    
    -- Modals
    modalDialog = nil,
    loadingScreen = nil,
}

-- Load a single UI sprite
function AssetsLoader.loadSprite(filename)
    local path = AssetsLoader.paths.ui .. filename
    
    -- Check if file exists
    local info = love.filesystem.getInfo(path)
    if not info then
        print("⚠ UI sprite not found:", path)
        print("  → Export from design/ui-design showcase and place in assets/images/ui/")
        return nil
    end
    
    local success, sprite = pcall(love.graphics.newImage, path)
    if success then
        print("✓ Loaded UI sprite:", filename)
        return sprite
    else
        print("✗ Failed to load sprite:", filename)
        print("  Error:", sprite)
        return nil
    end
end

-- Load all UI assets
function AssetsLoader.loadAll()
    print("\n=== Loading UI Assets ===")
    
    local loaded = 0
    local total = 0
    
    -- Load button sprites
    for _, size in ipairs({"small", "medium", "large"}) do
        for _, state in ipairs({"normal", "hover", "active"}) do
            total = total + 1
            local filename = string.format("button-primary-%s-%s.png", size, state)
            local sprite = AssetsLoader.loadSprite(filename)
            if sprite then
                AssetsLoader.ui["buttonPrimary" .. size:sub(1,1):upper() .. size:sub(2)][state] = sprite
                loaded = loaded + 1
            end
        end
    end
    
    -- Load HUD sprites
    total = total + 2
    AssetsLoader.ui.scoreDisplay.normal = AssetsLoader.loadSprite("score-display-normal.png")
    AssetsLoader.ui.scoreDisplay.combo = AssetsLoader.loadSprite("score-display-combo.png")
    if AssetsLoader.ui.scoreDisplay.normal then loaded = loaded + 1 end
    if AssetsLoader.ui.scoreDisplay.combo then loaded = loaded + 1 end
    
    -- Load progress bars
    for _, variant in ipairs({"cyan", "green", "purple", "orange"}) do
        total = total + 1
        local sprite = AssetsLoader.loadSprite("progress-bar-" .. variant .. ".png")
        if sprite then
            AssetsLoader.ui.progressBar[variant] = sprite
            loaded = loaded + 1
        end
    end
    
    -- Load panel
    total = total + 1
    AssetsLoader.ui.panelBackground = AssetsLoader.loadSprite("panel-background.png")
    if AssetsLoader.ui.panelBackground then loaded = loaded + 1 end
    
    -- Load cards
    total = total + 4
    AssetsLoader.ui.achievementUnlocked = AssetsLoader.loadSprite("achievement-unlocked.png")
    AssetsLoader.ui.achievementLocked = AssetsLoader.loadSprite("achievement-locked.png")
    AssetsLoader.ui.upgradeAvailable = AssetsLoader.loadSprite("upgrade-available.png")
    AssetsLoader.ui.upgradeLocked = AssetsLoader.loadSprite("upgrade-locked.png")
    if AssetsLoader.ui.achievementUnlocked then loaded = loaded + 1 end
    if AssetsLoader.ui.achievementLocked then loaded = loaded + 1 end
    if AssetsLoader.ui.upgradeAvailable then loaded = loaded + 1 end
    if AssetsLoader.ui.upgradeLocked then loaded = loaded + 1 end
    
    -- Load modals
    total = total + 2
    AssetsLoader.ui.modalDialog = AssetsLoader.loadSprite("modal-dialog.png")
    AssetsLoader.ui.loadingScreen = AssetsLoader.loadSprite("loading-screen.png")
    if AssetsLoader.ui.modalDialog then loaded = loaded + 1 end
    if AssetsLoader.ui.loadingScreen then loaded = loaded + 1 end
    
    print(string.format("\n=== UI Assets: %d/%d loaded ===", loaded, total))
    
    if loaded == 0 then
        print("\n⚠ No UI sprites found!")
        print("📸 Export components from http://localhost:3000")
        print("📁 Place PNG files in assets/images/ui/")
        print("✅ Game will use placeholder graphics until sprites are exported")
    end
    
    return loaded, total
end

-- Get button sprite for current state
function AssetsLoader.getButtonSprite(size, state)
    size = size or "medium"
    state = state or "normal"
    
    local sizeKey = "buttonPrimary" .. size:sub(1,1):upper() .. size:sub(2)
    return AssetsLoader.ui[sizeKey] and AssetsLoader.ui[sizeKey][state]
end

return AssetsLoader
