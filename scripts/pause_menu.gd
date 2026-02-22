class_name PauseMenu
extends CanvasLayer

# Signals emitted when user interacts with pause menu
signal resume_requested()
signal main_menu_requested()

# UI node references
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/MainMenuButton

func _ready() -> void:
	# Connect button signals
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	else:
		push_error("PauseMenu: continue_button not found")
	
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	else:
		push_error("PauseMenu: main_menu_button not found")
	
	# Hide by default
	hide_pause()

func show_pause() -> void:
	"""Display the pause menu overlay"""
	visible = true

func hide_pause() -> void:
	"""Hide the pause menu overlay"""
	visible = false

func _on_continue_pressed() -> void:
	"""Handle Continue button press"""
	resume_requested.emit()

func _on_main_menu_pressed() -> void:
	"""Handle Main Menu button press"""
	main_menu_requested.emit()
