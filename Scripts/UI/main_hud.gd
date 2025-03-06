extends Control

@export var popup_time: float = 4.0

@onready var hp_number: Label = $BG/VBoxContainer/HPText/HPNumber
@onready var key_number: Label = $BG/VBoxContainer/KeysText/KeyNumber
@onready var text_pop_up: NinePatchRect = $TextPopUp
@onready var text_pop_up_label: Label = $TextPopUp/Label
@onready var timer: Timer = $Timer
@onready var door_popup: NinePatchRect = $DoorPopUp
@onready var buttons: Array = [$DoorPopUp/HBoxContainer/Yes, $DoorPopUp/HBoxContainer/No]

signal popup_window(is_open: bool)
signal door_answer(yes: bool)

var selected_index: int = 0


func update_health(health: int, max_health: bool = false) -> void:
	var parts: PackedStringArray = hp_number.text.split("/")
	if max_health:
		hp_number.text = parts[0] + "/" + str(health)
	else:
		hp_number.text = str(health) + "/" + parts[1]


func update_key_number(k_number: int) -> void:
	key_number.text = str(k_number)


func show_pop_up(popup_text: String) -> void:
	if door_popup.visible:
		return
	timer.start(popup_time)
	text_pop_up_label.text = popup_text
	text_pop_up.visible = true


func _on_timer_timeout() -> void:
	text_pop_up.visible = false


func _on_popup_button_pressed(yes_open: bool) -> void:
	close_door_popup()
	door_answer.emit(yes_open)


func show_door_popup() -> void:
	popup_window.emit(true) # На всякий случай последовательность поменяла местами, если вдруг именно в эту миллисекунду игрок откроет инвентарь
	selected_index = 0
	highlight_selected_button()
	door_popup.visible = true


func close_door_popup() -> void:
	door_popup.visible = false
	popup_window.emit(false)


func _input(event: InputEvent) -> void:
	if not door_popup.visible:
		return
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		selected_index = 1 - selected_index
		highlight_selected_button()
	elif event.is_action_pressed("ui_accept"):
		buttons[selected_index].button_pressed = true
		buttons[selected_index].emit_signal("pressed")


func highlight_selected_button() -> void:
	buttons[selected_index].modulate = Color(1.2, 1.2, 1.2, 1)
	buttons[1 - selected_index].modulate = Color(1, 1, 1, 1)