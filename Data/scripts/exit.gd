extends Spatial

export(NodePath) var exit_trigger_area = ""

signal level_done


func _ready():
	print("Init Exit Area")
	get_node(exit_trigger_area).connect("body_entered", self, "_level_done")
	add_to_group("exits")

func _level_done(node: Node):
	if node.is_in_group("player"):
		print("Level Complete")
		emit_signal("level_done")