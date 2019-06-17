extends Label

func _ready():
	Globals.connect("levelnumber", self, "update_text")

func update_text(levelnum):
	text = defs.ALPHABET[levelnum]

