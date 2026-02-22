# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Fault Condition** - Clean Board on Level Start
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: Scope the property to concrete failing cases - level initialization with existing nodes
  - Test that `initialize_level()` removes all RunePair, Rune, and Element nodes when called with existing nodes in scene tree
  - Test cases: stale rune pairs, stale individual runes, stale elements
  - The test assertions should verify all old nodes are removed and preview matches spawned pair
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found (e.g., "RunePair nodes remain visible after initialize_level() call")
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.1, 2.2, 2.3_

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Gameplay Mechanics Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for normal gameplay (not calling initialize_level)
  - Test cases: pair spawning during gameplay, gravity application, match detection, preview generation during gameplay
  - Write property-based tests capturing observed behavior patterns
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 3. Fix for level start cleanup bug

  - [x] 3.1 Implement the fix in game_board.gd
    - Add cleanup_board() function to remove all RunePair, Rune, and Element child nodes
    - Call cleanup_board() at the start of initialize_grid()
    - Use get_children() to iterate through all child nodes
    - Check each child's type using `is` operator (RunePair, Rune, Element)
    - Call queue_free() on matching nodes
    - Verify next_rune_pair_data is generated before first spawn_new_pair() call
    - _Bug_Condition: isBugCondition(input) where input.initialize_level_called == true AND (input.has_existing_rune_pairs OR input.has_existing_runes OR input.has_existing_elements)_
    - _Expected_Behavior: all_old_nodes_removed(result) AND preview_matches_spawned_pair(result)_
    - _Preservation: Normal gameplay mechanics (pair spawning, gravity, matching, preview generation) must remain unchanged_
    - _Requirements: 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 3.4, 3.5_

  - [x] 3.2 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Clean Board on Level Start
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 3.3 Verify preservation tests still pass
    - **Property 2: Preservation** - Gameplay Mechanics Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm all tests still pass after fix (no regressions)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 4. Checkpoint - Ensure all tests pass and verify in Godot
  - Ensure all tests pass
  - **IMPORTANT**: Test the game in Godot editor to verify the changes work correctly
  - Test scenario: Start level 1 → play → return to menu → start level 1 again
  - Verify: Board is clean, no stale runes/elements visible, preview matches spawned pair
  - Ask the user if questions arise
