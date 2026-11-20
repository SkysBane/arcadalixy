extends CharacterBody2D

@export var controller_id := 0
@export var move_accel := 30.0
@export var max_speed := 300.0
@export var turn_speed := 0.06
@export var bullet_scene : PackedScene
var fire_cooldown := 0.3
var active_fire_cooldown := 0.0

func _physics_process(delta: float) -> void:
	active_fire_cooldown -= delta
	
	# get turning input
	var turn = Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X)
	if abs(turn) < 0.15:
		turn = 0
	
	
	# get movement input
	var movement_input = Vector2(
		Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_X), 
		Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_Y))

	# Prevent stick drift?
	if movement_input.length() < 0.15:
		movement_input = Vector2.ZERO

	# rotate
	rotation += turn*turn_speed
	
	# slowly come to a stop
	velocity *= 0.96
	
	# horizontal movement is not as strong
	movement_input.x *= 0.25
	# accelerate towards our movement input
	velocity += movement_input.rotated(rotation) * move_accel
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
		
	var firing := Input.get_joy_axis(controller_id, JOY_AXIS_TRIGGER_RIGHT) > 0.1
	if firing and active_fire_cooldown < 0:
		active_fire_cooldown = fire_cooldown
		fire_bullet()
	

	move_and_slide()

func fire_bullet():
	var bullet = bullet_scene.instantiate()

	
	var forward = Vector2.UP.rotated(global_rotation)
	bullet.linear_velocity = forward * 60 + velocity 
	bullet.add_constant_force(forward * 100)
	bullet.global_position = global_position + forward * 15
	bullet.global_rotation = global_rotation
	bullet.setup(200.0)
	
	
	# this calls _ready() inside bullet and adds it to the scene
	get_tree().root.add_child(bullet)

	
