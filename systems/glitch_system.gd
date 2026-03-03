extends Node

enum GlitchType { PLATFORM_VANISH, GRAVITY_INVERT, SCREEN_TEAR, COLOR_CORRUPT }

const COMPONENT_MAP := {
	GlitchType.PLATFORM_VANISH: "platform_controller_ic",
	GlitchType.GRAVITY_INVERT:  "gravity_regulator_555",
	GlitchType.SCREEN_TEAR:     "gpu_render_pipeline",
	GlitchType.COLOR_CORRUPT:   "color_dac_chip",
}

signal game_over

var active_glitches: Array[int] = []
var _meltdown_timer: float = 0.0
const MELTDOWN_THRESHOLD := 5.0

func _ready() -> void:
	add_to_group("glitch_system")

func trigger_random_glitch() -> void:
	if not multiplayer.is_server():
		return
	var all_types := [GlitchType.PLATFORM_VANISH, GlitchType.GRAVITY_INVERT,
					  GlitchType.SCREEN_TEAR, GlitchType.COLOR_CORRUPT]
	var available: Array[int] = []
	for t in all_types:
		if not active_glitches.has(t):
			available.append(t)
	if available.is_empty():
		return
	var chosen: int = available[randi() % available.size()]
	_activate_glitch(chosen)

func _activate_glitch(type: int) -> void:
	if active_glitches.has(type):
		return
	active_glitches.append(type)
	var comp_id: String = COMPONENT_MAP[type]
	notify_frontend_glitch.rpc(type, true)
	notify_backend_failure.rpc(comp_id, true)

func resolve_glitch_for_component(component_id: String) -> void:
	if not multiplayer.is_server():
		return
	for type in COMPONENT_MAP:
		if COMPONENT_MAP[type] == component_id:
			_deactivate_glitch(type)
			return

func _deactivate_glitch(type: int) -> void:
	active_glitches.erase(type)
	var comp_id: String = COMPONENT_MAP[type]
	notify_frontend_glitch.rpc(type, false)
	notify_backend_failure.rpc(comp_id, false)
	_meltdown_timer = 0.0

func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	if active_glitches.size() >= 4:
		_meltdown_timer += delta
		if _meltdown_timer >= MELTDOWN_THRESHOLD:
			game_over.emit()
	else:
		_meltdown_timer = 0.0

@rpc("authority", "call_local", "reliable")
func notify_frontend_glitch(type: int, active: bool) -> void:
	var world := _get_platformer_world()
	if world == null:
		return
	var glitch_layer = world.get_node_or_null("GlitchLayer")
	if glitch_layer == null:
		return
	if active:
		glitch_layer.apply_glitch(type)
	else:
		glitch_layer.remove_glitch(type)

@rpc("authority", "call_local", "reliable")
func notify_backend_failure(component_id: String, broken: bool) -> void:
	var world := _get_pcb_world()
	if world == null:
		return
	for child in world.get_children():
		if child.get("component_id") == component_id:
			child.set_broken(broken)
	var traces := world.get_node_or_null("PCBTraces")
	if traces:
		traces.mark_broken(component_id, broken)

func _get_platformer_world() -> Node:
	var game := get_tree().get_first_node_in_group("game_scene")
	if game == null:
		return null
	var vp := game.get_node_or_null("FrontendView/SubViewport")
	if vp == null:
		return null
	return vp.get_child(0) if vp.get_child_count() > 0 else null

func _get_pcb_world() -> Node:
	var game := get_tree().get_first_node_in_group("game_scene")
	if game == null:
		return null
	var vp := game.get_node_or_null("BackendView/SubViewport")
	if vp == null:
		return null
	return vp.get_child(0) if vp.get_child_count() > 0 else null
