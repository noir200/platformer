extends Area2D
@export_file("*.tscn") var next_scene_path: String = "" 

func _ready():
	visible = false
	
	var portal_shape = get_node_or_null("CollisionShape2D")
	if portal_shape != null:
		portal_shape.set_deferred("disabled", true)
	else:
		print("[WARNING] Portal: Could not find CollisionShape2D node.")
	
	add_to_group("level_portal")

func activate_portal():
	print("[SYSTEM] Portal activated! Turning on collision grids.")
	visible = true
	
	var portal_shape = get_node_or_null("CollisionShape2D")
	if portal_shape != null:
		portal_shape.set_deferred("disabled", false)

func reset_portal_status():
	visible = false
	
	var portal_shape = get_node_or_null("CollisionShape2D")
	if portal_shape != null:
		portal_shape.set_deferred("disabled", true)

func _on_body_entered(body):
	if visible and (body.is_in_group("player") or body.name == "Player"):
		print("[PORTAL] Player entered! Transitioning scene...")
		if next_scene_path != "":
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("[WARNING] No next level path assigned! Reloading current scene to test...")
			get_tree().reload_current_scene()
