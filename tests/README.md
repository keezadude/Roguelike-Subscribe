# Automated Testing System

## Overview

The automated testing system monitors vehicle position during gameplay to detect physics issues, spawn problems, and other anomalies. It's designed to catch bugs before they affect gameplay.

## Quick Start

### Running Tests During Gameplay

1. **Launch the game**
2. **Start a run** (press SPACE at main menu, then SPACE to launch)
3. **Press F3** during gameplay to start automated test
4. **Watch the console** for test results

### Keyboard Shortcuts

| Key | Function | Description |
|-----|----------|-------------|
| **F1** | Toggle Debug View | Shows physics bodies and stats |
| **F2** | Quick Position Check | Instant vehicle position validation |
| **F3** | Run Single Test | 10-second automated position test |
| **F4** | Run Full Test Suite | Complete automated test battery |

## Test Components

### 1. Vehicle Position Test

**File:** `tests/vehicle-position-test.lua`

**What it checks:**
- ✅ Vehicle spawns at acceptable Y position
- ✅ Vehicle doesn't fall through ground
- ✅ Vehicle doesn't fly off-screen
- ✅ No physics glitches (rapid Y-axis jumps)
- ✅ Position stays within acceptable range during gameplay

**Configuration:**
```lua
CONFIG = {
    MAX_ACCEPTABLE_Y = 800,     -- Max Y before "fell through ground"
    MIN_ACCEPTABLE_Y = -100,    -- Min Y before "flew off screen"
    EXPECTED_SPAWN_Y_MIN = 500, -- Expected spawn range minimum
    EXPECTED_SPAWN_Y_MAX = 700, -- Expected spawn range maximum
    TEST_DURATION = 10.0,       -- Test duration in seconds
    SAMPLE_RATE = 0.1,          -- Position sampling rate
}
```

### 2. Test Runner

**File:** `tests/test-runner.lua`

Coordinates multiple tests and generates comprehensive reports.

## How to Use

### Method 1: In-Game Testing (Recommended)

1. **Setup Phase:**
   ```
   Main Menu → Press SPACE → Vehicle spawns on ramp
   ```

2. **Start Test:**
   ```
   Press F3 → Test begins monitoring
   ```

3. **Launch Vehicle:**
   ```
   Hold SPACE → Release → Vehicle launches
   ```

4. **Monitor:**
   ```
   Test runs for 10 seconds
   Watch console for violations
   See overlay showing test status
   ```

5. **Review Results:**
   ```
   Test completes automatically
   Console shows detailed report
   ```

### Method 2: Quick Check

**When to use:** Quickly verify vehicle position without full test

1. **At any point during gameplay:**
   ```
   Press F2
   ```

2. **Console output:**
   ```
   ✅ Quick Check PASSED: Vehicle at Y=650.0
   OR
   ❌ Quick Check FAILED: Vehicle at Y=850.0 (acceptable range: -100.0 to 800.0)
   ```

### Method 3: Full Test Suite

**When to use:** Complete validation before release/commit

1. **From main menu:**
   ```
   Press F4
   ```

2. **Test runs automatically:**
   ```
   - Runs all configured tests
   - Each test takes 10 seconds
   - Generates comprehensive report
   ```

## Understanding Test Results

### Console Output Example

```
=== Starting Vehicle Position Test: Manual Position Test ===
📍 Initial spawn position: (100.0, 630.0)
📏 Ground reference: Y = 700.0

[Test monitors vehicle for 10 seconds...]

✅ No violations detected!

=== Test Complete: Manual Position Test [PASSED] ===
Duration: 10.00s
Samples: 100
Violations: 0

📊 Position Trace (every 1s):
Time(s) | X Position | Y Position | Speed
--------|------------|------------|-------
   0.00 |      100.0 |      630.0 |    0.0
   1.00 |      245.3 |      645.2 |  156.3
   2.00 |      412.8 |      658.1 |  201.5
   [...]
```

### Violation Types

| Violation Code | Meaning | Action Required |
|----------------|---------|-----------------|
| **SPAWN_FAILURE** | Vehicle didn't spawn | Check vehicle creation code |
| **SPAWN_TOO_HIGH** | Spawned above acceptable range | Adjust spawn Y position |
| **SPAWN_TOO_LOW** | Spawned below acceptable range | Adjust spawn Y position |
| **SPAWN_FAR_FROM_GROUND** | Spawned too far from ground | Check ground Y calculation |
| **FELL_THROUGH_GROUND** | Y exceeded max during gameplay | Physics collision issue |
| **FLEW_OFF_TOP** | Y below min during gameplay | Excessive upward force |
| **PHYSICS_GLITCH** | Abnormal Y velocity detected | Physics engine issue |

