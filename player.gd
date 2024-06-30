extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing = 'right'
var who = '1'
@export var hp = 1000
@onready var curr_state = $AnimatedSprite2D.animation
var attacks = ['light', 'heavy', 'special']
var immutable_states = ['light', 'heavy', 'special', 'hitstun']
var hitbox = null
var load_hitbox = load("res://hitbox.tscn")
var new_anim = false
var curr_stun = 0
var inStun = false
var dir = 1

func _process(delta):
	print(curr_stun)
		
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
			if Input.is_action_just_released('down'):
				$AnimatedSprite2D.play('stand')
			
			if Input.is_action_just_pressed("light"):
				$AnimatedSprite2D.play('light')
				make_hitbox(1, 1, 0.25, 0.2, 20, 20, 0, 5, 10, 100, 100)
			if Input.is_action_just_pressed("heavy"):
				$AnimatedSprite2D.play('heavy')
				make_hitbox(1, 1, 0.25, 0.15, 15, 33, 0, 15, 15, 0, 50)
				make_hitbox(2, 2, 0.25, 0.15, 15, 27, 0, 10, 20, 200, 50)
			if Input.is_action_just_pressed("special"):
				$AnimatedSprite2D.play('special')
			
		if curr_stun > 0:
			# $AnimatedSprite2D.play('hitstun')
			curr_stun -= 1
			if curr_stun == 0:
				inStun = false
				$AnimatedSprite2D.play('stand')
				
		curr_state = $AnimatedSprite2D.animation
		if new_anim:
			remote_set_animation.rpc(curr_state)
	
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


func _on_hurtbox_area_entered(hitbox):
	# check that its the opponents hitbox
	if hitbox.get_parent().name != name:
		var damage = hitbox.damage
		hp -= damage
		curr_stun = hitbox.hitstun
		inStun = true
		$AnimatedSprite2D.play('hitstun')
		velocity.x = hitbox.pushback_x*dir*-1
		velocity.y = hitbox.pushback_y
		
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

func remove_hitbox():
	remove_child(hitbox)

func _on_animated_sprite_2d_animation_looped():
	if $AnimatedSprite2D.animation in attacks:
		$AnimatedSprite2D.animation = 'stand'
		
func hitbox_manager(curr_frame: int):
	# if we have a hitbox
	if hitbox != null:
		# if its the end of the attack, get rid of the hitbox
		if curr_frame > hitbox.last_active:
			remove_hitbox()
			hitbox = null
		# if its time for an attack to hit, add it to the scene
		elif curr_frame == hitbox.first_active:
			add_child(hitbox)
		# covers edge case where a move has no recovery frames
		elif curr_state in ['stand', 'crouch', 'hitstun']:
			remove_hitbox()
			hitbox = null
		
		


