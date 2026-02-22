# Level Progression Bugs - Bugfix Design

## Overview

This design addresses three critical bugs affecting level progression and user experience in Runefall. The bugs are:

1. **Drop Speed Bug**: The `fall_speed` variable in `GameBoard` is not reset when a new level starts, causing rune pairs to fall at the fast-drop speed (0.05s) if the player was holding the down arrow key when the previous level ended.

2. **Notification Overflow Bug**: The `MessageLabel` in `GameUI` has insufficient width (600px) and uses a large font size (48px), causing long messages like "The shaman successfully calmed down all the elements" to overflow and become unreadable.

3. **Game Over Routing Bug**: When the game enters the LOSS state, there is no automatic routing back to the main menu. The player is stuck on the game screen with no way to return.

The fix strategy is minimal and targeted: reset `fall_speed` on level initialization, adjust `MessageLabel` properties to enable text wrapping, and add automatic routing to main menu after displaying the game over message.

## Glossary

- **Bug_Condition (C)**: The conditions that trigger each of the three bugs
- **Property (P)**: The desired behavior when the bug conditions are met
- **Preservation**: Existing gameplay behaviors that must remain unchanged by the fixes
- **fall_speed**: The variable in `GameBoard` that controls how fast rune pairs fall (0.5s normal, 0.05s fast-drop)
- **GameBoard.initialize_level()**: The function in `scripts/game_board.gd` that sets up a new level
- **MessageLabel**: The Label node in `GameUI` that displays game messages (level clear, game over, etc.)
- **GameState.State.LOSS**: The game state enum value representing game over condition
- **main.gd._on_state_changed_for_ui()**: The function that handles UI updates when game state changes

## Bug Details

### Fault Condition

The bugs manifest under three distinct conditions:

**Bug 1 - Drop Speed**: The bug occurs when a new level starts while the player was holding the down arrow key (or released it just before level transition). The `GameBoard.initialize_level()` function does not reset `fall_speed`, so it remains at 0.05s from the fast-drop input, making rune pairs fall uncontrollably fast.

**Bug 2 - Notification Overflow**: The bug occurs when any level completion message is displayed. The `MessageLabel` has a fixed width of 600px and font size of 48px with no text wrapping enabled, causing messages longer than ~12 characters to overflow the bounds and become cut off.

**Bug 3 - Game Over Routing**: The bug occurs when the game board emits `loss_condition_met` signal. The `GameState` transitions to LOSS state and displays "Game Over - The elements remain angry", but there is no subsequent action to return the player to the main menu, leaving them stuck.

**Formal Specification:**
```
FUNCTION isBugCondition_DropSpeed(input)
  INPUT: input of type LevelStartEvent
  OUTPUT: boolean
  
  RETURN input.levelNumber IN [1, 2, 3]
         AND GameBoard.fall_speed != 0.5
         AND GameBoard.initialize_level() was just called
END FUNCTION

FUNCTION isBugCondition_NotificationOverflow(input)
  INPUT: input of type MessageDisplayEvent
  OUTPUT: boolean
  
  RETURN input.messageText.length() > 12
         AND MessageLabel.autowrap_mode == AUTOWRAP_OFF
         AND MessageLabel.custom_minimum_size.x == 600
END FUNCTION

FUNCTION isBugCondition_GameOverRouting(input)
  INPUT: input of type GameStateChange
  OUTPUT: boolean
  
  RETURN input.newState == GameState.State.LOSS
         AND NOT scheduledTransitionToMenu()
END FUNCTION
```

### Examples

**Bug 1 - Drop Speed:**
- Player completes level 2 while holding down arrow key → Level 3 starts → Rune pairs fall at 0.05s speed (expected: 0.5s)
- Player fast-drops final pair of level 1 → Level 2 starts immediately → Rune pairs fall too fast (expected: 0.5s)
- Player starts level 1 normally → Rune pairs fall at correct 0.5s speed (edge case - works correctly)