## Customizing Tests

### Adjusting Thresholds

Edit `tests/vehicle-position-test.lua`:

```lua
VehiclePositionTest.CONFIG = {
    MAX_ACCEPTABLE_Y = 800,     -- Increase if vehicle legitimately goes lower
    MIN_ACCEPTABLE_Y = -100,    -- Decrease for more airtime tolerance
    EXPECTED_SPAWN_Y_MIN = 500, -- Adjust to match your spawn logic
    EXPECTED_SPAWN_Y_MAX = 700, -- Adjust to match your spawn logic
}
```

### Adding New Tests

1. **Create test file** in `tests/` directory
2. **Implement test class** with these methods:
   ```lua
   function Test:new(gameManager)
   function Test:startTest(testName)
   function Test:update(dt)
   function Test:endTest()
   ```

3. **Register in test-runner.lua:**
   ```lua
   function TestRunner:registerTests()
       self.tests.myNewTest = MyNewTest:new(self.gameManager)
   end
   ```

## Integration with CI/CD

### Headless Testing

For automated testing pipelines, you can run tests without graphics:

```lua
-- In main.lua
if arg[1] == "--test" then
    -- Run tests in headless mode
    game:runFullTestSuite()
    love.event.quit()
end
```

Then run:
```bash
love.exe . --test > test-results.log
```

## Troubleshooting

### Test Not Starting

**Symptom:** Pressing F3 does nothing

**Solutions:**
- Check console for error messages
- Ensure `tests/` directory exists
- Verify test files are present
- Check Lua path configuration

### False Positives

**Symptom:** Test fails but gameplay looks fine

**Solutions:**
- Review violation messages in console
- Check if thresholds are too strict
- Adjust CONFIG values in test file
- Verify ground Y calculation matches game

### False Negatives

**Symptom:** Test passes but vehicle has issues

**Solutions:**
- Increase test duration (TEST_DURATION)
- Decrease sample rate (SAMPLE_RATE) for more samples
- Add stricter thresholds
- Add additional validation checks

## Best Practices

### When to Run Tests

✅ **Before commits** - Run F4 (full suite)
✅ **After physics changes** - Run F3 (single test)
✅ **During debugging** - Use F2 (quick check)
✅ **Before releases** - Full automated CI/CD run

### Test-Driven Development

1. **Write test first** (define expected behavior)
2. **Run test** (should fail initially)
3. **Implement feature**
4. **Run test again** (should pass)
5. **Refactor** (test continues to pass)

### Interpreting Position Traces

The position trace shows vehicle movement over time:

```
Time(s) | X Position | Y Position | Speed
   0.00 |      100.0 |      630.0 |    0.0  ← Spawn position
   1.00 |      245.3 |      645.2 |  156.3  ← Launched, moving right/down
   2.00 |      412.8 |      658.1 |  201.5  ← Accelerating
   3.00 |      598.2 |      682.4 |  189.7  ← Slowing (friction)
   4.00 |      723.1 |      695.0 |   98.3  ← Near ground
   5.00 |      784.5 |      698.2 |   34.1  ← Almost stopped
```

Look for:
- Sudden Y jumps (physics glitches)
- Y going negative (flew off top)
- Y > 800 (fell through ground)
- Abnormal speed values

## Examples

### Example 1: Basic Position Check
```lua
-- Press F2 at any time
✅ Quick Check PASSED: Vehicle at Y=650.0
```

### Example 2: Spawn Validation
```lua
-- Press F3 after spawning vehicle
📍 Initial spawn position: (100.0, 630.0)
✅ Spawn position valid
✅ Within ground tolerance
```

### Example 3: Detecting Fall-Through
```lua
-- Test automatically detects issue
❌ VIOLATION [FELL_THROUGH_GROUND]: Vehicle fell below ground: Y=815.3 at t=3.45s (max: 800.0)

[Test continues, generates report with violation details]
```

## API Reference

### VehiclePositionTest

```lua
-- Create test
local test = VehiclePositionTest:new(gameManager)

-- Start test
test:startTest("Test Name")

-- Update (called each frame)
test:update(dt)

-- Get statistics
local stats = test:getStatistics()

-- Generate report
test:generateReport()
```

### TestRunner

```lua
-- Create runner
local runner = TestRunner:new(gameManager)

-- Run specific test
runner:runTest("vehiclePosition", "My Test")

-- Run all tests
runner:runAllTests()

-- Quick check
local passed = runner:quickPositionCheck()
```

---

## Support

For issues or questions about the testing system:
1. Check console output for detailed error messages
2. Review this README for common issues
3. Examine test configuration values
4. Add debug print statements to trace execution

**Happy Testing! 🧪**
