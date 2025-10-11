-- src/rendering/physics-3d-sync.lua
-- 2D Physics to 3D Rendering Synchronization
-- Maps 2D Box2D physics bodies to 3D model transformations

local Physics3DSync = {}
Physics3DSync.__index = Physics3DSync

function Physics3DSync:new(dream3D)
    local self = setmetatable({}, Physics3DSync)
    
    -- 3DreamEngine reference
    self.dream = dream3D
    
    -- Sync mappings (2D body -> 3D model)
    self.syncedObjects = {}
    
    -- Coordinate conversion
    self.pixelScale = 64  -- pixels per meter
    self.yOffset = 0      -- Y-axis offset for 3D positioning
    
    return self
end

function Physics3DSync:registerObject(body, model, options)
    --[[
        Register a 2D physics body to sync with a 3D model
        
        @param body: Breezefield physics body
        @param model: 3DreamEngine model object
        @param options: Sync options (scale, offset, rotation)
        @return: Sync ID
    ]]
    
    options = options or {}
    
    local syncData = {
        body = body,
        model = model,
        scale = options.scale or 1.0,
        offsetX = options.offsetX or 0,
        offsetY = options.offsetY or 0,
        offsetZ = options.offsetZ or 0,
        rotationOffset = options.rotationOffset or 0,
        flipZ = options.flipZ or false  -- Flip Z-axis if needed
    }
    
    table.insert(self.syncedObjects, syncData)
    
    return #self.syncedObjects
end

function Physics3DSync:registerRagdoll(ragdoll, models, options)
    --[[
        Register a ragdoll's multiple body parts with corresponding 3D models
        
        @param ragdoll: Ragdoll entity
        @param models: Table mapping part names to 3D models
        @param options: Sync options
        @return: Array of sync IDs
    ]]
    
    options = options or {}
    local syncIDs = {}
    
    -- Register each body part
    for partName, body in pairs(ragdoll.parts) do
        local model = models[partName]
        
        if model then
            local partOptions = {
                scale = options.scale or 1.0,
                offsetX = options.offsetX or 0,
                offsetY = options.offsetY or 0,
                offsetZ = options.offsetZ or 0,
                rotationOffset = options.rotationOffset or 0
            }
            
            local id = self:registerObject(body, model, partOptions)
            syncIDs[partName] = id
        end
    end
    
    return syncIDs
end

function Physics3DSync:update(dt)
    --[[
        Update all 3D model positions based on 2D physics
        
        @param dt: Delta time
    ]]
    
    for _, syncData in ipairs(self.syncedObjects) do
        self:updateObject(syncData)
    end
end

function Physics3DSync:updateObject(syncData)
    --[[
        Update a single synced object
        
        @param syncData: Sync data for the object
    ]]
    
    local body = syncData.body
    local model = syncData.model
    
    if not body or not model then
        return
    end
    
    -- Get 2D physics position and rotation
    local x2d, y2d = body:getPosition()
    local angle2d = body:getAngle()
    
    -- Convert to 3D coordinates
    local x3d = (x2d / self.pixelScale) + syncData.offsetX
    local y3d = self.yOffset + syncData.offsetY
    local z3d = (y2d / self.pixelScale) + syncData.offsetZ
    
    -- Flip Z if needed (for different coordinate systems)
    if syncData.flipZ then
        z3d = -z3d
    end
    
    -- Set 3D model position
    if model.setTransform then
        model:setTransform(x3d, y3d, z3d)
    elseif model.setPosition then
        model:setPosition(x3d, y3d, z3d)
    end
    
    -- Set 3D model rotation
    -- Convert 2D rotation (around Z) to 3D rotation
    local rotation = angle2d + syncData.rotationOffset
    
    if model.setRotation then
        model:setRotation(0, rotation, 0)  -- Rotate around Y-axis in 3D
    end
    
    -- Apply scale
    if model.setScale then
        model:setScale(syncData.scale, syncData.scale, syncData.scale)
    end
end

function Physics3DSync:unregisterObject(syncID)
    --[[
        Remove an object from synchronization
        
        @param syncID: Sync ID to remove
    ]]
    
    if syncID and self.syncedObjects[syncID] then
        table.remove(self.syncedObjects, syncID)
    end
end

function Physics3DSync:clear()
    --[[
        Clear all synced objects
    ]]
    
    self.syncedObjects = {}
end

function Physics3DSync:setPixelScale(scale)
    --[[
        Set pixel to meter conversion scale
        
        @param scale: Pixels per meter
    ]]
    
    self.pixelScale = scale
end

function Physics3DSync:setYOffset(offset)
    --[[
        Set Y-axis offset for 3D positioning
        
        @param offset: Y offset value
    ]]
    
    self.yOffset = offset
end

function Physics3DSync:getStats()
    --[[
        Get synchronization statistics
        
        @return: Stats table
    ]]
    
    return {
        syncedObjects = #self.syncedObjects,
        pixelScale = self.pixelScale,
        yOffset = self.yOffset
    }
end

return Physics3DSync
