extends TextureButton
class_name ActionButton

@onready var action_name: Label = $ActionName

# Функция просто ради названия 
func set_action(new_name: String) -> void:
	action_name.text = new_name
