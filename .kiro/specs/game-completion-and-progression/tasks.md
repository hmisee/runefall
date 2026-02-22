# Implementation Plan: Game Completion and Progression

## Overview

This implementation adds win/loss detection, UI enhancements (preview, menus), element-only gravity, pause functionality, and a 3-level progression system with persistence to Runefall. The implementation follows Godot's scene-based architecture with signal-driven communication between components.

## Tasks

- [x] 1. Create core state management and save system
  - [x] 1.1 Implement SaveManager component
    - Create `scripts/save_manager.gd` with save/load functions
    - Implement JSON-based persistence to `user://runefall_save.json`
    - Add error handling for missing/corrupted save files
    - _Requirements: 9.1, 9.2, 9.3_
  
  - [ ]* 1.2 Write property test for save/load round-trip
    - **Property 17: Save and load preserves unlock state**
    - **Validates: Requirements 9.1, 9.2**
    - Create `tests/test_persistence_pbt.gd`
    - Generate random max_unlocked values, verify save/load preserves them
  
  - [x] 1.3 Implement GameState component
    - Create `scripts/game_state.gd` with state machine (MENU, PLAYING, PAUSED, WIN, LOSS, TRANSITION)
    - Add level tracking (current_level, max_unlocked_level)
    - Implement state transition methods with validation
    - Add signals for state changes and level events
    - _Requirements: 1.1, 2.1, 6.4, 7.5_
  
  - [ ]* 1.4 Write unit tests for GameState
    - Create `tests/test_game_state.gd`
    - Test invalid state transitions (e.g., pause from menu)
    - Test level unlock progression
    - Test default state (level 1 unlocked when no save)
    - _Requirements: 1.1, 2.1, 6.4_

- [x] 2. Extend GameBoard with win/loss detection
  - [x] 2.1 Add win/loss signals and game control to GameBoard
    - Add signals: `win_condition_met()`, `loss_condition_met()`, `elements_remaining_changed(count)`
    - Add properties: `initial_element_count`, `game_active`
    - Implement `stop_game()` method to halt spawning
    - _Requirements: 1.2, 2.2_
  
  - [x] 2.2 Implement win condition checking
    - Add `get_element_count()` method to count remaining elements
    - Add `check_win_condition()` method (emit signal if count == 0)
    - Call win check after match clearing in existing match logic
    - _Requirements: 1.1, 1.4_
  
  - [ ]* 2.3 Write property test for win state transition
    - **Property 1: Win state transition on element clear**
    - **Validates: Requirements 1.1**
    - Create `tests/test_win_condition_pbt.gd`
    - Generate random board states, clear all elements, verify WIN state
  
  - [x] 2.4 Implement loss condition checking
    - Add `check_spawn_availability()` method to verify spawn position is empty
    - Modify spawn logic to check availability before creating pair
    - Emit `loss_condition_met()` signal when spawn blocked
    - _Requirements: 2.1, 2.4_
  
  - [ ]* 2.5 Write property test for loss on blocked spawn
    - **Property 4: Loss state transition on blocked spawn**
    - **Validates: Requirements 2.1**
    - Create `tests/test_loss_condition_pbt.gd`
    - Generate random board states with blocked spawn, verify LOSS state
  
  - [ ]* 2.6 Write property test for spawn control
    - **Property 2: Game end stops spawning**
    - **Validates: Requirements 1.2, 2.2**
    - Create `tests/test_spawn_control_pbt.gd`
    - Generate random end states, verify spawn attempts rejected

- [x] 3. Implement element-only gravity behavior
  - [x] 3.1 Modify gravity system to skip elements
    - Update existing gravity logic in `scripts/game_board.gd`
    - Add type checking to only move runes (skip elements)
    - Ensure elements stay in place when above empty space
    - _Requirements: 4.1, 4.2, 4.4_
  
  - [ ]* 3.2 Write property test for gravity behavior
    - **Property 9: Gravity affects only runes**
    - **Validates: Requirements 4.1, 4.2, 4.4**
    - Create `tests/test_gravity_behavior_pbt.gd`
    - Generate random boards with runes and elements, verify only runes move
  
  - [ ]* 3.3 Write property test for rune fall distance
    - **Property 10: Runes fall one cell per gravity step**
    - **Validates: Requirements 4.3**
    - Create `tests/test_rune_fall_pbt.gd`
    - Generate random rune positions, verify single-cell movement per step

