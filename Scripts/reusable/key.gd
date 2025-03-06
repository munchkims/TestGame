extends BasePickItem
class_name DoorKey

func _on_player_entered(player: Player) -> void:
    player.add_key()
    picked_up = true
    queue_free()
