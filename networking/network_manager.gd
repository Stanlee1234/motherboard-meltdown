extends Node

signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal connection_succeeded
signal connection_failed

const PORT := 8910
const MAX_PLAYERS := 2

var connected_players: Array[int] = []
var _peer: ENetMultiplayerPeer = null

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game() -> void:
	_peer = ENetMultiplayerPeer.new()
	var err := _peer.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		push_error("Failed to create server: %s" % error_string(err))
		connection_failed.emit()
		return
	multiplayer.multiplayer_peer = _peer
	connected_players.append(1)
	print("Server started on port %d" % PORT)

func join_game(ip: String) -> void:
	_peer = ENetMultiplayerPeer.new()
	var err := _peer.create_client(ip, PORT)
	if err != OK:
		push_error("Failed to connect to %s:%d — %s" % [ip, PORT, error_string(err)])
		connection_failed.emit()
		return
	multiplayer.multiplayer_peer = _peer
	print("Connecting to %s:%d" % [ip, PORT])

func disconnect_game() -> void:
	if _peer != null:
		_peer.close()
		_peer = null
	multiplayer.multiplayer_peer = null
	connected_players.clear()

func get_my_role() -> String:
	if multiplayer.is_server():
		return "frontend"
	return "backend"

func _on_peer_connected(id: int) -> void:
	connected_players.append(id)
	player_connected.emit(id)
	print("Peer connected: %d" % id)

func _on_peer_disconnected(id: int) -> void:
	connected_players.erase(id)
	player_disconnected.emit(id)
	print("Peer disconnected: %d" % id)

func _on_connected_to_server() -> void:
	connected_players.append(multiplayer.get_unique_id())
	connection_succeeded.emit()
	print("Connected to server as peer %d" % multiplayer.get_unique_id())

func _on_connection_failed() -> void:
	_peer = null
	multiplayer.multiplayer_peer = null
	connection_failed.emit()
	print("Connection failed")

func _on_server_disconnected() -> void:
	disconnect_game()
	print("Server disconnected")