- [ ] 4. Checkpoint - Verify core game logic
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implement next rune preview system
  - [x] 5.1 Add preview data generation to GameBoard
    - Add `next_rune_pair_data` property (Dictionary with rune1_type, rune2_type, rotation)
    - Implement `generate_next_pair_data()` method
    - Update preview data when spawning new pairs
    - _Requirements: 3.1, 3.2, 3.3_
  
  - [ ]* 5.2 Write property tests for preview system
    - **Property 6: Preview shows next pair**
    - **Property 7: Preview updates on pair activation**
    - **Property 8: Preview contains complete data**
    - **Validates: Requirements 3.1, 3.2, 3.3**
    - Create `tests/test_preview_pbt.gd`
    - Generate random rune sequences, verify preview accuracy and updates
  
  - [x] 5.3 Create GameUI component for preview display
    - Create `scenes/game_ui.tscn` with CanvasLayer
    - Add Label for messages, Control for preview, Labels for level/elements count
    - Create `scripts/game_ui.gd` with update methods
    - Implement `update_preview()` to display rune types and rotation visually
    - Position preview outside board area (x > 800)
    - _Requirements: 3.3, 3.4_
  
  - [ ]* 5.4 Write unit tests for preview UI
    - Create `tests/test_preview.gd`
    - Test preview positioned outside board bounds
    - Test preview updates when pair locks
    - _Requirements: 3.4_

- [x] 6. Implement level system and configuration
  - [x] 6.1 Add level configuration to GameBoard
    - Define LEVEL_CONFIG constant with 3 levels (10, 15, 20 elements)
    - Add level names: "Calm Beginnings", "Rising Chaos", "Elemental Storm"
    - _Requirements: 6.1, 6.2, 6.3_
  
  - [x] 6.2 Implement level initialization
    - Add `initialize_level(element_count)` method to GameBoard
    - Clear board and spawn specified number of elements
    - Ensure spawn position is clear after initialization
    - _Requirements: 6.2_
  
  - [ ]* 6.3 Write property tests for level system
    - **Property 12: Level element count increases with level number**
    - **Property 13: Level initialization spawns correct element count**
    - **Property 14: Winning unlocks next level**
    - **Validates: Requirements 6.2, 6.3, 6.4**
    - Create `tests/test_levels_pbt.gd`
    - Verify difficulty progression and initialization correctness
  
  - [ ]* 6.4 Write unit tests for level configuration
    - Create `tests/test_levels.gd`
    - Test three levels are configured
    - Test level names are present
    - _Requirements: 6.1_

- [x] 7. Create main menu with level selection
  - [x] 7.1 Create MainMenu scene and script
    - Create `scenes/main_menu.tscn` with CanvasLayer
    - Add VBoxContainer for level buttons
    - Create `scripts/main_menu.gd` with level button generation
    - Implement `initialize(max_unlocked)` to create buttons
    - Implement `update_unlock_state()` to enable/disable buttons
    - Add signals: `level_selected(level_number)`, `quit_requested()`
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [ ]* 7.2 Write property test for level selection
    - **Property 15: Locked levels are visually distinct**
    - **Property 16: Level selection starts correct level**
    - **Validates: Requirements 7.3, 7.4**
    - Create `tests/test_level_selection_pbt.gd`
    - Generate random unlock states, verify UI and level start behavior
  
  - [ ]* 7.3 Write unit tests for main menu
    - Create `tests/test_main_menu.gd`
    - Test game starts showing main menu
    - Test main menu displays level buttons
    - _Requirements: 7.1, 7.2_

