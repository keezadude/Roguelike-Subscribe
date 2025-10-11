-- tests/vehicle-position-test.lua
-- Automated Vehicle Position Validation Test
-- Detects if truck spawns or falls to unacceptable Y-axis positions

local VehiclePositionTest = {}
VehiclePositionTest.__index = VehiclePositionTest

-- Test configuration
VehiclePositionTest.CONFIG = {
    -- Y-axis thresholds (screen coordinates, Y increases downward)
    MAX_ACCEPTABLE_Y = 800,     -- Truck shouldn't go below this (fell through ground)
    MIN_ACCEPTABLE_Y = -100,    -- Truck shouldn't go above this (flew off screen)
    
    -- Initial spawn validation
    EXPECTED_SPAWN_Y_MIN = 500, -- Minimum expected Y position at spawn
    EXPECTED_SPAWN_Y_MAX = 700, -- Maximum expected Y position at spawn
    
    -- Ground reference (should match game-manager.lua)
    GROUND_Y = 700,             -- Expected ground position (screenHeight - 20)
    GROUND_TOLERANCE = 200,     -- How far from ground is acceptable
    
    -- Test duration
    TEST_DURATION = 10.0,       -- Seconds to monitor per test run
    SAMPLE_RATE = 0.1,          -- Sample position every 0.1 seconds
}

function VehiclePositionTest:new(gameManager)
    local self = setmetatable({}, VehiclePositionTest)
    
    self.gameManager = gameManager
    self.isRunning = false
    self.testResults = {}
    self.currentTest = nil
    
    -- Statistics
    self.stats = {
        totalTests = 0,
        passedTests = 0,
        failedTests = 0,
        violations = {}
    }
    
    return self
end

function VehiclePositionTest:startTest(testName)
    --[[
        Start a new automated test
        
        @param testName: Name/description of test
    ]]
    
    print(string.format("\n=== Starting Vehicle Position Test: %s ===", testName))
    
    self.isRunning = true
    self.currentTest = {
        name = testName,
        startTime = love.timer.getTime(),
        samples = {},
        violations = {},
        initialPosition = nil,
        passed = true
    }
    
    -- Validate initial spawn position
    self:validateInitialPosition()
end

function VehiclePositionTest:validateInitialPosition()
    --[[
        Check if vehicle spawned at acceptable Y position
    ]]
    
    if not self.gameManager.vehicle then
        self:recordViolation("SPAWN_FAILURE", "Vehicle not spawned")
        return
    end
    
    local x, y = self.gameManager.vehicle:getPosition()
    self.currentTest.initialPosition = {x = x, y = y}
    
    local screenHeight = love.graphics.getHeight()
    local expectedGroundY = screenHeight - 20
    
    print(string.format("📍 Initial spawn position: (%.1f, %.1f)", x, y))
    print(string.format("📏 Ground reference: Y = %.1f", expectedGroundY))
    
    -- Check if spawn Y is within expected range
    if y < self.CONFIG.EXPECTED_SPAWN_Y_MIN then
        self:recordViolation("SPAWN_TOO_HIGH", 
            string.format("Vehicle spawned too high: Y=%.1f (expected > %.1f)", 
                y, self.CONFIG.EXPECTED_SPAWN_Y_MIN))
    end
    
    if y > self.CONFIG.EXPECTED_SPAWN_Y_MAX then
        self:recordViolation("SPAWN_TOO_LOW", 
            string.format("Vehicle spawned too low: Y=%.1f (expected < %.1f)", 
                y, self.CONFIG.EXPECTED_SPAWN_Y_MAX))
    end
    
    -- Check if spawn is reasonable distance from ground
    local distanceFromGround = math.abs(y - expectedGroundY)
    if distanceFromGround > self.CONFIG.GROUND_TOLERANCE then
        self:recordViolation("SPAWN_FAR_FROM_GROUND",
            string.format("Vehicle spawned %.1f pixels from ground (tolerance: %.1f)",
                distanceFromGround, self.CONFIG.GROUND_TOLERANCE))
    end
end

