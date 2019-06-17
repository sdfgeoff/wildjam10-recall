extends TabContainer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false

func _start():
	Logging.info("Starting Game")
	get_tree().change_scene(defs.PLAY_SCENE)

func _quit():
	Logging.info("Quitting from main menu")
	get_tree().quit()

func _go_to_settings():
	Logging.info("Showing Settings")
	current_tab = 1

func _go_to_main():
	current_tab = 0
