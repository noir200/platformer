extends Node2D

func _ready():
	$Label.text = "Game Completed"

func _on_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
