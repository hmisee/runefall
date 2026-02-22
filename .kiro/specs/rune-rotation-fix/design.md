# Rune Rotation Fix Bugfix Design

## Overview

The rune rotation feature currently lacks collision validation, allowing runes to rotate into invalid positions (out of bounds or overlapping existing pieces). This fix implements proper collision checking with wall-kick behavior, similar to Tetris rotation systems. When rotation would cause a collision, the system attempts to shift the pair horizontally (wall-kick) to make the rotation valid. If no valid position exists, the rotation is blocked.

## Glossary

- **Bug_Condition (C)**: The condition that triggers the bug - when rotation is attempted but would result in invalid grid positions
- **Property (P)**: The desired behavior when rotation is pressed - rotation succeeds with wall-kick adjustment, or is blocked if no valid position exists
- **Preservation**: Existing movement, locking, and matching behavior that must remain unchanged by the fix
- **rotate_pair()**: The function in `scripts/rune_pair.gd` that toggles the orientation between horizontal and vertical
- **can_place_pair()**: The function in `scripts/game_board.gd` that validates if a pair can occupy a grid position
- **Wall-kick**: The technique of shifting a piece horizontally to make rotation valid when the naive rotation would collide
- **is_horizontal**: Boolean state in RunePair that determines if rune2 is to the right (true) or below (false) rune1

## Bug Details

### Fault Condition

The bug manifests when a player presses the rotation key (ui_up) and the resulting rotated position would either place runes outside the 8x16 grid bounds or overlap with existing pieces in the grid. The `rotate_pair()` function in `scripts/rune_pair.gd` simply toggles `is_horizontal` and updates visual positions without consulting the game board's collision system.

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type RotationAttempt
  OUTPUT: boolean
  
  LET rotated_orientation = NOT current_pair.is_horizontal
  LET rotated_positions = calculate_positions(current_pair.grid_x, current_pair.grid_y, rotated_orientation)
  
  RETURN input.action == "ui_up"
         AND (any_position_out_of_bounds(rotated_positions) 
              OR any_position_collides(rotated_positions))
