-- tests/example-usage.lua
-- Example usage of the automated testing system
-- This file demonstrates how to use the test API programmatically

--[[
    EXAMPLE 1: Basic Quick Check
    Use this during development to quickly verify position
]]

function example1_quickCheck(gameManager)
    print("\n=== EXAMPLE 1: Quick Position Check ===")
    
    -- Initialize test runner
    local TestRunner = require('tests.test-runner')
    local runner = TestRunner:new(gameManager)
    
    -- Perform quick check
    local passed = runner:quickPositionCheck()
    
    if passed then
        print("✅ Vehicle position is acceptable")
    else
        print("❌ Vehicle position is out of acceptable range")
    end
end

--[[
    EXAMPLE 2: Run Single Automated Test
    Use this to monitor vehicle for a duration
]]

function example2_singleTest(gameManager)
    print("\n=== EXAMPLE 2: Single Automated Test ===")
    
    local TestRunner = require('tests.test-runner')
    local runner = TestRunner:new(gameManager)
    
    -- Start a position test
    runner:runTest("vehiclePosition", "Example Test Run")
    
    -- Test will run automatically via update() calls
    -- Results will print to console after 10 seconds
end

--[[
    EXAMPLE 3: Custom Test with Modified Thresholds
    Use this when you need different validation criteria
]]

function example3_customThresholds(gameManager)
    print("\n=== EXAMPLE 3: Custom Thresholds ===")
    
    local VehiclePositionTest = require('tests.vehicle-position-test')
    local test = VehiclePositionTest:new(gameManager)
    
    -- Modify thresholds for this specific test
    test.CONFIG.MAX_ACCEPTABLE_Y = 850  -- Allow vehicle to go lower
    test.CONFIG.MIN_ACCEPTABLE_Y = -200 -- Allow more airtime
    test.CONFIG.TEST_DURATION = 5.0     -- Shorter test
    
    -- Start test with custom config
    test:startTest("Custom Threshold Test")
    
    print("Modified thresholds:")
    print(string.format("  Max Y: %.0f", test.CONFIG.MAX_ACCEPTABLE_Y))
    print(string.format("  Min Y: %.0f", test.CONFIG.MIN_ACCEPTABLE_Y))
    print(string.format("  Duration: %.1fs", test.CONFIG.TEST_DURATION))
end

--[[
    EXAMPLE 4: Multiple Sequential Tests
    Use this for comprehensive validation
]]

function example4_multipleTests(gameManager)
    print("\n=== EXAMPLE 4: Multiple Sequential Tests ===")
    
    local TestRunner = require('tests.test-runner')
    local runner = TestRunner:new(gameManager)
    
    -- Run full test suite (all tests in sequence)
    runner:runAllTests()
    
    -- After all tests complete, generate report
    -- (happens automatically)
end

--[[
    EXAMPLE 5: Conditional Testing Based on Game State
    Use this to run tests only in specific conditions
]]

function example5_conditionalTesting(gameManager)
    print("\n=== EXAMPLE 5: Conditional Testing ===")
    
    local TestRunner = require('tests.test-runner')
    local runner = TestRunner:new(gameManager)
    
    -- Only test if in SETUP or GAMEPLAY state
    local currentState = gameManager.stateMachine:getState()
    local validStates = {
        [gameManager.stateMachine.STATES.SETUP] = true,
        [gameManager.stateMachine.STATES.GAMEPLAY] = true
    }
    
    if validStates[currentState] then
        print("✅ Valid state for testing, starting test...")
        runner:runTest("vehiclePosition", "Conditional Test")
    else
        print("⚠️  Not in valid state for testing (current: " .. tostring(currentState) .. ")")
    end
end

--[[
    EXAMPLE 6: Custom Test Handler with Callbacks
    Use this to integrate test results into your own systems
]]

function example6_customHandler(gameManager)
    print("\n=== EXAMPLE 6: Custom Test Handler ===")
    
    local VehiclePositionTest = require('tests.vehicle-position-test')
    local test = VehiclePositionTest:new(gameManager)
    
    -- Override recordViolation to add custom handling
    local originalRecordViolation = test.recordViolation
    test.recordViolation = function(self, type, message)
        -- Call original
        originalRecordViolation(self, type, message)
        
        -- Custom handling
        if type == "FELL_THROUGH_GROUND" then
            print("🚨 CRITICAL: Vehicle fell through ground!")
            print("   → Pausing game for inspection")
            -- gameManager.stateMachine:setState(gameManager.stateMachine.STATES.PAUSE)
        elseif type == "PHYSICS_GLITCH" then
            print("⚡ Physics anomaly detected!")
            print("   → Logging physics state...")
            -- logPhysicsState(gameManager)
        end
    end
    
    -- Start test with custom handler
    test:startTest("Custom Handler Test")
end

--[[
    EXAMPLE 7: Programmatic Threshold Validation
    Use this to validate test configuration programmatically
]]