**Bug 2 - Notification Overflow:**
- Level 1 completed → Message "The shaman successfully calmed down all the elements" displays → Text is cut off at "The shaman successfully cal..." (expected: full text visible)
- Final level completed → Message "Congratulations! You have mastered all elements!" displays → Text overflows (expected: full text visible)
- Short message "Game Over" displays → Text fits within bounds (edge case - works correctly)

**Bug 3 - Game Over Routing:**
- Elements reach spawn position → `loss_condition_met` emitted → Game shows "Game Over" message → Player stuck on game screen (expected: return to main menu after 3 seconds)
- Player pauses and returns to menu manually → Works correctly (edge case - manual workaround exists)

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Level progression flow when player wins must continue to work (unlock next level, save progress, auto-advance after 3 seconds for non-final levels)
- Fast-drop functionality during gameplay must continue to work (pressing down arrow speeds up fall to 0.05s, releasing returns to 0.5s)
- Win condition auto-progress must continue to work (3-second delay before next level)
- All other game state transitions (MENU, PLAYING, PAUSED, WIN, TRANSITION) must remain unchanged
- Pause functionality must continue to work normally
- GameUI visibility toggling based on game state must remain unchanged
- Message display for win conditions must continue to work
- All player controls (left, right, rotate, down) must continue to function normally

**Scope:**
All inputs and game flows that do NOT involve the three specific bug conditions should be completely unaffected by these fixes. This includes:
- Normal gameplay without level transitions
- Mouse/keyboard input handling for menus
- Pause menu functionality
- Save/load system
- Match detection and gravity
- Preview display and UI updates

## Hypothesized Root Cause

Based on the bug description and code analysis, the root causes are:

1. **Drop Speed Not Reset**: The `GameBoard.initialize_level()` function clears the board and spawns elements but does not reset the `fall_speed` variable to its default value of 0.5. This is a simple omission in the initialization logic.
   - The `fall_speed` variable is modified by input handling (`ui_down` pressed sets it to 0.05, released sets it to 0.5)
   - When a level transition occurs during or immediately after fast-drop input, the value persists
   - No explicit reset occurs in `initialize_level()`

2. **MessageLabel Configuration**: The `MessageLabel` node in the GameUI scene has insufficient configuration for displaying long text:
   - Fixed width of 600px is too narrow for messages like "The shaman successfully calmed down all the elements" (60+ characters)
   - Font size of 48px is too large for the available space
   - Text wrapping is not enabled (`autowrap_mode` is likely set to `AUTOWRAP_OFF`)
   - No dynamic sizing or overflow handling

3. **Missing LOSS State Handler**: The `main.gd._on_state_changed_for_ui()` function handles WIN state with auto-progression logic but has no equivalent logic for LOSS state:
   - WIN state shows message and calls `_auto_progress_to_next_level()` which waits 3 seconds then starts next level
   - LOSS state only shows message with no follow-up action
   - No timer or signal connection to trigger `return_to_menu()` after game over

4. **Architectural Gap**: The game over flow is incomplete - the signal chain stops at displaying the message without completing the user journey back to the main menu.

## Correctness Properties

Property 1: Fault Condition - Drop Speed Reset on Level Start

_For any_ level start event where `initialize_level()` is called, the fixed function SHALL reset `fall_speed` to 0.5 seconds, ensuring rune pairs fall at the correct normal speed regardless of previous input state.

**Validates: Requirements 2.1, 2.2, 2.3**

Property 2: Fault Condition - Notification Text Fully Visible

_For any_ message display event where the message text length exceeds the label width, the fixed MessageLabel SHALL automatically wrap text or adjust sizing to ensure the full message is visible and readable within the UI bounds.

**Validates: Requirements 2.4, 2.5, 2.6**

Property 3: Fault Condition - Game Over Routes to Main Menu

_For any_ game state change to LOSS state, the fixed system SHALL display the game over message for 3 seconds and then automatically call `return_to_menu()` to transition back to the main menu.

**Validates: Requirements 2.7, 2.8**

Property 4: Preservation - Level Progression Flow

_For any_ game state change that is NOT related to the three bug conditions (normal gameplay, pause, win with auto-progress), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing level progression, save system, and UI state management functionality.

**Validates: Requirements 3.1, 3.2, 3.5, 3.6, 3.7, 3.8**

