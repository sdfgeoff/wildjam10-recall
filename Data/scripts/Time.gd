extends Label

var start_time = 0.0

func _ready():
	start_time = OS.get_ticks_msec()

func _process(delta):
	var delta_time = OS.get_ticks_msec() - start_time
	text = "%.1f" % (delta_time / 1000.0)
