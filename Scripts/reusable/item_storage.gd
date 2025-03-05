extends Node2D
class_name ItemStorage

@export var storage_cap: int = 24

var capacity: int
var storage: Array = []

signal storage_resized
signal item_added(item: Item)
signal item_removed(item: Item)


func _ready() -> void:
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
	print(storage)
	return true


func remove_item(item: Item) -> Item:
	var index: int = storage.find(item)
	if index != 1:
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
	capacity = new_capacity
	storage.resize(capacity)
	storage_resized.emit()
