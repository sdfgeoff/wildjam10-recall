"""
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

""" This file is to standardize logging across the project. This is 
instanced as an autoload "Logging" and can be used by any script"""
tool
extends Node


# This is so that you can (eg) display the log output on the screen
# for the user if you need/want to
signal message_logged(message)


func _init():
	ProjectSettings.set("logging/file_logging/enable_file_logging", true)


func _log(string: String):
	""" We just print here because the engine logging will
	pick it up. This is just to standardize log levels"""
	print(string)
	emit_signal("message_logged", string)


func warn(message: String, formats: Array = []):
	""" Something unexpected but causes no loss in functionality """
	_log("[WRN] " + message % formats)

func error(message: String, formats: Array = []):
	""" Something happened and as a result, things aren't going to work right """
	_log("[ERR] " + message % formats)

func info(message: String, formats: Array = []):
	""" Something expected happened, and this is to let you know that it happened """
	_log("[INF] " + message % formats)

func debug(message: String, formats: Array = []):
	""" This information may help debugging issues in the future, maybe """
	_log("[DBG] " + message % formats)