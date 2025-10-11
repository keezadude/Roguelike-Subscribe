-- src/game/state-machine.lua
-- Game State Machine
-- Manages game flow: Menu → Setup → Launch → Gameplay → Results → Shop

local StateMachine = {}
StateMachine.__index = StateMachine

-- Game states
StateMachine.STATES = {
    SPLASH = "splash",          -- Initial splash screen
    MAIN_MENU = "main_menu",    -- Main menu
    CHARACTER_SELECT = "character_select",  -- Choose ragdoll
    TRUCK_SELECT = "truck_select",  -- Choose vehicle
    SHOP = "shop",              -- Upgrade shop
    STATISTICS = "statistics",  -- Statistics & Progress page
    SETUP = "setup",            -- Pre-launch setup
    LAUNCH = "launch",          -- Launch phase
    GAMEPLAY = "gameplay",      -- Active gameplay
    RESULTS = "results",        -- Post-run results
    PAUSE = "pause",            -- Paused
    OPTIONS = "options"         -- Settings menu
}

function StateMachine:new(options)
    local self = setmetatable({}, StateMachine)
    
    options = options or {}
    
    -- Current state
    self.currentState = self.STATES.SPLASH
    self.previousState = nil
    
    -- State callbacks
    self.states = {}
    self.transitions = {}
    
    -- State timing
    self.stateTime = 0
    self.totalTime = 0
    
    return self
end

function StateMachine:registerState(stateName, callbacks)
    --[[
        Register callbacks for a state
        
        @param stateName: State name from STATES
        @param callbacks: {
            enter: function() - called when entering state
            exit: function() - called when leaving state
            update: function(dt) - called every frame
            draw: function() - called every frame
            keypressed: function(key) - optional key handler
            mousepressed: function(x, y, button) - optional mouse handler
        }
    ]]
    
    self.states[stateName] = callbacks or {}
end

function StateMachine:setState(newState, data)
    --[[
        Transition to a new state
        
        @param newState: Target state
        @param data: Optional data to pass to new state
    ]]
    
    if newState == self.currentState then
        return
    end
    
    print(string.format("[StateMachine] %s → %s", self.currentState, newState))
    
    -- Call exit callback for current state
    if self.states[self.currentState] and self.states[self.currentState].exit then
        self.states[self.currentState].exit()
    end
    
    -- Update state
    self.previousState = self.currentState
    self.currentState = newState
    self.stateTime = 0
    
    -- Call enter callback for new state
    if self.states[newState] and self.states[newState].enter then
        self.states[newState].enter(data)
    end
    
    -- Fire transition event
    self:fireTransition(self.previousState, newState)
end

function StateMachine:getState()
    --[[
        Get current state
        
        @return: Current state name
    ]]
    
    return self.currentState
end

function StateMachine:getPreviousState()
    --[[
        Get previous state
        
        @return: Previous state name
    ]]
    
    return self.previousState
end

function StateMachine:isState(stateName)
    --[[
        Check if in specific state
        
        @param stateName: State to check
        @return: true if current state matches
    ]]
    
    return self.currentState == stateName
end

function StateMachine:update(dt)
    --[[
        Update current state
        
        @param dt: Delta time
    ]]
    
    self.stateTime = self.stateTime + dt
    self.totalTime = self.totalTime + dt
    
    -- Call update callback for current state
    if self.states[self.currentState] and self.states[self.currentState].update then
        self.states[self.currentState].update(dt, self.stateTime)
    end
end

function StateMachine:draw()
    --[[
        Draw current state
    ]]
    
    -- Call draw callback for current state
    if self.states[self.currentState] and self.states[self.currentState].draw then
        self.states[self.currentState].draw()
    end
end

function StateMachine:keypressed(key)
    --[[
        Handle key press in current state
        
        @param key: Key that was pressed
    ]]
    
    if self.states[self.currentState] and self.states[self.currentState].keypressed then
        self.states[self.currentState].keypressed(key)
    end
end

function StateMachine:mousepressed(x, y, button)
    --[[
        Handle mouse press in current state
        
        @param x, y: Mouse position
        @param button: Mouse button
    ]]
    
    if self.states[self.currentState] and self.states[self.currentState].mousepressed then
        self.states[self.currentState].mousepressed(x, y, button)
    end
end

function StateMachine:registerTransition(fromState, toState, callback)
    --[[
        Register a transition callback
        
        @param fromState: Source state
        @param toState: Target state
        @param callback: function() called on transition
    ]]
    
    local key = fromState .. "_to_" .. toState
    self.transitions[key] = callback
end

function StateMachine:fireTransition(fromState, toState)
    --[[
        Fire transition event
    ]]
    
    local key = fromState .. "_to_" .. toState
    if self.transitions[key] then
        self.transitions[key]()
    end
end

function StateMachine:getStateTime()
    --[[
        Get time spent in current state
        
        @return: Time in seconds
    ]]
    
    return self.stateTime
end

function StateMachine:getTotalTime()
    --[[
        Get total game time
        
        @return: Time in seconds
    ]]
    
    return self.totalTime
end

return StateMachine
