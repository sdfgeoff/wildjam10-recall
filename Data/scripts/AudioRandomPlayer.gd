extends AudioStreamPlayer


export (float) var probability = 0.01
export(bool) var enable = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if enable and randf() < probability:
		play()
