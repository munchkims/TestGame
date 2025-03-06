extends Node2D
class_name ItemStorage

@export_range(0, MAX_CAPACITY) var storage_cap: int = 12

const MAX_CAPACITY: int = 40 # Взяла максимальную цифру, которая красиво помещается в инвентаре.

var capacity: int
var storage: Array = []

signal storage_resized
signal item_added(item: Item)
signal item_removed(item: Item)


func _ready() -> void:
	# По сути, из-за export_range это не обязательно, это больше для перестраховки и потенциальноо расширения кода для динамического создания хранилища
	if not (0 <= storage_cap and storage_cap <= MAX_CAPACITY):
		storage_cap = clamp(storage_cap, 0, MAX_CAPACITY)
	
	if capacity == 0:
		capacity = storage_cap
		storage.resize(capacity)


func add_item(item: Item) -> bool:
	if storage.all(func(i: Item) -> bool: return i != null):
		print("Inventory is full.")
		return false
	
	var index: int = storage.find(null)
	storage[index] = item
	print("added: ", item.item_name)
	item_added.emit(item)
	return true


func remove_item(item: Item) -> Item:
	var index: int = storage.find(item)
	if index != -1:
		var removed_item: Item = storage[index]
		storage.remove_at(index)
		storage.append(null)
		item_removed.emit(removed_item)
		return removed_item
	else:
		printerr("the item to remove was not found.")
		return null

	# if index >= 0 and index < storage.size():
	# 	if storage[index] == null:
	# 		return null
	# 	var removed_item: Item = storage[index]
	# 	storage.remove_at(index)
	# 	storage.append(null)
	# 	item_removed.emit(removed_item)
	# 	return removed_item
	# else:
	# 	printerr("index is out of bounds.")
	# 	return null


func resize_storage(new_capacity: int) -> void:
	if not (0 <= new_capacity and new_capacity <= MAX_CAPACITY):
		new_capacity = clamp(new_capacity, 0, MAX_CAPACITY)
	
	capacity = new_capacity
	storage.resize(capacity)
	storage_resized.emit()
