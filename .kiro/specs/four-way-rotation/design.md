# Design Document: Four-Way Rotation System

## Overview

This design implements a 4-way rotation system for rune pairs in Runefall, replacing the current 2-state boolean toggle with a proper 4-state rotation cycle. The system allows players to rotate through all four orientations (0°, 90°, 180°, 270°), enabling precise positioning of each rune in the pair.

The implementation replaces the `is_horizontal` boolean in `RunePair` with an integer `rotation_state` (0-3) and updates all dependent systems (collision detection, wall kicks, piece locking) to work with the new rotation model.

## Architecture

### Component Relationships

```
RunePair (rotation_state: 0-3)
    ├── Manages: rune1, rune2 positions
    ├── Provides: rotation_state, grid_x, grid_y
    └── Updates: visual positions based on rotation_state

GameBoard
    ├── Reads: RunePair.rotation_state
    ├── Calls: can_place_pair(x, y, rotation_state)
    ├── Handles: collision detection, wall kicks
    └── Executes: piece locking with correct positions
```

### Rotation State Mapping

The rotation state determines the relative positions of rune1 and rune2:

- **State 0**: Rune1 left, Rune2 right (horizontal, 0°)
- **State 1**: Rune1 top, Rune2 bottom (vertical, 90° clockwise)
- **State 2**: Rune2 left, Rune1 right (horizontal, 180°)
- **State 3**: Rune2 top, Rune1 bottom (vertical, 270° clockwise)

### Design Decisions

