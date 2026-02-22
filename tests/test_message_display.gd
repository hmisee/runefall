extends GdUnitTestSuite

# Test suite for GameUI message display functionality
# Feature: game-completion-and-progression, Task 10.1

func test_show_message_displays_text():
	# Arrange
	var game_ui = auto_free(load("res://scenes/game_ui.tscn").instantiate())
	add_child(game_ui)
	
	# Act
	game_ui.show_message("Test Message")
	
	# Assert
	assert_bool(game_ui.message_label.visible).is_true()
	assert_str(game_ui.message_label.text).is_equal("Test Message")

func test_show_message_with_duration_auto_hides():
	# Arrange
	var game_ui = auto_free(load("res://scenes/game_ui.tscn").instantiate())
	add_child(game_ui)
	
	# Act
	game_ui.show_message("Temporary Message", 0.5)
	
	# Assert - message should be visible initially
	assert_bool(game_ui.message_label.visible).is_true()
	
	# Wait for duration to elapse
	await get_tree().create_timer(0.6).timeout
	
	# Assert - message should be hidden after duration
	assert_bool(game_ui.message_label.visible).is_false()

func test_hide_message_hides_label():
	# Arrange
	var game_ui = auto_free(load("res://scenes/game_ui.tscn").instantiate())
	add_child(game_ui)
	game_ui.show_message("Visible Message")
	
	# Act
	game_ui.hide_message()
	
	# Assert
	assert_bool(game_ui.message_label.visible).is_false()

func test_message_label_is_centered():
	# Arrange
	var game_ui = auto_free(load("res://scenes/game_ui.tscn").instantiate())
	add_child(game_ui)
	
	# Assert - check that label is centered
	assert_float(game_ui.message_label.anchor_left).is_equal(0.5)
	assert_float(game_ui.message_label.anchor_top).is_equal(0.5)
	assert_int(game_ui.message_label.horizontal_alignment).is_equal(HORIZONTAL_ALIGNMENT_CENTER)
	assert_int(game_ui.message_label.vertical_alignment).is_equal(VERTICAL_ALIGNMENT_CENTER)

func test_message_label_has_large_font():
	# Arrange
	var game_ui = auto_free(load("res://scenes/game_ui.tscn").instantiate())
	add_child(game_ui)
	
	# Assert - font size should be 48 for high visibility
	var font_size = game_ui.message_label.get_theme_font_size("font_size")
	assert_int(font_size).is_equal(48)

func test_message_label_has_outline_for_visibility():
	# Arrange
	var game_ui = auto_free(load("res://scenes/game_ui.tscn").instantiate())
	add_child(game_ui)
	
	# Assert - should have outline for better visibility
	var outline_size = game_ui.message_label.get_theme_constant("outline_size")
	assert_int(outline_size).is_equal(8)
