extends GutTest
# Preservation Property Tests for Level Start Cleanup Bug
# **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**
#
# IMPORTANT: These tests verify normal gameplay mechanics remain unchanged
# They should PASS on UNFIXED code to establish baseline behavior
# 
# These tests do NOT call initialize_level() - they test normal gameplay only

const GameBoard = preload("res://scripts/game_board.gd")
const RunePair = preload("res://scripts/rune_pair.gd")
const Rune = preload("res://scripts/rune.gd")
const Element = preload("res://scripts/element.gd")

var game_board: GameBoard

func setup_minimal_board():
	# Create a minimal board without calling initialize_level
	game_board = GameBoard.new()
	game_board.initialize_grid()

func cleanup_game_board():
	if game_board:
		game_board.queue_free()
		game_board = null

func run_tests():
	print("\n=== PRESERVATION PROPERTY TESTS ===")
	print("Testing that normal gameplay mechanics remain unchanged\n")
	
	print("--- Test 1: Pair spawning uses preview data correctly ---")
	setup_minimal_board()
	test_pair_spawning_uses_preview()
	cleanup_game_board()
	
	print("\n--- Test 2: Gravity application works correctly ---")
	setup_minimal_board()
	test_gravity_application()
	cleanup_game_board()
	
	print("\n--- Test 3: Match detection works correctly ---")
	setup_minimal_board()
	test_match_detection()
	cleanup_game_board()
	
	print("\n--- Test 4: Preview generation during gameplay ---")
	setup_minimal_board()
	test_preview_generation()
	cleanup_game_board()

# Property Test 1: Pair spawning during gameplay uses preview data correctly
# EXPECTED: This test PASSES on unfixed code (baseline behavior)
func test_pair_spawning_uses_preview():
	print("Testing that spawn_new_pair() uses preview data correctly during gameplay")
	
	# Set up specific preview data
	game_board.next_rune_pair_data = {
		"rune1_type": 2,  # Earth
		"rune2_type": 3,  # Air
		"rotation": 0
	}
	
	print("Set preview data: rune1_type=2 (Earth), rune2_type=3 (Air)")
	
	# Enable game to allow spawning
	game_board.game_active = true
	
	# Spawn a new pair (normal gameplay, not initialize_level)
	game_board.spawn_new_pair()
	
	# Verify the spawned pair uses the preview data
	var spawned_pair = game_board.current_pair
	assert_true(spawned_pair != null, "A pair should be spawned")
	
	if spawned_pair:
		# Check that preview data was set on the pair
		assert_true(spawned_pair.use_preview_data, "Pair should use preview data")
		assert_eq(spawned_pair.preview_rune1_type, 2, "Preview rune1 should be Earth")
		assert_eq(spawned_pair.preview_rune2_type, 3, "Preview rune2 should be Air")
		print("✓ Pair spawning correctly uses preview data")

# Property Test 2: Gravity application works correctly during gameplay
# EXPECTED: This test PASSES on unfixed code (baseline behavior)
func test_gravity_application():
	print("Testing that gravity works correctly during normal gameplay")
	
	# Place a rune with empty space below it
	var test_rune = Rune.new()
	test_rune.rune_type = 1
	test_rune.grid_x = 3
	test_rune.grid_y = 5
	test_rune.position = game_board.grid_to_world(3, 5)
	game_board.add_child(test_rune)
	game_board.grid[5][3] = test_rune
	
	# Ensure space below is empty
	game_board.grid[6][3] = null
	
	print("Placed rune at (3, 5) with empty space at (3, 6)")
	
	# Apply gravity once
	var pieces_fell = game_board.apply_gravity_once()
	
	print("Gravity applied, pieces_fell=", pieces_fell)
	
	# Verify the rune fell
	assert_true(pieces_fell, "Rune should fall when space below is empty")
	assert_eq(test_rune.grid_y, 6, "Rune should be at y=6 after falling")
	assert_true(game_board.grid[5][3] == null, "Original position should be empty")
	assert_eq(game_board.grid[6][3], test_rune, "New position should contain the rune")
	print("✓ Gravity correctly moves runes downward")

# Property Test 3: Match detection works correctly during gameplay
# EXPECTED: This test PASSES on unfixed code (baseline behavior)
func test_match_detection():
	print("Testing that match detection works correctly during normal gameplay")
	
	# Create a horizontal match of 4 runes
	for i in range(4):
		var rune = Rune.new()
		rune.rune_type = 0  # All Fire type
		rune.grid_x = i
		rune.grid_y = 10
		rune.position = game_board.grid_to_world(i, 10)
		game_board.add_child(rune)
		game_board.grid[10][i] = rune
	
	print("Created horizontal match of 4 Fire runes at y=10")
	
	# Count runes before match detection
	var runes_before = count_runes_in_grid()
	print("Runes before match detection: ", runes_before)
	assert_eq(runes_before, 4, "Should have 4 runes before match detection")
	
	# Check and remove matches (without triggering win condition)
	var matches_found = game_board.check_and_remove_matches()
	
	print("Matches found: ", matches_found)
	
	# Verify matches were detected and removed
	assert_true(matches_found, "Match should be detected")
	
	# Count runes after match detection
	var runes_after = count_runes_in_grid()
	print("Runes after match detection: ", runes_after)
	assert_eq(runes_after, 0, "All matched runes should be removed")
	print("✓ Match detection correctly identifies and removes matches")

# Property Test 4: Preview generation during gameplay works correctly
# EXPECTED: This test PASSES on unfixed code (baseline behavior)
func test_preview_generation():
	print("Testing that preview generation works correctly during normal gameplay")
	
	# Generate preview data multiple times
	var preview1 = game_board.generate_next_pair_data()
	var preview2 = game_board.generate_next_pair_data()
	var preview3 = game_board.generate_next_pair_data()
	
	print("Generated 3 preview data sets")
	print("Preview 1: rune1_type=", preview1["rune1_type"], ", rune2_type=", preview1["rune2_type"])
	print("Preview 2: rune1_type=", preview2["rune1_type"], ", rune2_type=", preview2["rune2_type"])
	print("Preview 3: rune1_type=", preview3["rune1_type"], ", rune2_type=", preview3["rune2_type"])
	
	# Verify preview data structure
	assert_true(preview1.has("rune1_type"), "Preview should have rune1_type")
	assert_true(preview1.has("rune2_type"), "Preview should have rune2_type")
	assert_true(preview1.has("rotation"), "Preview should have rotation")
	
	# Verify types are in valid range (0-3 for 4 rune types)
	assert_true(preview1["rune1_type"] >= 0 and preview1["rune1_type"] <= 3, "rune1_type should be 0-3")
	assert_true(preview1["rune2_type"] >= 0 and preview1["rune2_type"] <= 3, "rune2_type should be 0-3")
	assert_eq(preview1["rotation"], 0, "rotation should be 0")
	
	print("✓ Preview generation produces valid data structures")

# Helper function to count runes in the grid
func count_runes_in_grid() -> int:
	var count = 0
	for y in range(game_board.GRID_HEIGHT):
		for x in range(game_board.GRID_WIDTH):
			if game_board.grid[y][x] != null and game_board.grid[y][x] is Rune:
				count += 1
	return count
