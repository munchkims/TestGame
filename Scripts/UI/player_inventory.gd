extends Control

#var player: Player
var player_inventory: StorageControl

const STORAGE_SCENE: Resource = preload("res://Scenes/UI/storage_control.tscn")
const INV_ITEM: Resource = preload("res://Scenes/reusable/inventory_item.tscn")

signal inventory_open(is_open: bool)
signal item_removed(used_item: Item)

var use_btn: ActionButton
var discard_btn: ActionButton

var inventory_blocked: bool = false

var item_spawn_radius: float = 25.0


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
	var selected_item: Item = player_inventory.get_selected_item()
	if selected_item == null:
		return
	var spawned_item: InventoryItem = INV_ITEM.instantiate()
	spawned_item.generate_new_uuid()
	spawned_item.item_data = selected_item
	spawned_item.texture = selected_item.item_sprite
	spawned_item.is_spawned = true
	var item_container: Node = get_tree().current_scene.get_node("Pickables")
	item_container.add_child(spawned_item)
	var player_body: CharacterBody2D = GlobalManager.player.player_movement
	var pos: Vector2 = _choose_spawn_point(player_body, item_spawn_radius)
	if pos == Vector2.ZERO:
		spawned_item.queue_free()
		print("Didn't find a position to drop the item. BACK TO THE INVENTORY!")
		return
	spawned_item.global_position = pos
	DataPersistence.save_spawned_item(spawned_item.uuid, spawned_item.item_data, spawned_item.global_position)
	item_removed.emit(selected_item)
	_close_and_open_inv()
	

func _on_next_slot_selected() -> void:
	var selected_item: Item = player_inventory.get_selected_item()
	if use_btn.disabled:
		if selected_item == null || selected_item.is_usable:
			use_btn.disabled = false
	elif selected_item and !selected_item.is_usable:
		use_btn.disabled = true
	

func _close_and_open_inv() -> void:
	player_inventory.toggle_visibility()
	inventory_open.emit(player_inventory.visible)


func _door_popup_open(is_open: bool) -> void:
	inventory_blocked = is_open
	# Временное решение, на случай если вдруг прям перед тем, как появится окно, игрок нажмет Q
	if inventory_blocked and player_inventory.visible == true:
		player_inventory.toggle_visibility()


func _choose_spawn_point(player_body: CharacterBody2D, radius: float) -> Vector2:
	var max_attempts: int = 100
	var attempts: int = 0
	var pos: Vector2

	while attempts < max_attempts:
		pos = player_body.get_random_position_in_radius(radius, 20)
		if player_body.is_position_free(pos, false): # Тут false, то есть не считаем areas (так как решила, что нет смысла запрещать вещам падать друг на друга)
			break
		attempts += 1
	
	if attempts < max_attempts:
		return pos

	return Vector2.ZERO