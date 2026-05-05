extends CharacterBody2D

# --- INVENTORY CONFIG ---
const HOTBAR_SIZE := 8
const EXTRA_SIZE := 8

var hotbar: Array = []
var extra_inventory: Array = []

# --- UI REFERENCES ---
@onready var hotbar_ui = $"../CanvasLayer/Hotbar"
@onready var menu_inventory = $"../CanvasLayer/Menu"
@onready var anim = $AnimatedSprite2D

# --- MOVEMENT CONFIG ---
@export var walk_speed := 120.0
@export var run_speed := 220.0


func _ready():
	# Initialize inventory arrays
	hotbar.resize(HOTBAR_SIZE)
	extra_inventory.resize(EXTRA_SIZE)

	# Update hotbar UI
	hotbar_ui.update_hotbar(hotbar)


# ---------------------------------------------------------
# ADD ITEM (Stacks first, then empty slot, then overflow)
# ---------------------------------------------------------
func add_to_hotbar(item_name: String):
	# 1. Try to stack onto an existing item
	for i in range(hotbar.size()):
		if hotbar[i] != null and hotbar[i]["name"] == item_name:
			hotbar[i]["count"] += 1
			hotbar_ui.update_hotbar(hotbar)
			return

	# 2. Try to place in an empty slot
	for i in range(hotbar.size()):
		if hotbar[i] == null:
			hotbar[i] = {
				"name": item_name,
				"count": 1
			}
			hotbar_ui.update_hotbar(hotbar)
			return

	# 3. Hotbar full → send to extra inventory
	add_to_extra_inventory(item_name)


# ---------------------------------------------------------
# EXTRA INVENTORY (simple overflow)
# ---------------------------------------------------------
func add_to_extra_inventory(item_name: String):
	for i in range(extra_inventory.size()):
		if extra_inventory[i] == null:
			extra_inventory[i] = {
				"name": item_name,
				"count": 1
			}
			menu_inventory.update_inventory(extra_inventory)
			return


# ---------------------------------------------------------
# ESC KEY — OPEN/CLOSE MENU
# ---------------------------------------------------------
func _input(event):
	if event.is_action_pressed("menu"):
		menu_inventory.toggle(extra_inventory)


# ---------------------------------------------------------
# MOVEMENT (disabled while menu is open)
# ---------------------------------------------------------
func _physics_process(_delta):
	if menu_inventory.is_open:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	var is_running := Input.is_action_pressed("run")
	var speed := run_speed if is_running else walk_speed

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
		play_move_animation(input_vector)
	else:
		velocity = Vector2.ZERO
		anim.play("idle")

	move_and_slide()


# ---------------------------------------------------------
# ANIMATION
# ---------------------------------------------------------
func play_move_animation(dir: Vector2):
	var anim_name := ""

	if abs(dir.x) > abs(dir.y):
		anim_name = "move_right" if dir.x > 0 else "move_left"
	else:
		anim_name = "move_down" if dir.y > 0 else "move_up"

	anim.play(anim_name)
