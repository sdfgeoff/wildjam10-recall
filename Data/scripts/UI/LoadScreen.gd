extends Panel

export (NodePath) var progress_bar = ""

var _complete = false

func _ready():
	set_progress(0)

func set_complete():
	_complete = true

func set_progress(percent: float):
	get_node(progress_bar).value = int(percent * 100)
	modulate.a = 1.0
	_complete = false


func _process(delta):
	if _complete:
		if modulate.a > 0.05:
			modulate.a -= 0.05
		else:
			modulate.a = 0