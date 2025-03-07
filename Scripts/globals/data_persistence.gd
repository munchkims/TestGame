extends Node

# Тут только открытые двери
var open_doors: Array = []

# Все items, которые надо сохранить
var tracked_items: Dictionary = {}

# Список spawned items, так как я это уже добавляла после того, как воплотила логику сохранения, поэтому решила сделать отдельный словарь как временное решение
var spawned_items: Dictionary = {}


func save_open_door(door_path: NodePath) -> void:
	if door_path not in open_doors:
		open_doors.append(door_path)


func remove_open_door(door_path: NodePath) -> void:
	open_doors.erase(door_path)


func is_door_open(door_path: NodePath) -> bool:
	return door_path in open_doors


func register_item(uuid: String, picked_up: bool) -> void:
	tracked_items[uuid] = picked_up


func is_picked_up(uuid: String) -> bool:
	if not tracked_items.has(uuid):
		return false
	else:
		return tracked_items[uuid]


func save_spawned_item(uuid: String, item_data: Item, pos: Vector2) -> void:
	var current_lvl: String = get_tree().current_scene.scene_file_path
	if not spawned_items.has(current_lvl):
		# Создаем список, который будет держать словари (не хотелось создавать доп класс, так как это так же было бы временным решением)
		spawned_items[current_lvl] = []
	
	spawned_items[current_lvl].append({
		"uuid": uuid,
		"item_data": item_data,
		"pos": pos
	})


func check_spawned_items() -> Array:
	var current_lvl: String = get_tree().current_scene.scene_file_path
	if spawned_items.has(current_lvl):
		return spawned_items[current_lvl]
	else:
		return []


func remove_spawned_item(uuid: String) -> void:
	# Не нужна итерация через весь словарь, так как items будут всегда удалены из сцены, где они были засповнены
	var current_lvl: String = get_tree().current_scene.scene_file_path
	for i_dict: Dictionary in spawned_items[current_lvl]:
		if i_dict["uuid"] == uuid:
			spawned_items[current_lvl].erase(i_dict) # Тут не делала обратный loop, так как удаляем всегда по одной


func reset() -> void:
	open_doors.clear()
	tracked_items.clear()


func reset_doors() -> void:
	if get_tree().current_scene.scene_file_path == "res://Scenes/main_game.tscn":
		for door_path: NodePath in open_doors:
			var door: Door = get_node(door_path)
			door.close()
	open_doors.clear()