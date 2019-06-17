extends AudioStreamPlayer


export (float) var base_volume = -40
export (float) var stability_factor = 0.01
export (float) var brownian_motion = 0.5
export (float) var volume_pitch_coupling = 0.1

func _ready():
	volume_db = base_volume

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var change = (randf() * 2.0 - 1.0) * brownian_motion
	volume_db = lerp(volume_db + change, base_volume, stability_factor)
	var vol_offset = volume_db - base_volume
	pitch_scale = clamp(vol_offset * volume_pitch_coupling + 1.0, 0.01, 2.0)
