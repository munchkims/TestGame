extends BasePickItem
class_name InventoryItem

# NB: item ID должен быть идентичен тому, что в файле JSON (res://Data/ItemData.json)
@export var item_id: String = ""

# Получает все данные про вещь из глобального словаря, который, в свою очередь, загружается, используя данные из файла JSON
var item_data: Item = null
var is_spawned: bool = false


func _ready() -> void:
	super._ready()
	
	# Если этот предмет был выкинут из инвентаря, то у него уже будет item_data
	if is_spawned:
		return
	
	# Вообще я могу поменять item_storage на Словарь (Dictionary), чтобы вообще не дублировать, а увеличивать количество (stack)
	# но я не была уверена, стоит ли, так как в задании этого не указано
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


func _save() -> void:
	if not is_spawned:
		DataPersistence.register_item(uuid, picked_up) # Если это оригинальная версия с редактора, то просто сохраняем состояние
	elif picked_up:
		DataPersistence.remove_spawned_item(uuid) # Если же это был выкинутый предмет, и его подобрали, то его просто удаляем из списка, чтобы потом не выгружать обратно