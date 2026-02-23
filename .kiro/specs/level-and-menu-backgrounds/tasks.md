# Implementation Plan: Level and Menu Backgrounds

## Overview

This implementation plan breaks down the Background_Manager system into discrete coding tasks. The system provides static backgrounds for three game levels and an animated background for the main menu, all managed through a centralized autoload singleton. Implementation follows Godot 4.3 best practices and integrates with the existing GameState system.

## Tasks

- [x] 1. Set up background asset structure and configuration
  - Create assets/backgrounds/ directory structure
  - Create backgrounds_config.json with all configuration data
  - Add placeholder background images (temporary colored rectangles)
  - Register Background_Manager in project.godot autoload
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 10.1, 10.4_

- [ ] 2. Implement Background_Manager core functionality
  - [x] 2.1 Create Background_Manager autoload singleton script
    - Implement configuration loading from backgrounds_config.json
    - Add error handling for missing or malformed configuration
    - Implement fallback color constants for each level
    - _Requirements: 1.1, 1.5, 10.1, 10.4, 10.5_

  - [ ]* 2.2 Write property test for configuration round-trip
    - **Property 6: Configuration Application Round-Trip**
    - **Validates: Requirements 4.4, 4.5, 10.2, 10.4**

  - [x] 2.3 Implement static background loading for levels
    - Create load_level_background(level_number: int) method
    - Implement CanvasLayer creation with z-index -100
    - Add Sprite2D node creation and texture loading
    - Implement viewport scaling (600x900) with aspect ratio preservation
    - Add ResourceLoader.exists() checks before loading
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 9.1, 9.2_

  - [ ]* 2.4 Write property tests for level background loading
    - **Property 1: Unique Backgrounds Per Level**
    - **Property 2: Level-to-Background Mapping**
    - **Property 4: Viewport Scaling**
    - **Validates: Requirements 1.1, 1.2, 1.4, 3.4**

- [ ] 3. Implement menu animated background system
  - [x] 3.1 Create menu background loading functionality
    - Implement load_menu_background() method
    - Add support for AnimatedSprite2D frame-based animation
    - Configure animation looping and playback speed from config
    - Implement viewport scaling for animated backgrounds
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.4_

  - [ ]* 3.2 Write property tests for menu animation
    - **Property 5: Menu Animation Looping**
    - **Property 9: Animation Frame Naming Sequence**
    - **Validates: Requirements 3.2, 5.5**

  - [x] 3.3 Add shader-based animation support (optional implementation)
    - Add shader material loading for procedural animations
    - Configure shader parameters from config
    - _Requirements: 4.2, 4.5_

- [ ] 4. Implement background cleanup and transitions
  - [x] 4.1 Create background cleanup functionality
    - Implement cleanup_current_background() method
    - Use queue_free() for safe node deletion
    - Clear cached references to freed nodes
    - _Requirements: 6.4_

  - [ ]* 4.2 Write property test for cleanup behavior
    - **Property 10: Background Cleanup on Transition**
    - **Validates: Requirements 6.2, 6.4**

  - [x] 4.3 Implement background transition logic
    - Add transition handling for menu-to-level switches
    - Add transition handling for level-to-level switches
    - Add transition handling for level-to-menu switches
    - Ensure cleanup happens before new background loads
    - _Requirements: 6.1, 6.2, 6.3_

  - [ ]* 4.4 Write unit tests for transition scenarios
    - Test menu-to-level transition
    - Test level-to-level transition
    - Test level-to-menu transition with animation resume
    - _Requirements: 6.1, 6.2, 6.3_

- [ ] 5. Integrate with GameState system
  - [x] 5.1 Connect to GameState signals
    - Connect to GameState.state_changed signal in _ready()
    - Implement _on_game_state_changed() callback
    - Add logic to determine which background to load based on state
    - Handle edge cases (GameState not available, invalid states)
    - _Requirements: 6.1, 6.2, 6.3_

  - [ ]* 5.2 Write integration tests for GameState signals
    - Test state_changed signal triggers correct background
    - Test invalid state handling
    - Test signal connection on initialization
    - _Requirements: 6.1, 6.2, 6.3_

- [ ] 6. Implement background preloading and performance optimization
  - [x] 6.1 Add background preloading on initialization
    - Implement _preload_all_backgrounds() method
    - Cache all background textures during _ready()
    - Add memory usage tracking and logging
    - _Requirements: 6.5, 7.4_

  - [x] 6.2 Configure texture compression for backgrounds
    - Set import settings for all background PNGs
    - Enable VRAM compression
    - Enable mipmaps and linear filtering
    - _Requirements: 7.3_

  - [ ]* 6.3 Write property test for texture compression
    - **Property 11: Texture Compression**
    - **Validates: Requirements 7.3**

- [ ] 7. Implement z-ordering and visibility features
  - [x] 7.1 Add z-ordering guarantees
    - Ensure CanvasLayer z-index is -100 for all backgrounds
    - Add validation that backgrounds render behind game elements
    - _Requirements: 1.3, 3.3, 9.1, 9.2_

  - [ ]* 7.2 Write property test for z-ordering
    - **Property 3: Background Z-Ordering**
    - **Validates: Requirements 1.3, 3.3, 9.1, 9.2**

  - [x] 7.3 Add opacity and contrast controls
    - Implement set_background_opacity(opacity: float) method
    - Apply opacity from configuration
    - Add optional darkening/blur for bright backgrounds
    - _Requirements: 2.4, 2.5, 9.4, 9.5, 10.2_

  - [ ]* 7.4 Write unit tests for opacity controls
    - Test opacity setting from config
    - Test set_background_opacity() method
    - Test opacity bounds (0.0 to 1.0)
    - _Requirements: 10.2_

