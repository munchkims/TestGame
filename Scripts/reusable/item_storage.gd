extends Node2D
class_name ItemStorage

@export var storage_cap: int = 24

var capacity: int
var storage: Array = []

# func _init(storage_capacity: int) -> void:
#     capacity = storage_capacity
#     storage.resize(capacity)


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
	return true


func remove_item(index: int) -> Item:
	if index >= 0 and index < storage.size():
		if storage[index] == null:
			return null
		var removed_item: Item = storage[index]
		storage.remove_at(index)
		storage.append(null)
		return removed_item
	else:
		printerr("index is out of bounds.")
		return null


func resize_storage(new_capacity: int) -> void:
	storage.resize(new_capacity)
