-- main_integrated.lua
-- Roguelike & Subscribe - Integrated Game
-- Complete game using all Week 0-3 systems

print("=== Roguelike & Subscribe Starting ===")
print("Truck Dismount meets Meta-Progression\n")

-- Load game manager
local GameManager = require('src.game.game-manager')

-- Global game instance
local game = nil

function love.load()
    print("\n=== Initializing Complete Game ===")
    
    -- Window setup
    love.window.setTitle("Roguelike & Subscribe - Truck Dismount + Meta-Progression")
    love.window.setMode(1280, 720, {
        vsync = 1,
        resizable = false,
        minwidth = 1280,
        minheight = 720
    })
    
    -- Create game manager (initializes all systems)
    game = GameManager:new()
    
    print("\n✓ Game loaded successfully!")
    print("\n" .. string.rep("=", 50))
    print("ROGUELIKE & SUBSCRIBE")
    print(string.rep("=", 50))
    print("\nPress SPACE to start your first run!")
end

function love.update(dt)
    if game then
        game:update(dt)
    end
end

function love.draw()
    if game then
        game:draw()
    end
    
    -- Version info
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    love.graphics.print("v0.1-alpha | Weeks 0-3 Integrated", 10, love.graphics.getHeight() - 20, 0, 0.8)
end

function love.keypressed(key)
    -- Global quit
    if key == "escape" and game and game.stateMachine:isState("MAIN_MENU") then
        love.event.quit()
    end
    
    if game then
        game:keypressed(key)
    end
end

function love.keyreleased(key)
    if game then
        game:keyreleased(key)
    end
end

function love.mousepressed(x, y, button)
    if game then
        game:mousepressed(x, y, button)
    end
end

function love.quit()
    print("\n=== Shutting Down ===")
    
    -- Save game before quitting
    if game and game.saveManager then
        game.saveManager:save()
        print("✓ Game saved")
    end
    
    print("Thanks for playing!")
    return false  -- Allow quit
end

print("\nmain_integrated.lua loaded - waiting for love.load()")
