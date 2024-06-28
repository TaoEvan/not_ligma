extends Node

var player
var peer

const PORT = 8000
const ADDRESS = "127.0.0.1"

func _ready():
	peer = ENetMultiplayerPeer.new()
	player = load("res://player.tscn")

# Called when the node enters the scene tree for the first time.
func _on_host_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(func(id): print("peer is connected"))
	print("ok")
	

func _on_join_pressed():
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	print("ok")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left_mouse"):
		var new_player = player.instantiate()
		add_child(new_player)
