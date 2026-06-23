@tool
extends Node2D

@export var build : bool = false :
	set(v):
		if v and Engine.is_editor_hint():
			build_background()
			build = false

# Level bounds (world space)
const LEVEL_X_START = -192
const LEVEL_X_END   = 1120
const LEVEL_Y_TOP   = -128
const LEVEL_Y_BOT   = 448
const LEVEL_W       = 1312  # 1120 - (-192)
const LEVEL_H       = 576   # 448 - (-128)

func build_background():
	print("Building mossy background...")
	var parent = get_parent()
	for layer_name in ["BackgroundDeco", "MossyHills", "HangingPlants"]:
		var layer = parent.get_node_or_null(layer_name)
		if layer:
			for child in layer.get_children():
				child.queue_free()
	_build_background_deco()
	_build_mossy_hills()
	_build_hanging_plants()
	print("Done!")

func _add_sprite(layer_name: String, tex_path: String,
				 col: int, row: int, tile_px: int,
				 pos: Vector2, sc: Vector2,
				 color: Color = Color.WHITE) -> void:
	var layer = get_parent().get_node_or_null(layer_name)
	if not layer:
		push_error("Layer not found: " + layer_name); return
	var tex = load(tex_path)
	if not tex:
		push_error("Texture not found: " + tex_path); return
	var s = Sprite2D.new()
	s.texture = tex
	s.region_enabled = true
	s.region_rect = Rect2(col * tile_px, row * tile_px, tile_px, tile_px)
	s.scale = sc
	s.position = pos
	s.modulate = color
	layer.add_child(s)
	s.owner = get_tree().edited_scene_root

func _add_strip(layer_name: String, tex_path: String,
				col: int, region_y: int, region_h: int,
				pos: Vector2, sc: Vector2,
				color: Color = Color.WHITE) -> void:
	var layer = get_parent().get_node_or_null(layer_name)
	if not layer:
		push_error("Layer not found: " + layer_name); return
	var tex = load(tex_path)
	if not tex:
		push_error("Texture not found: " + tex_path); return
	var s = Sprite2D.new()
	s.texture = tex
	s.region_enabled = true
	s.region_rect = Rect2(col * 512, region_y, 512, region_h)
	s.scale = sc
	s.position = pos
	s.modulate = color
	layer.add_child(s)
	s.owner = get_tree().edited_scene_root

func _build_background_deco():
	# Large atmospheric moss blob silhouettes — far back layer
	# Best tiles: [3,3]=100%, [6,3]=99%, [1,1]=93%, [3,1]=94%, [6,1]=100%
	# Spread across full level width x=-192 to x=1120
	# Sit in upper portion of level: y=-128 to y=100
	var p = "res://Mossy - BackgroundDecoration.png"
	var deep = Color(0.18, 0.40, 0.34, 0.80)
	var mid  = Color(0.25, 0.52, 0.42, 0.88)

	# scale 0.14 = 512*0.14 = ~72px per blob on screen — nice large shapes
	# [col, row, world_x, world_y, sx, sy, color]
	var tiles = [
		# Left zone (x: -192 to 100)
		[3, 3, -192, -80, 0.16, 0.18, deep],
		[6, 1, -110, -95, 0.14, 0.16, mid],
		[1, 1,  -30, -75, 0.15, 0.17, deep],
		[3, 1,   60, -90, 0.13, 0.15, mid],
		# Center-left (x: 100 to 400)
		[6, 3,  130, -85, 0.16, 0.18, deep],
		[1, 3,  220, -70, 0.14, 0.16, mid],
		[3, 3,  310, -88, 0.15, 0.17, deep],
		[5, 3,  395, -75, 0.13, 0.15, mid],
		# Center (x: 400 to 700)
		[6, 1,  450, -90, 0.16, 0.18, deep],
		[1, 1,  540, -72, 0.14, 0.16, mid],
		[3, 1,  628, -85, 0.15, 0.17, deep],
		[0, 3,  715, -78, 0.13, 0.15, mid],
		# Center-right (x: 700 to 950)
		[6, 3,  760, -92, 0.16, 0.18, deep],
		[3, 3,  848, -70, 0.14, 0.16, mid],
		[1, 3,  930, -86, 0.15, 0.17, deep],
		# Right zone (x: 950 to 1120)
		[6, 1,  990, -75, 0.13, 0.15, mid],
		[3, 1, 1055, -88, 0.16, 0.18, deep],
		[1, 1, 1090, -70, 0.14, 0.16, mid],
	]
	for t in tiles:
		_add_sprite("BackgroundDeco", p, t[0], t[1], 512,
					Vector2(t[2], t[3]), Vector2(t[4], t[5]), t[6])

