extends Sprite2D

@onready var pickable_area: PickableItem = $PickableItem

var picked_up: bool = false

func _ready() -> void:
    pickable_area.player_entered.connect(_on_player_entered)


func _on_player_entered(player: Player) -> void:
    player.add_key()
    picked_up = true
    # TODO saving because this bool means nothing if we delete the scene
    queue_free()


func load() -> void:
    pass


func save() -> void:
    pass