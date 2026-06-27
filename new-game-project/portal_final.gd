extends Area2D

@onready var anim = $AnimatedSprite2D
var transitioning = false

func _ready():
	visible = false
	transitioning = false
	var portal_shape = get_node_or_null("CollisionShape2D")
	if portal_shape != null:
		portal_shape.set_deferred("disabled", true)
	add_to_group("level_portal")

func activate_portal():
	visible = true
	anim.play("spin")
	var portal_shape = get_node_or_null("CollisionShape2D")
	if portal_shape != null:
		portal_shape.set_deferred("disabled", false)

func reset_portal_status():
	visible = false
	transitioning = false
	var portal_shape = get_node_or_null("CollisionShape2D")
	if portal_shape != null:
		portal_shape.set_deferred("disabled", true)

func _on_body_entered(body):
	if body.is_in_group("player") and not transitioning:
		transitioning = true
		get_tree().change_scene_to_file("res://victory_scene.tscn")
