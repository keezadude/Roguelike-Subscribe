-- tests/test-runner.lua
-- Automated Test Runner for Roguelike & Subscribe
-- Run all automated tests and generate reports

local VehiclePositionTest = require('tests.vehicle-position-test')

local TestRunner = {}
TestRunner.__index = TestRunner

function TestRunner:new(gameManager)
    local self = setmetatable({}, TestRunner)
    
    self.gameManager = gameManager
    self.tests = {}
    self.activeTest = nil
    self.testQueue = {}
    self.results = {}
    
    -- Initialize test suites
    self:registerTests()
    
    return self
end

function TestRunner:registerTests()
    --[[
        Register all available test suites
    ]]
    
    -- Vehicle Position Test
    self.tests.vehiclePosition = VehiclePositionTest:new(self.gameManager)
    
    print("✅ Registered test suites: vehicle-position")
end

function TestRunner:runTest(testName, runName)
    --[[
        Run a specific test
        
        @param testName: Which test suite to run
        @param runName: Descriptive name for this test run
    ]]
    
    local test = self.tests[testName]
    if not test then
        print(string.format("❌ Test suite '%s' not found", testName))
        return false
    end
    
    self.activeTest = test
    test:startTest(runName or testName)
    
    return true
end

function TestRunner:runAllTests()
    --[[
        Queue all tests to run in sequence
    ]]
    
    print("\n🧪 Running Full Test Suite...")
    
    -- Queue tests
    table.insert(self.testQueue, {suite = "vehiclePosition", name = "Initial Spawn Test"})
    
    -- Start first test
    self:processQueue()
end

function TestRunner:processQueue()
    --[[
        Process test queue
    ]]
    
    if #self.testQueue == 0 then
        self:generateFinalReport()
        return
    end
    
    local nextTest = table.remove(self.testQueue, 1)
    self:runTest(nextTest.suite, nextTest.name)
end

function TestRunner:update(dt)
    --[[
        Update active tests
        
        @param dt: Delta time
    ]]
    
    if self.activeTest then
        self.activeTest:update(dt)
        
        -- Check if test completed
        if not self.activeTest.isRunning then
            -- Store result
            table.insert(self.results, {
                suite = "vehiclePosition",
                result = self.activeTest.currentTest
            })
            
            self.activeTest = nil
            
            -- Process next test in queue
            if #self.testQueue > 0 then
                self:processQueue()
            else
                self:generateFinalReport()
            end
        end
    end
end

function TestRunner:draw()
    --[[
        Draw test overlay
    ]]
    
    if self.activeTest then
        self.activeTest:draw()
    end
end

function TestRunner:generateFinalReport()
    --[[
        Generate comprehensive report for all tests
    ]]
    
    print("\n" .. string.rep("=", 70))
    print("AUTOMATED TEST SUITE - FINAL REPORT")
    print(string.rep("=", 70))
    
    local totalTests = 0
    local passedTests = 0
    
    for _, result in ipairs(self.results) do
        totalTests = totalTests + 1
        if result.result and result.result.passed then
            passedTests = passedTests + 1
        end
    end
    
    print(string.format("Total Test Runs: %d", totalTests))
    print(string.format("Passed: %d", passedTests))
    print(string.format("Failed: %d", totalTests - passedTests))
    print(string.format("Pass Rate: %.1f%%", totalTests > 0 and (passedTests / totalTests * 100) or 0))
    
    -- Detailed results
    if #self.results > 0 then
        print("\nDetailed Results:")
        for i, result in ipairs(self.results) do
            local status = result.result.passed and "✅ PASS" or "❌ FAIL"
            print(string.format("\n%d. [%s] %s", i, status, result.result.name))
            
            if not result.result.passed then
                print(string.format("   Violations: %d", #result.result.violations))
                for _, violation in ipairs(result.result.violations) do
                    print(string.format("     - [%.2fs] %s: %s", 
                        violation.time, violation.type, violation.message))
                end
            end
        end
    end
    
    print(string.rep("=", 70))
    print("\n✨ Test suite complete!")
end

function TestRunner:quickPositionCheck()
    --[[
        Quick vehicle position check (can be called anytime during gameplay)
        
        @return: true if position acceptable, false otherwise
    ]]
    
    if not self.gameManager.vehicle then
        print("⚠️  Quick Check: Vehicle not found")
        return false
    end
    
    local x, y = self.gameManager.vehicle:getPosition()
    local screenHeight = love.graphics.getHeight()
    local maxY = screenHeight + 100  -- Allow some overflow
    local minY = -100
    
    local acceptable = y > minY and y < maxY
    
    if not acceptable then
        print(string.format("❌ Quick Check FAILED: Vehicle at Y=%.1f (acceptable range: %.1f to %.1f)",
            y, minY, maxY))
    else
        print(string.format("✅ Quick Check PASSED: Vehicle at Y=%.1f", y))
    end
    
    return acceptable
end

return TestRunner
