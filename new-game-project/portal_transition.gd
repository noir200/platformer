extends CanvasLayer

var next_scene = ""

@onready var anim = $Anim

func _ready():
	anim.visible = false
	anim.animation_finished.connect(_on_animation_done)

func play_transition(scene_path: String):
	next_scene = scene_path
	anim.visible = true
	anim.play("play")

func _on_animation_done():
	get_tree().change_scene_to_file(next_scene)
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		var transition = get_tree().root.find_child("PortalTransition", true, false)
		if transition:
			transition.play_transition("res://level_2.tscn")
		else:
			get_tree().change_scene_to_file("res://level_2.tscn")
