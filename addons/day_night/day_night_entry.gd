@tool
extends EditorPlugin


const NODE_NAME = "DayNightCycle"
const INHERITANCE = "Node"
const NODE_SCRIPT: Script = preload("res://addons/day_night/day_night_cycle.gd")
const NODE_ICON: Texture2D = preload("res://addons/day_night/node_icon.svg")


func _enter_tree() -> void:
	# Add CustomEOT-Node to the scene dialog
	#add_autoload_singleton(NODE_NAME, "res://addons/day_night/day_night_cycle.gd")
	add_custom_type(NODE_NAME, INHERITANCE, NODE_SCRIPT, NODE_ICON)


func _exit_tree() -> void:
	# Remove CustomEOT-Node to the scene dialog
	#remove_autoload_singleton(NODE_NAME)
	remove_custom_type(NODE_NAME)