function VehiclePositionTest:update(dt)
    --[[
        Update test monitoring
        
        @param dt: Delta time
    ]]
    
    if not self.isRunning or not self.currentTest then
        return
    end
    
    local elapsed = love.timer.getTime() - self.currentTest.startTime
    
    -- Check if test duration exceeded
    if elapsed > self.CONFIG.TEST_DURATION then
        self:endTest()
        return
    end
    
    -- Sample position at configured rate
    if not self.lastSampleTime then
        self.lastSampleTime = 0
    end
    
    self.lastSampleTime = self.lastSampleTime + dt
    
    if self.lastSampleTime >= self.CONFIG.SAMPLE_RATE then
        self:samplePosition()
        self.lastSampleTime = 0
    end
end

function VehiclePositionTest:samplePosition()
    --[[
        Sample and validate current vehicle position
    ]]
    
    if not self.gameManager.vehicle then
        return
    end
    
    local x, y = self.gameManager.vehicle:getPosition()
    local vx, vy = self.gameManager.vehicle:getVelocity()
    local speed = math.sqrt(vx * vx + vy * vy)
    
    local sample = {
        time = love.timer.getTime() - self.currentTest.startTime,
        x = x,
        y = y,
        velocity = {x = vx, y = vy},
        speed = speed
    }
    
    table.insert(self.currentTest.samples, sample)
    
    -- Check for Y-axis violations
    if y > self.CONFIG.MAX_ACCEPTABLE_Y then
        self:recordViolation("FELL_THROUGH_GROUND",
            string.format("Vehicle fell below ground: Y=%.1f at t=%.2fs (max: %.1f)",
                y, sample.time, self.CONFIG.MAX_ACCEPTABLE_Y))
    end
    
    if y < self.CONFIG.MIN_ACCEPTABLE_Y then
        self:recordViolation("FLEW_OFF_TOP",
            string.format("Vehicle flew too high: Y=%.1f at t=%.2fs (min: %.1f)",
                y, sample.time, self.CONFIG.MIN_ACCEPTABLE_Y))
    end
    
    -- Check for suspicious rapid Y movement (potential physics glitch)
    if #self.currentTest.samples > 1 then
        local prevSample = self.currentTest.samples[#self.currentTest.samples - 1]
        local deltaY = math.abs(y - prevSample.y)
        local deltaTime = sample.time - prevSample.time
        local yVelocity = deltaY / deltaTime
        
        -- If Y velocity is absurdly high, something's wrong
        if yVelocity > 5000 then  -- 5000 pixels/second is suspicious
            self:recordViolation("PHYSICS_GLITCH",
                string.format("Suspicious Y velocity: %.1f px/s at t=%.2fs",
                    yVelocity, sample.time))
        end
    end
end

function VehiclePositionTest:recordViolation(type, message)
    --[[
        Record a test violation
        
        @param type: Violation type code
        @param message: Descriptive message
    ]]
    
    local violation = {
        type = type,
        message = message,
        time = love.timer.getTime() - self.currentTest.startTime
    }
    
    table.insert(self.currentTest.violations, violation)
    self.currentTest.passed = false
    
    print(string.format("❌ VIOLATION [%s]: %s", type, message))
end

function VehiclePositionTest:endTest()
    --[[
        End current test and generate report
    ]]
    
    if not self.currentTest then
        return
    end
    
    self.isRunning = false
    
    local duration = love.timer.getTime() - self.currentTest.startTime
    local result = self.currentTest.passed and "PASSED" or "FAILED"
    
    print(string.format("\n=== Test Complete: %s [%s] ===", self.currentTest.name, result))
    print(string.format("Duration: %.2fs", duration))
    print(string.format("Samples: %d", #self.currentTest.samples))
    print(string.format("Violations: %d", #self.currentTest.violations))
    
    if #self.currentTest.violations > 0 then
        print("\n❌ Violations Found:")
        for i, violation in ipairs(self.currentTest.violations) do
            print(string.format("  %d. [%.2fs] %s: %s", 
                i, violation.time, violation.type, violation.message))
        end
    else
        print("\n✅ No violations detected!")
    end
    
    -- Update statistics
    self.stats.totalTests = self.stats.totalTests + 1
    if self.currentTest.passed then
        self.stats.passedTests = self.stats.passedTests + 1
    else
        self.stats.failedTests = self.stats.failedTests + 1
        table.insert(self.stats.violations, self.currentTest)
    end
    
    -- Store result
    table.insert(self.testResults, self.currentTest)
    
    -- Generate position trace
    self:generatePositionTrace()
    
    self.currentTest = nil
    self.lastSampleTime = nil
end

function VehiclePositionTest:generatePositionTrace()
    --[[
        Generate a text-based position trace for debugging
    ]]
    
    if not self.currentTest or #self.currentTest.samples == 0 then
        return
    end
    
    print("\n📊 Position Trace (every 1s):")
    print("Time(s) | X Position | Y Position | Speed")
    print("--------|------------|------------|-------")
    
    for i, sample in ipairs(self.currentTest.samples) do
        -- Print every ~1 second (every 10 samples at 0.1s rate)
        if i == 1 or i % 10 == 0 or i == #self.currentTest.samples then
            print(string.format("%7.2f | %10.1f | %10.1f | %6.1f",
                sample.time, sample.x, sample.y, sample.speed))
        end
    end
end

function VehiclePositionTest:runFullTestSuite()
    --[[
        Run complete automated test suite
    ]]
    
    print("\n" .. string.rep("=", 60))
    print("VEHICLE POSITION AUTOMATED TEST SUITE")
    print(string.rep("=", 60))
    
    -- Test 1: Spawn Position Validation
    self:startTest("Spawn Position Validation")
    -- Wait for test to complete naturally through update() calls
end

function VehiclePositionTest:getStatistics()
    --[[
        Get test statistics
        
        @return: Statistics table
    ]]
    
    return {
        totalTests = self.stats.totalTests,
        passedTests = self.stats.passedTests,
        failedTests = self.stats.failedTests,
        passRate = self.stats.totalTests > 0 and 
            (self.stats.passedTests / self.stats.totalTests * 100) or 0,
        violations = self.stats.violations
    }
end

function VehiclePositionTest:generateReport()
    --[[
        Generate comprehensive test report
    ]]
    
    local stats = self:getStatistics()
    
    print("\n" .. string.rep("=", 60))
    print("FINAL TEST REPORT")
    print(string.rep("=", 60))
    print(string.format("Total Tests: %d", stats.totalTests))
    print(string.format("Passed: %d (%.1f%%)", stats.passedTests, stats.passRate))
    print(string.format("Failed: %d", stats.failedTests))
    
    if #stats.violations > 0 then
        print("\n❌ Failed Tests Summary:")
        for i, test in ipairs(stats.violations) do
            print(string.format("\n%d. %s", i, test.name))
            print(string.format("   Initial Position: (%.1f, %.1f)", 
                test.initialPosition.x, test.initialPosition.y))
            print(string.format("   Violations: %d", #test.violations))
            for _, violation in ipairs(test.violations) do
                print(string.format("     - [%s] %s", violation.type, violation.message))
            end
        end
    else
        print("\n✅ All tests passed!")
    end
    
    print(string.rep("=", 60))
end

function VehiclePositionTest:draw()
    --[[
        Draw test status overlay (optional visual feedback)
    ]]
    
    if not self.isRunning or not self.currentTest then
        return
    end
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 10, 10, 400, 150)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("🧪 AUTOMATED TEST RUNNING", 20, 20)
    love.graphics.print(string.format("Test: %s", self.currentTest.name), 20, 45)
    
    local elapsed = love.timer.getTime() - self.currentTest.startTime
    love.graphics.print(string.format("Time: %.1fs / %.1fs", 
        elapsed, self.CONFIG.TEST_DURATION), 20, 70)
    love.graphics.print(string.format("Samples: %d", #self.currentTest.samples), 20, 95)
    
    local statusColor = self.currentTest.passed and {0, 1, 0} or {1, 0, 0}
    local statusText = self.currentTest.passed and "PASS" or "FAIL"
    love.graphics.setColor(statusColor)
    love.graphics.print(string.format("Status: %s", statusText), 20, 120)
    
    -- Draw violation count
    if #self.currentTest.violations > 0 then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print(string.format("Violations: %d", #self.currentTest.violations), 
            20, 145)
    end
end

return VehiclePositionTest
