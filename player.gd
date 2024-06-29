extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var hitbox = load("res://hitbox.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing = 'right'
var who = '1'
@onready var curr_state = $AnimatedSprite2D.animation

func _process(delta):
		
	if facing == 'left':
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	
	if is_multiplayer_authority():
		# Standing and crouching handling
		if Input.is_action_pressed('down'):
			$AnimatedSprite2D.animation = 'crouch'
		if Input.is_action_just_released('down'):
			$AnimatedSprite2D.animation = 'stand'
			
		# Attack handling
		if Input.is_action_just_pressed("light"):
			$AnimatedSprite2D.animation = 'light'
			var hitbox1 = hitbox.instantiate()
			hitbox1.position.x = position.x
			hitbox1.position.y = position.y
			print(str(hitbox1.position.x) + " " + str(hitbox1.position.y))
		if Input.is_action_just_pressed("heavy"):
			$AnimatedSprite2D.animation = 'heavy'
		if Input.is_action_just_pressed("special"):
			$AnimatedSprite2D.animation = 'special'
			
		curr_state = $AnimatedSprite2D.animation
		remote_set_animation.rpc(curr_state)
	
	# End of frame call to update the current state of the character
		
	

func _physics_process(delta):
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
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
	$AnimatedSprite2D.animation = authority_animation
