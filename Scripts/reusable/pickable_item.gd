extends Area2D
class_name PickableItem

signal player_entered(player: Player)

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var parent: Node2D = body.get_parent()
	if parent is Player:
		player_entered.emit(parent)
