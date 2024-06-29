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
	if Input.is_action_just_pressed('space'):
		queue_free()
		
	if facing == 'left':
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	
	# Standing and crouching handling
	if Input.is_action_pressed('down'+who):
		$AnimatedSprite2D.animation = 'crouch'
	if Input.is_action_just_released('down'+who):
		$AnimatedSprite2D.animation = 'stand'
		
	# Attack handling
	if Input.is_action_just_pressed("light"+who):
		$AnimatedSprite2D.animation = 'light'
		var hitbox1 = hitbox.instantiate()
		print(get_tree())
		hitbox1.position.x = position.x
		hitbox1.position.y = position.y
		print(str(hitbox1.position.x) + " " + str(hitbox1.position.y))
		#var hitbox1 = Area2D.new()
		#var hitbox1_visual = Sprite2D.new()
		#hitbox1_visual.texture = load('res://icon.svg')
		#hitbox1_visual.position.x = 100
		#hitbox1_visual.position.y = 100
		#hitbox1.add_to_group('hitbox'+who)
		#hitbox1.add_child(hitbox1_visual)
		#print(hitbox1_visual.texture)
	if Input.is_action_just_pressed("heavy"+who):
		$AnimatedSprite2D.animation = 'heavy'
	if Input.is_action_just_pressed("special"+who):
		$AnimatedSprite2D.animation = 'special'
	
	
	# End of frame call to update the current state of the character
	curr_state = $AnimatedSprite2D.animation
		
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left"+who, "right"+who)
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
