extends Resource
class_name Item

var item_id: String
var item_name: String
var description: String
var item_sprite: Texture2D
var is_usable: bool = true
var is_reusable: bool = false

var use_func: Callable


func set_use_func(function: Callable) -> void:
	use_func = function
