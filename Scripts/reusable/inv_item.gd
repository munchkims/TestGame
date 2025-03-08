extends BasePickItem
class_name InventoryItem

# NB: item ID должен быть идентичен тому, что в файле JSON (res://Data/ItemData.json)
@export var item_id: String = ""


var item_data: Item = null
var is_spawned: bool = false


func _ready() -> void:
	super._ready()
	# Вообще я могу поменять item_storage на Словарь (Dictionary), чтобы вообще не дублировать, а увеличивать количество (stack)
	# но я не была уверена, стоит ли, так как в задании этого не указано
	if is_spawned:
		return
	item_data = ItemDb.get_item(item_id).duplicate(true)
	
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


func save() -> void:
	if not is_spawned:
		DataPersistence.register_item(uuid, picked_up)
	elif picked_up:
		DataPersistence.remove_spawned_item(uuid)