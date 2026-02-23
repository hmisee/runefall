extends Node2D
class_name Element

enum ElementType { FIRE, WATER, EARTH, AIR }

@export var element_type: ElementType = ElementType.FIRE
@export var grid_x: int = 0
@export var grid_y: int = 0

var sprite_node: Node2D  # Either Sprite2D or ColorRect for fallback
var colors = {
	ElementType.FIRE: Color.RED,
	ElementType.WATER: Color.BLUE,
	ElementType.EARTH: Color.SADDLE_BROWN,
	ElementType.AIR: Color.LIGHT_GRAY
}

func _ready():
	_create_visual_representation()

func _create_visual_representation():
	# Request sprite from SpriteManager using "element" piece type
	var sprite_texture = SpriteManager.get_sprite(element_type, "element")
	
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
	# Draw a circle for elements (angry faces)
	draw_circle(Vector2.ZERO, 20, colors[element_type])
	draw_arc(Vector2.ZERO, 20, 0, TAU, 32, Color.WHITE, 2)

func set_element_type(type: ElementType):
	element_type = type
	
	# Update visual representation based on current mode
	if sprite_node and sprite_node is Sprite2D:
		# Sprite mode - update the sprite texture
		var sprite_texture = SpriteManager.get_sprite(element_type, "element")
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
