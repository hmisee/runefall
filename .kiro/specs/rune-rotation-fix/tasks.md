# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Fault Condition** - Rotation Collision Validation
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate rotation ignores collision and bounds checking
  - **Scoped PBT Approach**: Scope the property to concrete failing cases: rotation at right edge (x=7 horizontal), rotation with collision below
  - Test that rotation at x=7 horizontal is blocked or wall-kicked (should fail on unfixed code - rotation succeeds placing rune2 out of bounds)
  - Test that rotation with piece below is blocked or wall-kicked (should fail on unfixed code - rotation succeeds causing overlap)
  - Test that valid rotation in open space succeeds (should pass on both unfixed and fixed code)
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found (e.g., "rotation at x=7 horizontal places rune2 at x=8 which is out of bounds")
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Non-Rotation Input Behavior
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-rotation inputs (movement, locking, matching)
  - Observe: Left/right movement works with collision checking
  - Observe: Automatic fall and down-key acceleration work correctly
  - Observe: Pairs lock and separate into individual runes correctly
  - Observe: Match-4 detection works after pairs lock
  - Write property-based tests capturing observed behavior patterns for movement, locking, and matching
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 3. Fix for rune rotation collision validation

  - [x] 3.1 Update can_place_pair() to accept optional orientation parameter
    - Add parameter: `orientation: bool = current_pair.is_horizontal`
    - Use this parameter instead of current_pair.is_horizontal when calculating positions
    - This allows testing hypothetical rotations without modifying state
    - _Bug_Condition: isBugCondition(input) where naive rotation would cause out-of-bounds or collision_
    - _Expected_Behavior: Rotation succeeds with wall-kick or is blocked if no valid position exists_
    - _Preservation: Movement, locking, matching behavior unchanged_
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [x] 3.2 Update get_pair_positions() to accept optional orientation parameter
    - Add parameter: `orientation: bool = current_pair.is_horizontal`
    - Use this parameter instead of current_pair.is_horizontal when calculating positions
    - _Bug_Condition: isBugCondition(input) where naive rotation would cause out-of-bounds or collision_
    - _Expected_Behavior: Rotation succeeds with wall-kick or is blocked if no valid position exists_
    - _Preservation: Movement, locking, matching behavior unchanged_
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [x] 3.3 Add rotate_current_pair() function to GameBoard
    - Check if naive rotation (same grid_x, toggled orientation) is valid using can_place_pair()
    - If invalid, attempt wall-kick: try grid_x - 1, then grid_x + 1
    - If any position is valid, apply rotation by calling current_pair.rotate_pair() and update grid_x if needed
    - If no valid position, block rotation (do nothing)
    - _Bug_Condition: isBugCondition(input) where naive rotation would cause out-of-bounds or collision_
    - _Expected_Behavior: Rotation succeeds with wall-kick or is blocked if no valid position exists_
    - _Preservation: Movement, locking, matching behavior unchanged_
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [x] 3.4 Modify handle_input() to call rotate_current_pair()
    - Replace `current_pair.rotate_pair()` with `rotate_current_pair()` in ui_up handler
    - _Bug_Condition: isBugCondition(input) where naive rotation would cause out-of-bounds or collision_
    - _Expected_Behavior: Rotation succeeds with wall-kick or is blocked if no valid position exists_
    - _Preservation: Movement, locking, matching behavior unchanged_
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [x] 3.5 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Rotation Collision Validation
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [x] 3.6 Verify preservation tests still pass
    - **Property 2: Preservation** - Non-Rotation Input Behavior
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm all tests still pass after fix (no regressions)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise
