extends CharacterBody2D

var new_anim = false
var curr_stun = 0
var inStun = false
var dir = 1
var gravity = 800
var facing = 'left'
var combo_length = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if facing == 'right':
		dir = 1
	else:
		dir = -1
	if curr_stun > 0:
			# $AnimatedSprite2D.play('hitstun')
			curr_stun -= 1
			# print(curr_stun)
			if curr_stun == 0:
				inStun = false
				# $AnimatedSprite2D.play('stand')
				velocity.x = 0
				velocity.y = 0
				print("DROP")
				combo_length = 0
				
func _on_hurtbox_area_entered(hitbox):
	# check that its the opponents hitbox
	if hitbox.get_parent().name != name:
		var damage = hitbox.damage
		# hp -= damage
		curr_stun = hitbox.hitstun
		inStun = true
		# $AnimatedSprite2D.play('hitstun')
		velocity.x = hitbox.pushback_x*dir*-1
		velocity.y += hitbox.pushback_y
		combo_length += 1
		print("COMBO COUNT " + str(combo_length))

func _physics_process(delta):
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
			
		move_and_slide()
