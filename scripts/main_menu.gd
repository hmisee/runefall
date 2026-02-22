class_name MainMenu
extends CanvasLayer

# Signals
signal level_selected(level_number: int)
signal quit_requested()

# Node references
@onready var level_buttons_container: VBoxContainer = $CenterContainer/VBoxContainer/LevelButtonsContainer
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel

# State
var level_buttons: Array[Button] = []
const MAX_LEVELS: int = 3

# Level configuration (matches GameBoard.LEVEL_CONFIG)
const LEVEL_CONFIG = {
	1: { "elements": 10, "name": "Calm Beginnings" },
	2: { "elements": 15, "name": "Rising Chaos" },
	3: { "elements": 20, "name": "Elemental Storm" }
}

func _ready() -> void:
	hide()

# Initialize menu with level buttons
func initialize(max_unlocked: int) -> void:
	# Clear existing buttons
	for button in level_buttons:
		button.queue_free()
	level_buttons.clear()
	
	# Create buttons for each level
	for level_num in range(1, MAX_LEVELS + 1):
		var button = Button.new()
		var level_info = LEVEL_CONFIG[level_num]
		button.text = "Level %d: %s" % [level_num, level_info["name"]]
		button.custom_minimum_size = Vector2(300, 50)
		
		# Connect button signal
		button.pressed.connect(_on_level_button_pressed.bind(level_num))
		
		# Add to container
		level_buttons_container.add_child(button)
		level_buttons.append(button)
	
	# Add Exit button after level buttons
	var exit_button = Button.new()
	exit_button.text = "Exit"
	exit_button.custom_minimum_size = Vector2(300, 50)
	exit_button.pressed.connect(_on_exit_button_pressed)
	level_buttons_container.add_child(exit_button)
	
	# Update unlock state
	update_unlock_state(max_unlocked)

# Update which levels are enabled/disabled
func update_unlock_state(max_unlocked: int) -> void:
	for i in range(level_buttons.size()):
		var level_num = i + 1
		var button = level_buttons[i]
		button.disabled = level_num > max_unlocked
		
		# Visual feedback for locked levels
		if button.disabled:
			button.text = "🔒 " + button.text.replace("🔒 ", "")
		else:
			button.text = button.text.replace("🔒 ", "")

# Show the menu
func show_menu() -> void:
	show()

# Hide the menu
func hide_menu() -> void:
	hide()

# Button press handler
func _on_level_button_pressed(level_number: int) -> void:
	level_selected.emit(level_number)

# Exit button press handler
func _on_exit_button_pressed() -> void:
	quit_requested.emit()
