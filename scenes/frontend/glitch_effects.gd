extends CanvasLayer

const GlitchType = preload("res://systems/glitch_system.gd").GlitchType

var active_glitches: Dictionary = {}
var _platforms: Array[Node] = []
var _player: CharacterBody2D = null

# Screen-tear ColorRect
var _tear_rect: ColorRect = null
# Color-corrupt ColorRect
var _corrupt_rect: ColorRect = null

func _ready() -> void:
	_tear_rect = ColorRect.new()
	_tear_rect.color = Color.TRANSPARENT
	_tear_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tear_rect.visible = false
	var tear_mat := ShaderMaterial.new()
	tear_mat.shader = load("res://shaders/screen_tear.gdshader")
	_tear_rect.material = tear_mat
	add_child(_tear_rect)

	_corrupt_rect = ColorRect.new()
	_corrupt_rect.color = Color.TRANSPARENT
	_corrupt_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_corrupt_rect.visible = false
	var corrupt_mat := ShaderMaterial.new()
	corrupt_mat.shader = load("res://shaders/color_corrupt.gdshader")
	_corrupt_rect.material = corrupt_mat
	add_child(_corrupt_rect)

func set_platforms(p: Array[Node]) -> void:
	_platforms = p

func set_player(p: CharacterBody2D) -> void:
	_player = p

func apply_glitch(type: int) -> void:
	if active_glitches.has(type):
		return
	active_glitches[type] = true
	match type:
		GlitchType.PLATFORM_VANISH:
			_toggle_random_platforms(false)
		GlitchType.GRAVITY_INVERT:
			if _player and _player.has_method("invert_gravity"):
				_player.invert_gravity()
		GlitchType.SCREEN_TEAR:
			_tear_rect.visible = true
		GlitchType.COLOR_CORRUPT:
			_corrupt_rect.visible = true

func remove_glitch(type: int) -> void:
	if not active_glitches.has(type):
		return
	active_glitches.erase(type)
	match type:
		GlitchType.PLATFORM_VANISH:
			_toggle_random_platforms(true)
		GlitchType.GRAVITY_INVERT:
			if _player and _player.has_method("restore_gravity"):
				_player.restore_gravity()
		GlitchType.SCREEN_TEAR:
			_tear_rect.visible = false
		GlitchType.COLOR_CORRUPT:
			_corrupt_rect.visible = false

func _toggle_random_platforms(visible_state: bool) -> void:
	if _platforms.is_empty():
		return
	# Hide/show roughly half the platforms
	var count := max(1, _platforms.size() / 2)
	for i in count:
		_platforms[i].visible = visible_state
