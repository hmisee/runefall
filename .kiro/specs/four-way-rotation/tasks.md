# Implementation Plan: Four-Way Rotation System

## Overview

This implementation replaces the boolean `is_horizontal` property with an integer `rotation_state` (0-3) to enable proper 4-way rotation for rune pairs. The changes affect two main files: `scripts/rune_pair.gd` and `scripts/game_board.gd`. All dependent systems (collision detection, wall kicks, piece locking) will be updated to work with the new rotation model.

## Tasks

- [x] 1. Update RunePair class to use rotation_state
  - [x] 1.1 Replace is_horizontal with rotation_state property
    - Remove `var is_horizontal: bool = true`
    - Add `var rotation_state: int = 0`
    - _Requirements: 1.1_
  
  - [x] 1.2 Update rotate_pair() method to cycle through 4 states
    - Change from boolean toggle to modulo arithmetic: `rotation_state = (rotation_state + 1) % 4`
    - _Requirements: 2.1, 2.2_
  
  - [x] 1.3 Update update_positions() to handle all 4 rotation states
    - Replace if/else with match statement for states 0, 1, 2, 3
    - State 0: rune1 at (25, 25), rune2 at (75, 25)
    - State 1: rune1 at (25, 25), rune2 at (25, 75)
    - State 2: rune1 at (75, 25), rune2 at (25, 25)
    - State 3: rune1 at (25, 75), rune2 at (25, 25)
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 2.3_
  
  - [ ]* 1.4 Write property test for rotation state cycling
    - **Property 1: Rotation State Cycling**
    - **Validates: Requirements 2.1, 2.2**
    - Test that rotation cycles through 0→1→2→3→0 for 100 random starting states
  
  - [ ]* 1.5 Write property test for position mapping correctness
    - **Property 2: Position Mapping Correctness**
    - **Validates: Requirements 1.2, 1.3, 1.4, 1.5, 2.3**
    - Test that visual positions match expected layout for all rotation states

- [x] 2. Update GameBoard collision detection system
  - [x] 2.1 Update get_pair_positions() to use rotation_state
    - Change parameter from `orientation: bool` to `rotation: int`
    - Replace if/else with match statement for states 0, 1, 2, 3
    - Return positions in order [rune1_position, rune2_position]
    - _Requirements: 3.4, 5.3_
  
  - [x] 2.2 Update can_place_pair() signature to use rotation_state
    - Change parameter from `orientation: bool` to `rotation: int`
    - Update default parameter to use `current_pair.rotation_state`
    - Pass rotation parameter to get_pair_positions()
    - _Requirements: 3.1, 3.4_
  
  - [ ]* 2.3 Write property test for collision detection
    - **Property 3: Collision Detection for All Rotations**
    - **Validates: Requirements 3.1, 3.4**
    - Test collision detection works correctly for all rotation states with random board configurations

- [x] 3. Update GameBoard rotation and wall kick logic
  - [x] 3.1 Update rotate_current_pair() to calculate target rotation state
    - Calculate `target_rotation = (current_pair.rotation_state + 1) % 4`
    - Update all can_place_pair() calls to pass target_rotation
    - Maintain wall kick sequence: try current, try left, try right
    - _Requirements: 3.2, 4.1, 4.2, 4.3, 4.4_
  
  - [ ]* 3.2 Write property test for wall kick sequence
    - **Property 4: Wall Kick Sequence**
    - **Validates: Requirements 3.2, 4.1, 4.2, 4.3, 4.4**
    - Test wall kicks try positions in correct order with random board configurations
  
  - [ ]* 3.3 Write property test for rotation blocking
    - **Property 5: Rotation Blocking Preserves State**
    - **Validates: Requirements 3.3**
    - Test that blocked rotations preserve current state and position

- [x] 4. Update GameBoard horizontal movement bounds
  - [x] 4.1 Update move_pair_horizontal() to check rotation_state
    - Replace `if current_pair.is_horizontal` with `if current_pair.rotation_state == 0 or current_pair.rotation_state == 2`
    - Adjust max_x bounds for horizontal orientations (states 0 and 2)
    - _Requirements: 6.1, 6.4_

- [x] 5. Verify piece locking correctness
  - [x] 5.1 Verify lock_pair() works with new rotation system
    - Confirm get_pair_positions() returns correct order for all states
    - Verify rune1 placed at positions[0], rune2 at positions[1]
    - Test that locked pieces appear at correct grid coordinates
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [ ]* 5.2 Write property test for locking position correctness
    - **Property 6: Locking Position Correctness**
    - **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**
    - Test that locked runes are placed at correct grid coordinates for all rotation states

- [ ] 6. Checkpoint - Ensure all tests pass
  - Run all property-based tests and unit tests
  - Verify rotation cycles through all 4 states correctly
  - Verify collision detection works for all orientations
  - Verify wall kicks function properly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 7. Integration testing with existing systems
  - [ ] 7.1 Test gravity system with four-way rotation
    - Spawn pairs in various rotation states
    - Lock them and verify gravity pulls pieces down correctly
    - Verify no pieces get stuck or misplaced
    - _Requirements: 6.3_
  
  - [ ] 7.2 Test match detection with four-way rotation
    - Create matches using pieces locked in different rotation states
    - Verify horizontal and vertical matches are detected
    - Verify matched pieces are removed correctly
    - _Requirements: 6.3_
  
  - [ ]* 7.3 Write property test for system preservation
    - **Property 7: Gravity and Match Detection Preservation**
    - **Validates: Requirements 6.3**
    - Test that gravity and match detection work identically before and after four-way rotation

- [ ] 8. Final checkpoint - Complete verification
  - Ensure all tests pass, ask the user if questions arise.
  - Verify all 6 requirements are satisfied
  - Confirm backward compatibility with existing game systems

## Notes

- Tasks marked with `*` are optional property-based tests and can be skipped for faster MVP
- Each task references specific requirements for traceability
- The implementation follows a bottom-up approach: RunePair first, then GameBoard
- Property tests should use at least 100 iterations for comprehensive coverage
- All property tests must include feature and property tags in comments
