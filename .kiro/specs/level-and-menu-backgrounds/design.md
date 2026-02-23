# Design Document: Level and Menu Backgrounds

## Overview

This feature adds visual atmosphere to Runefall through a Background_Manager system that handles both static level backgrounds and an animated menu background. The system integrates with the existing Godot 4.3 architecture, following patterns established by SpriteManager for asset management and leveraging Godot's CanvasLayer system for proper rendering order.

The Background_Manager will be implemented as an autoloaded singleton, providing centralized background control across all game scenes. Each of the three game levels receives a unique static background reflecting its elemental theme (Fire/Earth, Water/Air, Mixed), while the main menu features a looping animated background to create an engaging entry experience.

Key design goals:
- Minimal performance impact (maintain 60 FPS gameplay)
- Clean separation from gameplay logic
- Flexible animation system supporting multiple implementation approaches
- Integration with existing Replicate MCP workflow for asset generation
- Configuration-driven asset management

## Architecture

### System Components

**Background_Manager (Autoload Singleton)**
- Central controller for all background operations
- Manages background lifecycle (load, display, cleanup)
- Handles transitions between menu and level backgrounds
- Provides configuration-driven asset loading
- Implements fallback behavior for missing assets

**Background Configuration (backgrounds_config.json)**
- JSON configuration file defining background assets and settings
- Specifies file paths for each level and menu background
- Defines animation parameters (speed, loop settings)
- Allows opacity and visual adjustment per background
- Follows pattern established by sprites_config.json

**Background Assets (assets/backgrounds/)**
- Organized directory structure for background images
- Static PNG images for three level backgrounds
- Animated frames or shader resources for menu background
- Generated via Replicate MCP integration
- Compressed textures for memory efficiency

### Integration Points

**GameState Integration**
- Background_Manager listens to GameState.state_changed signal
- Automatically switches backgrounds on level transitions
- Resumes menu animation when returning to menu
- No direct coupling - signal-based communication only

**Scene Integration**
- Background_Manager creates CanvasLayer nodes dynamically
- Injects background layers into active scene tree
- Ensures proper z-ordering (backgrounds behind all game elements)
- Cleans up previous backgrounds before loading new ones

**Replicate MCP Integration**
- Extends existing sprite generation workflow
- Uses backgrounds_config.json for generation prompts
- Maintains consistent art style with game sprites
- Documents generation parameters for reproducibility

### Rendering Architecture

**CanvasLayer Hierarchy**
```
Scene Root
├── Background_CanvasLayer (z-index: -100)
│   └── Background_Sprite (Sprite2D or AnimatedSprite2D)
├── Game_Elements (z-index: 0)
└── UI_Elements (z-index: 100)
```

The Background_Manager creates a dedicated CanvasLayer with negative z-index to ensure backgrounds render behind all gameplay and UI elements. This approach provides clean separation and prevents any rendering conflicts.

## Components and Interfaces

### Background_Manager API

```gdscript
class_name BackgroundManager
extends Node

# Public API
func load_level_background(level_number: int) -> void
func load_menu_background() -> void
func set_background_opacity(opacity: float) -> void
func cleanup_current_background() -> void

# Configuration
func load_config() -> Dictionary
func get_background_path(background_id: String) -> String

# Fallback handling
func show_fallback_background(color: Color) -> void
func has_background_asset(background_id: String) -> bool

# Signals
signal background_loaded(background_id: String)
signal background_load_failed(background_id: String)
```

**Key Methods:**

`load_level_background(level_number: int)`
- Validates level number (1-3)
- Loads corresponding static background from config
- Creates CanvasLayer and Sprite2D nodes
- Scales background to fill viewport (600x900)
- Emits background_loaded signal on success
- Falls back to solid color if asset missing

`load_menu_background()`
- Loads animated menu background from config
- Creates CanvasLayer and AnimatedSprite2D (or shader-based node)
- Configures animation looping and playback speed
- Starts animation playback immediately
- Handles multiple animation implementation types

`cleanup_current_background()`
- Removes current CanvasLayer from scene tree
- Frees background nodes using queue_free()
- Clears cached references
- Called before loading new background

