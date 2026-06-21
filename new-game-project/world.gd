extends Node2D

@onready var level_completed = $"Node/Level Completed"
var total_coins = 0

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	total_coins = get_tree().get_nodes_in_group("coins").size()

	for coin in get_tree().get_nodes_in_group("coins"):
		coin.tree_exited.connect(_on_coin_collected)

func _on_coin_collected():
	total_coins -= 1
	if total_coins <= 0:
		level_completed.show_screen()
		
