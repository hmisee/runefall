# Implementation Plan: Sprite Graphics Integration

## Overview

This implementation replaces ColorRect-based rendering with Sprite2D nodes for runes and elements. The approach follows a layered strategy: first establish the asset management foundation (SpriteManager singleton), then modify the visual representation layer (Rune and Element classes), and finally integrate everything with proper fallback handling. Each step validates functionality through code before moving forward.

## Tasks

- [x] 1. Create sprite asset directory structure and credits file
  - Create `assets/sprites/` directory with subdirectories for fire, water, earth, and air
  - Create `assets/sprites/CREDITS.md` file with attribution template
  - _Requirements: 1.1, 7.1, 7.4_

- [x] 2. Implement SpriteManager singleton
  - [x] 2.1 Create SpriteManager autoload script
    - Create `sprite_manager.gd` with basic singleton structure
    - Define sprite_cache dictionary and missing_sprites array
    - Implement sprite path generation logic
    - _Requirements: 1.2, 1.4_
  
  - [x] 2.2 Implement sprite loading and caching logic
    - Write `_ready()` method to load all sprite assets
    - Implement `get_sprite()` method for sprite lookup
    - Implement `has_sprite()` method for availability checking
    - Add error handling for missing files
    - _Requirements: 1.4, 1.5, 8.1, 8.2_
  
  - [x] 2.3 Write property test for sprite cache completeness
    - **Property 1: Sprite Cache Completeness**
    - **Validates: Requirements 1.2**
  
  - [x] 2.4 Register SpriteManager as autoload in project settings
    - Add SpriteManager to autoload configuration
    - Verify singleton is accessible from other scripts
    - _Requirements: 1.4_

- [x] 3. Checkpoint - Verify SpriteManager initialization
  - Ensure SpriteManager loads without errors, ask the user if questions arise.

- [x] 4. Implement sprite scaling utility
  - [x] 4.1 Create sprite scaling helper function
    - Write `_scale_sprite_to_cell()` function in SpriteManager or as utility
    - Calculate scale factor based on CELL_SIZE and texture dimensions
    - Apply uniform scaling to maintain aspect ratio
    - _Requirements: 2.3, 3.3, 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 4.2 Write property test for sprite scaling and positioning
    - **Property 4: Sprite Scaling and Positioning**
    - **Validates: Requirements 2.3, 3.3, 6.1, 6.2, 6.3, 6.4, 6.5**

- [x] 5. Modify Rune class to use Sprite2D nodes
  - [x] 5.1 Add sprite node variable and visual creation method
    - Add `sprite_node: Node2D` variable to Rune class
    - Create `_create_visual_representation()` method
    - Request sprite from SpriteManager in `_ready()`
    - _Requirements: 2.1, 2.2_
  
  - [x] 5.2 Implement sprite rendering path
    - Create Sprite2D node when sprite is available
    - Apply sprite texture from SpriteManager
    - Scale and center sprite using scaling utility
    - Add sprite node to scene tree
    - _Requirements: 2.1, 2.2, 2.3_
  
  - [x] 5.3 Implement fallback rendering path
    - Detect when sprite is unavailable
    - Create fallback visual using existing _draw() approach or ColorRect
    - Use appropriate color from colors dictionary
    - _Requirements: 1.5, 8.1, 8.4_
  
  - [x] 5.4 Update set_rune_type() to handle sprite changes
    - Modify `set_rune_type()` to update sprite texture when type changes
    - Handle fallback mode in type changes
    - _Requirements: 2.1_
  
  - [x] 5.5 Write property test for type-sprite correspondence
    - **Property 2: Type-Sprite Correspondence**
    - **Validates: Requirements 2.1, 3.1**
  
  - [x] 5.6 Write property test for sprite node usage
    - **Property 3: Sprite Node Usage**
    - **Validates: Requirements 2.2, 3.2**
  
  - [x] 5.7 Write property test for sprite orientation preservation
    - **Property 5: Sprite Orientation Preservation**
    - **Validates: Requirements 5.1**

