extends Area2D

# ==============================================================================
# COIN LIFETIME CONTROLLER (CRASH-PROOF POOLING)
# ==============================================================================

var is_collected : bool = false

func _ready():
	z_index = 5
	is_collected = false
	
	add_to_group("respawnable_coins")
	
	if not is_in_group("coins"):
		add_to_group("coins")

func _on_body_entered(body):
	if not is_collected and (body.is_in_group("player") or body.name == "Player"):
		execute_coin_collection()

func execute_coin_collection():
	is_collected = true
	visible = false
	
	# CRASH-PROOF: Safely search for the shape node before disabling
	var coin_shape = get_node_or_null("CollisionShape2D")
	if coin_shape != null:
		coin_shape.set_deferred("disabled", true)
	else:
		print("[WARNING] Coin: Could not find CollisionShape2D node.")
		
	if is_in_group("coins"):
		remove_from_group("coins")
	
	print("[ITEM] Coin hidden and removed from group pool.")
	check_global_win_condition()

func respawn_coin():
	if is_collected:
		is_collected = false
		visible = true
		
		# CRASH-PROOF: Safely search for the shape node before enabling
		var coin_shape = get_node_or_null("CollisionShape2D")
		if coin_shape != null:
			coin_shape.set_deferred("disabled", false)
			
		if not is_in_group("coins"):
			add_to_group("coins")
			
		print("[ITEM_RESET] Coin restored to counting registry.")

func check_global_win_condition():
	var remaining_coins = get_tree().get_nodes_in_group("coins").size()
	
	if remaining_coins == 0:
		print("[SYSTEM] All coins collected! Revealing escape portal node...")
		get_tree().call_group("level_portal", "activate_portal")
