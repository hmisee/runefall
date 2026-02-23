extends Node2D
class_name Rune

enum RuneType { FIRE, WATER, EARTH, AIR }

@export var rune_type: RuneType = RuneType.FIRE
@export var grid_x: int = 0
@export var grid_y: int = 0

var sprite_node: Node2D  # Either Sprite2D or ColorRect for fallback
var colors = {
	RuneType.FIRE: Color.RED,
	RuneType.WATER: Color.BLUE,
	RuneType.EARTH: Color.SADDLE_BROWN,
	RuneType.AIR: Color.LIGHT_GRAY
}

func _ready():
	_create_visual_representation()

func _create_visual_representation():
	# Request sprite from SpriteManager
	var sprite_texture = SpriteManager.get_sprite(rune_type, "rune")
	
	if sprite_texture:
		# Sprite is available - create Sprite2D node
		var sprite = Sprite2D.new()
		sprite.texture = sprite_texture
		
		# Scale and center sprite using SpriteManager utility
		SpriteManager.scale_sprite_to_cell(sprite)
		
		# Add sprite node to scene tree
		add_child(sprite)
		sprite_node = sprite
	else:
		# Sprite not available - fallback to current drawing method
		queue_redraw()

func _draw():
	# Draw a square for runes
	var size = 18
	draw_rect(Rect2(-size, -size, size * 2, size * 2), colors[rune_type])
	draw_rect(Rect2(-size, -size, size * 2, size * 2), Color.WHITE, false, 2)

func set_rune_type(type: RuneType):
	rune_type = type
	
	# Update visual representation based on current mode
	if sprite_node and sprite_node is Sprite2D:
		# Sprite mode - update the sprite texture
		var sprite_texture = SpriteManager.get_sprite(rune_type, "rune")
		if sprite_texture:
			sprite_node.texture = sprite_texture
		else:
			# Sprite no longer available, switch to fallback
			sprite_node.queue_free()
			sprite_node = null
			queue_redraw()
	else:
		# Fallback mode - trigger redraw
		queue_redraw()
