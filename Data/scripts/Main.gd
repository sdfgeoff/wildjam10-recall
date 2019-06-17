extends Control

export(NodePath) var world_owner = ""
export(NodePath) var load_screen = ""
export(NodePath) var pause_menu = ""
export(NodePath) var filter = ""
export(NodePath) var stability_label = ""

enum States {
	LOADING,
	PLAYING,
	PAUSED
}

var _state = States.LOADING
var _loader = null


func _process(delta):
	match _state:
		States.LOADING:
			_state_loadstate(delta)
			get_tree().paused = true
		States.PLAYING:
			_state_playstate(delta)
			get_tree().paused = false
		States.PAUSED:
			_state_pausedstate(delta)
			get_tree().paused = true


func _state_loadstate(delta):
	get_node(pause_menu).hide()
	if _loader == null:
		Logging.info("Starting loading level")
		var levelnumber = Globals.get("levelnumber")
		if levelnumber < len(defs.LEVELS):
			_loader = preload("res://scripts/BackgroundLoader.gd").new()
			_loader.connect("complete", self, "_load_state_complete")
			_loader.connect("error", self, "_load_state_error")
			_loader.connect("progress", self, "_load_state_progress")
			_loader.start(defs.LEVELS[levelnumber])
		else:
			Logging.error("Requested level outside known levelnumbers")
			get_tree().quit()
	else:
		_loader.update()

func _load_state_complete():
	self._state = States.PLAYING
	get_node(load_screen).set_complete()
	var level = _loader.get_loaded_resource()
	get_node(world_owner).add_child(level.instance())
	for node in get_tree().get_nodes_in_group("exits"):
		node.connect("level_done", self, "_level_complete")

func _load_state_error():
	Logging.info("Loading Failed")
	get_tree().quit()

func _load_state_progress(percent):
	get_node(load_screen).set_progress(percent)


func _state_playstate(delta):
	get_node(pause_menu).hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("ui_cancel"):
		pause()
	
	var warp_strength = 0.0
	for node in get_tree().get_nodes_in_group("targets"):
		if !node.complete:
			warp_strength += 1.0 / (node.get_achieve_distance() + 1.0)
	var hueshift = warp_strength
	get_node(stability_label).text = "%4.1f%%" % (pow(warp_strength, 0.5) * 100.0)
	get_node(filter).set_hueshift(hueshift * 0.05)


func _state_pausedstate(delta):
	get_node(pause_menu).show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("ui_cancel"):
		resume()


func pause():
	if _state == States.PLAYING:
		Logging.info("Pausing")
		self._state = States.PAUSED
	else:
		Logging.warn("Pause from not playing")

func resume():
	if _state == States.PAUSED:
		Logging.info("Resuming")
		self._state = States.PLAYING
	else:
		Logging.warn("Resume from not suspended")


func _level_complete():
	Logging.info("Level Complete")
	var levelnumber = Globals.get("levelnumber")
	if levelnumber + 1 < len(defs.LEVELS):
		Logging.info("Moving to next level")
		Globals.set("levelnumber", levelnumber + 1)
		get_tree().reload_current_scene()
	else:
		Logging.info("Levels finished. Going to main menu")
		_go_to_main_menu()

func _go_to_main_menu():
	get_tree().change_scene(defs.MENU_SCENE)