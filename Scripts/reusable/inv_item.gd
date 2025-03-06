extends BasePickItem
class_name InventoryItem

# NB: item ID должен быть идентичен тому, что в файле JSON (res://Data/ItemData.json)
@export var item_id: String = ""


var item_data: Item = null
var duplicate_item: Item


func _ready() -> void:
	super._ready()
	item_data = ItemDb.get_item(item_id)
	
	# Годот что-то странно дублировал с помощью duplicate() - даже с true, поэтому было принято решение делать отдельную копию.
	# Вообще я бы поменяла item_storage на Словарь (Dictionary), чтобы не дублировать и просто сделить за количеством вещей, но в силу ограниченных сроков понимаю, что не успею
	
	if item_data:
		texture = item_data.item_sprite
		duplicate_item = Item.new()
		duplicate_item.item_id = item_data.item_id
		duplicate_item.item_name = item_data.item_name
		duplicate_item.description = item_data.description
		duplicate_item.item_sprite = item_data.item_sprite
		duplicate_item.set_use_func(GlobalManager.item_function(duplicate_item.item_id))
		duplicate_item.is_usable = item_data.is_usable
		duplicate_item.is_reusable = item_data.is_reusable
	else:
		printerr("data not found. Are you sure you used a correct id?")


func _on_player_entered(_player: Player) -> void:
	if _player.add_item(duplicate_item):
		picked_up = true
		queue_free()
	else:
		return