- [x] 6. Modify Element class to use Sprite2D nodes
  - [x] 6.1 Add sprite node variable and visual creation method
    - Add `sprite_node: Node2D` variable to Element class
    - Create `_create_visual_representation()` method
    - Request sprite from SpriteManager in `_ready()`
    - _Requirements: 3.1, 3.2_
  
  - [x] 6.2 Implement sprite rendering path
    - Create Sprite2D node when sprite is available
    - Apply sprite texture from SpriteManager
    - Scale and center sprite using scaling utility
    - Add sprite node to scene tree
    - _Requirements: 3.1, 3.2, 3.3_
  
  - [x] 6.3 Implement fallback rendering path
    - Detect when sprite is unavailable
    - Create fallback visual using existing _draw() approach or ColorRect
    - Use appropriate color from colors dictionary
    - _Requirements: 1.5, 8.1, 8.4_
  
  - [x] 6.4 Update set_element_type() to handle sprite changes
    - Modify `set_element_type()` to update sprite texture when type changes
    - Handle fallback mode in type changes
    - _Requirements: 3.1_

- [x] 7. Checkpoint - Verify sprite rendering for both Rune and Element
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Implement sprite position synchronization
  - [x] 8.1 Ensure sprite position updates with game object position
    - Verify sprite nodes inherit position from parent Node2D
    - Test position updates during falling and movement
    - _Requirements: 5.2_
  
  - [x] 8.2 Write property test for sprite position synchronization
    - **Property 6: Sprite Position Synchronization**
    - **Validates: Requirements 5.2**

- [x] 9. Implement sprite lifecycle management
  - [x] 9.1 Verify sprite removal with game object removal
    - Test that sprite nodes are removed when parent is queue_free()'d
    - Verify no orphaned sprites remain in scene tree
    - _Requirements: 5.3_
  
  - [x] 9.2 Write property test for sprite lifecycle coupling
    - **Property 7: Sprite Lifecycle Coupling**
    - **Validates: Requirements 5.3**

- [x] 10. Validate game logic independence
  - [x] 10.1 Test collision detection with sprites
    - Run existing collision tests with sprite rendering enabled
    - Verify collision behavior is unchanged
    - _Requirements: 5.4_
  
  - [x] 10.2 Test grid positioning with sprites
    - Run existing grid placement tests with sprite rendering enabled
    - Verify grid logic is unchanged
    - _Requirements: 5.5_
  
  - [x] 10.3 Test match-4 detection with sprites
    - Run existing match detection tests with sprite rendering enabled
    - Verify match logic is unchanged
    - _Requirements: 5.3_
  
  - [x] 10.4 Write property test for game logic independence
    - **Property 8: Game Logic Independence**
    - **Validates: Requirements 5.4, 5.5**

- [x] 11. Implement and test fallback system
  - [x] 11.1 Test fallback activation with missing sprites
    - Temporarily remove sprite files
    - Verify fallback rendering activates
    - Verify game remains playable
    - _Requirements: 8.1, 8.3_
  
  - [x] 11.2 Write property test for fallback activation
    - **Property 9: Fallback Activation**
    - **Validates: Requirements 1.5, 8.1**
  
  - [x] 11.3 Write property test for missing sprite logging
    - **Property 10: Missing Sprite Logging**
    - **Validates: Requirements 8.2**
  
  - [x] 11.4 Write property test for fallback color consistency
    - **Property 11: Fallback Color Consistency**
    - **Validates: Requirements 8.4**

- [x] 12. Final integration and validation
  - [x] 12.1 Remove old _draw() methods from Rune and Element
    - Clean up deprecated drawing code
    - Ensure fallback uses ColorRect or simplified approach
    - _Requirements: 2.2, 3.2_
  
  - [x] 12.2 Add debug logging for sprite loading status
    - Log successful sprite loads
    - Log missing sprites with file paths
    - Add `get_missing_sprites()` method to SpriteManager
    - _Requirements: 8.2_
  
  - [x] 12.3 Verify color consistency across all element types
    - Test that Fire uses red/orange for both rune and element
    - Test that Water uses blue/cyan for both rune and element
    - Test that Earth uses brown/green for both rune and element
    - Test that Air uses white/light gray for both rune and element
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 13. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties across randomized inputs
- Unit tests validate specific examples and edge cases
- The implementation maintains backward compatibility through the fallback system
- All sprite loading errors are handled gracefully without crashing the game
