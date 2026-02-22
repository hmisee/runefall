class_name SaveManager
extends Node

## SaveManager handles persistent storage of level unlock state
## Uses JSON format to save/load player progress

const SAVE_PATH = "user://runefall_save.json"
const SAVE_VERSION = "1.0"


## Save the player's progress to persistent storage
## @param max_unlocked_level: The highest level the player has unlocked
func save_progress(max_unlocked_level: int) -> void:
	var save_data = {
		"max_unlocked_level": max_unlocked_level,
		"version": SAVE_VERSION
	}
	
	var json_string = JSON.stringify(save_data, "\t")
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file == null:
		push_error("SaveManager: Failed to open save file for writing: " + str(FileAccess.get_open_error()))
		return
	
	file.store_string(json_string)
	file.close()
	print("SaveManager: Progress saved (max_unlocked_level: %d)" % max_unlocked_level)


## Load the player's progress from persistent storage
## @return: The max unlocked level, defaults to 1 if no save exists or on error
func load_progress() -> int:
	if not FileAccess.file_exists(SAVE_PATH):
		print("SaveManager: No save file found, defaulting to level 1")
		return 1
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: Failed to open save file: " + str(FileAccess.get_open_error()))
		return 1
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_warning("SaveManager: Failed to parse save file (error: %d)" % parse_result)
		return 1
	
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("SaveManager: Save file data is not a dictionary")
		return 1
	
	var max_unlocked = data.get("max_unlocked_level", 1)
	print("SaveManager: Progress loaded (max_unlocked_level: %d)" % max_unlocked)
	return max_unlocked


## Check if a save file exists
## @return: true if save file exists, false otherwise
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
