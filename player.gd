extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 800
var facing = 'right'
var who = '1'
@export var hp = 1000
@onready var curr_state = $AnimatedSprite2D.animation
var loops_to_cancel = ['light', 'heavy', 'special']
var cancellable_attacks = ['heavy']
var immutable_states = ['light', 'heavy', 'special', 'hitstun']
var hitbox = null
var hitboxes = []
var load_hitbox = load("res://hitbox.tscn")
var new_anim = false
var curr_stun = 0
var inStun = false
var dir = 1
# combo length refers to how many hits YOU are in the combo
var combo_length = 0

func _process(delta):
	# print(curr_stun)
		
	if facing == 'left':
		$AnimatedSprite2D.flip_h = true
		dir = -1
	else:
		$AnimatedSprite2D.flip_h = false
		dir = 1
	
	if is_multiplayer_authority():
		# print($AnimatedSprite2D.frame)
		hitbox_manager($AnimatedSprite2D.frame)
		if curr_state not in immutable_states and curr_stun == 0:
		# Attack handling
			# Standing and crouching handling
			if Input.is_action_pressed('down'):
				$AnimatedSprite2D.play('crouch')
				new_anim = true
			if Input.is_action_just_released('down'):
				$AnimatedSprite2D.play('stand')
				new_anim = true
			
			if Input.is_action_just_pressed("light"):
				$AnimatedSprite2D.play('light')
				print('light')
				new_anim = true
				make_hitbox(1, 1, 0.9, 0.3, 55, 40, 0, 18, 10, 75, 0)
				velocity.x = 0
			if Input.is_action_just_pressed("heavy"):
				$AnimatedSprite2D.play('heavy')
				print('heavy')
				new_anim = true
				make_hitbox(1, 1, 0.5, 0.3, 30, 100, 0, 25, 15, 0, -300)
				make_hitbox(2, 2, 0.7, 0.4, 60, 70, 0, 40, 20, -100, -300)
				velocity.x = 0
			if Input.is_action_just_pressed("special"):
				new_anim = true
				$AnimatedSprite2D.play('special')
		if curr_state in cancellable_attacks or curr_state not in immutable_states:
			if Input.is_action_just_pressed("special"):
				new_anim = true
				$AnimatedSprite2D.play('special')
			
		if curr_stun > 0:
			# $AnimatedSprite2D.play('hitstun')
			curr_stun -= 1
			if curr_stun == 0:
				inStun = false
				$AnimatedSprite2D.play('stand')
				velocity.x = 0
				velocity.y = 0
				
		curr_state = $AnimatedSprite2D.animation
		if new_anim:
			remote_set_animation.rpc(curr_state)
			new_anim = false
	
	# End of frame call to update the current state of the character
		
	

func _physics_process(delta):
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		if curr_state not in immutable_states:
			var direction = Input.get_axis("left", "right")
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
		remote_set_position.rpc(global_position)
		
@rpc("unreliable")
func remote_set_position(authority_position):
	global_position = authority_position

@rpc("unreliable")
func remote_set_animation(authority_animation):
	$AnimatedSprite2D.play(authority_animation)
# my attempt
#@rpc("unreliable")
#func remote_set_hitstun(authority_hitstun):
	#inStun = true
	#curr_stun = authority_hitstun

func _on_hurtbox_area_entered(hitbox):
	# check that its the opponents hitbox
	if hitbox.get_parent().name != name:
		var damage = hitbox.damage
		hp -= damage
		curr_stun = hitbox.hitstun
		inStun = true
		$AnimatedSprite2D.play('hitstun')
		velocity.x = hitbox.pushback_x*dir*-1
		velocity.y += hitbox.pushback_y
		combo_length += 1
		print("COMBO COUNT " + str(combo_length))
		
		# print(hitbox.get_parent().name + "'s hitbox touched " + name + "'s hurtbox and dealt " + str(damage))
		
func make_hitbox(first_active: int, last_active: int, hitbox_size_x: float, hitbox_size_y: float, hitbox_x_offset: float, hitbox_y_offset: float, id: int, hitstun: int, damage: int, pushback_x: int, pushback_y: int):
	hitbox = load_hitbox.instantiate()
	hitbox.last_active = last_active
	hitbox.first_active = first_active
	hitbox.id = id
	hitbox.hitstun = hitstun
	hitbox.damage = damage
	hitbox.pushback_x = pushback_x
	hitbox.pushback_y = pushback_y
	# add_child(hitbox)
	var hitbox_collider = hitbox.get_child(0)
	if facing != 'right':
		dir = -1
	hitbox_collider.scale.y = hitbox_size_y
	hitbox_collider.scale.x = hitbox_size_x
	hitbox_collider.position.x += hitbox_x_offset*dir
	hitbox_collider.position.y += hitbox_y_offset
	hitboxes.append(hitbox)
	# print(hitbox_collider.position.y)

func remove_hitbox(hitbox):
	remove_child(hitbox)
	hitboxes.erase(hitbox)

func _on_animated_sprite_2d_animation_looped():
	if $AnimatedSprite2D.animation in loops_to_cancel:
		$AnimatedSprite2D.animation = 'stand'
		
		
func hitbox_manager(curr_frame: int):
	# if we have a hitbox
	for hitbox in hitboxes:
		# if its the end of the attack, get rid of the hitbox
		if curr_frame > hitbox.last_active:
			remove_hitbox(hitbox)
			hitbox = null
		# if its time for an attack to hit, add it to the scene
		elif curr_frame == hitbox.first_active:
			add_child(hitbox)
		# covers edge case where a move has no recovery frames
		elif curr_state in ['stand', 'crouch', 'hitstun']:
			remove_hitbox(hitbox)
			hitbox = null
		
		


