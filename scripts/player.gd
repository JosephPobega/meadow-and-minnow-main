extends CharacterBody2D

# ---------------------------------------------------------
# INVENTORY CONFIG
# ---------------------------------------------------------
const HOTBAR_SIZE := 6
const EXTRA_SIZE := 8

var hotbar: Array = []
var extra_inventory: Array = []
var selected_index: int = 0

# ---------------------------------------------------------
# TILE CONSTANTS
# ---------------------------------------------------------
const GRASS_ATLAS := Vector2i(9, 2)
const TILLED_ATLAS := Vector2i(9, 10)
const WET_ATLAS := Vector2i(9, 11)
const PLANTED_ATLAS := Vector2i(5, 10)


# ---------------------------------------------------------
# NODE REFERENCES
# ---------------------------------------------------------
@onready var hotbar_ui = $"../CanvasLayer/Hotbar"
@onready var menu_inventory = $"../CanvasLayer/Menu"
@onready var anim = $AnimatedSprite2D
@onready var tilemap = $"../TileMap"

# ---------------------------------------------------------
# MOVEMENT CONFIG
# ---------------------------------------------------------
@export var walk_speed: float = 120.0
@export var run_speed: float = 220.0

var last_dir: Vector2 = Vector2.DOWN
var is_using_tool: bool = false

# ---------------------------------------------------------
# READY
# ---------------------------------------------------------
func _ready():
	hotbar.resize(HOTBAR_SIZE)
	extra_inventory.resize(EXTRA_SIZE)
	hotbar_ui.update_hotbar(hotbar)
	hotbar_ui.center_selector_later(selected_index)

# ---------------------------------------------------------
# HOTBAR HELPERS
# ---------------------------------------------------------
func get_selected_item():
	return hotbar[selected_index]

func select_slot(index: int):
	selected_index = index
	hotbar_ui.update_selector(index)

# ---------------------------------------------------------
# ADD ITEM TO HOTBAR
# ---------------------------------------------------------
func add_to_hotbar(item_data):

	# 1. Try stacking
	for i in range(hotbar.size()):
		if hotbar[i] != null and hotbar[i]["name"] == item_data["name"]:
			hotbar[i]["count"] += 1
			hotbar_ui.update_hotbar(hotbar)
			return

	# 2. Empty slot
	for i in range(hotbar.size()):
		if hotbar[i] == null:
			item_data["count"] = 1
			hotbar[i] = item_data
			hotbar_ui.update_hotbar(hotbar)
			return

	# 3. Overflow
	add_to_extra_inventory(item_data)

func add_to_extra_inventory(item_data):
	for i in range(extra_inventory.size()):
		if extra_inventory[i] == null:
			extra_inventory[i] = item_data
			extra_inventory[i]["count"] = 1
			menu_inventory.update_inventory(extra_inventory)
			return

# ---------------------------------------------------------
# INPUT
# ---------------------------------------------------------
func _input(event):

	# Number keys (1–6)
	if event.is_action_pressed("hotbar_1"): select_slot(0)
	if event.is_action_pressed("hotbar_2"): select_slot(1)
	if event.is_action_pressed("hotbar_3"): select_slot(2)
	if event.is_action_pressed("hotbar_4"): select_slot(3)
	if event.is_action_pressed("hotbar_5"): select_slot(4)
	if event.is_action_pressed("hotbar_6"): select_slot(5)

	# Menu toggle
	if event.is_action_pressed("menu"):
		menu_inventory.toggle(extra_inventory)

	# Tool use (F key)
	if event.is_action_pressed("action"):
		var item = get_selected_item()
		if item != null and item.has("tool") and item["tool"] != null:
			item["tool"].use(self)

# ---------------------------------------------------------
# MOVEMENT
# ---------------------------------------------------------
func _physics_process(_delta):

	if is_using_tool or menu_inventory.is_open:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	var speed := run_speed if Input.is_action_pressed("run") else walk_speed

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed

		# Force last_dir to 4 directions only
		if abs(input_vector.x) > abs(input_vector.y):
			last_dir = Vector2(sign(input_vector.x), 0)
		else:
			last_dir = Vector2(0, sign(input_vector.y))

		play_move_animation(last_dir)

	else:
		velocity = Vector2.ZERO
		anim.play("idle")

	move_and_slide()

# ---------------------------------------------------------
# MOVE ANIMATION
# ---------------------------------------------------------
func play_move_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		anim.play("move_right" if dir.x > 0 else "move_left")
	else:
		anim.play("move_down" if dir.y > 0 else "move_up")

# ---------------------------------------------------------
# TILE INTERACTION HELPERS
# ---------------------------------------------------------
func get_facing_tile() -> Vector2i:
	var base_size: Vector2 = Vector2(tilemap.tile_set.tile_size)
	var scaled_size: Vector2 = base_size * tilemap.scale
	var world_pos = global_position + last_dir * scaled_size
	return tilemap.local_to_map(world_pos)

func get_atlas(tile_pos: Vector2i) -> Vector2i:
	return tilemap.get_cell_atlas_coords(0, tile_pos)

func can_till(tile_pos: Vector2i) -> bool:
	return get_atlas(tile_pos) == GRASS_ATLAS


func till(tile_pos: Vector2i):
	tilemap.set_cell(0, tile_pos, 0, TILLED_ATLAS)


func can_water(tile_pos: Vector2i) -> bool:
	return get_atlas(tile_pos) == TILLED_ATLAS 
	
func water(tile_pos: Vector2i):
	if can_water(tile_pos):
		tilemap.set_cell(0, tile_pos, 0, WET_ATLAS)

func can_plant(tile_pos: Vector2i) -> bool:
	var atlas := get_atlas(tile_pos)
	return atlas == TILLED_ATLAS or atlas == WET_ATLAS

func plant_seed(tile_pos: Vector2i):
	tilemap.set_cell(0, tile_pos, 0, Vector2i(9, 10))
