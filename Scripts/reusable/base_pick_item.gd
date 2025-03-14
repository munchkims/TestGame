@tool
extends Sprite2D
class_name BasePickItem

# Данный класс - родитель для классов InventoryItem и DoorKey, так как много одного функционала (uuid, подбор игроком, сохранение)

# UUID для сохранения
@export var uuid: String = ""

# ВАЖНО: в классах, которые унаследывают данный класс, UUID не генерируется, если в их скрипте не подписать @tool
# Однако, это даже плюс: после того, как мы сгенерировали все id, лучше @tool убрать из классов-наследников, так как иногда _ready() все равно проскакивает, даже при условии is_editor_hint
# Поэтому, если долгое время нет надобности генерировать UUID, то @tool можно убрать в #
@export var generate_uuid: bool = false:
	set(value):
		if value:
			generate_new_uuid()
		generate_uuid = false


@onready var pickable_area: Area2D = $Area2D

var picked_up: bool = false


func _ready() -> void:
	if Engine.is_editor_hint(): # Иначе прокается из-за @tool
		return
	
	if uuid == "":
		printerr("Forgot to set uuid! name: ", name) # Напоминание, так как uuid надо добавлять еще в редакторе, до запуска игры, иначе не сохранится

	if DataPersistence.is_picked_up(uuid): # Если по uuid оказывается, что уже подбирали предмет, то удаляем его
		_load_info()
		return

	pickable_area.body_entered.connect(_on_body_entered)
	

# Так как базовый класс не будет использован сам по себе, очень важно определить логику для наследников
func _on_player_entered(_player: Player) -> void:
	printerr("This function should be overwritten in inheriting classes!")


func _on_body_entered(body: Node2D) -> void:
	var parent: Node2D = body.get_parent()
	if parent is Player:
		_on_player_entered(parent)


func _load_info() -> void:
	picked_up = true
	queue_free()


func _save() -> void:
	DataPersistence.register_item(uuid, picked_up)


# Теперь когда мы удаляем предмет, он сам и его статус сохраняется
func _exit_tree() -> void:
	_save()


# Так как в GODOT нет build-in функции для генерации UUID, это временное решение чисто для тестового задания (а так можно либо самим написать, либо использовать плагин) 
func generate_new_uuid() -> void:
	uuid = str(get_instance_id())
	notify_property_list_changed()
	print("Generated UUID: ", uuid)