END FUNCTION
```

### Examples

- **Horizontal near right edge**: Pair at (6, 5) horizontal. Rotating to vertical would place rune2 at (6, 6), which is valid. But pair at (7, 5) horizontal rotating to vertical would place rune2 at (7, 6), also valid. However, pair at (7, 5) horizontal has rune2 at (8, 5) which is out of bounds (x >= 8).

- **Vertical near bottom**: Pair at (3, 14) vertical with rune2 at (3, 15). Rotating to horizontal would place rune2 at (4, 14), which is valid. But pair at (3, 15) vertical would have rune2 at (3, 16) which is out of bounds (y >= 16).

- **Collision with existing pieces**: Pair at (2, 5) vertical. Grid has a piece at (3, 5). Rotating to horizontal would place rune2 at (3, 5), causing overlap.

- **Valid rotation**: Pair at (3, 5) horizontal with no pieces at (3, 5) or (3, 6). Rotating to vertical is valid and should succeed immediately.

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Horizontal movement (left/right keys) must continue to work with existing collision checking
- Vertical movement (automatic fall and down key) must continue to work with existing collision checking
- Pair locking must continue to separate runes and place them correctly in the grid
- Match detection and gravity must continue to work after pairs lock
- Visual positioning of runes within pairs must remain consistent with grid coordinates

**Scope:**
All inputs that do NOT involve the rotation key (ui_up) should be completely unaffected by this fix. This includes:
- Movement keys (ui_left, ui_right, ui_down)
- Automatic falling behavior
- Pair locking when reaching bottom or collision
- Match checking and piece removal
- Gravity application after matches

## Hypothesized Root Cause

Based on the bug description and code analysis, the root cause is clear:

1. **Missing Collision Validation**: The `rotate_pair()` function in `scripts/rune_pair.gd` operates independently without any communication with the game board's collision system. It simply toggles `is_horizontal` and updates local visual positions.

2. **No Access to Grid State**: The RunePair class has no reference to the GameBoard or its grid, so it cannot check if the rotated position would be valid.

3. **Separation of Concerns Gone Wrong**: While separating visual representation (RunePair) from game logic (GameBoard) is good design, the rotation logic was placed in the wrong layer. Rotation affects grid positions and must validate against the grid.

4. **No Wall-Kick Implementation**: Even if collision checking existed, there's no logic to attempt horizontal shifts when naive rotation fails.

## Correctness Properties

Property 1: Fault Condition - Rotation with Collision Validation

_For any_ rotation attempt where the naive rotation would cause out-of-bounds or collision, the fixed system SHALL either successfully rotate with wall-kick adjustment (shifting the pair left or right by 1 cell), or block the rotation entirely if no valid position exists within the wall-kick range.

**Validates: Requirements 2.1, 2.2, 2.3**

Property 2: Fault Condition - Valid Rotation Success

_For any_ rotation attempt where the naive rotation is valid (no collision, within bounds), the fixed system SHALL immediately rotate the pair without requiring wall-kick adjustment.

**Validates: Requirements 2.4**

Property 3: Fault Condition - Wall-Kick Position Update

_For any_ rotation attempt where wall-kick is applied, the fixed system SHALL update both the orientation (is_horizontal) and the grid position (grid_x) of the pair to reflect the shifted position.

**Validates: Requirements 2.5**

Property 4: Preservation - Non-Rotation Input Behavior

_For any_ input that is NOT the rotation key (movement keys, automatic fall, locking), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing movement, collision, locking, matching, and gravity functionality.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**

## Fix Implementation

### Changes Required

The fix requires moving rotation logic from RunePair to GameBoard and implementing wall-kick collision checking.

**File**: `scripts/game_board.gd`

**Function**: Add new `rotate_current_pair()` function

**Specific Changes**:
1. **Add rotate_current_pair() function**: Create a new function in GameBoard that handles rotation with collision validation and wall-kick logic
   - Check if naive rotation (same grid_x, toggled orientation) is valid using can_place_pair()
   - If invalid, attempt wall-kick: try grid_x - 1, then grid_x + 1
   - If any position is valid, apply rotation and update grid_x if needed
   - If no valid position, block rotation (do nothing)

2. **Modify handle_input()**: Change the ui_up input handler to call the new GameBoard function instead of calling RunePair's rotate_pair()
   - Replace `current_pair.rotate_pair()` with `rotate_current_pair()`

3. **Update can_place_pair() signature**: Modify can_place_pair to accept an optional orientation parameter
   - Add parameter: `orientation: bool = current_pair.is_horizontal`
   - Use this parameter instead of current_pair.is_horizontal when calculating positions
   - This allows testing hypothetical rotations without modifying state

4. **Update get_pair_positions() signature**: Modify get_pair_positions to accept an optional orientation parameter
   - Add parameter: `orientation: bool = current_pair.is_horizontal`
   - Use this parameter instead of current_pair.is_horizontal when calculating positions

5. **Keep rotate_pair() in RunePair**: The visual update function remains, but is now only called by GameBoard after validation
   - No changes needed to RunePair.rotate_pair() itself
   - It becomes a "dumb" visual update function called only when rotation is confirmed valid

**File**: `scripts/rune_pair.gd`

**No changes required** - the rotate_pair() function remains as-is for visual updates

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code (rotation succeeds when it shouldn't), then verify the fix works correctly (rotation blocked or wall-kicked) and preserves existing behavior (movement still works).

### Exploratory Fault Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm that rotation currently ignores collision and bounds checking.

**Test Plan**: Write tests that attempt rotation in invalid scenarios and verify that the unfixed code allows invalid rotations. Run these tests on the UNFIXED code to observe failures.

**Test Cases**:
1. **Right Edge Rotation Test**: Place horizontal pair at x=7 (rightmost valid horizontal position), attempt rotation to vertical (will succeed on unfixed code, placing rune2 out of bounds)
2. **Bottom Edge Rotation Test**: Place vertical pair at y=15 (bottommost position), attempt rotation to horizontal (will succeed on unfixed code if space exists)
3. **Collision Rotation Test**: Place horizontal pair with a piece directly below rune1, attempt rotation to vertical (will succeed on unfixed code, causing overlap)
4. **Valid Rotation Test**: Place pair in open space, attempt rotation (should succeed on both unfixed and fixed code)

**Expected Counterexamples**:
- Rotation succeeds even when resulting positions are out of bounds (x >= 8 or y >= 16)
- Rotation succeeds even when resulting positions overlap existing grid pieces
- No wall-kick behavior exists - rotation either succeeds naively or should be blocked but isn't

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds (rotation would cause collision), the fixed function either applies wall-kick successfully or blocks rotation.

**Pseudocode:**
```
FOR ALL rotation_attempt WHERE isBugCondition(rotation_attempt) DO
  initial_state := capture_pair_state()
  result := rotate_current_pair_fixed()
  
  IF result.rotation_occurred THEN
    ASSERT result.used_wall_kick = true
    ASSERT is_valid_position(result.new_x, result.new_y, result.new_orientation)
  ELSE
    ASSERT pair_state_unchanged(initial_state)
  END IF
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold (non-rotation inputs), the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL input WHERE input.action != "ui_up" DO
  ASSERT game_behavior_original(input) = game_behavior_fixed(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across different game states
- It catches edge cases in movement, locking, and matching that manual tests might miss
- It provides strong guarantees that non-rotation behavior is unchanged

**Test Plan**: Observe behavior on UNFIXED code first for movement and locking, then write property-based tests capturing that behavior.

**Test Cases**:
1. **Horizontal Movement Preservation**: Verify left/right movement continues to work with collision checking across various grid states
2. **Vertical Movement Preservation**: Verify automatic fall and down-key acceleration continue to work correctly
3. **Locking Preservation**: Verify pairs lock correctly and separate into individual runes in both orientations
4. **Matching Preservation**: Verify match-4 detection continues to work after pairs lock

### Unit Tests

- Test rotation at right edge (x=7 horizontal) - should wall-kick left or block
- Test rotation at left edge (x=0 horizontal) - should succeed or wall-kick right if needed
- Test rotation near bottom (y=15 vertical) - should succeed if space exists horizontally
- Test rotation with collision - should wall-kick or block
- Test rotation in open space - should succeed immediately
- Test wall-kick left (naive rotation blocked, x-1 valid)
- Test wall-kick right (naive rotation blocked, x+1 valid)
- Test rotation blocked (naive and both wall-kicks invalid)

### Property-Based Tests

- Generate random grid states with pairs at various positions and orientations, verify rotation behavior is correct (valid rotations succeed, invalid ones are blocked or wall-kicked)
- Generate random grid states with existing pieces, verify rotation respects collisions
- Generate random game states with movement inputs, verify movement behavior is unchanged from original
- Generate random game states with locking scenarios, verify locking behavior is unchanged

### Integration Tests

- Test full game flow: spawn pair, move horizontally, rotate, move more, lock - verify all steps work correctly
- Test rotation in all three edge scenarios: right edge, bottom edge, collision
- Test that visual feedback (rune positions) updates correctly after rotation and wall-kick
- Test rapid rotation attempts (spam rotation key) - verify state remains consistent
