extends Control

#var player: Player
var player_inventory: StorageControl

const STORAGE_SCENE: Resource = preload("res://Scenes/UI/storage_control.tscn")
const INV_ITEM: Resource = preload("res://Scenes/reusable/inventory_item.tscn")

signal inventory_open(is_open: bool)
signal item_removed(used_item: Item)
signal item_discarded(discarded_item: InventoryItem)

var use_btn: ActionButton
var discard_btn: ActionButton


var item_spawn_radius: float = 25.0

# Создаем storage control и кнопки, и подключаем их
func create_player_inventory(storage: ItemStorage) -> void:
	player_inventory = STORAGE_SCENE.instantiate()
	player_inventory.storage = storage
	add_child(player_inventory)
	use_btn = add_buttons("Использовать", _on_use_button_pressed)
	discard_btn = add_buttons("Выбросить", _on_discard_button_pressed)
	player_inventory.new_selection.connect(_on_next_slot_selected)


func add_buttons(btn_name: String, btn_func: Callable) -> ActionButton:
	var new_btn: ActionButton = player_inventory.add_button(btn_name)
	if new_btn == null:
		printerr("no more button space.")
		return null
	new_btn.pressed.connect(btn_func)
	return new_btn


# При нажатии на кнопку использовать, используем если есть, и потом убираем из инвентаря, и закрываем UI
func _on_use_button_pressed() -> void:
	var selected_item: Item = player_inventory.get_selected_item()
	if selected_item == null:
		return
	selected_item.use_func.call()
	if not selected_item.is_reusable:
		item_removed.emit(selected_item)
	close_and_open_inv()


# Тут создаем новую инстанцию InventoryItem, добавляем к ней данные item_data, отправляем информацию, что это новый сповн, генерируем uuid для сохранения
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
	# Решила остальные вещи оставить на распоряжение Player скрипта, так как иначе нужен референс к playermovement, и я не хочу, чтоб этот скрипт о нем знал
	item_discarded.emit(spawned_item)
	

func remove_item(removed_item: Item) -> void:
	item_removed.emit(removed_item)
	if player_inventory.visible:
		close_and_open_inv()
	

func _on_next_slot_selected() -> void:
	var selected_item: Item = player_inventory.get_selected_item()
	if selected_item == null:
		use_btn.disabled = true
		discard_btn.disabled = true
		return
	if use_btn.disabled:
		if selected_item.is_usable:
			use_btn.disabled = false
	elif not selected_item.is_usable:
		use_btn.disabled = true
	discard_btn.disabled = false
	

func close_and_open_inv() -> void:
	player_inventory.toggle_visibility()
	inventory_open.emit(player_inventory.visible)


# Выбираем место, куда выкинуть предмет. Ограничение минимального радиуса для того, чтобы игрок не подобрал его сразу
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