Property 5: Preservation - Player Controls

_For any_ player input during gameplay (left, right, rotate, down arrow for fast-drop), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing control responsiveness and fast-drop functionality.

**Validates: Requirements 3.3, 3.4, 3.9, 3.10**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

**File 1**: `scripts/game_board.gd`

**Function**: `initialize_level()`

**Specific Changes**:
1. **Reset fall_speed**: Add a single line `fall_speed = 0.5` at the beginning of the `initialize_level()` function (after the function signature, before or after `initialize_grid()` call)
   - This ensures every level starts with normal drop speed
   - Placement: Insert after line 96 (after `func initialize_level(element_count: int) -> void:`)

**File 2**: `scripts/game_ui.gd` or `scenes/game_ui.tscn`

**Node**: `MessageLabel`

**Specific Changes**:
1. **Enable Text Wrapping**: Set `autowrap_mode` property to `AUTOWRAP_WORD` or `AUTOWRAP_WORD_SMART` to allow text to wrap to multiple lines
   - This can be done in the scene file (.tscn) or via code in `_ready()`
   
2. **Increase Label Width**: Increase `custom_minimum_size.x` from 600px to at least 800px, or remove the constraint entirely to allow full width
   - Alternative: Keep width but reduce font size from 48px to 32px or 36px

3. **Enable Vertical Expansion**: Set `custom_minimum_size.y` to allow multiple lines (e.g., 100px or 150px) or use `autowrap_mode` with sufficient height

**Recommended Approach**: Modify in scene file for immediate visual feedback, or add code in `game_ui.gd._ready()`:
```gdscript
if message_label:
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    message_label.custom_minimum_size = Vector2(800, 150)
```

**File 3**: `scripts/main.gd`

**Function**: `_on_state_changed_for_ui()`

**Specific Changes**:
1. **Add LOSS State Auto-Routing**: In the `match new_state:` block, modify the `GameState.State.LOSS` case to include automatic routing logic similar to WIN state
   - Current code only shows message: `game_ui.show_message("Game Over - The elements remain angry")`
   - Add timer and routing: After showing message, wait 3 seconds, then call `game_state.return_to_menu()`

2. **Implementation Pattern**: Follow the same pattern as WIN state's `_auto_progress_to_next_level()` function
   - Create a new helper function `_auto_return_to_menu()` or inline the logic
   - Use `await get_tree().create_timer(3.0).timeout` to wait 3 seconds
   - Call `game_state.return_to_menu()` after timeout

**Specific Code Addition** (around line 119 in main.gd):
```gdscript
GameState.State.LOSS:
    game_ui.show_message("Game Over - The elements remain angry")
    # Auto-return to main menu after 3 seconds
    await get_tree().create_timer(3.0).timeout
    if game_state:
        game_state.return_to_menu()
```

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bugs on unfixed code, then verify the fixes work correctly and preserve existing behavior.

### Exploratory Fault Condition Checking

**Goal**: Surface counterexamples that demonstrate the three bugs BEFORE implementing the fixes. Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

**Test Plan**: Write automated tests that simulate the bug conditions and assert the expected failures. Run these tests on the UNFIXED code to observe failures and understand the root causes.

**Test Cases**:
1. **Drop Speed Bug - Level 2 to 3 Transition**: Simulate completing level 2 while holding down arrow key, then check that level 3 starts with fall_speed = 0.05 (will fail on unfixed code, should be 0.5)

2. **Drop Speed Bug - Fast Drop Before Lock**: Simulate pressing down arrow, then locking a pair, then starting a new level, verify fall_speed persists at 0.05 (will fail on unfixed code)

3. **Notification Overflow Bug - Long Message**: Display "The shaman successfully calmed down all the elements" and measure rendered text bounds vs MessageLabel bounds (will show overflow on unfixed code)

4. **Notification Overflow Bug - Final Level Message**: Display "Congratulations! You have mastered all elements!" and verify text visibility (will show overflow on unfixed code)

5. **Game Over Routing Bug - LOSS State**: Trigger loss_condition_met signal, wait 5 seconds, verify game state is still LOSS and not MENU (will fail on unfixed code - should transition to MENU)

