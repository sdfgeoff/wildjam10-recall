extends Spatial

export(NodePath) var target_position = ""
export(NodePath) var collision_shape_path = ""
export(NodePath) var mesh_obj = ""

const ambiance_sound = preload("res://sounds/midhum.wav")
const can_complete_sound = preload("res://sounds/ventilator.wav")
const achieved_sound = preload("res://sounds/clank.wav")

var _inited = false
var mat = null
var complete = false
var _ambiance_player: AudioStreamPlayer3D = null
var _achieved_player: AudioStreamPlayer3D = null
var _achieve_distance = 10.0

func _ready():
	_inited = true
	mat = get_node(mesh_obj).mesh.surface_get_material(0).duplicate()
	get_node(mesh_obj).set_surface_material(0, mat)
	
	
	_ambiance_player = AudioStreamPlayer3D.new()
	get_node(target_position).add_child(_ambiance_player)
	_ambiance_player.global_transform = global_transform
	_ambiance_player.stream = ambiance_sound
	_ambiance_player.play()
	
	_achieved_player = AudioStreamPlayer3D.new()
	get_node(target_position).add_child(_achieved_player)
	_achieved_player.global_transform = global_transform
	_achieved_player.stream = achieved_sound
	_achieved_player.unit_db = 10.0
	
	add_to_group("targets")
	
	call_deferred("set_complete", false)


func get_achieve_distance():
	return _achieve_distance


func _process(_delta):
	if !complete:
		var can_achieve = _do_distort()
		if can_achieve and Input.is_action_just_pressed("summon"):
			set_complete(true)
	else:
		
		if _ambiance_player.unit_db < -100.0:
			_ambiance_player.stop()
		else:
			_ambiance_player.unit_db -= 0.2
			_ambiance_player.pitch_scale = clamp(_ambiance_player.pitch_scale - 0.2, 0.01, 2.0)



func _do_distort():
	var can_achieve = false
	var camera = get_viewport().get_camera()
	var cam_to_target = get_node(target_position).global_transform.origin - camera.global_transform.origin
	var cam_to_self = camera.global_transform.origin - global_transform.origin
	var camera_view = camera.global_transform.basis.z
	#print(cam_to_target)
	
	cam_to_target.y *= 0.5
	var dist_to_target = cam_to_target.length()
	var angle_to_target = camera_view.normalized().angle_to(cam_to_self.normalized())
	var distort_amount = dist_to_target + abs(angle_to_target)
	_ambiance_player.pitch_scale = 1/distort_amount
	distort_amount = pow(distort_amount* 0.5, 3.0)
	
	if distort_amount < 0.3:
		can_achieve = true
		
	_achieve_distance = distort_amount
	
	if can_achieve:
		if _ambiance_player.stream != can_complete_sound:
			_ambiance_player.stream = can_complete_sound
			_ambiance_player.play()
	else:
		
		if _ambiance_player.stream != ambiance_sound:
			_ambiance_player.stream = ambiance_sound
			_ambiance_player.play()

	mat.set_shader_param("distort_amount", distort_amount)
	var highlight = mat.get_shader_param("highlight")
	highlight.a = lerp(highlight.a, float(can_achieve), 0.5)
	mat.set_shader_param("highlight", highlight)
	return can_achieve


func set_complete(val):
	complete = val
	if val:
		mat.set_shader_param("distort_amount", 0.0)
		var highlight = mat.get_shader_param("highlight")
		highlight.a = 0.0
		mat.set_shader_param("highlight", highlight)
		_achieved_player.play()
	else:
		_ambiance_player.play()
	get_node(collision_shape_path).disabled = !val
	