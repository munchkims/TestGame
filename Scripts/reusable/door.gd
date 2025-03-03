extends Sprite2D
class_name Door

@export var inside_door: bool
@export var target_scene: String
@export var target_door: String

var loaded_scene: PackedScene
var is_open: bool = false
@onready var door_transition: Area2D = $DoorTransition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loaded_scene = load(target_scene) as PackedScene
	
	if inside_door:
		is_open = true
		self_modulate.a = 0
	else:
		load_info()


func load_info() -> void:
	is_open = false


func _on_body_entered(body: Node2D) -> void:
	var parent: Node2D = body.get_parent()
	if parent is Player:
		if is_open or parent.has_key():
			SceneTransitionManager.change_scene(loaded_scene, target_door)