6. **Edge Case - Normal Level Start**: Start level 1 without any prior input, verify fall_speed = 0.5 (should pass on unfixed code)

**Expected Counterexamples**:
- Bug 1: `fall_speed` will be 0.05 instead of 0.5 after level transition with fast-drop input
- Bug 2: MessageLabel rendered width will exceed 600px, text will be truncated
- Bug 3: Game will remain in LOSS state indefinitely with no automatic transition to MENU
- Possible causes confirmed: missing initialization, insufficient UI configuration, incomplete state transition logic

### Fix Checking

**Goal**: Verify that for all inputs where the bug conditions hold, the fixed functions produce the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition_DropSpeed(input) DO
  result := initialize_level_fixed(input.levelNumber)
  ASSERT GameBoard.fall_speed == 0.5
END FOR

FOR ALL input WHERE isBugCondition_NotificationOverflow(input) DO
  result := show_message_fixed(input.messageText)
  ASSERT messageIsFullyVisible(result)
END FOR

FOR ALL input WHERE isBugCondition_GameOverRouting(input) DO
  result := handle_loss_state_fixed(input)
  WAIT 3.5 seconds
  ASSERT GameState.current_state == GameState.State.MENU
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug conditions do NOT hold, the fixed functions produce the same result as the original functions.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition_DropSpeed(input) DO
  ASSERT initialize_level_original(input) == initialize_level_fixed(input)
END FOR

FOR ALL input WHERE NOT isBugCondition_NotificationOverflow(input) DO
  ASSERT show_message_original(input) == show_message_fixed(input)
END FOR

FOR ALL input WHERE NOT isBugCondition_GameOverRouting(input) DO
  ASSERT handle_state_change_original(input) == handle_state_change_fixed(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-buggy inputs

**Test Plan**: Observe behavior on UNFIXED code first for normal gameplay scenarios, then write property-based tests capturing that behavior.

**Test Cases**:
1. **Fast-Drop During Gameplay Preservation**: Observe that pressing/releasing down arrow during normal gameplay changes fall_speed correctly on unfixed code, then verify this continues after fix

2. **Win State Auto-Progress Preservation**: Observe that completing a non-final level auto-progresses after 3 seconds on unfixed code, then verify this continues after fix

3. **Short Message Display Preservation**: Observe that short messages like "Game Over" display correctly on unfixed code, then verify this continues after fix

4. **Pause/Resume Preservation**: Observe that pause menu functionality works correctly on unfixed code, then verify this continues after fix

5. **Level Unlock and Save Preservation**: Observe that completing levels unlocks next level and saves progress on unfixed code, then verify this continues after fix

### Unit Tests

- Test `initialize_level()` resets `fall_speed` to 0.5 for all level numbers (1, 2, 3)
- Test `initialize_level()` resets `fall_speed` even when called with `fall_speed` already at 0.05
- Test MessageLabel displays long messages without overflow after fix
- Test MessageLabel displays short messages correctly (regression check)
- Test LOSS state triggers automatic return to menu after 3 seconds
- Test WIN state still auto-progresses to next level (regression check)
- Test fast-drop input during gameplay still works correctly (press down = 0.05, release = 0.5)

### Property-Based Tests

- Generate random level numbers (1-3) and verify `initialize_level()` always resets `fall_speed` to 0.5
- Generate random message strings of varying lengths and verify all are fully visible in MessageLabel
- Generate random game state transitions and verify only LOSS state triggers menu routing, all others preserve original behavior
- Generate random input sequences during gameplay and verify fall_speed behavior is preserved for non-level-transition scenarios

### Integration Tests

- Test full game flow: Start level 1 → Complete with fast-drop → Level 2 starts → Verify normal drop speed
- Test full game flow: Start level 2 → Trigger game over → Wait 3 seconds → Verify return to main menu
- Test full game flow: Complete all levels → Verify final congratulations message is fully visible
- Test level transition timing: Complete level while holding down arrow → Verify next level has correct drop speed
- Test pause during level transition: Pause game → Resume → Complete level → Verify next level initializes correctly
