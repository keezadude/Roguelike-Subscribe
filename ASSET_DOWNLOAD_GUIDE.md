# Asset Download Guide - Week 2

## 📦 Required Assets for Week 2

This guide provides direct download links and organization instructions for all game assets.

---

## 🎨 3D Character Models

### 1. Quaternius - Ultimate Modular Men Pack (FREE, CC0)

**Download**: https://quaternius.com/packs/ultimatemodularmen.html

**What to Download**:
- Ultimate Modular Men Pack (GLB format preferred)
- Includes modular characters perfect for ragdolls
- CC0 License - completely free for commercial use

**Where to Save**:
```
assets/models/characters/quaternius/
  ├── base_character.glb
  ├── modular_head_01.glb
  ├── modular_torso_01.glb
  ├── modular_arms_01.glb
  └── modular_legs_01.glb
```

**Alternative Direct Link**: https://quaternius.itch.io/

---

### 2. Kenney Car Kit (FREE, CC0)

**Download**: https://kenney.nl/assets/car-kit

**What to Download**:
- Car Kit (FBX or OBJ format)
- Includes trucks, cars, wheels
- Perfect for Week 3 vehicle physics

**Where to Save**:
```
assets/models/vehicles/kenney/
  ├── truck_01.obj
  ├── truck_02.obj
  ├── wheel.obj
  └── textures/
```

**Note**: Also download the Racing Kit for more variety:
https://kenney.nl/assets/racing-kit

---

### 3. Poly Pizza Models (FREE, Various Licenses)

**Search Trucks**: https://poly.pizza/search/truck

**Recommended Downloads**:
- Low-poly truck models (< 5000 polygons)
- GLB or GLTF format preferred
- Check license (most are CC-BY or CC0)

**Where to Save**:
```
assets/models/vehicles/poly-pizza/
  ├── truck_lowpoly_01.glb
  ├── truck_lowpoly_02.glb
  └── attribution.txt  (if CC-BY)
```

**Search Characters**: https://poly.pizza/explore/People-and-Characters

---

## 🔊 Sound Effects

### Freesound.org Impact Sounds (FREE, CC0)

**Search Terms**:
- "impact" + CC0 filter
- "crash" + CC0 filter
- "thud" + CC0 filter
- "collision" + CC0 filter

**Direct CC0 Browse**: https://freesound.org/browse/tags/cc0/

**Recommended Sounds**:
1. Body impacts (thud, punch, hit)
2. Metal crashes (for vehicles)
3. Breaking/cracking sounds
4. Whoosh/swoosh (for movement)

**Where to Save**:
```
assets/sounds/impacts/
  ├── body_impact_01.ogg
  ├── body_impact_02.ogg
  ├── metal_crash_01.ogg
  ├── metal_crash_02.ogg
  ├── bone_crack_01.ogg
  └── whoosh_01.ogg
```

**Format**: Download as OGG (best for Love2D)

---

## 📂 Complete Asset Structure

After downloading all assets, your structure should look like:

```
assets/
├── fonts/
│   └── (UI fonts - Week 0)
├── images/
│   └── ui/
│       └── (UI sprites - Week 0)
├── models/
│   ├── characters/
│   │   ├── quaternius/
│   │   │   ├── base_character.glb
│   │   │   ├── modular_head.glb
│   │   │   ├── modular_torso.glb
│   │   │   ├── modular_arms.glb
│   │   │   └── modular_legs.glb
│   │   └── poly-pizza/
│   │       └── (additional characters)
│   └── vehicles/
│       ├── kenney/
│       │   ├── truck_01.obj
│       │   ├── truck_02.obj
│       │   └── textures/
│       └── poly-pizza/
│           └── (additional vehicles)
├── shaders/
│   └── (custom shaders - Week 4+)
└── sounds/
    ├── impacts/
    │   ├── body_impact_01.ogg
    │   ├── metal_crash_01.ogg
    │   └── bone_crack_01.ogg
    └── music/
        └── (background music - Week 6)
```

---

## 🚀 Quick Download Checklist

### Week 2 Priority (Required Now):
- [ ] Quaternius Ultimate Modular Men Pack
- [ ] At least 1 character model in GLB format
- [ ] Test model in `assets/models/characters/test/`

### Week 3 Priority (Next Week):
- [ ] Kenney Car Kit
- [ ] 2-3 truck models
- [ ] Impact sound effects (5-10 sounds)

### Week 6 Priority (Later):
- [ ] Background music
- [ ] UI sound effects
- [ ] Ambient sounds

---

## 🔧 Format Recommendations

### 3D Models:
- **Preferred**: GLB (GLTF binary)
- **Alternative**: OBJ (simple, widely supported)
- **Avoid**: FBX (harder to parse in Lua)

### Textures:
- **Format**: PNG (transparency support)
- **Size**: 512x512 or 1024x1024
- **Compression**: Keep reasonable file sizes

### Audio:
- **Format**: OGG Vorbis (best Love2D support)
- **Sample Rate**: 44100 Hz
- **Channels**: Mono (for effects), Stereo (for music)

---

## 📝 License Tracking

Create `assets/LICENSES.txt` with attribution:

```
=== 3D Models ===

Quaternius - Ultimate Modular Men Pack
License: CC0 (Public Domain)
Source: https://quaternius.com
Usage: Character models and ragdoll system

Kenney - Car Kit
License: CC0 (Public Domain)
Source: https://kenney.nl
Usage: Vehicle models

Poly Pizza - [Model Name]
License: [Check individual model]
Source: https://poly.pizza
Attribution: [If CC-BY, add creator name]
Usage: Additional models

=== Sound Effects ===

Freesound.org - Impact Sounds
License: CC0 (Public Domain)
Source: https://freesound.org
Individual sounds:
  - [sound_name] by [author] (CC0)
  - [sound_name] by [author] (CC0)

```

---

## 🎯 Week 2 Minimum Requirements

To proceed with Week 2 development, you need **at minimum**:

1. **One character model** (GLB format)
   - Can be any humanoid model
   - Will be used for ragdoll testing
   - Quaternius is recommended

2. **Test the model** loads in 3DreamEngine
   - Place in `assets/models/characters/test/`
   - Name it `test_character.glb`

---

## 🔗 Quick Links Reference

- **Quaternius**: https://quaternius.com
- **Kenney Assets**: https://kenney.nl/assets
- **Poly Pizza**: https://poly.pizza
- **Freesound CC0**: https://freesound.org/browse/tags/cc0/
- **Sketchfab CC0**: https://sketchfab.com/search?licenses=322a749bcfa841b29dff1e8a1bb74b0b&type=models

---

## ⚠️ Important Notes

1. **Always check licenses** before using assets
2. **Keep attribution.txt** for CC-BY assets
3. **Test models load** before committing to them
4. **Optimize poly count** - keep under 10k triangles per model
5. **Consistent scale** - ensure all models are similarly sized

---

**Next Step**: Download Quaternius character pack and place one model in `assets/models/characters/test/test_character.glb`

Then the game code can automatically load and render it!

---

**Last Updated**: 2025-10-10  
**For**: Week 2 - Asset Integration & Ragdoll  
**Status**: Ready for downloads
