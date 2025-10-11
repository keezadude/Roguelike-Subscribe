-- src/systems/damage-calculator.lua
-- Damage Calculation System
-- Calculates damage based on kinetic energy, body parts, and collision parameters

local DamageCalculator = {}
DamageCalculator.__index = DamageCalculator

-- Damage scaling constants
DamageCalculator.CONSTANTS = {
    -- Energy to damage conversion
    -- Reduced from 0.01 to 0.000005 to prevent all hits capping at max damage
    -- At this scale: 150 px/s = ~85 dmg, 300 px/s = ~340 dmg, 600 px/s = caps at 500
    energyToDamageScale = 0.000005,
    
    -- Minimum impact threshold (prevents tiny bumps from dealing damage)
    minImpactVelocity = 50,  -- pixels/second (increased from 5 to reduce spam)
    minImpactEnergy = 10000,  -- Joules (increased to match new scale)
    
    -- Maximum damage cap per hit
    maxDamagePerHit = 500,
    
    -- Collision type multipliers
    collisionMultipliers = {
        head_on = 1.5,      -- Front collision
        side_impact = 1.2,  -- Side collision
        rear_end = 0.8,     -- Back collision
        glancing = 0.5      -- Shallow angle collision
    }
}

function DamageCalculator:new(options)
    local self = setmetatable({}, DamageCalculator)
    
    options = options or {}
    
    -- Configuration
    self.energyScale = options.energyScale or self.CONSTANTS.energyToDamageScale
    self.minVelocity = options.minVelocity or self.CONSTANTS.minImpactVelocity
    self.minEnergy = options.minEnergy or self.CONSTANTS.minImpactEnergy
    self.maxDamage = options.maxDamage or self.CONSTANTS.maxDamagePerHit
    
    -- Statistics
    self.stats = {
        totalHits = 0,
        totalDamage = 0,
        highestDamage = 0,
        headshots = 0,
        bodyshots = 0
    }
    
    return self
end

function DamageCalculator:calculateCollisionDamage(vehicle, ragdoll, collisionData)
    --[[
        Calculate damage from vehicle-ragdoll collision
        
        @param vehicle: Vehicle entity
        @param ragdoll: Ragdoll entity
        @param collisionData: {
            bodyPart: name of ragdoll part hit,
            impactPoint: {x, y},
            vehicleVelocity: {x, y},
            ragdollVelocity: {x, y},
            normalImpulse: collision impulse
        }
        
        @return: {
            damage: total damage dealt,
            bodyPart: part that was hit,
            multiplier: damage multiplier applied,
            impactType: type of collision,
            kineticEnergy: energy of impact
        }
    ]]
    
    collisionData = collisionData or {}
    
    -- Get velocities
    local vx1, vy1 = collisionData.vehicleVelocity.x or 0, collisionData.vehicleVelocity.y or 0
    local vx2, vy2 = collisionData.ragdollVelocity.x or 0, collisionData.ragdollVelocity.y or 0
    
    -- Calculate relative velocity
    local relVx = vx1 - vx2
    local relVy = vy1 - vy2
    local relSpeed = math.sqrt(relVx * relVx + relVy * relVy)
    
    -- Check minimum impact threshold
    if relSpeed < self.minVelocity then
        return {
            damage = 0,
            bodyPart = collisionData.bodyPart,
            multiplier = 0,
            impactType = "negligible",
            kineticEnergy = 0
        }
    end
    
    -- Calculate kinetic energy of impact
    -- KE = 0.5 * m * v^2
    local vehicleMass = vehicle.SPECS.bodyMass or 1500
    local kineticEnergy = 0.5 * vehicleMass * (relSpeed * relSpeed)
    
    -- Check minimum energy threshold
    if kineticEnergy < self.minEnergy then
        return {
            damage = 0,
            bodyPart = collisionData.bodyPart,
            multiplier = 0,
            impactType = "low_energy",
            kineticEnergy = kineticEnergy
        }
    end
    
    -- Base damage from kinetic energy
    local baseDamage = kineticEnergy * self.energyScale
    
    -- Get body part multiplier
    local bodyPart = collisionData.bodyPart or "torso"
    local bodyMultiplier = ragdoll.DAMAGE_MULTIPLIERS[bodyPart] or 1.0
    
    -- Determine collision type and get multiplier
    local impactType = self:determineImpactType(vehicle, ragdoll, collisionData)
    local collisionMultiplier = self.CONSTANTS.collisionMultipliers[impactType] or 1.0
    
    -- Calculate final damage
    local totalDamage = baseDamage * bodyMultiplier * collisionMultiplier
    
    -- Cap damage
    totalDamage = math.min(totalDamage, self.maxDamage)
    
    -- Update statistics
    self.stats.totalHits = self.stats.totalHits + 1
    self.stats.totalDamage = self.stats.totalDamage + totalDamage
    
    if totalDamage > self.stats.highestDamage then
        self.stats.highestDamage = totalDamage
    end
    
    if bodyPart == "head" then
        self.stats.headshots = self.stats.headshots + 1
    else
        self.stats.bodyshots = self.stats.bodyshots + 1
    end
    
    return {
        damage = totalDamage,
        bodyPart = bodyPart,
        multiplier = bodyMultiplier * collisionMultiplier,
        impactType = impactType,
        kineticEnergy = kineticEnergy
    }
