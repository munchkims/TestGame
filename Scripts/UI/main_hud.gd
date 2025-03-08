extends Control
class_name PlayerMainHUD

@export var popup_time: float = 4.0

@onready var hp_number: Label = $BG/VBoxContainer/HPText/HPNumber
@onready var key_number: Label = $BG/VBoxContainer/KeysText/KeyNumber
@onready var text_pop_up: NinePatchRect = $TextPopUp
@onready var text_pop_up_label: Label = $TextPopUp/Label
@onready var timer: Timer = $Timer
@onready var door_popup: NinePatchRect = $DoorPopUp
@onready var buttons: Array = [$DoorPopUp/HBoxContainer/Yes, $DoorPopUp/HBoxContainer/No]

@onready var player_inv: Control = $PlayerInventory

enum HUD_State {NONE, DOOR_POPUP, IN_INVENTORY}

var current_state: HUD_State = HUD_State.NONE
var input_disabled: bool = false

signal door_answer(yes: bool)
signal ui_state_changed(current_state: HUD_State)

var selected_index: int = 0


func _ready() -> void:
	player_inv.inventory_open.connect(_on_inventory_state_changed)


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


func show_door_popup() -> void:
	if current_state == HUD_State.IN_INVENTORY: # На всякий случай, если игрок именно в эту миллисекунду нажмет Q
		player_inv.close_and_open_inv()
	current_state = HUD_State.DOOR_POPUP
	selected_index = 0
	_highlight_selected_button()
	door_popup.visible = true
	ui_state_changed.emit(current_state)


func close_door_popup() -> void:
	door_popup.visible = false
	current_state = HUD_State.NONE
	ui_state_changed.emit(current_state)


func disable_input(disable: bool) -> void:
	input_disabled = disable


func _on_timer_timeout() -> void:
	text_pop_up.visible = false


func _on_popup_button_pressed(yes_open: bool) -> void:
	close_door_popup()
	door_answer.emit(yes_open)


# В зависимости от state, мониторим разный input, чтобы нельзя было включить инвентарь, когда появляется окно с вопросом
func _input(event: InputEvent) -> void:
	if input_disabled:
		return
	match current_state:
		HUD_State.IN_INVENTORY, HUD_State.NONE:
			if event.is_action_pressed("Inv"):
				player_inv.close_and_open_inv()
		HUD_State.DOOR_POPUP:
			if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
				selected_index = 1 - selected_index
				_highlight_selected_button()
			elif event.is_action_pressed("ui_accept"):
				buttons[selected_index].button_pressed = true
				buttons[selected_index].emit_signal("pressed")
		

func _highlight_selected_button() -> void:
	buttons[selected_index].modulate = Color(1.2, 1.2, 1.2, 1)
	buttons[1 - selected_index].modulate = Color(1, 1, 1, 1)


func _on_inventory_state_changed(is_open: bool) -> void:
	if is_open:
		current_state = HUD_State.IN_INVENTORY
		ui_state_changed.emit(current_state)
	else:
		current_state = HUD_State.NONE
		ui_state_changed.emit(current_state)
