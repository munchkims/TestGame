extends BasePickItem
class_name InventoryItem

# NB: item ID должен быть идентичен тому, что в файле JSON (res://Data/ItemData.json)
@export var item_id: String = ""


var item_data: Item = null
#var duplicate_item: Item


func _ready() -> void:
	super._ready()
	item_data = ItemDb.get_item(item_id).duplicate(true)
	
	# Вообще я могу поменять item_storage на Словарь (Dictionary), чтобы вообще не дублировать, но я не была уверена, стоит ли, так как в задании этого не указано
	
	if item_data:
		texture = item_data.item_sprite

	else:
		printerr("data not found. Are you sure you used a correct id?")


func _on_player_entered(_player: Player) -> void:
	if _player.add_item(item_data):
		picked_up = true
		queue_free()
	else:
		return
