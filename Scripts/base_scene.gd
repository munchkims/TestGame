extends Node2D
class_name BaseScene

@onready var player: Player = get_node_or_null("Player")
@onready var door_cont: Node2D = $Doors

func _ready() -> void:
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
	
	if GlobalManager.needs_reload:
		GlobalManager.post_scene_load()
