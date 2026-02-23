extends Node

## Manual integration test for Task 14.1
## This test manually verifies the complete background flow
## Run by adding this script to a scene and running it

func _ready():
	print("\n=== Manual Background Flow Test ===\n")
	
	# Wait for autoloads to initialize
	await get_tree().create_timer(0.5).timeout
	
	# Get autoloads
	var bg_manager = get_node("/root/BackgroundManager")
	var game_state = get_node("/root/GameState")
	
	print("Step 1: Verify autoloads exist")
	print("  Background_Manager: ", "OK" if bg_manager else "MISSING")
	print("  GameState: ", "OK" if game_state else "MISSING")
	
	if not bg_manager or not game_state:
		print("\n✗ FAIL: Required autoloads not found")
		return
	
	print("\nStep 2: Load menu background")
	bg_manager.load_menu_background()
	await get_tree().create_timer(0.2).timeout
	print("  Current background: ", bg_manager.get_current_background_id())
	print("  Background loaded: ", "YES" if bg_manager.is_background_loaded() else "NO")
	
	print("\nStep 3: Transition to Level 1")
	game_state.start_level(1)
	await get_tree().create_timer(0.2).timeout
	print("  Current background: ", bg_manager.get_current_background_id())
	print("  Background loaded: ", "YES" if bg_manager.is_background_loaded() else "NO")
	
	print("\nStep 4: Transition to Level 2")
	game_state.complete_level()
	await get_tree().create_timer(0.2).timeout
	game_state.start_level(2)
	await get_tree().create_timer(0.2).timeout
	print("  Current background: ", bg_manager.get_current_background_id())
	print("  Background loaded: ", "YES" if bg_manager.is_background_loaded() else "NO")
	
	print("\nStep 5: Transition to Level 3")
	game_state.complete_level()
	await get_tree().create_timer(0.2).timeout
	game_state.start_level(3)
	await get_tree().create_timer(0.2).timeout
	print("  Current background: ", bg_manager.get_current_background_id())
	print("  Background loaded: ", "YES" if bg_manager.is_background_loaded() else "NO")
	
	print("\nStep 6: Return to menu")
	game_state.return_to_menu()
	await get_tree().create_timer(0.2).timeout
	print("  Current background: ", bg_manager.get_current_background_id())
	print("  Background loaded: ", "YES" if bg_manager.is_background_loaded() else "NO")
	
	print("\n=== Test Complete ===")
	print("All transitions executed successfully!")
	print("\nVerify visually that:")
	print("  - All backgrounds loaded without errors")
	print("  - Transitions were smooth (no flicker)")
	print("  - Menu background is animated")
	print("  - Level backgrounds are static and themed correctly")
	
	# Exit after a moment
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
