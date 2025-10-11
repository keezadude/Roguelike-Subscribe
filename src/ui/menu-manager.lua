-- src/ui/menu-manager.lua
-- Menu state management and navigation
-- Week 0 Day 4 - Menu System

local Slab = require('lib.Slab')
local Animations = require('src.ui.animations')

local MenuManager = {}
MenuManager.__index = MenuManager

-- Menu states
MenuManager.States = {
    MAIN_MENU = "main_menu",
    SETTINGS = "settings",
    ACHIEVEMENTS = "achievements",
    UPGRADES = "upgrades",
    PAUSE = "pause",
    GAME_OVER = "game_over",
}

function MenuManager:new()
    local self = setmetatable({}, MenuManager)
    
    self.currentState = MenuManager.States.MAIN_MENU
    self.previousState = nil
    self.menus = {}
    self.transition = {
        active = false,
        duration = 0.3,
        timer = 0,
        from = nil,
        to = nil,
    }
    
    -- UI elements tracking
    self.buttons = {}
    self.hoveredButton = nil
    self.pressedButton = nil
    
    return self
end

-- Register a menu
function MenuManager:registerMenu(name, menu)
    self.menus[name] = menu
    if menu.init then
        menu:init()
    end
end

-- Change menu state
function MenuManager:setState(newState, transition)
    if self.currentState == newState then return end
    
    transition = transition ~= false -- default true
    
    -- Store previous state
    self.previousState = self.currentState
    
    -- Exit current menu
    if self.menus[self.currentState] and self.menus[self.currentState].exit then
        self.menus[self.currentState]:exit()
    end
    
    if transition then
        -- Animate transition
        self.transition.active = true
        self.transition.timer = 0
        self.transition.from = self.currentState
        self.transition.to = newState
    else
        -- Instant transition
        self.currentState = newState
        
        -- Enter new menu
        if self.menus[newState] and self.menus[newState].enter then
            self.menus[newState]:enter()
        end
    end
end

-- Go back to previous menu
function MenuManager:back()
    if self.previousState then
        self:setState(self.previousState)
    end
end

-- Update menu manager
function MenuManager:update(dt)
    -- Update transitions
    if self.transition.active then
        self.transition.timer = self.transition.timer + dt
        
        if self.transition.timer >= self.transition.duration then
            -- Transition complete
            self.transition.active = false
            self.currentState = self.transition.to
            
            -- Enter new menu
            if self.menus[self.currentState] and self.menus[self.currentState].enter then
                self.menus[self.currentState]:enter()
            end
        end
    end
    
    -- Update current menu
    if not self.transition.active then
        if self.menus[self.currentState] and self.menus[self.currentState].update then
            self.menus[self.currentState]:update(dt)
        end
    end
    
    -- Update animations
    Animations.update(dt)
end

-- Draw menu
function MenuManager:draw()
    if self.transition.active then
        -- Draw transition
        local progress = self.transition.timer / self.transition.duration
        
        -- Draw fading out menu
        if self.menus[self.transition.from] and self.menus[self.transition.from].draw then
            love.graphics.push()
            love.graphics.setColor(1, 1, 1, 1 - progress)
            self.menus[self.transition.from]:draw()
            love.graphics.pop()
        end
        
        -- Draw fading in menu
        if self.menus[self.transition.to] and self.menus[self.transition.to].draw then
            love.graphics.push()
            love.graphics.setColor(1, 1, 1, progress)
            self.menus[self.transition.to]:draw()
            love.graphics.pop()
        end
        
        love.graphics.setColor(1, 1, 1, 1)
    else
        -- Draw current menu
        if self.menus[self.currentState] and self.menus[self.currentState].draw then
            self.menus[self.currentState]:draw()
        end
    end
end

-- Button helper
function MenuManager:createButton(id, x, y, width, height, text, callback)
    local button = {
        id = id,
        x = x,
        y = y,
        originalY = y,
        width = width,
        height = height,
        text = text,
        callback = callback,
        scale = 1.0,
        opacity = 1.0,
        hovered = false,
        pressed = false,
    }
    
    self.buttons[id] = button
    return button
end

-- Check if mouse is over button
function MenuManager:isMouseOverButton(button)
    local mx, my = love.mouse.getPosition()
    return mx >= button.x - button.width/2 * button.scale and
           mx <= button.x + button.width/2 * button.scale and
           my >= button.y - button.height/2 * button.scale and
           my <= button.y + button.height/2 * button.scale
end

-- Handle button hover
function MenuManager:updateButton(button, dt)
    local isOver = self:isMouseOverButton(button)
    
    -- Hover state changed
    if isOver and not button.hovered then
        button.hovered = true
        Animations.patterns.buttonHover(button)
    elseif not isOver and button.hovered then
        button.hovered = false
        Animations.patterns.buttonUnhover(button, button.originalY)
    end
    
    return isOver
end

-- Draw button (placeholder for sprite)
function MenuManager:drawButton(button, sprite)
    love.graphics.push()
    love.graphics.translate(button.x, button.y)
    love.graphics.scale(button.scale, button.scale)
    
    if sprite then
        -- Draw sprite
        love.graphics.setColor(1, 1, 1, button.opacity)
        love.graphics.draw(sprite, -sprite:getWidth()/2, -sprite:getHeight()/2)
    else
        -- Draw placeholder
        love.graphics.setColor(0.3, 0.3, 0.4, button.opacity)
        love.graphics.rectangle("fill", -button.width/2, -button.height/2, button.width, button.height, 8)
        love.graphics.setColor(0.5, 0.5, 0.6, button.opacity)
        love.graphics.rectangle("line", -button.width/2, -button.height/2, button.width, button.height, 8)
        
        -- Draw text
        love.graphics.setColor(1, 1, 1, button.opacity)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(button.text)
        love.graphics.print(button.text, -textWidth/2, -font:getHeight()/2)
    end
    
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

-- Handle button click
function MenuManager:handleButtonClick(button)
    if self:isMouseOverButton(button) then
        button.pressed = true
        Animations.patterns.buttonPress(button)
        
        if button.callback then
            -- Delay callback until after animation
            love.timer.sleep(0.1)
            button.callback()
        end
        
        Animations.patterns.buttonRelease(button, button.hovered)
        return true
    end
    return false
end

-- Clear all buttons
function MenuManager:clearButtons()
    self.buttons = {}
    self.hoveredButton = nil
    self.pressedButton = nil
end

return MenuManager
