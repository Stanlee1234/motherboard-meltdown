extends Node

const SYNC_RATE := 20.0
var _timer: float = 0.0

func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	_timer += delta
	if _timer >= 1.0 / SYNC_RATE:
		_timer = 0.0
		_send_state()

func _send_state() -> void:
	var world := _get_platformer_world()
	if world == null:
		return
	var player := world.get_node_or_null("PlayerCharacter")
	if player == null:
		return
	var glitch_sys := get_tree().get_first_node_in_group("glitch_system")
	var glitches: Array = []
	if glitch_sys:
		glitches = glitch_sys.active_glitches.duplicate()
	_sync_preview.rpc(player.position, player.velocity, player.anim_state, glitches)

@rpc("authority", "unreliable")
func _sync_preview(pos: Vector2, vel: Vector2, anim: String, glitches: Array) -> void:
	if multiplayer.is_server():
		return
	var game := get_tree().get_first_node_in_group("game_scene")
	if game == null:
		return
	var vp := game.get_node_or_null("FrontendPreview/SubViewport")
	if vp == null:
		return
	var world := vp.get_child(0) if vp.get_child_count() > 0 else null
	if world == null:
		return
	var player := world.get_node_or_null("PlayerCharacter")
	if player:
		player.position = player.position.lerp(pos, 0.5)

func _get_platformer_world() -> Node:
	var game := get_tree().get_first_node_in_group("game_scene")
	if game == null:
		return null
	var vp := game.get_node_or_null("FrontendView/SubViewport")
	if vp == null:
		return null
	return vp.get_child(0) if vp.get_child_count() > 0 else null
