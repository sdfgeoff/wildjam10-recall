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

""" This file provides callbacks on a single flat-list/dictionary. This
allows a set of variables to be subscribed to by /anyone/ 

This is mostly useful for program-wide settings or other things that
need UI's and internal access in a non-direct manner.
"""
tool
extends Node

var values = {}


func init(default_dict):
	values = default_dict.duplicate()
	for key in default_dict:
		add_user_signal(key)


func get(key: String):
	assert key in values
	return values[key]


func set(key: String, val):
	assert key in values
	assert typeof(val) == typeof(values[key])
	values[key] = val
	emit_signal(key, val)


func connect(key: String,
		target: Object,
		method: String,
		binds := [],
		flags := 0):
	"""Overload connect to also call the function.
	This ensures everything is up to date with the
	global state"""
	assert key in values
	.connect(key, target, method, binds, flags)
	target.callv(method, [get(key)] + binds)
