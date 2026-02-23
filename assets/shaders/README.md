# Shader-Based Animated Backgrounds

This directory contains shader files for creating procedurally animated backgrounds in Runefall.

## Overview

Shader-based backgrounds provide an alternative to frame-based animations, allowing for smooth, procedural effects without requiring multiple image files. Shaders run on the GPU and can create effects like rotation, pulsing, waves, and color shifts.

## Available Shaders

### animated_background.gdshader
A versatile shader that combines rotation and wave distortion effects.

**Parameters:**
- `time_scale` (0.1 - 5.0): Controls animation speed
- `color_tint` (Color): Tints the background texture
- `wave_amplitude` (0.0 - 1.0): Strength of wave distortion
- `wave_frequency` (0.1 - 10.0): Frequency of wave patterns
- `rotation_speed` (-2.0 - 2.0): Rotation speed (negative for reverse)
- `base_texture` (Texture): The base image to apply effects to

**Use cases:**
- Mystical swirling backgrounds
- Rotating elemental energies
- Dynamic water/air effects

### pulsing_background.gdshader
A simpler shader that creates a pulsing/breathing effect.

**Parameters:**
- `pulse_speed` (0.1 - 5.0): Speed of the pulsing effect
- `pulse_intensity` (0.0 - 1.0): Strength of brightness variation
- `pulse_color` (Color): Color tint applied during pulse
- `base_texture` (Texture): The base image to apply effects to

**Use cases:**
- Glowing magical effects
- Breathing/living backgrounds
- Subtle ambient animation

## Configuration

To use a shader-based background, configure it in `backgrounds_config.json`:

```json
{
  "backgrounds": {
    "my_shader_background": {
      "type": "shader",
      "path": "res://assets/backgrounds/my_texture.png",
      "shader_path": "res://assets/shaders/animated_background.gdshader",
      "opacity": 0.85,
      "shader_params": {
        "time_scale": 0.5,
        "color_tint": "#FFFFFF",
        "wave_amplitude": 0.05,
        "wave_frequency": 3.0,
        "rotation_speed": 0.2
      }
    }
  }
}
```

### Configuration Fields

- **type**: Must be `"shader"` for shader-based backgrounds
- **path**: Path to the base texture (can be empty to use a white texture)
- **shader_path**: Path to the `.gdshader` file
- **opacity**: Overall opacity of the background (0.0 - 1.0)
- **shader_params**: Dictionary of shader parameters
  - Parameter names must match the shader's uniform names
  - Color values can be hex strings (e.g., `"#FF0000"`) or Color objects
  - Numeric values are passed directly to the shader

## Creating Custom Shaders

To create a new shader for backgrounds:

1. Create a new `.gdshader` file in this directory
2. Use `shader_type canvas_item;` at the top
3. Define uniforms for configurable parameters
4. Implement the `fragment()` function to apply effects
5. Use `TIME` for animation (automatically provided by Godot)
6. Sample the base texture with `texture(base_texture, UV)`

### Example Template

```glsl
shader_type canvas_item;

uniform float my_speed : hint_range(0.1, 5.0) = 1.0;
uniform vec4 my_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D base_texture : hint_default_white;

void fragment() {
    // Your effect logic here
    float t = TIME * my_speed;
    
    // Sample the base texture
    vec4 tex_color = texture(base_texture, UV);
    
    // Apply your effect
    COLOR = tex_color * my_color;
}
```

## Performance Considerations

- Shader-based backgrounds run on the GPU and are generally very efficient
- Complex shaders with many calculations may impact performance on lower-end hardware
- Test on target hardware to ensure 60 FPS gameplay is maintained
- Simpler shaders (like pulsing_background.gdshader) have minimal performance impact

## Advantages Over Frame-Based Animation

- **Smaller file size**: No need for multiple image files
- **Smooth animation**: Runs at full frame rate without frame stepping
- **Configurable**: Parameters can be adjusted without regenerating assets
- **Dynamic**: Can respond to game state or time in real-time
- **Scalable**: Works at any resolution without quality loss

## Disadvantages

- **Requires shader knowledge**: More technical than frame-based animation
- **Limited artistic control**: Procedural effects may not match specific artistic vision
- **Debugging complexity**: Shader errors can be harder to diagnose

## When to Use Shaders vs Frames

**Use shaders when:**
- You want smooth, continuous animation
- File size is a concern
- You need configurable, parametric effects
- The effect is geometric/mathematical (rotation, waves, etc.)

**Use frame-based animation when:**
- You have specific hand-crafted or AI-generated frames
- The animation is complex and non-procedural
- You want precise artistic control over each frame
- The animation has discrete states or keyframes

## Testing

Shader backgrounds can be tested using `tests/test_shader_background_loading.gd`, which verifies:
- Shader files can be loaded
- Shader materials are applied correctly
- Parameters are configured from JSON
- Color string conversion works
- Fallback behavior for missing shaders

## Integration with Background_Manager

The Background_Manager automatically handles shader backgrounds when `type: "shader"` is specified in the configuration. It:

1. Loads the shader resource from `shader_path`
2. Creates a Sprite2D node with the base texture
3. Creates a ShaderMaterial and applies the shader
4. Sets all shader parameters from `shader_params`
5. Converts color strings (e.g., "#FF0000") to Color objects
6. Scales the sprite to fill the viewport
7. Adds the sprite to a CanvasLayer with z-index -100

No additional code is required to use shader backgrounds beyond configuration.
