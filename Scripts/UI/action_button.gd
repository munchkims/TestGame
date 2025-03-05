extends TextureButton
class_name ActionButton

@onready var action_name: Label = $ActionName

func set_action(new_name: String) -> void:
	action_name.text = new_name


func disable() -> void:
	disabled = true
