extends BasePickItem
class_name DoorKey


# Override класса BasePickItem, вся логика сохранения и прочего прописана там
func _on_player_entered(player: Player) -> void:
    player.add_key()
    picked_up = true
    queue_free()