function example7_validateThresholds(gameManager)
    print("\n=== EXAMPLE 7: Validate Thresholds ===")
    
    local VehiclePositionTest = require('tests.vehicle-position-test')
    local test = VehiclePositionTest:new(gameManager)
    
    local screenHeight = love.graphics.getHeight()
    local groundY = screenHeight - 20
    
    print("Validating test configuration against game constants...")
    
    -- Check if max Y threshold matches ground
    if test.CONFIG.MAX_ACCEPTABLE_Y > groundY + 100 then
        print("⚠️  MAX_ACCEPTABLE_Y is too lenient")
        print(string.format("   Expected: < %.0f, Got: %.0f", 
            groundY + 100, test.CONFIG.MAX_ACCEPTABLE_Y))
    end
    
    -- Check if spawn range matches actual spawn logic
    local expectedSpawnY = gameManager.vehicle and select(2, gameManager.vehicle:getPosition()) or 0
    if expectedSpawnY < test.CONFIG.EXPECTED_SPAWN_Y_MIN or 
       expectedSpawnY > test.CONFIG.EXPECTED_SPAWN_Y_MAX then
        print("⚠️  Spawn thresholds don't match actual spawn position")
        print(string.format("   Actual: %.0f, Expected: %.0f-%.0f",
            expectedSpawnY, 
            test.CONFIG.EXPECTED_SPAWN_Y_MIN,
            test.CONFIG.EXPECTED_SPAWN_Y_MAX))
    end
    
    print("✅ Threshold validation complete")
end

--[[
    EXAMPLE 8: Integration with CI/CD
    Use this in automated build pipelines
]]

function example8_cicdIntegration(gameManager)
    print("\n=== EXAMPLE 8: CI/CD Integration ===")
    
    local TestRunner = require('tests.test-runner')
    local runner = TestRunner:new(gameManager)
    
    -- Run all tests
    runner:runAllTests()
    
    -- Wait for tests to complete (in CI/CD, you'd use callbacks)
    -- Then check results
    
    -- Get statistics
    local stats = runner.tests.vehiclePosition:getStatistics()
    
    print("\nCI/CD Test Results:")
    print(string.format("  Total: %d", stats.totalTests))
    print(string.format("  Passed: %d", stats.passedTests))
    print(string.format("  Failed: %d", stats.failedTests))
    print(string.format("  Pass Rate: %.1f%%", stats.passRate))
    
    -- Exit with appropriate code for CI/CD
    if stats.failedTests > 0 then
        print("\n❌ Build failed - tests did not pass")
        -- os.exit(1)  -- Uncomment in CI/CD
    else
        print("\n✅ Build passed - all tests successful")
        -- os.exit(0)  -- Uncomment in CI/CD
    end
end

--[[
    EXAMPLE 9: Real-time Position Monitoring
    Use this to add live position display during gameplay
]]

function example9_realtimeMonitoring(gameManager)
    print("\n=== EXAMPLE 9: Real-time Monitoring ===")
    
    -- Add this to your game's draw() function
    local function drawPositionMonitor()
        if not gameManager.vehicle then return end
        
        local x, y = gameManager.vehicle:getPosition()
        local vx, vy = gameManager.vehicle:getVelocity()
        local speed = math.sqrt(vx * vx + vy * vy)
        
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 10, 100, 300, 120)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("POSITION MONITOR", 20, 110)
        love.graphics.print(string.format("X: %.1f", x), 20, 135)
        love.graphics.print(string.format("Y: %.1f", y), 20, 155)
        love.graphics.print(string.format("Speed: %.1f", speed), 20, 175)
        
        -- Color code Y position
        if y > 800 then
            love.graphics.setColor(1, 0, 0)
            love.graphics.print("⚠️  BELOW GROUND", 20, 195)
        elseif y < -100 then
            love.graphics.setColor(1, 0, 0)
            love.graphics.print("⚠️  ABOVE SCREEN", 20, 195)
        else
            love.graphics.setColor(0, 1, 0)
            love.graphics.print("✅ IN RANGE", 20, 195)
        end
    end
    
    print("Add drawPositionMonitor() to your draw() function for live monitoring")
end

--[[
    EXAMPLE 10: Export Test Results to File
    Use this to save test results for later analysis
]]

function example10_exportResults(gameManager)
    print("\n=== EXAMPLE 10: Export Results ===")
    
    local TestRunner = require('tests.test-runner')
    local runner = TestRunner:new(gameManager)
    
    -- Run tests
    runner:runAllTests()
    
    -- After tests complete, export results
    local function exportToFile()
        local stats = runner.tests.vehiclePosition:getStatistics()
        
        local filename = string.format("test-results-%s.txt", 
            os.date("%Y%m%d-%H%M%S"))
        
        local file = io.open(filename, "w")
        if file then
            file:write("AUTOMATED TEST RESULTS\n")
            file:write("======================\n\n")
            file:write(string.format("Date: %s\n", os.date()))
            file:write(string.format("Total Tests: %d\n", stats.totalTests))
            file:write(string.format("Passed: %d\n", stats.passedTests))
            file:write(string.format("Failed: %d\n", stats.failedTests))
            file:write(string.format("Pass Rate: %.1f%%\n\n", stats.passRate))
            
            if #stats.violations > 0 then
                file:write("VIOLATIONS:\n")
                for i, test in ipairs(stats.violations) do
                    file:write(string.format("\n%d. %s\n", i, test.name))
                    for _, violation in ipairs(test.violations) do
                        file:write(string.format("   [%.2fs] %s: %s\n",
                            violation.time, violation.type, violation.message))
                    end
                end
            end
            
            file:close()
            print(string.format("✅ Results exported to: %s", filename))
        else
            print("❌ Failed to create export file")
        end
    end
    
    print("Results will be exported after tests complete")
end

-- Return example functions for use in other modules
return {
    quickCheck = example1_quickCheck,
    singleTest = example2_singleTest,
    customThresholds = example3_customThresholds,
    multipleTests = example4_multipleTests,
    conditionalTesting = example5_conditionalTesting,
    customHandler = example6_customHandler,
    validateThresholds = example7_validateThresholds,
    cicdIntegration = example8_cicdIntegration,
    realtimeMonitoring = example9_realtimeMonitoring,
    exportResults = example10_exportResults
}