end

function DamageCalculator:determineImpactType(vehicle, ragdoll, collisionData)
    --[[
        Determine the type of impact (head-on, side, etc.)
        
        @param vehicle: Vehicle entity
        @param ragdoll: Ragdoll entity
        @param collisionData: Collision information
        
        @return: Impact type string
    ]]
    
    -- Get vehicle velocity direction
    local vx, vy = collisionData.vehicleVelocity.x or 0, collisionData.vehicleVelocity.y or 0
    local vehicleAngle = math.atan2(vy, vx)
    
    -- Get collision normal (direction from ragdoll to vehicle)
    local impactPoint = collisionData.impactPoint or {x = 0, y = 0}
    local ragdollX, ragdollY = ragdoll:getPosition()
    
    local normalX = impactPoint.x - ragdollX
    local normalY = impactPoint.y - ragdollY
    local normalAngle = math.atan2(normalY, normalX)
    
    -- Calculate angle difference
    local angleDiff = math.abs(vehicleAngle - normalAngle)
    
    -- Normalize to 0-π range
    while angleDiff > math.pi do
        angleDiff = angleDiff - 2 * math.pi
    end
    angleDiff = math.abs(angleDiff)
    
    -- Determine impact type based on angle
    if angleDiff < math.pi / 6 then
        return "head_on"  -- Within 30 degrees = head-on
    elseif angleDiff < math.pi / 3 then
        return "side_impact"  -- 30-60 degrees = side impact
    elseif angleDiff < 2 * math.pi / 3 then
        return "glancing"  -- 60-120 degrees = glancing blow
    else
        return "rear_end"  -- > 120 degrees = rear-end
    end
end

function DamageCalculator:calculateExplosionDamage(explosionCenter, target, explosionForce, explosionRadius)
    --[[
        Calculate damage from an explosion
        
        @param explosionCenter: {x, y}
        @param target: Entity with getPosition()
        @param explosionForce: Maximum force of explosion
        @param explosionRadius: Radius of explosion effect
        
        @return: {
            damage: damage dealt,
            force: {x, y} force vector,
            distance: distance from explosion
        }
    ]]
    
    local targetX, targetY = target:getPosition()
    local dx = targetX - explosionCenter.x
    local dy = targetY - explosionCenter.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- No damage outside radius
    if distance > explosionRadius then
        return {
            damage = 0,
            force = {x = 0, y = 0},
            distance = distance
        }
    end
    
    -- Calculate falloff (inverse square with minimum)
    local falloff = 1 - (distance / explosionRadius)
    falloff = math.max(0, math.min(1, falloff))
    
    -- Calculate damage
    local baseDamage = explosionForce * 0.01  -- Scale factor
    local damage = baseDamage * falloff * falloff  -- Square falloff for damage
    
    -- Calculate force vector
    local angle = math.atan2(dy, dx)
    local forceMagnitude = explosionForce * falloff
    
    return {
        damage = damage,
        force = {
            x = math.cos(angle) * forceMagnitude,
            y = math.sin(angle) * forceMagnitude
        },
        distance = distance,
        falloff = falloff
    }
end

function DamageCalculator:getStats()
    --[[
        Get damage statistics
        
        @return: Stats table
    ]]
    
    return {
        totalHits = self.stats.totalHits,
        totalDamage = self.stats.totalDamage,
        highestDamage = self.stats.highestDamage,
        averageDamage = self.stats.totalHits > 0 and (self.stats.totalDamage / self.stats.totalHits) or 0,
        headshots = self.stats.headshots,
        bodyshots = self.stats.bodyshots,
        headshotPercentage = self.stats.totalHits > 0 and (self.stats.headshots / self.stats.totalHits * 100) or 0
    }
end

function DamageCalculator:reset()
    --[[
        Reset statistics
    ]]
    
    self.stats = {
        totalHits = 0,
        totalDamage = 0,
        highestDamage = 0,
        headshots = 0,
        bodyshots = 0
    }
end

return DamageCalculator
