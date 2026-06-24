extends CharacterBody2D
@export var movement_data : PlayerMovementData
var just_wall_jumped = false
var jump_count = 0
var max_jumps = 2
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	
@onready var camera_2d: Camera2D = $Camera2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyotejumptimer: Timer = $coyotejumptimer
@onready var starting_position = global_position

func _ready():
	reset_physics_interpolation()

##-------------------------------------------------------------------------------------------##

func _physics_process(delta):
	var was_on_floor = is_on_floor()
	var direction = Input.get_axis("move_left", "move_right")
	apply_gravity(delta)

	if not handle_wall_jump():
		handle_jump()
	handle_acceleration(direction, delta)
	apply_friction(direction, delta)
	apply_air_resistance(direction, delta)
	
	move_and_slide()

	update_animation(direction)
	if is_on_floor():
		jump_count = 0
	elif coyotejumptimer.is_stopped() and jump_count == 0:
		jump_count = 2 
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyotejumptimer.start()

##-------------------------------------------------------------------------------------------------------##


func handle_wall_jump() -> bool:
	if not is_on_wall_only(): return false
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_normal.x * movement_data.speed * 0.85
		velocity.y = movement_data.jump_velocity
		jump_count = 1
		just_wall_jumped = true
		animated_sprite_2d.play("jump")
		return true
		
	return false

func apply_gravity(delta):
	if not is_on_floor():
		var grav_scale = movement_data.gravity_scale  # renamed from scale
		if velocity.y > 0:
			grav_scale *= 1.4
		velocity.y += gravity * grav_scale * delta
		velocity.y = min(velocity.y, 800.0)

func handle_jump():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or not coyotejumptimer.is_stopped():
			velocity.y = movement_data.jump_velocity
			jump_count += 1
			coyotejumptimer.stop()
		elif jump_count < max_jumps:
			velocity.y = movement_data.jump_velocity
			velocity.x *= 0.8
			jump_count += 1
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5
	if is_on_floor() and velocity.y > 200:
		camera_2d.offset = Vector2(0, 6)
		await get_tree().create_timer(0.05).timeout
		camera_2d.offset = Vector2.ZERO

func apply_friction(direction, delta):
	if direction == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(direction, delta):
	if direction == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func handle_acceleration(direction, delta):
	if just_wall_jumped:
		if is_on_floor() or abs(velocity.x) < movement_data.speed * 0.4:
			just_wall_jumped = false
		else:
			return
	if direction != 0:
		var accel = movement_data.acceleration
		if not is_on_floor():
			accel *= 0.5   
		velocity.x = move_toward(velocity.x, movement_data.speed * direction, accel * delta)

func update_animation(direction):
	if abs(velocity.x) > 5.0:
		animated_sprite_2d.flip_h = (velocity.x < 0)
	elif direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)
	if is_on_floor():
		if direction != 0:
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle")
	else:
		if animated_sprite_2d.animation != "jump":
			animated_sprite_2d.play("jump")

var is_dying = false

func _on_hazard_detector_area_entered(area):
	if is_dying:
		return
	is_dying = true
	_do_respawn()

func _do_respawn():
	velocity = Vector2.ZERO
	set_physics_process(false)
	$AnimatedSprite2D.scale = Vector2(4, 4)
	$AnimatedSprite2D.play("death")
	await $AnimatedSprite2D.animation_finished
	position = starting_position
	velocity = Vector2.ZERO
	$AnimatedSprite2D.scale = Vector2(0.121, 0.141)
	$AnimatedSprite2D.play("idle")
	camera_2d.reset_smoothing()
	set_physics_process(true)
	is_dying = false
