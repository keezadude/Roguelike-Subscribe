-- src/ui/main-menu.lua
-- Main menu implementation
-- Week 0 Day 4 - Main Menu

local Animations = require('src.ui.animations')

local MainMenu = {}
MainMenu.__index = MainMenu

function MainMenu:new(menuManager)
    local self = setmetatable({}, MainMenu)
    
    self.menuManager = menuManager
    self.buttons = {}
    self.backgroundOpacity = 0
    self.titleY = -100
    
    -- UI sprites (will be loaded from exports)
    self.sprites = {
        buttonPrimary = nil, -- TODO: Load from assets/images/ui/button-primary-md-normal.png
        buttonSecondary = nil,
        logo = nil,
    }
    
    return self
end

function MainMenu:init()
    -- Load UI sprites here when exported
    -- self.sprites.buttonPrimary = love.graphics.newImage("assets/images/ui/button-primary-md-normal.png")
end

function MainMenu:enter()
    print("Entering Main Menu")
    
    -- Clear previous buttons
    self.menuManager:clearButtons()
    
    -- Screen center
    local centerX = love.graphics.getWidth() / 2
    local centerY = love.graphics.getHeight() / 2
    
    -- Create buttons
    local buttonSpacing = 80
    local startY = centerY - 40
    
    self.buttons.play = self.menuManager:createButton(
        "play",
        centerX,
        startY,
        200,
        50,
        "START GAME",
        function() 
            print("Starting game...")
            -- TODO: Transition to game state
        end
    )
    
    self.buttons.settings = self.menuManager:createButton(
        "settings",
        centerX,
        startY + buttonSpacing,
        200,
        50,
        "SETTINGS",
        function() 
            self.menuManager:setState(self.menuManager.States.SETTINGS)
        end
    )
    
    self.buttons.achievements = self.menuManager:createButton(
        "achievements",
        centerX,
        startY + buttonSpacing * 2,
        200,
        50,
        "ACHIEVEMENTS",
        function() 
            self.menuManager:setState(self.menuManager.States.ACHIEVEMENTS)
        end
    )
    
    self.buttons.quit = self.menuManager:createButton(
        "quit",
        centerX,
        startY + buttonSpacing * 3,
        200,
        50,
        "QUIT",
        function() 
            love.event.quit()
        end
    )
    
    -- Animate entrance
    self.backgroundOpacity = 0
    Animations.patterns.fadeIn({opacity = 0}, 0.5, 0)
    
    self.titleY = -100
    Animations.patterns.slideIn({y = self.titleY}, "top", 100, 0.8, 0.2)
    
    -- Stagger button animations
    local buttons = {self.buttons.play, self.buttons.settings, self.buttons.achievements, self.buttons.quit}
    Animations.patterns.stagger(buttons, function(button, delay)
        return Animations.patterns.scalePop(button, 1.0, 0.4, delay + 0.3)
    end, 0.1)
end

function MainMenu:exit()
    print("Exiting Main Menu")
end

function MainMenu:update(dt)
    -- Update button hover states
    for _, button in pairs(self.buttons) do
        self.menuManager:updateButton(button, dt)
    end
end

function MainMenu:draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    
    -- Background gradient
    love.graphics.setColor(0.05, 0.05, 0.1)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    local titleFont = love.graphics.newFont(48)
    love.graphics.setFont(titleFont)
    local title = "ROGUELIKE & SUBSCRIBE"
    local titleWidth = titleFont:getWidth(title)
    love.graphics.print(title, w/2 - titleWidth/2, 100)
    
    -- Subtitle
    local subtitleFont = love.graphics.newFont(16)
    love.graphics.setFont(subtitleFont)
    love.graphics.setColor(0.7, 0.7, 0.8)
    local subtitle = "Week 0 - UI Foundation Complete"
    local subtitleWidth = subtitleFont:getWidth(subtitle)
    love.graphics.print(subtitle, w/2 - subtitleWidth/2, 160)
    
    -- Draw buttons
    love.graphics.setFont(love.graphics.newFont(20))
    for _, button in pairs(self.buttons) do
        self.menuManager:drawButton(button, self.sprites.buttonPrimary)
    end
    
    -- Footer instructions
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(0.5, 0.5, 0.6)
    love.graphics.print("Hover over buttons to see animations | ESC to quit", 10, h - 30)
    
    love.graphics.setColor(1, 1, 1)
end

function MainMenu:mousepressed(x, y, button)
    if button == 1 then -- Left click
        for _, btn in pairs(self.buttons) do
            if self.menuManager:handleButtonClick(btn) then
                break
            end
        end
    end
end

function MainMenu:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return MainMenu
