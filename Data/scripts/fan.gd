extends Spatial

export (NodePath) var fanblades = ""
export (float) var speed = 0.5

export (AudioStream) var motor_sound = preload("res://sounds/fan.wav")
#export (AudioStream) var blade_sound = null
#export (float) var blade_sound_angle_delta = deg2rad(60)

var _motor_sound = null

func _ready():
	_motor_sound = AudioStreamPlayer3D.new()
	add_child(_motor_sound)
	_motor_sound.stream = motor_sound
	_motor_sound.play()
	_motor_sound.unit_db = 5.0


func _process(delta):
	get_node(fanblades).rotation.y += delta * speed
