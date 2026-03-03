extends Node

const SCREEN_W := 1280
const SCREEN_H := 720
const PREVIEW_W := 384   # ~30% of 1280
const BACKEND_W := 896   # ~70% of 1280

func _ready() -> void:
	add_to_group("game_scene")
	var role := NetworkManager.get_my_role()
	_setup_layout(role)

func _setup_layout(role: String) -> void:
	var frontend_view: SubViewportContainer = $FrontendView
	var backend_view: SubViewportContainer = $BackendView
	var frontend_preview: SubViewportContainer = $FrontendPreview

	if role == "frontend":
		frontend_view.visible = true
		frontend_view.position = Vector2.ZERO
		frontend_view.size = Vector2(SCREEN_W, SCREEN_H)
		backend_view.visible = false
		frontend_preview.visible = false
	else:
		frontend_view.visible = false
		# Preview left 30%
		frontend_preview.visible = true
		frontend_preview.position = Vector2.ZERO
		frontend_preview.size = Vector2(PREVIEW_W, SCREEN_H)
		# PCB right 70%
		backend_view.visible = true
		backend_view.position = Vector2(PREVIEW_W, 0)
		backend_view.size = Vector2(BACKEND_W, SCREEN_H)
