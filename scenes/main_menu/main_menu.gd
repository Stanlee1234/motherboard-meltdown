extends Control

@onready var status_label: Label = $VBox/StatusLabel
@onready var host_button: Button = $VBox/HostSection/HostButton
@onready var ip_input: LineEdit = $VBox/JoinSection/IPInput
@onready var join_button: Button = $VBox/JoinSection/JoinButton

func _ready() -> void:
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.player_disconnected.connect(_on_player_disconnected)
	NetworkManager.connection_succeeded.connect(_on_connection_succeeded)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	_set_status("Ready — Enter IP or Host a Game")

func _on_host_button_pressed() -> void:
	NetworkManager.host_game()
	host_button.disabled = true
	join_button.disabled = true
	_set_status("Waiting for Player 2...")

func _on_join_button_pressed() -> void:
	var ip := ip_input.text.strip_edges()
	if ip.is_empty():
		ip = "127.0.0.1"
	NetworkManager.join_game(ip)
	host_button.disabled = true
	join_button.disabled = true
	_set_status("Connecting to %s..." % ip)

func _on_player_connected(_peer_id: int) -> void:
	if multiplayer.is_server() and NetworkManager.connected_players.size() >= 2:
		_set_status("Player 2 connected! Starting game...")
		await get_tree().create_timer(0.5).timeout
		_start_game.rpc()

func _on_player_disconnected(_peer_id: int) -> void:
	_set_status("Player disconnected.")
	host_button.disabled = false
	join_button.disabled = false

func _on_connection_succeeded() -> void:
	_set_status("Connected! Waiting for host...")

func _on_connection_failed() -> void:
	_set_status("Connection failed. Try again.")
	host_button.disabled = false
	join_button.disabled = false

@rpc("authority", "call_local", "reliable")
func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _set_status(text: String) -> void:
	if status_label:
		status_label.text = text
