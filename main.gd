extends Node

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = load("res://player.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left_mouse"):
		var new_player = player.instantiate()
		add_child(new_player)
