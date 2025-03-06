extends Control

@export var popup_time: float = 4.0

@onready var hp_number: Label = $BG/VBoxContainer/HPText/HPNumber
@onready var key_number: Label = $BG/VBoxContainer/KeysText/KeyNumber
@onready var text_pop_up: NinePatchRect = $TextPopUp
@onready var text_pop_up_label: Label = $TextPopUp/Label
@onready var timer: Timer = $Timer

signal popup_window(is_open: bool)


func update_health(health: int, max_health: bool = false) -> void:
	var parts: PackedStringArray = hp_number.text.split("/")
	if max_health:
		hp_number.text = parts[0] + "/" + str(health)
	else:
		hp_number.text = str(health) + "/" + parts[1]


func update_key_number(k_number: int) -> void:
	key_number.text = str(k_number)


func show_pop_up(popup_text: String) -> void:
	timer.start(popup_time)
	text_pop_up_label.text = popup_text
	text_pop_up.visible = true


func _on_timer_timeout() -> void:
	text_pop_up.visible = false


func show_door_window() -> void:
	pass