- [ ] 8. Implement error handling and fallback behavior
  - [x] 8.1 Add missing asset fallback system
    - Implement show_fallback_background(color: Color) method
    - Add has_background_asset(background_id: String) check
    - Create fallback ColorRect nodes when assets missing
    - Emit background_load_failed signal
    - _Requirements: 1.5, 10.5_

  - [x] 8.2 Add configuration error handling
    - Handle missing configuration keys with defaults
    - Handle invalid configuration values with warnings
    - Handle malformed JSON with hardcoded fallback config
    - Log all errors with context
    - _Requirements: 10.4, 10.5_

  - [ ]* 8.3 Write unit tests for error handling
    - Test missing asset fallback colors
    - Test missing config keys use defaults
    - Test invalid config values logged
    - Test malformed JSON uses fallback
    - _Requirements: 1.5, 10.4, 10.5_

- [ ] 9. Add background signals and API
  - [x] 9.1 Implement background event signals
    - Add background_loaded(background_id: String) signal
    - Add background_load_failed(background_id: String) signal
    - Emit signals at appropriate points in loading process
    - _Requirements: 1.1, 3.1_

  - [x] 9.2 Add utility API methods
    - Implement get_background_path(background_id: String) method
    - Add current background state queries
    - Add configuration access methods
    - _Requirements: 10.1_

  - [ ]* 9.3 Write unit tests for signals and API
    - Test background_loaded signal emission
    - Test background_load_failed signal emission
    - Test get_background_path() method
    - _Requirements: 1.1, 3.1, 10.1_

- [x] 10. Checkpoint - Ensure all tests pass
  - ✓ All 17 tests passing
  - ✓ Compressed texture issue fixed
  - ✓ Memory usage: 18.17 MB / 50 MB (36% of target)

- [ ] 11. Implement Replicate MCP integration for background generation
  - [x] 11.1 Create background generation script
    - Extend sprite_generator.py pattern for backgrounds
    - Read generation prompts from backgrounds_config.json
    - Generate backgrounds at 600x900 resolution
    - Store generated files in assets/backgrounds/ directory
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

  - [x] 11.2 Document generation parameters
    - Add generation metadata to backgrounds_config.json
    - Document Replicate model and parameters used
    - Add comments explaining generation workflow
    - _Requirements: 8.3, 8.5_

  - [ ]* 11.3 Write tests for Replicate integration
    - Test generation prompts exist in config
    - Test generation parameters documented
    - Test generated assets stored correctly
    - _Requirements: 8.1, 8.2, 8.4_

- [ ] 12. Implement background theming for levels
  - [x] 12.1 Configure level background themes
    - Set Level 1 to warm fire/earth colors
    - Set Level 2 to cool water/air colors
    - Set Level 3 to mixed elemental colors
    - Adjust opacity for gameplay visibility
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [ ]* 12.2 Write unit tests for theming
    - Test Level 1 uses warm color palette
    - Test Level 2 uses cool color palette
    - Test Level 3 uses mixed color palette
    - Test contrast ratios meet minimum requirements
    - _Requirements: 2.1, 2.2, 2.3, 2.5, 9.5_

- [ ] 13. Implement animation frame support
  - [x] 13.1 Add frame-based animation loading
    - Load multiple frame files for AnimatedSprite2D
    - Create SpriteFrames resource dynamically
    - Configure frame timing and loop settings
    - Handle missing frames gracefully
    - _Requirements: 4.1, 4.4, 5.5_

  - [ ]* 13.2 Write property test for frame organization
    - **Property 7: Background Directory Organization**
    - **Property 8: Menu and Level Background Separation**
    - **Validates: Requirements 5.1, 5.3**

  - [ ]* 13.3 Write unit tests for animation frames
    - Test AnimatedSprite2D support
    - Test animation loop configuration
    - Test animation speed configuration
    - Test missing frames handled
    - _Requirements: 4.1, 4.4_

- [ ] 14. Final integration and polish
  - [x] 14.1 Wire all components together
    - Verify Background_Manager autoload registration
    - Test complete flow: menu → level 1 → level 2 → level 3 → menu
    - Verify all backgrounds load correctly
    - Verify all transitions work smoothly
    - _Requirements: 1.1, 1.2, 3.1, 6.1, 6.2, 6.3_

  - [x] 14.2 Add performance validation
    - Verify 60 FPS maintained during gameplay with backgrounds
    - Verify menu animation runs at 30+ FPS
    - Verify memory usage stays under 50MB
    - Log performance metrics
    - _Requirements: 7.1, 7.2, 7.4, 7.5_

  - [ ]* 14.3 Write integration tests for complete system
    - Test complete menu-to-level-to-menu flow
    - Test scene tree injection
    - Test preload on initialization
    - _Requirements: 6.1, 6.2, 6.3, 6.5_

- [x] 15. Final checkpoint - Ensure all tests pass
  - ✓ All 17 tests passing
  - ✓ All core functionality implemented
  - ✓ Performance validated
  - ✓ Integration verified

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- Background_Manager follows the autoload singleton pattern established in Godot
- All backgrounds use CanvasLayer with z-index -100 for proper rendering order
- Replicate MCP integration follows the pattern from sprite-graphics-integration feature
- Performance targets: 60 FPS gameplay, 30+ FPS menu animation, <50MB memory
