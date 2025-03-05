extends Control

#var player: Player
var player_inventory: StorageControl

const STORAGE_SCENE: Resource = preload("res://Scenes/UI/storage_control.tscn")

signal inventory_open(is_open: bool)

var use_btn: ActionButton
var discard_btn: ActionButton

# func _ready() -> void:
# 	player = _fetch_player()
# 	if player == null:
# 		printerr("No player found!")
# 	player_inventory = STORAGE_SCENE.instantiate()
# 	player_inventory.storage = player.player_inventory
# 	add_child(player_inventory)
# 	use_btn = add_buttons("Использовать", _on_use_button_pressed)
# 	discard_btn = add_buttons("Выбросить", _on_discard_button_pressed)

func create_player_inventory(storage: ItemStorage) -> void:
	player_inventory = STORAGE_SCENE.instantiate()
	player_inventory.storage = storage
	add_child(player_inventory)
	use_btn = add_buttons("Использовать", _on_use_button_pressed)
	discard_btn = add_buttons("Выбросить", _on_discard_button_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Inv"):
		player_inventory.toggle_visibility()
		inventory_open.emit(player_inventory.visible)


func add_buttons(btn_name: String, btn_func: Callable) -> ActionButton:
	var new_btn: ActionButton = player_inventory.add_button(btn_name)
	if new_btn == null:
		printerr("no more button space.")
		return null
	new_btn.pressed.connect(btn_func)
	return new_btn


func _on_use_button_pressed() -> void:
	print("used button pressed!")


func _on_discard_button_pressed() -> void:
	print("discard button pressed!")


func _fetch_player() -> Player:
	var main_game: Node = get_tree().get_root().get_node("MainGame")
	if main_game:
		return main_game.get_node_or_null("Player")
	return null