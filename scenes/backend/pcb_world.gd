extends Node2D

const PAN_SPEED := 300.0

@onready var camera: Camera2D = $Camera2D

func _process(delta: float) -> void:
	var pan := Vector2.ZERO
	pan.x = Input.get_axis("ui_left", "ui_right")
	pan.y = Input.get_axis("ui_up", "ui_down")
	if pan != Vector2.ZERO:
		camera.position += pan * PAN_SPEED * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom = (camera.zoom * 1.1).clamp(Vector2(0.3, 0.3), Vector2(3.0, 3.0))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom = (camera.zoom * 0.9).clamp(Vector2(0.3, 0.3), Vector2(3.0, 3.0))

func _draw() -> void:
var grid_color := Color(0.1, 0.4, 0.1, 0.4)
var grid_size := 40.0
var extent := 2000.0
var steps := int(extent / grid_size)
for i in range(-steps, steps + 1):
var coord := i * grid_size
draw_line(Vector2(-extent, coord), Vector2(extent, coord), grid_color, 1.0)
draw_line(Vector2(coord, -extent), Vector2(coord, extent), grid_color, 1.0)
