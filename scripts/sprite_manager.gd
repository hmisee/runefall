extends Node

# Sprite cache structure: { ElementType: { "rune": Texture2D, "element": Texture2D } }
var sprite_cache: Dictionary = {}
var missing_sprites: Array[String] = []

# Element type names for path generation
const TYPE_NAMES = {
	0: "fire",    # Rune.RuneType.FIRE / Element.ElementType.FIRE
	1: "water",   # Rune.RuneType.WATER / Element.ElementType.WATER
	2: "earth",   # Rune.RuneType.EARTH / Element.ElementType.EARTH
	3: "air"      # Rune.RuneType.AIR / Element.ElementType.AIR
}

# Piece types
const PIECE_TYPES = ["rune", "element"]

func _ready() -> void:
	_load_all_sprites()

func _load_all_sprites() -> void:
	# Initialize sprite cache for each element type
	for element_type in TYPE_NAMES.keys():
		sprite_cache[element_type] = {}
		
		for piece_type in PIECE_TYPES:
			var sprite_path = _generate_sprite_path(element_type, piece_type)
			var texture = _load_sprite(sprite_path)
			
			# Always add the key to the cache, even if texture is null
			sprite_cache[element_type][piece_type] = texture
			
			if not texture:
				missing_sprites.append(sprite_path)
				push_warning("SpriteManager: Failed to load sprite at %s" % sprite_path)

func _generate_sprite_path(element_type: int, piece_type: String) -> String:
	var type_name = TYPE_NAMES.get(element_type, "fire")
	return "res://assets/sprites/%s/%s_%s.png" % [type_name, type_name, piece_type]

func _load_sprite(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var texture = load(path)
		if texture is Texture2D:
			return texture
	return null

func get_sprite(element_type: int, piece_type: String) -> Texture2D:
	if sprite_cache.has(element_type) and sprite_cache[element_type].has(piece_type):
		return sprite_cache[element_type][piece_type]
	return null

func has_sprite(element_type: int, piece_type: String) -> bool:
	return get_sprite(element_type, piece_type) != null

func get_missing_sprites() -> Array[String]:
	return missing_sprites

# Scale a sprite to fit within CELL_SIZE while maintaining aspect ratio
# This function modifies the sprite's scale property to fit within the grid cell
func scale_sprite_to_cell(sprite: Sprite2D) -> void:
	if not sprite or not sprite.texture:
		push_warning("SpriteManager: Cannot scale sprite - sprite or texture is null")
		return
	
	var texture_size = sprite.texture.get_size()
	var max_dimension = max(texture_size.x, texture_size.y)
	
	# Avoid division by zero
	if max_dimension == 0:
		push_warning("SpriteManager: Cannot scale sprite - texture has zero dimensions")
		return
	
	# Calculate scale factor to fit within CELL_SIZE
	# Using GameBoard.CELL_SIZE constant (50 pixels)
	var scale_factor = GameBoard.CELL_SIZE / max_dimension
	sprite.scale = Vector2(scale_factor, scale_factor)
	
	# Center the sprite within the cell
	# Sprite2D uses centered origin by default, so position offset is not needed
	# The sprite will be centered at its parent's position (0,0 relative to parent)
