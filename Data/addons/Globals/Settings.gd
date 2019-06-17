extends Node

const FILE_PATH := "user://settings.conf"

# This is used to disble auto-saving when some internal
# operation would cause it to occur many times
var _disable_autosave_internal := false


var settings_list = []

func _init(globals, settings):
	_disable_autosave_internal = true
	settings_list = settings
	for setting in settings_list:
		globals.connect(setting, self, "_on_setting_changed", [setting])
	_disable_autosave_internal = false

func _on_setting_changed(_setting, _new_value):
	if _disable_autosave_internal:
		return
	save()


func load():
	Logging.info("Loading Settings")
	var settings_file := File.new()
	var res := settings_file.open(FILE_PATH, settings_file.READ)
	if res != OK:
		Logging.warn("Unable to read settings file")
		return
	var json = JSON.parse(settings_file.get_as_text())
	if json.error:
		Logging.warn("Unable to parse settings file: %s", [json.error_string])
		return
	settings_file.close()
	
	_disable_autosave_internal = true  # Don't try save while loading!
	for key in json.result:
		if key in settings_list:
			var val = json.result[key]

			# JSON can't store ints, so if we're expecting one and have a float
			# try convert it.
			if typeof(Globals.get(key)) is int and val is float:
				val = int(val)

			if typeof(val) != typeof(Globals.get(key)):
				Logging.warn("Unable to load setting %s due to type mismatch", [key])
				continue
			Globals.set(key, val)
	_disable_autosave_internal = false


func save():
	Logging.info("Saving Settings")
	var file := File.new()
	var res := file.open(FILE_PATH, file.WRITE)
	if res != OK:
		Logging.warn("Unable to write settings file")
		return
	
	var out_dict = {}
	for key in settings_list:
		out_dict[key] = Globals.get(key)
	
	var out_string = JSON.print(out_dict, "  ", true)
	file.store_string(out_string)
	file.close()