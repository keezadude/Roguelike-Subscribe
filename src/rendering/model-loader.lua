-- src/rendering/model-loader.lua
-- 3D Model Loading System
-- Handles loading and caching 3D models using 3DreamEngine

local ModelLoader = {}
ModelLoader.__index = ModelLoader

function ModelLoader:new(dream3D)
    local self = setmetatable({}, ModelLoader)
    
    -- 3DreamEngine reference
    self.dream = dream3D
    
    -- Model cache
    self.models = {}
    self.loadedCount = 0
    
    -- Asset paths
    self.basePath = "assets/models/"
    
    return self
end

function ModelLoader:loadModel(modelPath, options)
    --[[
        Load a 3D model from file
        
        @param modelPath: Path to model file (relative to basePath)
        @param options: Loading options
        @return: Loaded model object or nil
    ]]
    
    options = options or {}
    
    -- Check cache first
    if self.models[modelPath] then
        print("✓ Model loaded from cache:", modelPath)
        return self.models[modelPath]
    end
    
    -- Full path
    local fullPath = self.basePath .. modelPath
    
    -- Check if file exists
    if not love.filesystem.getInfo(fullPath) then
        print("✗ Model file not found:", fullPath)
        print("  Please ensure the model is in:", self.basePath)
        return nil
    end
    
    -- Load model using 3DreamEngine
    local success, model = pcall(function()
        return self.dream:loadObject(fullPath)
    end)
    
    if not success or not model then
        print("✗ Failed to load model:", modelPath)
        print("  Error:", tostring(model))
        return nil
    end
    
    -- Cache model
    self.models[modelPath] = model
    self.loadedCount = self.loadedCount + 1
    
    print("✓ Model loaded successfully:", modelPath)
    
    return model
end

function ModelLoader:loadCharacterModel(characterName)
    --[[
        Load a character model by name
        
        @param characterName: Name of character (e.g., "test_character")
        @return: Model object or nil
    ]]
    
    -- Try different formats
    local formats = {".glb", ".gltf", ".obj"}
    
    for _, format in ipairs(formats) do
        local path = "characters/" .. characterName .. format
        local model = self:loadModel(path)
        
        if model then
            return model
        end
    end
    
    print("✗ Character model not found:", characterName)
    print("  Tried formats: .glb, .gltf, .obj")
    return nil
end

function ModelLoader:loadVehicleModel(vehicleName)
    --[[
        Load a vehicle model by name
        
        @param vehicleName: Name of vehicle (e.g., "truck_01")
        @return: Model object or nil
    ]]
    
    local formats = {".glb", ".gltf", ".obj"}
    
    for _, format in ipairs(formats) do
        local path = "vehicles/" .. vehicleName .. format
        local model = self:loadModel(path)
        
        if model then
            return model
        end
    end
    
    print("✗ Vehicle model not found:", vehicleName)
    return nil
end

function ModelLoader:createPlaceholderModel()
    --[[
        Create a simple placeholder model when no 3D model is available
        
        @return: Placeholder model data
    ]]
    
    return {
        isPlaceholder = true,
        type = "box",
        size = {1, 1, 1}
    }
end

function ModelLoader:getModelStats()
    --[[
        Get loading statistics
        
        @return: Stats table
    ]]
    
    return {
        loadedModels = self.loadedCount,
        cachedModels = #self.models
    }
end

return ModelLoader
