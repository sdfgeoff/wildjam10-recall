extends ViewportContainer

var _postfx = null

func _ready():
	_postfx = material
	Globals.connect("config/graphics/enable_post_fx", self, "_set_postfx")

func _set_postfx(val):
	Logging.info("Configuring postfx")
	if !val:
		material = null
	else:
		material = _postfx


func set_hueshift(percent):
	if material != null:
		material.set_shader_param("hue_shift_probability", percent)