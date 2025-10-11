-- src/ui/animations.lua
-- GSAP-inspired animation system for Love2D using flux
-- Week 0 Day 4 - Animation System

local flux = require('lib.flux')

local Animations = {}

-- Animation presets (mapped from GSAP/Framer Motion to flux)
Animations.easings = {
    -- Linear
    linear = "linear",
    
    -- Quad (most common for UI)
    quadIn = "quadin",
    quadOut = "quadout",
    quadInOut = "quadinout",
    
    -- Cubic (smooth UI transitions)
    cubicIn = "cubicin",
    cubicOut = "cubicout",
    cubicInOut = "cubicinout",
    
    -- Quart (panel slides)
    quartIn = "quartin",
    quartOut = "quartout",
    quartInOut = "quartinout",
    
    -- Expo (dramatic entrances)
    expoIn = "expoin",
    expoOut = "expoout",
    expoInOut = "expoinout",
    
    -- Back (overshoots - great for buttons)
    backIn = "backin",
    backOut = "backout",
    backInOut = "backinout",
    
    -- Elastic (bouncy - for score/combos)
    elasticIn = "elasticin",
    elasticOut = "elasticout",
    elasticInOut = "elasticinout",
}

-- Common animation patterns
Animations.patterns = {}

-- Fade in element
function Animations.patterns.fadeIn(element, duration, delay)
    duration = duration or 0.5
    delay = delay or 0
    
    element.opacity = 0
    
    return flux.to(element, duration, {opacity = 1})
        :ease(Animations.easings.quadOut)
        :delay(delay)
end

-- Fade out element
function Animations.patterns.fadeOut(element, duration, delay)
    duration = duration or 0.5
    delay = delay or 0
    
    return flux.to(element, duration, {opacity = 0})
        :ease(Animations.easings.quadIn)
        :delay(delay)
end

-- Slide in from direction
function Animations.patterns.slideIn(element, direction, distance, duration, delay)
    direction = direction or "bottom" -- top, bottom, left, right
    distance = distance or 100
    duration = duration or 0.6
    delay = delay or 0
    
    local startX, startY = element.x, element.y
    
    if direction == "bottom" then
        element.y = element.y + distance
    elseif direction == "top" then
        element.y = element.y - distance
    elseif direction == "left" then
        element.x = element.x - distance
    elseif direction == "right" then
        element.x = element.x + distance
    end
    
    return flux.to(element, duration, {x = startX, y = startY})
        :ease(Animations.easings.quartOut)
        :delay(delay)
end

-- Scale pop (buttons, achievements)
function Animations.patterns.scalePop(element, targetScale, duration, delay)
    targetScale = targetScale or 1
    duration = duration or 0.4
    delay = delay or 0
    
    element.scale = 0
    
    return flux.to(element, duration, {scale = targetScale})
        :ease(Animations.easings.backOut)
        :delay(delay)
end

-- Button hover (scale up slightly)
function Animations.patterns.buttonHover(element)
    return flux.to(element, 0.2, {scale = 1.05, y = element.y - 2})
        :ease(Animations.easings.backOut)
end

-- Button unhover (return to normal)
function Animations.patterns.buttonUnhover(element, originalY)
    return flux.to(element, 0.2, {scale = 1.0, y = originalY})
        :ease(Animations.easings.quadOut)
end

-- Button press (scale down)
function Animations.patterns.buttonPress(element)
    return flux.to(element, 0.1, {scale = 0.95})
        :ease(Animations.easings.quadIn)
end

-- Button release (return to hover or normal)
function Animations.patterns.buttonRelease(element, isHovered)
    local targetScale = isHovered and 1.05 or 1.0
    return flux.to(element, 0.15, {scale = targetScale})
        :ease(Animations.easings.quadOut)
end

-- Score number count up
function Animations.patterns.scoreCountUp(element, targetValue, duration)
    duration = duration or 1.0
    
    return flux.to(element, duration, {value = targetValue})
        :ease(Animations.easings.expoOut)
end

