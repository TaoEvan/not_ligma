extends Node

var player
var peer
var ip_address

const PORT = 8000
#const ADDRESS = "127.0.0.1"
const ADDRESS = '192.168.192.77'
var h = load("res://hitbox.tscn")

func _ready():
	peer = ENetMultiplayerPeer.new()
	player = load("res://player.tscn")
	
	$player1.facing = 'right'
	$player2.facing = 'left'
	
	$player1.who = '1'
	$player2.who = '2'
	
	if OS.has_feature("windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
		elif OS.has_feature("x11"):
			if OS.has_environment("HOSTNAME"):
				ip_address =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
		elif OS.has_feature("OSX"):
			if OS.has_environment("HOSTNAME"):
				ip_address =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
				
	print(ip_address)

# Called when the node enters the scene tree for the first time.
func _on_host_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(func(id): print("peer is connected"))
	print("ok")
	print(IP.get_local_addresses())
	

func _on_join_pressed():
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	print("ok")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
