@tool
extends Sprite2D
class_name InventoryItem

# NB: item ID должен быть идентичен тому, что в файле JSON (res://Data/ItemData.json)
@export var item_id: String = ""

# UUID для сохранения
@export var uuid: String = ""

@export var generate_uuid: bool = false:
	set(value):
		if value:
			generate_new_uuid()
		generate_uuid = false

@onready var pickable_area: PickableItem = $PickableItem
var item_data: Item = null
var duplicate_item: Item

var picked_up: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): # Иначе прокается из-за @tool
		return
	
	if DataPersistence.is_picked_up(uuid):
		load_info()
		return
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
	
	pickable_area.player_entered.connect(_on_player_entered)


func _on_player_entered(player: Player) -> void:
	if player.add_item(duplicate_item):
		picked_up = true
		queue_free()
	else:
		return

func load_info() -> void:
	picked_up = true
	queue_free()


func save() -> void:
	DataPersistence.register_item(uuid, picked_up)


# Теперь когда мы удаляем предмет, он сам и его статус сохраняется
func _exit_tree() -> void:
	save()


# Так как в GODOT нет build-in функции для генерации UUID, это временное решение чисто для тестового задания (а так можно либо самим написать, либо использовать плагин) 
func generate_new_uuid() -> void:
	uuid = str(get_instance_id())
	notify_property_list_changed()
	print("Generated UUID: ", uuid)