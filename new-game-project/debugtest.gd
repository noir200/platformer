extends CharacterBody2D

# ==============================================================================
# UNIFIED ENEMY CHARACTER CONTROLLER - ACADEMIC DEVELOPMENT COMPONENT
# TASK COMPILATION TARGET: LEDGE RECOVERY AND SCALE ADJUSTMENT PATCH
# DESCRIPTION: Fixed direction sensor offsets for uniform left/right edge detection.
# ==============================================================================

# --- EXPORT ADJUSTMENT PARAMETERS ---
# SPEED BOOSTED AGAIN: Bumped up further so it acts like a fast, dangerous patrol unit!
@export var patrol_speed : float = 160.0
@export var accel : float = 700.0
@export var gravity_scale : float = 2.2

# --- SYSTEM MANAGEMENT STATUS TRACKERS ---
var current_state : String = "patrol" 
var facing_right : bool = true        
var direction : int = 1               

# --- PHYSICS AND CORE SCENE REGISTER ENGINE CONTEXTS ---
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var spawn_pos : Vector2 = Vector2.ZERO

# --- STATE LIFETIME REGISTER TIMERS ---
var idle_timer : float = 0.0

@onready var sprite = $AnimatedSprite2D

func _ready():
	# Capture the exact initial footprint vector so we can snap back on death loops
	spawn_pos = global_position
	current_state = "patrol"
	direction = 1
	facing_right = true
	
	# ==========================================================================
	# SOLUTION FOR: "How to make the monster smaller"
	# ==========================================================================
	self.scale = Vector2(0.5, 0.5)

func _physics_process(delta):
	# Apply normal gravity calculations
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
		if velocity.y > 800.0:
			velocity.y = 800.0
	else:
		velocity.y = 0

	# State Logic Calculations
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
		
		# ======================================================================
		# SOLUTION FOR: "Monster falls down going left, but turns when going right"
		# ======================================================================
		if is_on_wall() or check_if_at_ledge():
			direction = direction * -1
			current_state = "idle"
			idle_timer = randf_range(0.5, 1.2)
		else:
			velocity.x = move_toward(velocity.x, direction * patrol_speed, accel * delta)

	# ==========================================================================
	# FIXED: REVERSED HORIZONTAL SPRITE DIRECTION MIRROR GATES
	# ==========================================================================
	if sprite != null and abs(velocity.x) > 1.0:
		sprite.flip_h = (direction == 1)

	# Execute final physical position updates
	move_and_slide()
	
	# Evaluate contacts to detect if it struck the player.
	check_player_killing_collision()

func check_if_at_ledge() -> bool:
	if not is_on_floor(): 
		return false
		
	# --- SYMMETRICAL SENSOR MATRIX CORRECTION ---
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

# ==============================================================================
# SUBROUTINE LOGIC: INSTANT TERMINATION ROUTING
# ==============================================================================
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
