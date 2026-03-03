extends CanvasLayer

@onready var health_bar: ProgressBar = $VBox/HealthBar
@onready var timer_label: Label = $VBox/TimerLabel
@onready var alerts_label: Label = $VBox/AlertsLabel
@onready var game_over_overlay: Control = $GameOverOverlay
@onready var uptime_label: Label = $GameOverOverlay/Panel/VBox/UptimeLabel

var _health: float = 100.0
var _elapsed: float = 0.0
var _game_over: bool = false

func _ready() -> void:
	game_over_overlay.visible = false
	var glitch_sys := get_tree().get_first_node_in_group("glitch_system")
	if glitch_sys:
		glitch_sys.game_over.connect(_on_game_over)

func _process(delta: float) -> void:
	if _game_over:
		return
	_elapsed += delta
	timer_label.text = "UPTIME: %s" % _format_time(_elapsed)

	var glitch_sys := get_tree().get_first_node_in_group("glitch_system")
	if glitch_sys:
		var count: int = glitch_sys.active_glitches.size()
		_health = clampf(_health - count * 2.0 * delta, 0.0, 100.0)
		# Recover health when glitches are resolved
		if count == 0:
			_health = clampf(_health + 5.0 * delta, 0.0, 100.0)
		health_bar.value = _health

		var alert_lines: Array[String] = []
		for type in glitch_sys.active_glitches:
			var comp_id: String = glitch_sys.COMPONENT_MAP[type]
			alert_lines.append("⚠ " + comp_id.to_upper().replace("_", " "))
		alerts_label.text = "\n".join(alert_lines)

func _on_game_over() -> void:
	_game_over = true
	uptime_label.text = "Total Uptime: %s" % _format_time(_elapsed)
	game_over_overlay.visible = true

func _on_return_to_menu_pressed() -> void:
	NetworkManager.disconnect_game()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func _format_time(seconds: float) -> String:
	var m := int(seconds) / 60
	var s := int(seconds) % 60
	return "%02d:%02d" % [m, s]
