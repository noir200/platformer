extends CanvasLayer

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_screen():
	if not is_inside_tree():
		return
	show()
	get_tree().paused = true
