-- src/effects/particle-system.lua
-- Particle Effects System
-- Manages impact debris, dust clouds, and visual effects

local ParticleSystem = {}
ParticleSystem.__index = ParticleSystem

function ParticleSystem:new(options)
    local self = setmetatable({}, ParticleSystem)
    
    options = options or {}
    
    -- Active particles
    self.particles = {}
    self.maxParticles = options.maxParticles or 1000
    
    -- Particle pools for different effect types
    self.pools = {
        impact = {},
        debris = {},
        dust = {},
        spark = {},
        blood = {}
    }
    
    -- Enabled effects
    self.enabled = options.enabled ~= false
    
    return self
end

function ParticleSystem:createImpactEffect(x, y, intensity, color)
    --[[
        Create impact particle burst
        
        @param x, y: Impact position
        @param intensity: Effect intensity (1-10)
        @param color: Optional color {r, g, b}
    ]]
    
    if not self.enabled or #self.particles >= self.maxParticles then
        return
    end
    
    intensity = intensity or 5
    color = color or {0.8, 0.8, 0.8}
    
    local particleCount = math.floor(intensity * 3)
    
    for i = 1, particleCount do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(50, 150) * (intensity / 5)
        
        table.insert(self.particles, {
            type = "impact",
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            size = love.math.random(2, 6),
            lifetime = love.math.random(0.3, 0.8),
            maxLifetime = 0.8,
            color = {color[1], color[2], color[3], 1},
            gravity = 300
        })
    end
end

function ParticleSystem:createDebrisEffect(x, y, velocity, count)
    --[[
        Create flying debris particles
        
        @param x, y: Origin position
        @param velocity: {vx, vy} initial velocity
        @param count: Number of debris pieces
    ]]
    
    if not self.enabled or #self.particles >= self.maxParticles then
        return
    end
    
    count = count or 8
    velocity = velocity or {x = 0, y = 0}
    
    for i = 1, count do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(100, 300)
        
        table.insert(self.particles, {
            type = "debris",
            x = x + love.math.random(-10, 10),
            y = y + love.math.random(-10, 10),
            vx = velocity.x + math.cos(angle) * speed,
            vy = velocity.y + math.sin(angle) * speed,
            rotation = love.math.random() * math.pi * 2,
            rotationSpeed = (love.math.random() - 0.5) * 10,
            size = love.math.random(3, 8),
            lifetime = love.math.random(0.5, 1.5),
            maxLifetime = 1.5,
            color = {0.5, 0.4, 0.3, 1},
            gravity = 600,
            bounce = 0.3
        })
    end
end

function ParticleSystem:createDustCloud(x, y, radius, density)
    --[[
        Create dust cloud effect
        
        @param x, y: Center position
        @param radius: Cloud radius
        @param density: Particle density
    ]]
    
    if not self.enabled or #self.particles >= self.maxParticles then
        return
    end
    
    radius = radius or 30
    density = density or 15
    
    for i = 1, density do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random() * radius
        
        table.insert(self.particles, {
            type = "dust",
            x = x + math.cos(angle) * distance,
            y = y + math.sin(angle) * distance,
            vx = math.cos(angle) * love.math.random(10, 30),
            vy = math.sin(angle) * love.math.random(10, 30) - 20,
            size = love.math.random(8, 20),
            lifetime = love.math.random(0.5, 1.2),
            maxLifetime = 1.2,
            color = {0.7, 0.7, 0.6, 0.5},
            gravity = -50,  -- Dust floats up
            fadeStart = 0.3
        })
    end
end

function ParticleSystem:createSparkEffect(x, y, direction, count)
    --[[
        Create spark particles
        
        @param x, y: Origin position
        @param direction: Direction angle (radians)
        @param count: Number of sparks
    ]]
    
    if not self.enabled or #self.particles >= self.maxParticles then
        return
    end
    
    count = count or 10
    
    for i = 1, count do
        local spread = 0.5
        local angle = direction + (love.math.random() - 0.5) * spread
        local speed = love.math.random(200, 400)
        
        table.insert(self.particles, {
            type = "spark",
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            size = love.math.random(1, 3),
            lifetime = love.math.random(0.1, 0.4),
            maxLifetime = 0.4,
            color = {1, 0.8, 0.2, 1},
            gravity = 400,
            trail = true
        })
    end
end

function ParticleSystem:createBloodEffect(x, y, intensity)
    --[[
        Create blood splatter particles
        
        @param x, y: Impact position
        @param intensity: Effect intensity
    ]]
    
    if not self.enabled or #self.particles >= self.maxParticles then
        return
    end
    
    intensity = intensity or 3
    
    for i = 1, intensity * 5 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(50, 200)
        
        table.insert(self.particles, {
            type = "blood",
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            size = love.math.random(2, 5),
            lifetime = love.math.random(0.3, 0.7),
            maxLifetime = 0.7,
            color = {0.8, 0.1, 0.1, 1},
            gravity = 400
        })
    end
end

function ParticleSystem:update(dt)
    --[[
        Update all particles
        
        @param dt: Delta time
    ]]
    
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        
        -- Update lifetime
        p.lifetime = p.lifetime - dt
        
        if p.lifetime <= 0 then
            table.remove(self.particles, i)
        else
            -- Update position
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            
            -- Apply gravity
            if p.gravity then
                p.vy = p.vy + p.gravity * dt
            end
            
            -- Apply rotation
            if p.rotationSpeed then
                p.rotation = p.rotation + p.rotationSpeed * dt
            end
            
            -- Fade out
            local lifetimeRatio = p.lifetime / p.maxLifetime
            
            if p.fadeStart and lifetimeRatio < p.fadeStart then
                p.color[4] = (lifetimeRatio / p.fadeStart) * (p.color[4] or 1)
            else
                p.color[4] = lifetimeRatio
            end
            
            -- Air resistance
            p.vx = p.vx * 0.98
            p.vy = p.vy * 0.98
        end
    end
end

function ParticleSystem:draw()
    --[[
        Draw all particles
    ]]
    
    for _, p in ipairs(self.particles) do
        love.graphics.setColor(p.color)
        
        if p.type == "spark" and p.trail then
            -- Draw spark with trail
            love.graphics.setLineWidth(p.size)
            local trailX = p.x - p.vx * 0.01
            local trailY = p.y - p.vy * 0.01
            love.graphics.line(trailX, trailY, p.x, p.y)
        elseif p.rotation then
            -- Draw rotated particle
            love.graphics.push()
            love.graphics.translate(p.x, p.y)
            love.graphics.rotate(p.rotation)
            love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size)
            love.graphics.pop()
        else
            -- Draw simple circle
            love.graphics.circle("fill", p.x, p.y, p.size)
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function ParticleSystem:clear()
    --[[
        Remove all particles
    ]]
    
    self.particles = {}
end

function ParticleSystem:getCount()
    --[[
        Get number of active particles
        
        @return: Particle count
    ]]
    
    return #self.particles
end

function ParticleSystem:setEnabled(enabled)
    --[[
        Enable or disable particle effects
        
        @param enabled: true/false
    ]]
    
    self.enabled = enabled
    
    if not enabled then
        self:clear()
    end
end

return ParticleSystem
