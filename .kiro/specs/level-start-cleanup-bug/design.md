# Level Start Cleanup Bug - Bugfix Design

## Overview

When starting a level in Runefall, the `initialize_level()` function fails to properly clean up existing game objects from previous sessions. This causes two visual bugs: stale rune pairs remain visible on the board, and the preview display shows colors that don't match the actual spawning runes. The fix requires adding proper cleanup of child nodes before reinitializing the grid and ensuring the preview system uses freshly generated data.

## Glossary

- **Bug_Condition (C)**: The condition that triggers the bug - when `initialize_level()` is called with existing RunePair, Rune, or Element nodes in the scene tree
- **Property (P)**: The desired behavior when starting a level - all previous game objects should be removed and preview should match actual spawning runes
- **Preservation**: Existing gameplay mechanics (pair spawning, gravity, matching, preview generation) that must remain unchanged by the fix
- **initialize_level()**: The function in `scripts/game_board.gd` that sets up a new level with a specified number of elements
- **initialize_grid()**: The function that clears the grid array but currently does not free child nodes
- **next_rune_pair_data**: The dictionary that stores preview data for the next rune pair to spawn

## Bug Details

### Fault Condition

The bug manifests when `initialize_level()` is called while RunePair, Rune, or Element nodes exist in the scene tree from previous gameplay. The `initialize_grid()` function only clears the grid array references but does not free the actual node instances, leaving them visible on screen. Additionally, the preview system uses stale `next_rune_pair_data` from before the board reinitialization.

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type GameBoardState
  OUTPUT: boolean
  
  RETURN input.initialize_level_called == true
         AND (input.has_existing_rune_pairs OR input.has_existing_runes OR input.has_existing_elements)
         AND NOT all_child_nodes_freed_before_spawn
