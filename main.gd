extends Node

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = load("res://player.tscn")
	var network = ENetMultiplayerPeer.new()
	network.create_server(8000)
	multiplayer.multiplayer_peer = network
	
	network.peer_connected.connect(func(id): print("Player connected. ID: ", id))
	
	$player1.facing = 'right'
	$player2.facing = 'left'
	
	$player1.who = '1'
	$player2.who = '2'


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left_mouse"):
		var new_player = player.instantiate()
		add_child(new_player)
