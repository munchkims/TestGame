extends Control

var player: Player
var player_storage: StorageControl

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Inv"):
		pass