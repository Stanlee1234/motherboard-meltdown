extends Node2D

var _components: Array[Node] = []
var _broken_ids: Array[String] = []

const TRACE_COLOR_NORMAL := Color(0.8, 0.6, 0.1)
const TRACE_COLOR_BROKEN := Color(0.5, 0.05, 0.05)
const TRACE_WIDTH := 3.0

func _ready() -> void:
	for child in get_parent().get_children():
		if child.has_method("set_broken"):
			_components.append(child)

func mark_broken(component_id: String, broken: bool) -> void:
	if broken:
		if not _broken_ids.has(component_id):
			_broken_ids.append(component_id)
	else:
		_broken_ids.erase(component_id)
	queue_redraw()

func _draw() -> void:
	if _components.size() < 2:
		return
	for i in _components.size() - 1:
		var a: Node2D = _components[i]
		var b: Node2D = _components[i + 1]
		var a_id: String = a.component_id if "component_id" in a else ""
		var b_id: String = b.component_id if "component_id" in b else ""
		var col := TRACE_COLOR_BROKEN if (_broken_ids.has(a_id) or _broken_ids.has(b_id)) else TRACE_COLOR_NORMAL
		draw_line(a.position, b.position, col, TRACE_WIDTH)
