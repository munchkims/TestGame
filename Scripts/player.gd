extends Node2D
class_name Player

@onready var player_stats: PlayerStats = $PlayerStats
@onready var player_storage: ItemStorage = $PlayerStorage
@onready var player_storage_control: Control = $PlayerHUD/PlayerInventory


func _ready() -> void:
	player_storage_control.create_player_inventory(player_storage)
	player_storage_control.item_removed.connect(_on_item_removed)

func has_key() -> bool:
	return true

func add_key() -> void:
	pass


func add_item(item: Item) -> bool:
	if player_storage.add_item(item):
		return true
	else:
		return false


func _on_item_removed(item_removed: Item) -> void:
	player_storage.remove_item(item_removed)