- [x] 8. Implement pause menu
  - [x] 8.1 Create PauseMenu scene and script
    - Create `scenes/pause_menu.tscn` with CanvasLayer
    - Add "Continue" and "Main Menu" buttons
    - Create `scripts/pause_menu.gd` with show/hide methods
    - Add signals: `resume_requested()`, `main_menu_requested()`
    - _Requirements: 5.3_
  
  - [x] 8.2 Add pause functionality to GameState
    - Implement `pause_game()` and `resume_game()` methods
    - Add Escape key handling in Main scene
    - Connect pause state to GameBoard to freeze logic
    - _Requirements: 5.1, 5.2, 5.4, 5.5_
  
  - [ ]* 8.3 Write property test for pause freeze
    - **Property 11: Pause freezes game logic**
    - **Validates: Requirements 5.2**
    - Create `tests/test_pause_freeze_pbt.gd`
    - Generate random game states, verify pause freezes timers and movement
  
  - [ ]* 8.4 Write unit tests for pause menu
    - Create `tests/test_pause.gd`
    - Test Escape key shows pause menu
    - Test Continue button resumes game
    - Test Main Menu button returns to menu
    - _Requirements: 5.1, 5.3, 5.4, 5.5_

- [ ] 9. Checkpoint - Verify UI and menus
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Implement win/loss messages and auto-progression
  - [x] 10.1 Add message display to GameUI
    - Implement `show_message(text, duration)` method
    - Add Timer for auto-hiding messages
    - Style message label for visibility
    - _Requirements: 1.3, 2.3_
  
  - [x] 10.2 Connect win/loss signals to UI
    - Connect GameBoard signals to GameState
    - Connect GameState signals to GameUI
    - Display appropriate messages on win/loss
    - _Requirements: 1.3, 2.3, 6.5_
  
  - [x] 10.3 Implement auto-progression after win
    - Add 3-second timer after win message
    - Automatically start next level for non-final levels
    - Show final congratulations for final level with menu option
    - _Requirements: 8.1, 8.2, 8.3, 8.4_
  
  - [ ]* 10.4 Write property test for auto-progression
    - **Property 18: Auto-progression after non-final level win**
    - **Validates: Requirements 8.2**
    - Create `tests/test_auto_progression_pbt.gd`
    - Generate random non-final levels, verify next level starts after timer
  
  - [ ]* 10.5 Write unit tests for win/loss messages
    - Create `tests/test_messages.gd`
    - Test win message displays for 3 seconds
    - Test final level shows congratulations
    - Test loss message displays correctly
    - _Requirements: 1.3, 2.3, 8.1, 8.3_

- [x] 11. Wire all components together in Main scene
  - [x] 11.1 Update Main scene structure
    - Add GameState, SaveManager, GameUI, MainMenu, PauseMenu nodes to `scenes/main.tscn`
    - Ensure proper node hierarchy and initialization order
    - _Requirements: All_
  
  - [x] 11.2 Connect all signals between components
    - Connect GameBoard → GameState (win/loss signals)
    - Connect GameState → GameUI (state changes, level info)
    - Connect GameState → MainMenu (unlock state)
    - Connect MainMenu → GameState (level selection)
    - Connect PauseMenu → GameState (pause/resume)
    - Connect GameState → SaveManager (level completion)
    - _Requirements: All_
  
  - [ ]* 11.3 Write property test for save trigger
    - **Property 19: Save triggered on level completion**
    - **Validates: Requirements 9.4**
    - Create `tests/test_save_trigger_pbt.gd`
    - Generate random level completions, verify save manager called
  
  - [x] 11.4 Implement game initialization flow
    - Load save data on game start
    - Initialize main menu with unlock state
    - Show main menu as initial state
    - _Requirements: 7.1, 7.5, 9.2_

- [ ] 12. Final checkpoint - Complete integration testing
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional property-based and unit tests that can be skipped for faster MVP
- Each task references specific requirements for traceability
- The implementation builds incrementally: core logic → UI → integration
- Checkpoints ensure validation at key milestones
- Property tests validate universal correctness properties across randomized inputs
- Unit tests validate specific examples, edge cases, and UI interactions
- All code uses GDScript for Godot 4.3
- Existing GameBoard code will be extended, not replaced
- Signal-driven architecture ensures loose coupling between components
