# GSAP to flux Animation Mapping

## Purpose
This document maps GSAP easing functions (used in React UI design) to flux.lua easing functions (used in Love2D game).

---

## Easing Function Mapping

### Linear
| GSAP | flux | Description |
|------|------|-------------|
| `none` | `linear` | No easing, constant rate |

### Quadratic
| GSAP | flux | Description |
|------|------|-------------|
| `power1.in` | `quadin` | Quadratic ease in |
| `power1.out` | `quadout` | Quadratic ease out |
| `power1.inOut` | `quadinout` | Quadratic ease in-out |

### Cubic
| GSAP | flux | Description |
|------|------|-------------|
| `power2.in` | `cubicin` | Cubic ease in |
| `power2.out` | `cubicout` | Cubic ease out |
| `power2.inOut` | `cubicinout` | Cubic ease in-out |

### Quartic
| GSAP | flux | Description |
|------|------|-------------|
| `power3.in` | `quartin` | Quartic ease in |
| `power3.out` | `quartout` | Quartic ease out |
| `power3.inOut` | `quartinout` | Quartic ease in-out |

### Quintic
| GSAP | flux | Description |
|------|------|-------------|
| `power4.in` | `quintin` | Quintic ease in |
| `power4.out` | `quintout` | Quintic ease out |
| `power4.inOut` | `quintinout` | Quintic ease in-out |

### Exponential
| GSAP | flux | Description |
|------|------|-------------|
| `expo.in` | `expoin` | Exponential ease in |
| `expo.out` | `expoout` | Exponential ease out |
| `expo.inOut` | `expoinout` | Exponential ease in-out |

### Sine
| GSAP | flux | Description |
|------|------|-------------|
| `sine.in` | `sinein` | Sine ease in |
| `sine.out` | `sineout` | Sine ease out |
| `sine.inOut` | `sineinout` | Sine ease in-out |

### Circular
| GSAP | flux | Description |
|------|------|-------------|
| `circ.in` | `circin` | Circular ease in |
| `circ.out` | `circout` | Circular ease out |
| `circ.inOut` | `circinout` | Circular ease in-out |

### Elastic
| GSAP | flux | Description |
|------|------|-------------|
| `elastic.in` | `elasticin` | Elastic ease in (bouncy) |
| `elastic.out` | `elasticout` | Elastic ease out (bouncy) |
| `elastic.inOut` | `elasticinout` | Elastic ease in-out (bouncy) |

### Back
| GSAP | flux | Description |
|------|------|-------------|
| `back.in` | `backin` | Overshoots and comes back (in) |
| `back.out` | `backout` | Overshoots and comes back (out) |
| `back.inOut` | `backinout` | Overshoots and comes back (in-out) |

### Bounce
| GSAP | flux | Description |
|------|------|-------------|
| `bounce.in` | *(custom)* | Bouncing effect (in) - needs custom implementation |
| `bounce.out` | *(custom)* | Bouncing effect (out) - needs custom implementation |
| `bounce.inOut` | *(custom)* | Bouncing effect (in-out) - needs custom implementation |

---

## Recommended Mappings for Game UI

### Menu Buttons
```lua
-- Framer Motion: spring { stiffness: 400, damping: 25 }
-- flux equivalent:
flux.to(button, 0.3, {scale = 1.02}):ease("backout")
```

### Panel Transitions
```lua
-- GSAP: power3.out
-- flux equivalent:
flux.to(panel, 0.5, {y = 0, opacity = 1}):ease("quartout")
```

### Score Popups
```lua
-- GSAP: elastic.out
-- flux equivalent:
flux.to(score, 0.8, {y = -50, scale = 1.5}):ease("elasticout")
```

### HUD Elements (Smooth)
```lua
-- GSAP: power2.inOut
-- flux equivalent:
flux.to(hud, 0.4, {alpha = 1}):ease("cubicinout")
```

### Achievement Unlocks
```lua
-- GSAP: back.out(1.7)
-- flux equivalent:
flux.to(achievement, 0.6, {scale = 1}):ease("backout")
```

---

## Common Animation Patterns

### Fade In
```lua
-- Start: opacity = 0
-- End: opacity = 1
flux.to(element, 0.5, {opacity = 1}):ease("quadout")
```

### Slide In from Bottom
```lua
-- Start: y = 100
-- End: y = 0
flux.to(element, 0.6, {y = 0}):ease("quartout")
```

### Scale Pop
```lua
-- Start: scale = 0
-- End: scale = 1
flux.to(element, 0.4, {scale = 1}):ease("backout")
```

### Stagger Effect (Manual)
```lua
-- Stagger multiple elements with delay
for i, element in ipairs(elements) do
    flux.to(element, 0.5, {y = 0}):ease("quadout"):delay((i-1) * 0.1)
end
```

---

## flux.lua Notes

**Available easing functions:**
- `linear`
- `quadin`, `quadout`, `quadinout`
- `cubicin`, `cubicout`, `cubicinout`
- `quartin`, `quartout`, `quartinout`
- `quintin`, `quintout`, `quintinout`
- `expoin`, `expoout`, `expoinout`
- `sinein`, `sineout`, `sineinout`
- `circin`, `circout`, `circinout`
- `backin`, `backout`, `backinout`
- `elasticin`, `elasticout`, `elasticinout`

**flux Features:**
- Chaining: `:oncomplete()`, `:delay()`, `:after()`
- Looping: Manual implementation needed
- Update: Call `flux.update(dt)` in `love.update()`

---

## Workflow

1. **Design in React/Framer Motion** (Magic MCP)
   - Use natural spring animations
   - Visual feedback for timing

2. **Export as Screenshot**
   - Capture static states (normal, hover, active)

3. **Implement in flux**
   - Map spring → `backout` or `elasticout`
   - Adjust duration to match feel
   - Test and tweak

---

**Last Updated**: 2025-10-10
**Reference**: Week 0 Day 2 - UI Foundation Setup
