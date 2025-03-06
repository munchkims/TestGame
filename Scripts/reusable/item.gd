extends Resource
class_name Item

@export var item_id: String
@export var item_name: String
@export var description: String
@export var item_sprite: Texture2D
@export var is_usable: bool = true
@export var is_reusable: bool = false

@export var use_func: Callable


func set_use_func(function: Callable) -> void:
	use_func = function
