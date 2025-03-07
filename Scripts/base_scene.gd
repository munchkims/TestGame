extends Node2D
class_name BaseScene

@export var level_floor: NodePath

@onready var player: Player = get_node_or_null("Player")
@onready var door_cont: Node2D = $Doors
@onready var item_container: Node2D = $Pickables

const INV_ITEM: Resource = preload("res://Scenes/reusable/inventory_item.tscn")

var tile_layer: TileMapLayer

func _ready() -> void:
	tile_layer = get_node(level_floor)
	if SceneTransitionManager.saved_player:
		if player:
			# Otherwise it gets freed at the end of the frame, causing the naming issue
			remove_child(player)
			player.queue_free()

		player = SceneTransitionManager.saved_player
		add_child(player)
		player.name = "Player"
		if SceneTransitionManager.saved_door:
			var door: Node = door_cont.get_node("door_" + SceneTransitionManager.saved_door)
			var spawn_point: Node = door.get_node("SpawnPoint")
			var player_body: CharacterBody2D = player.get_node("PlayerMovement")
			player_body.global_position = spawn_point.global_position
			# Так как в задании написано, что при переходе между сценами направление взгляда не должно сохраняться
			player_body.cardinal_direction = Vector2.DOWN
			player_body.animate()
			
	
	if GlobalManager.needs_reload:
		GlobalManager.post_scene_load()
	
	var spawned_items: Array = DataPersistence.check_spawned_items()
	if not spawned_items.is_empty():
		for item: Variant in spawned_items:
			var spawned_item: InventoryItem = INV_ITEM.instantiate()
			spawned_item.uuid = item["uuid"]
			spawned_item.item_data = item["item_data"]
			spawned_item.is_spawned = true
			spawned_item.texture = spawned_item.item_data.item_sprite
			item_container.add_child(spawned_item)
			spawned_item.global_position = item["pos"]
