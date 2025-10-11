-- main-menu-test.lua
-- Week 0 Day 4 - Menu System Test
-- Run this with: love . --fused main-menu-test.lua

print("=== Week 0 Day 4: Menu System Test ===")

-- Load libraries
local flux = require('lib.flux')
local Animations = require('src.ui.animations')
local MenuManager = require('src.ui.menu-manager')
local MainMenu = require('src.ui.main-menu')

-- Game state
local menuManager

function love.load()
    print("\n--- Initializing Menu System ---")
    
    -- Create menu manager
    menuManager = MenuManager:new()
    print("✓ MenuManager created")
    
    -- Create and register main menu
    local mainMenu = MainMenu:new(menuManager)
    menuManager:registerMenu(MenuManager.States.MAIN_MENU, mainMenu)
    print("✓ Main Menu registered")
    
    -- Start at main menu
    menuManager:setState(MenuManager.States.MAIN_MENU, false)
    print("✓ Entered Main Menu state")
    
    -- Window settings
    love.window.setTitle("Roguelike & Subscribe - Menu Test")
    print("\n=== Menu System Ready ===")
    print("Hover over buttons to see animations!")
end

function love.update(dt)
    menuManager:update(dt)
end

function love.draw()
    menuManager:draw()
    
    -- Show FPS
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.setColor(1, 1, 1)
end

function love.mousepressed(x, y, button)
    local currentMenu = menuManager.menus[menuManager.currentState]
    if currentMenu and currentMenu.mousepressed then
        currentMenu:mousepressed(x, y, button)
    end
end

function love.keypressed(key)
    local currentMenu = menuManager.menus[menuManager.currentState]
    if currentMenu and currentMenu.keypressed then
        currentMenu:keypressed(key)
    end
end

print("\nMain menu test loaded! Run with Love2D to see animated menu.")
