extends Node2D

# 1. Point this directly to your actual Portal node
@onready var portal = $Portal 
var total_coins = 0

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	# 2. Make sure the portal is hidden when the game starts
	if portal:
		portal.hide() 
	
	total_coins = get_tree().get_nodes_in_group("coins").size()
	
	for coin in get_tree().get_nodes_in_group("coins"):
		coin.tree_exited.connect(_on_coin_collected)

func _on_coin_collected():
	total_coins -= 1
	if total_coins <= 0:
		if portal:
			portal.show()
