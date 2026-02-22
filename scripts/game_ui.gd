extends CanvasLayer
class_name GameUI

# Node references
@onready var message_label: Label = $MessageLabel
@onready var preview_container: Panel = $PreviewContainer
@onready var preview_label: Label = $PreviewLabel
@onready var level_label: Label = $LevelLabel
@onready var elements_label: Label = $ElementsLabel

# Constants for rune colors (matching game_board.gd types)
const RUNE_COLORS = [
	Color(1.0, 0.3, 0.3),  # 0: Fire (red)
	Color(0.3, 0.5, 1.0),  # 1: Water (blue)
	Color(0.6, 0.4, 0.2),  # 2: Earth (brown)
	Color(0.8, 0.8, 0.8)   # 3: Air (light gray)
]

const PREVIEW_RUNE_SIZE = 30

func _ready():
	# Hide message by default
	if message_label:
		message_label.hide()

func show_message(text: String, duration: float = 0.0) -> void:
	if not message_label:
		return
	
	message_label.text = text
	message_label.show()
	
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout
		hide_message()

func hide_message() -> void:
	if message_label:
		message_label.hide()

func update_preview(rune1_type: int, rune2_type: int, rotation: int) -> void:
	if not preview_container:
		return
	
	# Clear existing preview
	for child in preview_container.get_children():
		child.queue_free()
	
	# Draw preview based on rotation
	var rune1_color = RUNE_COLORS[rune1_type]
	var rune2_color = RUNE_COLORS[rune2_type]
	
	# Create ColorRect nodes for visual representation
	var rune1_rect = ColorRect.new()
	rune1_rect.color = rune1_color
	rune1_rect.custom_minimum_size = Vector2(PREVIEW_RUNE_SIZE, PREVIEW_RUNE_SIZE)
	
	var rune2_rect = ColorRect.new()
	rune2_rect.color = rune2_color
	rune2_rect.custom_minimum_size = Vector2(PREVIEW_RUNE_SIZE, PREVIEW_RUNE_SIZE)
	
	# Position based on rotation
	match rotation:
		0:  # Horizontal: rune1 left, rune2 right
			rune1_rect.position = Vector2(0, 0)
			rune2_rect.position = Vector2(PREVIEW_RUNE_SIZE + 5, 0)
		1:  # Vertical: rune1 top, rune2 bottom
			rune1_rect.position = Vector2(0, 0)
			rune2_rect.position = Vector2(0, PREVIEW_RUNE_SIZE + 5)
		2:  # Horizontal: rune2 left, rune1 right
			rune2_rect.position = Vector2(0, 0)
			rune1_rect.position = Vector2(PREVIEW_RUNE_SIZE + 5, 0)
		3:  # Vertical: rune2 top, rune1 bottom
			rune2_rect.position = Vector2(0, 0)
			rune1_rect.position = Vector2(0, PREVIEW_RUNE_SIZE + 5)
	
	preview_container.add_child(rune1_rect)
	preview_container.add_child(rune2_rect)

func update_level_display(level: int) -> void:
	if level_label:
		level_label.text = "Level: " + str(level)

func update_elements_count(count: int) -> void:
	if elements_label:
		elements_label.text = "Elements: " + str(count)