END FUNCTION
```

### Examples

- **Stale Rune Pairs**: Start game from main menu → play level 1 → return to menu → start level 1 again. Expected: clean board. Actual: previous rune pairs still visible.
- **Preview Mismatch**: Start level 1 → observe preview shows red/blue → actual spawning pair is green/yellow. Expected: preview matches spawning pair. Actual: preview shows stale data.
- **Multiple Sessions**: Play several games in succession → each new game accumulates more visual artifacts from previous sessions. Expected: each game starts clean. Actual: visual clutter increases.
- **Edge Case - First Launch**: Launch game for first time → level 1 starts clean because no previous nodes exist. Expected: continues to work correctly.

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Normal pair spawning during gameplay must continue to use preview data correctly
- Gravity application after locking pairs must continue to work
- Match detection (horizontal and vertical) must continue to function
- Preview generation for subsequent pairs during gameplay must remain unchanged
- Grid boundary drawing must continue to display correctly
- Element spawning logic must continue to place elements randomly at the bottom

**Scope:**
All inputs that do NOT involve calling `initialize_level()` should be completely unaffected by this fix. This includes:
- Pair movement and rotation during active gameplay
- Locking pairs and spawning new pairs during a level
- Match detection and removal
- Gravity application
- Win/loss condition checking

## Hypothesized Root Cause

Based on the bug description and code analysis, the most likely issues are:

1. **Missing Node Cleanup**: The `initialize_grid()` function only clears the grid array (`grid[y][x] = null`) but does not iterate through and free existing child nodes
   - RunePair nodes remain in the scene tree
   - Individual Rune nodes (from locked pairs) remain in the scene tree
   - Element nodes remain in the scene tree

2. **Stale Preview Data**: The `initialize_level()` function generates `next_rune_pair_data` AFTER calling `initialize_grid()`, but the preview UI may be updated before this happens or uses cached data

3. **Timing Issue**: The preview signal `preview_updated.emit()` is called in `spawn_new_pair()`, which uses the newly generated `next_rune_pair_data`, but there may be a timing issue where old data is displayed first

4. **No Explicit Cleanup Step**: There is no dedicated cleanup function that removes all game objects before reinitializing the board

## Correctness Properties

Property 1: Fault Condition - Clean Board on Level Start

_For any_ game state where `initialize_level()` is called with existing RunePair, Rune, or Element nodes in the scene tree, the fixed function SHALL remove all such nodes before spawning new elements and pairs, resulting in a visually clean board with only the newly spawned game objects.

**Validates: Requirements 2.1, 2.2, 2.3**

Property 2: Preservation - Gameplay Mechanics Unchanged

_For any_ game state where `initialize_level()` is NOT being called (normal gameplay with pair spawning, locking, matching, and gravity), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing gameplay mechanics.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

**File**: `scripts/game_board.gd`

**Function**: `initialize_grid()`

**Specific Changes**:
1. **Add Node Cleanup Loop**: Before clearing the grid array, iterate through all children of the GameBoard node and free any RunePair, Rune, or Element instances
   - Use `get_children()` to get all child nodes
   - Check each child's type using `is` operator
   - Call `queue_free()` on matching nodes

2. **Ensure Preview Data Freshness**: Verify that `next_rune_pair_data` is generated BEFORE the first `spawn_new_pair()` call in `initialize_level()`
   - The current code already does this correctly
   - Ensure no stale data exists from previous sessions

3. **Add Cleanup Function**: Create a dedicated `cleanup_board()` function that handles all node removal
   - Call this function at the start of `initialize_grid()`
   - Makes the cleanup logic reusable and explicit

4. **Verify Preview Signal Timing**: Ensure `preview_updated.emit()` in `spawn_new_pair()` uses the freshly generated `next_rune_pair_data`
   - The current code already does this correctly
   - The issue is likely that old nodes are visible, not that the preview is wrong

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

### Exploratory Fault Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

**Test Plan**: Write tests that simulate starting a level with existing nodes in the scene tree. Run these tests on the UNFIXED code to observe failures and understand the root cause.

**Test Cases**:
1. **Stale Rune Pairs Test**: Create RunePair nodes, call `initialize_level()`, verify old pairs are NOT removed (will fail on unfixed code)
2. **Stale Runes Test**: Create individual Rune nodes, call `initialize_level()`, verify old runes are NOT removed (will fail on unfixed code)
3. **Stale Elements Test**: Create Element nodes, call `initialize_level()`, verify old elements are NOT removed (will fail on unfixed code)
4. **Preview Mismatch Test**: Set `next_rune_pair_data` to specific values, call `initialize_level()`, verify preview doesn't match spawned pair (may fail on unfixed code)

**Expected Counterexamples**:
- Old RunePair, Rune, and Element nodes remain in the scene tree after `initialize_level()` is called
- Possible causes: `initialize_grid()` only clears array, no explicit node cleanup

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL gameState WHERE isBugCondition(gameState) DO
  result := initialize_level_fixed(gameState)
  ASSERT all_old_nodes_removed(result)
  ASSERT preview_matches_spawned_pair(result)
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL gameState WHERE NOT isBugCondition(gameState) DO
  ASSERT gameplay_behavior_original(gameState) = gameplay_behavior_fixed(gameState)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-buggy inputs

**Test Plan**: Observe behavior on UNFIXED code first for normal gameplay (pair spawning, locking, matching, gravity), then write property-based tests capturing that behavior.

**Test Cases**:
1. **Pair Spawning Preservation**: Observe that `spawn_new_pair()` uses preview data correctly during gameplay on unfixed code, then write test to verify this continues after fix
2. **Gravity Preservation**: Observe that gravity works correctly on unfixed code, then write test to verify this continues after fix
3. **Matching Preservation**: Observe that match detection works correctly on unfixed code, then write test to verify this continues after fix
4. **Preview Generation Preservation**: Observe that preview generation during gameplay works correctly on unfixed code, then write test to verify this continues after fix

### Unit Tests

- Test `initialize_level()` with existing nodes in scene tree
- Test that all RunePair, Rune, and Element nodes are removed
- Test that preview data matches spawned pair after initialization
- Test edge case of first launch (no existing nodes)

### Property-Based Tests

- Generate random game states with varying numbers of existing nodes and verify all are cleaned up
- Generate random gameplay sequences and verify preservation of spawning, gravity, and matching behavior
- Test that preview system works correctly across many level initializations

### Integration Tests

- Test full game flow: start level → play → return to menu → start level again
- Test multiple consecutive game sessions to verify no accumulation of artifacts
- Test that visual display is clean after level initialization
- Manually test in Godot editor to verify visual correctness
