extends Sprite2D
class_name Door

# Данный скрипт нуждается в Path (копируем из res://), на какой уровень мы отправляем игрока
# Также нужно название двери на новом уровне: так как каждый уровень имеет в стуктуре контейнер для дверей Doors, на случай если их несколько
# Но не все название, а его часть, приставка (то, что идет после door_)

@export var inside_door: bool
@export var target_scene: String
@export var target_door: String

var loaded_scene: PackedScene
var is_open: bool = false
@onready var door_transition: Area2D = $DoorTransition


func _ready() -> void:
	loaded_scene = load(target_scene) as PackedScene
	
	if inside_door:
		open()
	else:
		_load_info()


func _load_info() -> void:
	if DataPersistence.is_door_open(get_path()):
		open()


func _on_body_entered(body: Node2D) -> void:
	var parent: Node2D = body.get_parent()
	if parent is Player:
		if is_open:
			SceneTransitionManager.change_scene(loaded_scene, target_door)
		elif parent.has_key():
			parent.door_popup(self)
		else:
			return


# Данную функцию вызывает игрок, если отвечает "да" на вопрос, использовать ли ключ
func enter() -> void:
	open()
	DataPersistence.save_open_door(get_path())
	SceneTransitionManager.change_scene(loaded_scene, target_door)


func open() -> void:
	is_open = true
	self_modulate.a = 0


func close() -> void:
	is_open = false
	#DataPersistence.remove_open_door(get_path()) - Не была уверена, сделать это через Main Game Scene, или же Data Persistence: но потом выбрала Data Persistence, поэтому тут убрала 
	self_modulate.a = 1
