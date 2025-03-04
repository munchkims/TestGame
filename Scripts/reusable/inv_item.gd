extends Sprite2D
class_name InventoryItem

# Note: this item ID should be identical to the one in the JSON file (res://Data/ItemData.json)
@export var item_id: String = ""

@onready var pickable_area: PickableItem = $PickableItem
var item_data: Item = null

var picked_up: bool = false

func _ready() -> void:
	item_data = ItemDb.get_item(item_id).duplicate() # In case we have several apples and such
	if item_data:
		texture = item_data.item_sprite
	else:
		printerr("data not found. Are you sure you used a correct id?")
	
	pickable_area.player_entered.connect(_on_player_entered)


func _on_player_entered(player: Player) -> void:
	if player.add_item(item_data):
		picked_up = true
		# TODO saving because this bool means nothing if we delete the scene
		queue_free()
	else:
		return

func load() -> void:
	pass


func save() -> void:
	pass
