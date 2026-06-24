extends Control

func _ready():
	$VBoxContainer/start.pressed.connect(_on_play_pressed)
	$VBoxContainer/quit.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://world_copy.tscn")

func _on_quit_pressed():
	get_tree().quit()