### Configuration Structure

**backgrounds_config.json**
```json
{
  "defaults": {
    "opacity": 1.0,
    "fallback_colors": {
      "level_1": "#8B4513",
      "level_2": "#4682B4",
      "level_3": "#9370DB"
    }
  },
  "backgrounds": {
    "level_1": {
      "path": "res://assets/backgrounds/level_1_bg.png",
      "type": "static",
      "opacity": 0.85
    },
    "level_2": {
      "path": "res://assets/backgrounds/level_2_bg.png",
      "type": "static",
      "opacity": 0.85
    },
    "level_3": {
      "path": "res://assets/backgrounds/level_3_bg.png",
      "type": "static",
      "opacity": 0.85
    },
    "menu": {
      "path": "res://assets/backgrounds/menu_bg",
      "type": "animated",
      "animation_speed": 1.0,
      "loop": true,
      "frame_count": 8
    }
  },
  "generation_prompts": {
    "level_1": "Mystical background with warm fire and earth tones, volcanic landscape with glowing embers, pixel art style, game background",
    "level_2": "Serene background with cool water and air colors, flowing streams and cloudy sky, pixel art style, game background",
    "level_3": "Epic background mixing all four elements, swirling elemental energies, pixel art style, game background",
    "menu": "Animated magical rune circle slowly rotating, mystical energy particles, pixel art style, game background, 8 frames"
  }
}
```

### Background Asset Organization

```
assets/backgrounds/
├── level_1_bg.png          # Fire/Earth themed (600x900)
├── level_2_bg.png          # Water/Air themed (600x900)
├── level_3_bg.png          # Mixed elements (600x900)
└── menu_bg/
    ├── frame_0.png         # Animation frame 0
    ├── frame_1.png         # Animation frame 1
    └── ...                 # Additional frames
```

## Data Models

### BackgroundConfig Class

```gdscript
class_name BackgroundConfig
extends Resource

@export var background_id: String
@export var path: String
@export var type: String  # "static" or "animated"
@export var opacity: float = 1.0
@export var animation_speed: float = 1.0
@export var loop: bool = true
@export var frame_count: int = 1
```

### BackgroundState

Internal state tracking within Background_Manager:

