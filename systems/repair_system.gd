extends Node

var total_repairs: int = 0
var _repair_start_times: Dictionary = {}

func _ready() -> void:
	add_to_group("repair_system")

@rpc("any_peer", "call_local", "reliable")
func report_component_fixed(component_id: String) -> void:
	if not multiplayer.is_server():
		return
	total_repairs += 1
	var glitch_sys := get_tree().get_first_node_in_group("glitch_system")
	if glitch_sys:
		glitch_sys.resolve_glitch_for_component(component_id)
	print("Repair completed: %s (total: %d)" % [component_id, total_repairs])
