"""
This file contains thing that are globally accessible. This is used
rather than ProjectSettings to avoid cluttering the settings file and
to allow us to create signals for all of our settings.
"""
tool
extends "res://addons/Globals/Globals.gd"

const Settings := preload("res://addons/Globals/Settings.gd")

const GLOBALS = {
	"levelnumber": 0,
	"config/controls/invert_mouse_y": true,
	"config/controls/mouse_sensitivity": 0.05,
	"config/graphics/fullscreen": true,
	"config/graphics/enable_post_fx": true,
}

const SETTINGS = [
	"config/controls/invert_mouse_y",
	"config/controls/mouse_sensitivity",
	"config/graphics/fullscreen",
	"config/graphics/enable_post_fx"
]

var _settings = null


var _init = false

func _ready():
	start()

func _process(_delta):
	if !_init:
		start()

func start():
	_init = true
	randomize()
	Logging.info("Setting up globals")
	.init(GLOBALS)
	_settings = Settings.new(self, SETTINGS)
	_settings.load()

	# Things that don't have better places to be and need to be running all the time
	connect("config/graphics/fullscreen", self, "_set_fullscreen")

func _set_fullscreen(val):
	OS.window_fullscreen = val