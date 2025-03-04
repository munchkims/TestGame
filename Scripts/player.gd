extends Node2D
class_name Player

@onready var player_stats: PlayerStats = $PlayerStats
@onready var player_inventory: ItemStorage = $PlayerInventory

func has_key() -> bool:
	return true

func add_key() -> void:
	pass


func add_item(item: Item) -> bool:
	if player_inventory.add_item(item):
		return true
	else:
		return false