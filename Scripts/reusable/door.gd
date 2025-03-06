extends Sprite2D
class_name Door

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
		load_info()


func load_info() -> void:
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


func enter() -> void:
	open()
	DataPersistence.save_open_door(get_path())
	SceneTransitionManager.change_scene(loaded_scene, target_door)


func open() -> void:
	is_open = true
	self_modulate.a = 0


func close() -> void:
	is_open = false
	DataPersistence.remove_open_door(get_path())
	self_modulate.a = 1
