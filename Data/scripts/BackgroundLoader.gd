# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

""" This is used to load a scene file or resource in the background.
Emits a bunch of signals to indicate progress
"""

class_name BackgroundLoader
extends Node

# This signal is emitted if the load fails
signal error()

# This signal is emitted when the load is finished
# the supplied node is the one that was just instanced
signal complete(resource)

# Emitted with a percentage loaded
signal progress(percent)

# Maximum number of milliseconds to spend inside the update
# part os this loader
const MAX_MS_PER_FRAME = 10


var loader: ResourceInteractiveLoader = null
var scene_path: String = ""

var loaded = false


func start(data_path):
	loaded = false
	scene_path = data_path
	Logging.info("Initilizing loading of file: %s", [scene_path])

	if not ResourceLoader.has_cached(scene_path):
		loader = ResourceLoader.load_interactive(scene_path)
	else:
		loaded = true


func update():
	""" Do some steps of the load sequence. This will 
	cause one of the signals (complete, progress, error) to be emitted """
	# TODO: guard against calls after loading is complete
	if loader == null:
		if loaded == true:
			emit_signal("complete")
			return
		else:
			Logging.error("Loader failed to initilize")
			emit_signal("error")
			return
	var start_time = OS.get_ticks_msec()
	while OS.get_ticks_msec() < start_time + MAX_MS_PER_FRAME: 
		var status = loader.poll()

		if status == ERR_FILE_EOF: # Finished loading.
			emit_signal("complete")
			loaded = true
			break
		elif status == OK:  # Loaded something
			emit_signal("progress", float(loader.get_stage()) / loader.get_stage_count())
			break
		else:
			Logging.error("Loader failed during loading %s. Error is %s", [
				_reverse_enum(loader.Error, status)
			])
			emit_signal("error")
			break


func get_loaded_resource():
	""" Instace the scene and parent it to the world_root as defined in the 
	_init function """
	if loader != null:
		return loader.get_resource()
	else:
		Logging.info("Level loading from already in cache")
		return ResourceLoader.load(scene_path, "", true)