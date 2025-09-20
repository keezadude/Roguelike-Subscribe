-- validate.lua
-- Simple validation script to check library paths

print("Validating library setup...")

-- Check if lib directory exists
local function dirExists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return false -- It's a file
    end
    local f = io.open(path .. "/.", "r")
    if f then
        f:close()
        return true -- It's a directory
    end
    return false
end

-- Check if file exists
local function fileExists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Validate library structure
local libraries = {
    "lib/tiny-ecs/tiny.lua",
    "lib/hump/vector.lua",
    "lib/hump/camera.lua",
    "lib/hump/timer.lua",
    "lib/hump/gamestate.lua",
    "lib/hump/class.lua",
    "lib/breezefield/init.lua",
    "lib/rotLove/src/rot.lua",
    "lib/astray/astray/init.lua",
    "lib/loveblobs/loveblobs/init.lua",
    "lib/andross/andross/init.lua"
}

print("\nLibrary validation:")
local allValid = true

for _, lib in ipairs(libraries) do
    local exists = fileExists(lib)
    print(string.format("  %s: %s", lib, exists and "✓" or "✗"))
    if not exists then
        allValid = false
    end
end

-- Check main files
local mainFiles = {
    "main.lua",
    "conf.lua",
    "setup.lua"
}

print("\nMain files:")
for _, file in ipairs(mainFiles) do
    local exists = fileExists(file)
    print(string.format("  %s: %s", file, exists and "✓" or "✗"))
    if not exists then
        allValid = false
    end
end

if allValid then
    print("\n✓ All libraries and files are properly set up!")
    print("Ready to run with Love2D!")
else
    print("\n✗ Some files are missing. Check the setup.")
end