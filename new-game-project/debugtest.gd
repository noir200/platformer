extends CharacterBody2D
@export var patrol_speed : float = 160.0
@export var accel : float = 700.0
@export var gravity_scale : float = 2.2
@export var enemy_scale : Vector2 = Vector2(0.8, 0.8)
var current_state : String = "patrol"
var facing_right : bool = true
var direction : int = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var spawn_pos : Vector2 = Vector2.ZERO
var idle_timer : float = 0.0
@onready var sprite = $AnimatedSprite2D

func _ready():
	spawn_pos = global_position
	current_state = "patrol"
	direction = 1
	facing_right = true
	self.scale = enemy_scale

func _physics_process(delta):

	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
		if velocity.y > 800.0:
			velocity.y = 800.0
	else:
		velocity.y = 0

	if current_state == "idle":
		velocity.x = move_toward(velocity.x, 0, 1000 * delta)
		if sprite != null:
			sprite.play("idle")
		idle_timer -= delta
		if idle_timer <= 0.0:
			current_state = "patrol"

	elif current_state == "patrol":
		if sprite != null:
			sprite.play("walk")

		if is_on_wall() or check_if_at_ledge():
			direction = direction * -1
			current_state = "idle"
			idle_timer = randf_range(0.5, 1.2)
		else:
			velocity.x = move_toward(velocity.x, direction * patrol_speed, accel * delta)

	if sprite != null and abs(velocity.x) > 1.0:
		sprite.flip_h = (direction == 1)

	move_and_slide()

	check_player_killing_collision()

func check_if_at_ledge() -> bool:
	if not is_on_floor():
		return false

	var sensor_look_ahead = 24.0 * direction
	var sensor_down_depth = 48.0

	var check_pos = global_position + Vector2(sensor_look_ahead, sensor_down_depth)
	var physics_space = get_world_2d().direct_space_state

	if physics_space != null:
		var point_query = PhysicsPointQueryParameters2D.new()
		point_query.position = check_pos
		point_query.collision_mask = 1
		point_query.exclude = [self]

		return physics_space.intersect_point(point_query).size() == 0
	return false

func check_player_killing_collision():
	var maximum_contacts = get_slide_collision_count()

	for i in range(maximum_contacts):
		var collision = get_slide_collision(i)
		var target = collision.get_collider()

		if is_instance_valid(target):
			if target.is_in_group("player") or target.name == "Player":
				execute_player_termination_sequence(target)

func execute_player_termination_sequence(player_instance):
	print("[ALERT] Player touched! Teleporting target back to starting boundaries...")

	if is_instance_valid(player_instance):
		if "starting_position" in player_instance:
			player_instance.global_position = player_instance.starting_position
		else:
			player_instance.global_position = Vector2(100, 100)

		player_instance.velocity = Vector2.ZERO

	global_position = spawn_pos
	velocity = Vector2.ZERO
	current_state = "patrol"
	direction = 1
	idle_timer = 0.0

	get_tree().call_group("respawnable_coins", "respawn_coin")
	get_tree().call_group("level_portal", "reset_portal_status")