func _build_mossy_hills():
	# Rounded hill silhouettes — mid layer
	# Best tiles: [2,0]=82%, [2,1]=72%, [2,2]=77%, [1,3]=79%
	# Sit near bottom of level — y around 350 to 420
	# (level bottom is y=448, so hills peek above ground tiles)
	var p = "res://Mossy - MossyHills.png"
	var lush   = Color(0.42, 0.80, 0.50, 1.00)
	var shadow = Color(0.28, 0.60, 0.38, 0.95)

	# scale 0.14 = 512*0.14 = ~72px — good chunky hill size
	# Two rows: back row higher up (more transparent), front row on ground line
	# [col, row, world_x, world_y, sx, sy, color]
	var tiles = [
		# Back row — y=310, darker
		[2, 0, -192, 310, 0.14, 0.12, shadow],
		[2, 1,  -80, 305, 0.16, 0.13, shadow],
		[2, 2,   50, 312, 0.14, 0.12, shadow],
		[1, 3,  175, 308, 0.15, 0.13, shadow],
		[2, 0,  300, 305, 0.16, 0.12, shadow],
		[2, 1,  425, 310, 0.14, 0.13, shadow],
		[2, 2,  550, 307, 0.15, 0.12, shadow],
		[1, 3,  670, 312, 0.16, 0.13, shadow],
		[2, 0,  790, 308, 0.14, 0.12, shadow],
		[2, 1,  910, 305, 0.15, 0.13, shadow],
		[2, 2, 1020, 310, 0.16, 0.12, shadow],
		# Front row — y=355, lush green
		[2, 0, -192, 355, 0.16, 0.14, lush],
		[2, 2,  -55, 350, 0.18, 0.15, lush],
		[2, 1,   85, 357, 0.16, 0.14, lush],
		[1, 3,  220, 352, 0.17, 0.15, lush],
		[2, 0,  355, 356, 0.18, 0.14, lush],
		[2, 2,  490, 350, 0.16, 0.15, lush],
		[2, 1,  625, 354, 0.17, 0.14, lush],
		[1, 3,  755, 350, 0.18, 0.15, lush],
		[2, 0,  885, 356, 0.16, 0.14, lush],
		[2, 2, 1010, 352, 0.17, 0.15, lush],
	]
	for t in tiles:
		_add_sprite("MossyHills", p, t[0], t[1], 512,
					Vector2(t[2], t[3]), Vector2(t[4], t[5]), t[6])

func _build_hanging_plants():
	# Long draping vines from top of level
	# Confirmed: cols 0 and 1, rows 3+4 are the long vines
	# region_y=1536, region_h=1024 captures both rows 3 and 4
	# Hang from y=LEVEL_Y_TOP=-128, spread across full level width
	var p = "res://Mossy - Hanging Plants.png"
	var bright = Color(0.58, 0.88, 0.62, 0.95)
	var dark   = Color(0.38, 0.65, 0.44, 0.85)

	# scale x=0.10 → 512*0.10 = ~51px wide per vine
	# scale y=0.22 → 1024*0.22 = ~225px tall — drapes nicely from top
	# Spread vines every ~110px across level width
	# [col (0 or 1), world_x, sx, sy, color]
	var strips = [
		[0, -192, 0.10, 0.22, bright],
		[1,  -80, 0.10, 0.22, dark],
		[0,   30, 0.10, 0.22, bright],
		[1,  140, 0.10, 0.22, dark],
		[0,  250, 0.10, 0.22, bright],
		[1,  360, 0.10, 0.22, dark],
		[0,  470, 0.10, 0.22, bright],
		[1,  580, 0.10, 0.22, dark],
		[0,  690, 0.10, 0.22, bright],
		[1,  800, 0.10, 0.22, dark],
		[0,  910, 0.10, 0.22, bright],
		[1, 1020, 0.10, 0.22, dark],
	]
	for s in strips:
		_add_strip("HangingPlants", p, s[0], 1536, 1024,
				   Vector2(s[1], LEVEL_Y_TOP), Vector2(s[2], s[3]), s[4])
