extends Node2D
class_name Player

@onready var player_stats: PlayerStats = $PlayerStats
@onready var player_storage: ItemStorage = $PlayerStorage
@onready var player_storage_control: Control = $PlayerHUD/PlayerInventory
@onready var player_main_HUD: Control = $PlayerHUD/MainHUD
@onready var player_movement: CharacterBody2D = $PlayerMovement


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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		var received_text: String = player_movement.is_near_interactable()
		if received_text != "":
			player_main_HUD.show_pop_up(received_text)
