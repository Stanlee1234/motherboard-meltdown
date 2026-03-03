extends Node

signal difficulty_increased(level: int)

const BASE_INTERVAL := 10.0
const MIN_INTERVAL := 3.0
const RAMP_DURATION := 120.0

var elapsed: float = 0.0
var current_level: int = 0
var _glitch_timer: float = 0.0

func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	elapsed += delta
	_glitch_timer += delta
	var interval := _get_current_interval()
	if _glitch_timer >= interval:
		_glitch_timer = 0.0
		_trigger()
		var new_level := int(elapsed / 30.0)
		if new_level > current_level:
			current_level = new_level
			difficulty_increased.emit(current_level)

func _get_current_interval() -> float:
	var t := clampf(elapsed / RAMP_DURATION, 0.0, 1.0)
	return lerpf(BASE_INTERVAL, MIN_INTERVAL, t)

func _trigger() -> void:
	var glitch_sys := get_tree().get_first_node_in_group("glitch_system")
	if glitch_sys:
		glitch_sys.trigger_random_glitch()
		# At higher difficulty levels, fire multiple glitches
		if current_level >= 2:
			glitch_sys.trigger_random_glitch()

func get_survival_time() -> float:
	return elapsed