1. **Integer over Enum**: Using `int` (0-3) instead of an enum for simplicity and easy modulo arithmetic
2. **Preserve Wall Kick Logic**: Existing wall kick sequence (try current, try left, try right) remains unchanged
3. **Minimal API Changes**: `grid_x` and `grid_y` remain as the anchor point (top-left of the pair's bounding box)
4. **Position Calculation**: All position logic centralized in `update_positions()` and `get_pair_positions()`

## Components and Interfaces

### RunePair Class Changes

**Modified Properties:**
```gdscript
# Remove
var is_horizontal: bool = true

# Add
var rotation_state: int = 0  # Valid values: 0, 1, 2, 3
```

**Modified Methods:**
```gdscript
func rotate_pair():
    # Increment rotation state with wrap-around
    rotation_state = (rotation_state + 1) % 4
    update_positions()

func update_positions():
    # Map rotation state to visual positions
    match rotation_state:
        0:  # Horizontal: rune1 left, rune2 right
            rune1.position = Vector2(25, 25)
            rune2.position = Vector2(75, 25)
        1:  # Vertical: rune1 top, rune2 bottom
            rune1.position = Vector2(25, 25)
            rune2.position = Vector2(25, 75)
        2:  # Horizontal: rune2 left, rune1 right
            rune1.position = Vector2(75, 25)
            rune2.position = Vector2(25, 25)
        3:  # Vertical: rune2 top, rune1 bottom
            rune1.position = Vector2(25, 75)
            rune2.position = Vector2(25, 25)
```

### GameBoard Class Changes

**Modified Methods:**
```gdscript
func rotate_current_pair():
    # Calculate target rotation state
    var target_rotation = (current_pair.rotation_state + 1) % 4
    
    # Try naive rotation (same grid_x)
    if can_place_pair(current_pair.grid_x, current_pair.grid_y, target_rotation):
        current_pair.rotate_pair()
        return
    
    # Try wall-kick left
    if can_place_pair(current_pair.grid_x - 1, current_pair.grid_y, target_rotation):
        current_pair.grid_x -= 1
        current_pair.position = grid_to_world_pair(current_pair.grid_x, current_pair.grid_y)
        current_pair.rotate_pair()
        return
    
    # Try wall-kick right
    if can_place_pair(current_pair.grid_x + 1, current_pair.grid_y, target_rotation):
        current_pair.grid_x += 1
        current_pair.position = grid_to_world_pair(current_pair.grid_x, current_pair.grid_y)
        current_pair.rotate_pair()
        return
    
    # No valid position - block rotation

func can_place_pair(x: int, y: int, rotation: int = current_pair.rotation_state) -> bool:
    if y >= GRID_HEIGHT:
        return false
    
    var positions = get_pair_positions(x, y, rotation)
    for pos in positions:
        if pos.x < 0 or pos.x >= GRID_WIDTH or pos.y < 0 or pos.y >= GRID_HEIGHT:
            return false
        if grid[pos.y][pos.x] != null:
            return false
    return true

func get_pair_positions(x: int, y: int, rotation: int = current_pair.rotation_state) -> Array:
    var positions = []
    match rotation:
        0:  # Horizontal: rune1 left, rune2 right
            positions.append(Vector2i(x, y))
            positions.append(Vector2i(x + 1, y))
        1:  # Vertical: rune1 top, rune2 bottom
            positions.append(Vector2i(x, y))
            positions.append(Vector2i(x, y + 1))
        2:  # Horizontal: rune2 left, rune1 right
            positions.append(Vector2i(x + 1, y))
            positions.append(Vector2i(x, y))
        3:  # Vertical: rune2 top, rune1 bottom
            positions.append(Vector2i(x, y + 1))
            positions.append(Vector2i(x, y))
    return positions

func move_pair_horizontal(direction: int):
    var new_x = current_pair.grid_x + direction
    var max_x = GRID_WIDTH - 1
    
    # Adjust bounds for horizontal orientations
    if current_pair.rotation_state == 0 or current_pair.rotation_state == 2:
        max_x = GRID_WIDTH - 2
    
    if new_x >= 0 and new_x <= max_x:
        if can_place_pair(new_x, current_pair.grid_y):
            current_pair.grid_x = new_x
            current_pair.position = grid_to_world_pair(new_x, current_pair.grid_y)
```

**Note on `get_pair_positions` Return Order:**
The function returns positions in the order [rune1_position, rune2_position] to maintain consistency with the locking logic that expects `positions[0]` for rune1 and `positions[1]` for rune2.

## Data Models

### Rotation State Model

```
rotation_state: int ∈ {0, 1, 2, 3}

Mapping:
  0 → (rune1: (0, 0), rune2: (1, 0))  # Horizontal
  1 → (rune1: (0, 0), rune2: (0, 1))  # Vertical
  2 → (rune1: (1, 0), rune2: (0, 0))  # Horizontal flipped
  3 → (rune1: (0, 1), rune2: (0, 0))  # Vertical flipped

Invariant: rotation_state ∈ [0, 3]
```

### Position Coordinate System

```
Grid coordinates: (grid_x, grid_y) = anchor point (top-left)
Visual offsets: Relative to anchor in pixels (CELL_SIZE = 50)

For rotation_state:
  0: rune1 at (0, 0), rune2 at (+1, 0)
  1: rune1 at (0, 0), rune2 at (0, +1)
  2: rune1 at (+1, 0), rune2 at (0, 0)
  3: rune1 at (0, +1), rune2 at (0, 0)
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Rotation State Cycling

*For any* rotation state value (0-3), calling rotate_pair() should increment the state by 1 modulo 4, cycling back to 0 after state 3.

**Validates: Requirements 2.1, 2.2**

### Property 2: Position Mapping Correctness

*For any* rotation state (0-3), the visual positions of rune1 and rune2 should match the expected layout for that state, with horizontal states (0, 2) placing runes side-by-side and vertical states (1, 3) placing runes vertically.

**Validates: Requirements 1.2, 1.3, 1.4, 1.5, 2.3**

### Property 3: Collision Detection for All Rotations

*For any* rotation state and grid position, the collision detection should correctly identify both rune positions and return false if either position is occupied or out of bounds.

**Validates: Requirements 3.1, 3.4**

### Property 4: Wall Kick Sequence

*For any* rotation attempt that would collide at the current position, the system should try positions in order: current, grid_x - 1, grid_x + 1, and apply the first valid position or block rotation if none are valid.

**Validates: Requirements 3.2, 4.1, 4.2, 4.3, 4.4**

### Property 5: Rotation Blocking Preserves State

*For any* rotation attempt where no valid position exists (including wall kicks), the rotation state should remain unchanged and the pair should stay at its current position.

**Validates: Requirements 3.3**

### Property 6: Locking Position Correctness

*For any* rotation state, when a pair locks, both runes should be placed at grid coordinates that match their visual positions, with the correct rune (rune1 or rune2) at each position.

**Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**

### Property 7: Gravity and Match Detection Preservation

*For any* game state before and after implementing four-way rotation, the gravity system and match detection should continue to function identically, with pieces falling and matches being detected correctly.

**Validates: Requirements 6.3**

## Error Handling

### Invalid Rotation State

**Scenario**: rotation_state becomes invalid (< 0 or > 3)

**Prevention**: Use modulo arithmetic `(rotation_state + 1) % 4` to ensure values stay in range

**Detection**: Add assertions in debug builds to catch invalid states

**Recovery**: Not applicable - prevention ensures this cannot occur

### Collision Detection Edge Cases

**Scenario**: Rotation near grid boundaries or dense piece clusters

**Handling**: 
- Wall kick system tries alternative positions
- If all positions invalid, rotation is blocked
- Current state is preserved (no partial updates)

**User Feedback**: Rotation simply doesn't occur (standard puzzle game behavior)

### Locking Position Mismatch

**Scenario**: Visual position doesn't match grid position during locking

**Prevention**: 
- Single source of truth: `get_pair_positions()` function
- Used consistently for collision, movement, and locking
- Match statement ensures all rotation states are handled

**Detection**: Property-based tests verify position consistency

## Testing Strategy

### Dual Testing Approach

This feature requires both unit tests and property-based tests for comprehensive coverage:

**Unit Tests** focus on:
- Specific examples of each rotation state (0, 1, 2, 3)
- Edge cases like rotation at grid boundaries
- Wall kick scenarios (left wall, right wall, blocked)
- Integration with existing systems (gravity, match detection)

**Property-Based Tests** focus on:
- Universal properties that hold for all rotation states
- Comprehensive input coverage through randomization
- Invariant preservation across operations

### Property-Based Testing Configuration

**Framework**: GUT (Godot Unit Test) with custom property test helpers

**Configuration**:
- Minimum 100 iterations per property test
- Random rotation states (0-3)
- Random grid positions within bounds
- Random board configurations (empty, sparse, dense)

**Test Tagging Format**:
Each property test must include a comment referencing its design property:
```gdscript
# Feature: four-way-rotation, Property 1: Rotation State Cycling
func test_rotation_cycling_property():
    # Test implementation
```

### Property Test Implementation Approach

For each correctness property, implement a single property-based test that:

1. **Generates** random valid inputs (rotation states, positions, board states)
2. **Executes** the operation under test
3. **Asserts** the property holds for the generated inputs
4. **Repeats** for at least 100 iterations

Example structure:
```gdscript
func test_property_X():
    for i in range(100):
        var random_state = randi() % 4
        var random_x = randi() % GRID_WIDTH
        var random_y = randi() % GRID_HEIGHT
        # Test property holds for these inputs
        assert_property_holds(random_state, random_x, random_y)
```

### Unit Test Coverage

**Critical Unit Tests**:
1. Each rotation state produces correct positions (4 tests)
2. Rotation cycles from 3 back to 0 (1 test)
3. Wall kick left when rotation blocked (1 test)
4. Wall kick right when left fails (1 test)
5. Rotation blocked when all positions invalid (1 test)
6. Locking places runes correctly for each state (4 tests)
7. Horizontal movement respects rotation state bounds (2 tests)

**Integration Tests**:
1. Gravity works after four-way rotation implementation
2. Match detection works with rotated pieces
3. Game over detection still functions

### Test Execution

Run tests with:
```bash
# Run all tests
godot --headless -s addons/gut/gut_cmdln.gd

# Run specific test suite
godot --headless -s addons/gut/gut_cmdln.gd -gtest=test_four_way_rotation.gd
```

### Acceptance Criteria Validation

Each acceptance criterion maps to specific tests:

- **Requirement 1**: Unit tests for each rotation state + Property 2
- **Requirement 2**: Property 1 (cycling) + unit test for 3→0 wrap
- **Requirement 3**: Property 3 (collision) + Property 5 (blocking)
- **Requirement 4**: Property 4 (wall kicks) + unit tests for each kick scenario
- **Requirement 5**: Property 6 (locking) + unit tests for each state
- **Requirement 6**: Property 7 (preservation) + integration tests

## Implementation Notes

### Migration Path

1. Add `rotation_state` property to RunePair (default 0)
2. Update `update_positions()` to use match statement
3. Update `rotate_pair()` to use modulo arithmetic
4. Update GameBoard's `get_pair_positions()` to use rotation_state
5. Update GameBoard's `can_place_pair()` signature
6. Update GameBoard's `rotate_current_pair()` to calculate target state
7. Update GameBoard's `move_pair_horizontal()` bounds checking
8. Remove `is_horizontal` property (last step)

### Backward Compatibility Notes

The `is_horizontal` property can be temporarily maintained during migration:
```gdscript
var is_horizontal: bool:
    get: return rotation_state == 0 or rotation_state == 2
```

This allows gradual migration if needed, though a direct replacement is recommended.

### Performance Considerations

- Match statements compile to jump tables (O(1) lookup)
- Modulo operation is negligible for small values
- No additional memory allocation during rotation
- Position calculations remain constant time

### Visual Debugging

For development, consider adding debug visualization:
```gdscript
func _draw():
    # Draw rotation state indicator
    var state_text = str(rotation_state)
    draw_string(font, Vector2(5, 15), state_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.YELLOW)
```

This helps verify rotation state during testing and development.
