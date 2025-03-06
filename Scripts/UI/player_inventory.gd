extends Control

#var player: Player
var player_inventory: StorageControl

const STORAGE_SCENE: Resource = preload("res://Scenes/UI/storage_control.tscn")

signal inventory_open(is_open: bool)
signal item_removed(used_item: Item)

var use_btn: ActionButton
var discard_btn: ActionButton

var inventory_blocked: bool = false


func create_player_inventory(storage: ItemStorage) -> void:
	player_inventory = STORAGE_SCENE.instantiate()
	player_inventory.storage = storage
	add_child(player_inventory)
	use_btn = add_buttons("Использовать", _on_use_button_pressed)
	discard_btn = add_buttons("Выбросить", _on_discard_button_pressed)
	player_inventory.new_selection.connect(_on_next_slot_selected)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Inv") and not inventory_blocked:
		_close_and_open_inv()


func add_buttons(btn_name: String, btn_func: Callable) -> ActionButton:
	var new_btn: ActionButton = player_inventory.add_button(btn_name)
	if new_btn == null:
		printerr("no more button space.")
		return null
	new_btn.pressed.connect(btn_func)
	return new_btn


func _on_use_button_pressed() -> void:
	var selected_item: Item = player_inventory.get_selected_item()
	if selected_item == null:
		return
	selected_item.use_func.call()
	if not selected_item.is_reusable:
		item_removed.emit(selected_item)
	_close_and_open_inv()


func _on_discard_button_pressed() -> void:
	print("discard button pressed!")


func _on_next_slot_selected() -> void:
	var selected_item: Item = player_inventory.get_selected_item()
	if use_btn.disabled:
		if selected_item == null || selected_item.is_usable:
			use_btn.disabled = false
	elif selected_item and !selected_item.is_usable:
		use_btn.disabled = true
	

func _fetch_player() -> Player:
	var main_game: Node = get_tree().get_root().get_node("MainGame")
	if main_game:
		return main_game.get_node_or_null("Player")
	return null


func _close_and_open_inv() -> void:
	player_inventory.toggle_visibility()
	inventory_open.emit(player_inventory.visible)


func _door_popup_open(is_open: bool) -> void:
	inventory_blocked = is_open
	# Временное решение, на случай если вдруг прям перед тем, как появится окно, игрок нажмет Q
	if inventory_blocked and player_inventory.visible == true:
		player_inventory.toggle_visibility()
