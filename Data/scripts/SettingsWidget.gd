tool
extends GridContainer

var _inited = false

enum Widgets {
	BOOL,
	SPINBOX,
}

const SETTINGS = [
	["ENABLEPOSTFX", "config/graphics/enable_post_fx", Widgets.BOOL],
	["ENABLEFULLSCREEN", "config/graphics/fullscreen", Widgets.BOOL],
	[],
	["INVERTMOUSE", "config/controls/invert_mouse_y", Widgets.BOOL],
	["MOUSESENSITIVITY", "config/controls/mouse_sensitivity", Widgets.SPINBOX],
]


func _ready():
	init()
	
func _process(delta):
	if !_inited:
		init()


func init():
	Logging.info("Generating settings menu")
	columns = 2
	_inited = true
	for child in get_children():
		child.queue_free()

	for setting in SETTINGS:
		if setting == []:
			add_child(HSeparator.new())
			add_child(HSeparator.new())
		else:
			var label = Label.new()
			label.size_flags_horizontal = label.SIZE_EXPAND_FILL
			label.text = tr(setting[0])
			add_child(label)
			add_child(generate_widget(setting))


func generate_widget(setting):
	match setting[2]:
		Widgets.BOOL:
			var boolbox = BoolBox.new()
			boolbox.setup(setting)
			return boolbox
		_:
			return Control.new()

class BoolBox extends CheckButton:
	var _config = []
	func setup(config):
		_config = config
		Globals.connect(_config[1], self, "_update_from_globals")
		connect("toggled", self, "_update_from_ui")
		
	func _update_from_globals(val):
		pressed = val
	
	func _update_from_ui(val):
		Logging.debug("Changing setting")
		Globals.set(_config[1], val)