```gdscript
# Current background state
var current_background_id: String = ""
var current_canvas_layer: CanvasLayer = null
var current_sprite_node: Node = null  # Sprite2D or AnimatedSprite2D
var config_data: Dictionary = {}
var is_initialized: bool = false
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property 1: Unique Backgrounds Per Level

*For any* two different level numbers (1, 2, or 3), loading their respective backgrounds should result in different background assets being displayed.

**Validates: Requirements 1.1**

### Property 2: Level-to-Background Mapping

*For any* valid level number (1-3), loading that level's background should result in the background asset corresponding to that specific level number being displayed.

**Validates: Requirements 1.2**

### Property 3: Background Z-Ordering

*For any* background loaded (level or menu), the background's CanvasLayer z-index should be less than the z-index of all gameplay elements and all UI elements.

**Validates: Requirements 1.3, 3.3, 9.1, 9.2**

### Property 4: Viewport Scaling

*For any* background loaded (level or menu), the background should be scaled to completely fill the viewport dimensions (600x900 pixels) while maintaining its aspect ratio.

**Validates: Requirements 1.4, 3.4**

### Property 5: Menu Animation Looping

*For any* menu background animation, the animation loop property should be set to true, ensuring continuous playback.

**Validates: Requirements 3.2**

### Property 6: Configuration Application Round-Trip

*For any* configuration parameter (opacity, animation speed, file path), setting a value in the configuration file and loading the background should result in the background having that configured value applied.

**Validates: Requirements 4.4, 4.5, 10.2, 10.4**

### Property 7: Background Directory Organization

*For any* background asset path defined in the configuration, the path should point to a location within the dedicated backgrounds directory (res://assets/backgrounds/).

**Validates: Requirements 5.1**

### Property 8: Menu and Level Background Separation

*For any* menu background path and any level background path, they should point to different directory locations or file structures.

**Validates: Requirements 5.3**

### Property 9: Animation Frame Naming Sequence

*For any* animated background using frame-based animation, the frame files should follow a numbered sequence pattern (frame_0, frame_1, frame_2, etc.).

**Validates: Requirements 5.5**

### Property 10: Background Cleanup on Transition

*For any* two different backgrounds, loading the second background after the first should result in the first background's nodes being removed from the scene tree and freed from memory.

**Validates: Requirements 6.2, 6.4**

### Property 11: Texture Compression

*For any* background texture loaded, the texture should have compression enabled to minimize memory usage.

**Validates: Requirements 7.3**

## Error Handling

### Missing Asset Handling

**Fallback Colors**
When a background asset fails to load, the Background_Manager displays a solid color fallback:
- Level 1: Warm brown (#8B4513) suggesting fire/earth
- Level 2: Steel blue (#4682B4) suggesting water/air
- Level 3: Medium purple (#9370DB) suggesting mixed elements

**Error Logging**
All asset loading failures are logged with:
- Background ID that failed to load
- Expected file path
- Timestamp of failure
- Fallback action taken

**Graceful Degradation**
The game continues to function normally with fallback backgrounds. Gameplay is never blocked by missing background assets.

### Invalid Configuration Handling

**Missing Configuration Keys**
When required configuration keys are missing:
- Log warning with missing key name
- Use default value from DEFAULTS constant
- Continue loading with defaults

**Invalid Configuration Values**
When configuration values are invalid (negative opacity, invalid paths):
- Log warning with invalid value and reason
- Use default value
- Continue loading with defaults

**Malformed JSON**
When backgrounds_config.json cannot be parsed:
- Log error with parse failure details
- Use hardcoded fallback configuration
- All backgrounds use fallback colors

### Animation Errors

**Missing Animation Frames**
When animated background frames are missing:
- Log warning with missing frame numbers
- Use available frames only
- Continue animation with partial frame set

**Animation Playback Errors**
When AnimatedSprite2D fails to play:
- Log error with animation state
- Fall back to static first frame
- Continue with non-animated background

### Runtime Errors

**Scene Tree Access Errors**
When Background_Manager cannot access scene tree:
- Log error with context
- Defer background loading until tree is ready
- Use _ready() signal to retry

**Memory Allocation Errors**
When texture loading fails due to memory:
- Log critical error
- Free unused backgrounds immediately
- Use solid color fallback

## Testing Strategy

### Dual Testing Approach

This feature requires both unit tests and property-based tests for comprehensive coverage:

**Unit Tests** focus on:
- Specific examples of background loading (Level 1, Level 2, Level 3, Menu)
- Edge cases (missing assets, invalid config, malformed JSON)
- Integration points (GameState signal handling, scene tree injection)
- Error conditions (memory failures, missing frames)

**Property-Based Tests** focus on:
- Universal properties that hold across all backgrounds
- Configuration round-trip validation
- Z-ordering guarantees
- Cleanup behavior across all transitions

### Property-Based Testing Configuration

**Testing Library**: GUT (Godot Unit Test) with custom property test helpers

**Test Configuration**:
- Minimum 100 iterations per property test
- Each property test references its design document property
- Tag format: `# Feature: level-and-menu-backgrounds, Property {number}: {property_text}`

**Property Test Implementation**:
Each correctness property listed above will be implemented as a single property-based test that:
1. Generates random valid inputs (level numbers, config values, etc.)
2. Executes the Background_Manager operation
3. Verifies the property holds for all generated inputs
4. Reports any counterexamples that violate the property

### Unit Test Coverage

**Background Loading Tests**
- `test_load_level_1_background()`: Verify Level 1 background loads correctly
- `test_load_level_2_background()`: Verify Level 2 background loads correctly
- `test_load_level_3_background()`: Verify Level 3 background loads correctly
- `test_load_menu_background()`: Verify menu background loads and animates
- `test_missing_asset_fallback()`: Verify fallback color when asset missing
- `test_invalid_level_number()`: Verify error handling for invalid level numbers