-- Pulse effect (for combo multipliers)
function Animations.patterns.pulse(element, scaleAmount, duration)
    scaleAmount = scaleAmount or 0.1
    duration = duration or 0.5
    
    local originalScale = element.scale or 1.0
    local pulseScale = originalScale + scaleAmount
    
    return flux.to(element, duration / 2, {scale = pulseScale})
        :ease(Animations.easings.quadInOut)
        :after(element, duration / 2, {scale = originalScale})
        :ease(Animations.easings.quadInOut)
end

-- Shake effect (screen shake, error feedback)
function Animations.patterns.shake(element, intensity, duration)
    intensity = intensity or 5
    duration = duration or 0.3
    
    local originalX = element.x
    local shakes = 8
    local shakeDuration = duration / shakes
    
    local tween = flux.to(element, shakeDuration, {x = originalX + intensity})
    
    for i = 1, shakes - 1 do
        local offset = (i % 2 == 0) and intensity or -intensity
        tween = tween:after(element, shakeDuration, {x = originalX + offset})
    end
    
    return tween:after(element, shakeDuration, {x = originalX})
end

-- Stagger animation for multiple elements
function Animations.patterns.stagger(elements, animationFunc, staggerDelay)
    staggerDelay = staggerDelay or 0.1
    
    local tweens = {}
    for i, element in ipairs(elements) do
        local delay = (i - 1) * staggerDelay
        tweens[i] = animationFunc(element, delay)
    end
    
    return tweens
end

-- Progress bar fill
function Animations.patterns.progressFill(element, targetWidth, duration)
    duration = duration or 1.5
    
    element.width = 0
    
    return flux.to(element, duration, {width = targetWidth})
        :ease(Animations.easings.expoOut)
end

-- Glow pulse (for highlights)
function Animations.patterns.glowPulse(element, minAlpha, maxAlpha, duration)
    minAlpha = minAlpha or 0.3
    maxAlpha = maxAlpha or 0.8
    duration = duration or 1.5
    
    element.glowAlpha = minAlpha
    
    local function createPulse()
        flux.to(element, duration / 2, {glowAlpha = maxAlpha})
            :ease(Animations.easings.sineInOut)
            :after(element, duration / 2, {glowAlpha = minAlpha})
            :ease(Animations.easings.sineInOut)
            :oncomplete(createPulse)
    end
    
    createPulse()
end

-- Rotate continuously (loading spinner)
function Animations.patterns.rotateLoop(element, speed)
    speed = speed or 2.0 -- seconds per rotation
    
    element.rotation = 0
    
    local function rotate()
        flux.to(element, speed, {rotation = math.pi * 2})
            :ease(Animations.easings.linear)
            :oncomplete(function()
                element.rotation = 0
                rotate()
            end)
    end
    
    rotate()
end

-- Menu transition (slide + fade)
function Animations.patterns.menuTransition(oldMenu, newMenu, direction)
    direction = direction or "left"
    local distance = 200
    
    -- Fade out and slide old menu
    if oldMenu then
        Animations.patterns.fadeOut(oldMenu, 0.3)
        if direction == "left" then
            flux.to(oldMenu, 0.3, {x = oldMenu.x - distance})
        else
            flux.to(oldMenu, 0.3, {x = oldMenu.x + distance})
        end
    end
    
    -- Fade in and slide new menu
    if newMenu then
        newMenu.opacity = 0
        if direction == "left" then
            newMenu.x = newMenu.x + distance
        else
            newMenu.x = newMenu.x - distance
        end
        
        Animations.patterns.fadeIn(newMenu, 0.4, 0.1)
        flux.to(newMenu, 0.4, {x = newMenu.x - distance})
            :ease(Animations.easings.quartOut)
            :delay(0.1)
    end
end

-- Helper: Stop all animations on element
function Animations.stopAll(element)
    flux.to(element, 0, {}):stop()
end

-- Helper: Update all flux animations (call in love.update)
function Animations.update(dt)
    flux.update(dt)
end

return Animations
