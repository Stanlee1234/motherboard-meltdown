extends Node2D

@export var component_id: String = ""
@export var component_type: String = "IC Chip"

var is_broken: bool = false

var _repair_progress: float = 0.0
var _repairing: bool = false
const REPAIR_TIME := 2.0

@onready var body_rect: ColorRect = $BodyRect
@onready var label: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var particles: CPUParticles2D = $Sparks

func _ready() -> void:
	label.text = component_id.replace("_", "\n")
	progress_bar.visible = false
	progress_bar.max_value = REPAIR_TIME
	progress_bar.value = 0.0
	particles.emitting = false

func set_broken(broken: bool) -> void:
	is_broken = broken
	if broken:
		body_rect.color = Color(0.8, 0.1, 0.1)
		particles.emitting = true
	else:
		body_rect.color = Color(0.2, 0.6, 0.2)
		particles.emitting = false
		_repair_progress = 0.0
		_repairing = false
		progress_bar.visible = false
		progress_bar.value = 0.0

func _input(event: InputEvent) -> void:
	if not is_broken:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _is_mouse_over():
			_repairing = true
			progress_bar.visible = true
		elif not event.pressed:
			_repairing = false

func _process(delta: float) -> void:
	if not is_broken or not _repairing:
		return
	if not _is_mouse_over():
		_repairing = false
		return
	_repair_progress += delta
	progress_bar.value = _repair_progress
	if _repair_progress >= REPAIR_TIME:
		_complete_repair()

func _complete_repair() -> void:
	_repairing = false
	_repair_progress = 0.0
	progress_bar.visible = false
	var repair_sys := get_tree().get_first_node_in_group("repair_system")
	if repair_sys:
		repair_sys.report_component_fixed.rpc_id(1, component_id)

func _is_mouse_over() -> bool:
	var local_mouse := get_local_mouse_position()
	var rect := body_rect.get_rect()
	return rect.has_point(local_mouse)
