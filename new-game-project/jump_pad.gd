extends Area2D

@export var launch_force: float = -1000.0
@export var shake_duration: float = 0.3
@export var shake_strength: float = 8.0

func _ready():
	$AnimatedSprite2D.play("spin")

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.velocity.y = launch_force
		var cam = body.get_node_or_null("Camera2D")
		if cam:
			shake_camera(cam)

func shake_camera(cam: Camera2D):
	var elapsed = 0.0
	while elapsed < shake_duration:
		var strength = shake_strength * (1.0 - elapsed / shake_duration)
		cam.offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		elapsed += get_process_delta_time()
		await get_tree().process_frame
	cam.offset = Vector2.ZERO
