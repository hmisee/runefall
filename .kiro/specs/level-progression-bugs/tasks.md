# Implementation Plan

- [x] 1. Write bug condition exploration tests
  - **Property 1: Fault Condition** - Level Progression Bugs
  - **CRITICAL**: These tests MUST FAIL on unfixed code - failure confirms the bugs exist
  - **DO NOT attempt to fix the tests or the code when they fail**
  - **NOTE**: These tests encode the expected behavior - they will validate the fixes when they pass after implementation
  - **GOAL**: Surface counterexamples that demonstrate the three bugs exist
  - **Scoped PBT Approach**: Scope properties to concrete failing cases for reproducibility
  - Test Bug 1 - Drop Speed: Simulate completing level 2 while holding down arrow, verify fall_speed persists at 0.05 instead of resetting to 0.5
  - Test Bug 2 - Notification Overflow: Display "The shaman successfully calmed down all the elements", verify text overflows 600px MessageLabel bounds
  - Test Bug 3 - Game Over Routing: Trigger LOSS state, wait 5 seconds, verify game remains in LOSS state instead of transitioning to MENU
  - The test assertions should match the Expected Behavior Properties from design (fall_speed = 0.5, text fully visible, auto-route to menu)
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests FAIL (this is correct - it proves the bugs exist)
  - Document counterexamples found to understand root causes
  - Mark task complete when tests are written, run, and failures are documented
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8_

- [x] 2. Write preservation property tests (BEFORE implementing fixes)
  - **Property 2: Preservation** - Non-Buggy Gameplay Behavior
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy inputs
  - Write property-based tests capturing observed behavior patterns from Preservation Requirements
  - Property-based testing generates many test cases for stronger guarantees
  - Test Preservation 1: Fast-drop during normal gameplay (press down = 0.05s, release = 0.5s) works correctly
  - Test Preservation 2: Win state auto-progress to next level after 3 seconds works correctly
  - Test Preservation 3: Short messages like "Game Over" display correctly without overflow
  - Test Preservation 4: Pause/resume functionality works correctly
  - Test Preservation 5: Level unlock and save system works correctly
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10_

- [x] 3. Fix for level progression bugs

  - [x] 3.1 Fix Bug 1 - Reset fall_speed on level initialization
    - Open `scripts/game_board.gd`
    - In `initialize_level()` function, add `fall_speed = 0.5` after the function signature (around line 96)
    - This ensures every level starts with normal drop speed regardless of previous input state
    - _Bug_Condition: isBugCondition_DropSpeed(input) where input.levelNumber IN [1,2,3] AND fall_speed != 0.5_
    - _Expected_Behavior: fall_speed == 0.5 after initialize_level() is called_
    - _Preservation: Fast-drop functionality during gameplay must continue to work (Requirements 3.3, 3.4)_
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 3.2 Fix Bug 2 - Enable text wrapping for MessageLabel
    - Open `scripts/game_ui.gd`
    - In `_ready()` function, add configuration for message_label node
    - Set `message_label.autowrap_mode = TextServer.AUTOWRAP_WORD`
    - Set `message_label.custom_minimum_size = Vector2(800, 150)` to allow wrapping and multiple lines
    - This ensures long messages are fully visible and readable
    - _Bug_Condition: isBugCondition_NotificationOverflow(input) where input.messageText.length() > 12_
    - _Expected_Behavior: messageIsFullyVisible(result) for all message lengths_
    - _Preservation: Short message display must continue to work correctly (Requirement 3.7)_
    - _Requirements: 2.4, 2.5, 2.6_

  - [x] 3.3 Fix Bug 3 - Add automatic routing from LOSS state to main menu
    - Open `scripts/main.gd`
    - In `_on_state_changed_for_ui()` function, modify the `GameState.State.LOSS` case (around line 119)
    - After `game_ui.show_message("Game Over - The elements remain angry")`, add auto-routing logic
    - Add `await get_tree().create_timer(3.0).timeout` to wait 3 seconds
    - Add `if game_state: game_state.return_to_menu()` to transition back to main menu
    - This completes the game over flow by routing player back to main menu
    - _Bug_Condition: isBugCondition_GameOverRouting(input) where input.newState == LOSS AND NOT scheduledTransitionToMenu()_
    - _Expected_Behavior: GameState.current_state == MENU after 3 seconds_
    - _Preservation: WIN state auto-progress must continue to work (Requirements 3.1, 3.2)_
    - _Requirements: 2.7, 2.8_

  - [x] 3.4 Verify bug condition exploration tests now pass
    - **Property 1: Expected Behavior** - Level Progression Bugs Fixed
    - **IMPORTANT**: Re-run the SAME tests from task 1 - do NOT write new tests
    - The tests from task 1 encode the expected behavior
    - When these tests pass, it confirms the expected behavior is satisfied
    - Run bug condition exploration tests from step 1
    - **EXPECTED OUTCOME**: Tests PASS (confirms bugs are fixed)
    - Verify Bug 1 test passes: fall_speed resets to 0.5 on level start
    - Verify Bug 2 test passes: long messages display fully without overflow
    - Verify Bug 3 test passes: LOSS state auto-routes to MENU after 3 seconds
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8_

  - [x] 3.5 Verify preservation tests still pass
    - **Property 2: Preservation** - Non-Buggy Gameplay Behavior Preserved
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm fast-drop during gameplay still works correctly
    - Confirm win state auto-progress still works correctly
    - Confirm short message display still works correctly
    - Confirm pause/resume functionality still works correctly
    - Confirm level unlock and save system still works correctly
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10_

- [x] 4. Checkpoint - Ensure all tests pass
  - Run all exploration tests and verify they pass (bugs are fixed)
  - Run all preservation tests and verify they pass (no regressions)
  - Manually test the game flow: complete levels with fast-drop, trigger game over, verify messages display correctly
  - Ensure all tests pass, ask the user if questions arise