**Configuration Tests**
- `test_load_config_from_file()`: Verify config loads from JSON
- `test_config_missing_keys_use_defaults()`: Verify default values used
- `test_config_invalid_values_logged()`: Verify warnings logged for invalid values
- `test_malformed_json_uses_fallback()`: Verify hardcoded fallback when JSON invalid

**Transition Tests**
- `test_menu_to_level_transition()`: Verify menu background replaced by level background
- `test_level_to_level_transition()`: Verify level backgrounds switch correctly
- `test_level_to_menu_transition()`: Verify menu animation resumes
- `test_background_cleanup_on_transition()`: Verify old nodes freed

**Animation Tests**
- `test_animated_sprite_2d_support()`: Verify AnimatedSprite2D backgrounds work
- `test_animation_loop_configuration()`: Verify loop setting applied
- `test_animation_speed_configuration()`: Verify speed setting applied
- `test_missing_frames_handled()`: Verify partial frame sets work

**Integration Tests**
- `test_game_state_signal_integration()`: Verify GameState.state_changed triggers background changes
- `test_scene_tree_injection()`: Verify CanvasLayer added to active scene
- `test_preload_on_initialization()`: Verify all backgrounds cached at startup

**Replicate MCP Integration Tests**
- `test_generation_prompts_exist()`: Verify config contains generation prompts
- `test_generation_parameters_documented()`: Verify generation params in config
- `test_generated_assets_stored_correctly()`: Verify generated files in correct directories

### Performance Testing

While not part of unit/property tests, performance should be validated:
- Frame rate monitoring with backgrounds active (target: 60 FPS)
- Memory usage profiling with all backgrounds loaded (target: <50MB)
- Animation smoothness verification (target: 30+ FPS for menu animation)

### Test Execution

**Running Tests**:
```bash
# Run all background tests
godot --headless -s tests/run_background_tests.gd

# Run property-based tests only
godot --headless -s tests/run_background_property_tests.gd

# Run unit tests only
godot --headless -s tests/run_background_unit_tests.gd
```

**Continuous Integration**:
All tests should pass before merging background feature changes. Property-based tests with 100+ iterations provide high confidence in correctness.

## Implementation Notes

### Godot-Specific Considerations

**Autoload Registration**
Background_Manager must be registered in project.godot:
```
[autoload]
BackgroundManager="*res://scripts/background_manager.gd"
```

**Resource Loading**
Use `ResourceLoader.exists()` before `load()` to prevent errors:
```gdscript
if ResourceLoader.exists(path):
    var texture = load(path)
```

**Node Lifecycle**
Always use `queue_free()` instead of `free()` for safe node deletion:
```gdscript
if current_canvas_layer:
    current_canvas_layer.queue_free()
    current_canvas_layer = null
```

**Signal Connections**
Connect to GameState signals in `_ready()`:
```gdscript
func _ready():
    load_config()
    if GameState:
        GameState.state_changed.connect(_on_game_state_changed)
```

### Performance Optimization

**Texture Compression**
Import settings for background PNGs:
- Compress: VRAM Compressed
- Mipmaps: Enabled
- Filter: Linear

**Preloading Strategy**
Load all backgrounds during initialization to prevent runtime hitches:
```gdscript
func _ready():
    _preload_all_backgrounds()
```

**Memory Management**
Only keep current background in scene tree. Previous backgrounds are freed immediately on transition.

### Asset Generation Workflow

**Using Replicate MCP**:
1. Read generation prompts from backgrounds_config.json
2. Use existing sprite_generator.py pattern for background generation
3. Generate at 600x900 resolution for viewport match
4. Store in assets/backgrounds/ directory
5. Update config with actual file paths

**Animation Frame Generation**:
For menu background animation:
1. Generate 8 frames with consistent style
2. Name frames: frame_0.png through frame_7.png
3. Store in assets/backgrounds/menu_bg/ directory
4. Configure frame_count in config

### Future Enhancements

**Potential Additions** (not in current scope):
- Parallax scrolling backgrounds with multiple layers
- Shader-based procedural backgrounds
- Background transitions with fade effects
- Dynamic backgrounds that react to gameplay events
- Background music synchronization with menu animation

These enhancements can be added later without modifying the core Background_Manager architecture.
