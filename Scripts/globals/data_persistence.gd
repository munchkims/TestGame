extends Node

# Тут только открытые двери
var open_doors: Array = []

# Все items, которые надо сохранить
var tracked_items: Dictionary = {}


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


func reset() -> void:
	open_doors.clear()
	tracked_items.clear()


func reset_doors() -> void:
	open_doors.clear()