extends Control
class_name StorageControl

var storage: ItemStorage

const SLOT_SCENE: Resource = preload("res://Scenes/UI/inv_slot.tscn")
const BUTTON_SCENE: Resource = preload("res://Scenes/UI/action_button.tscn")

@onready var slot_container: GridContainer = $BG/SlotContainer
@onready var button_container: VBoxContainer = $BG/ButtonsBG/ButtonContainer
@onready var pointer: TextureRect = $BG/Pointer

enum SelectionState {INVENTORY, BUTTONS}
var selection_state: SelectionState = SelectionState.INVENTORY

signal new_selection

var selected_index: int = -1
var selected_button_index: int = 0
var slots: Array
var action_buttons: Array

func _ready() -> void:
	visible = false
	_populate()
	if storage:
		storage.item_added.connect(_on_item_added)
		storage.item_removed.connect(_on_item_removed)
		storage.storage_resized.connect(resize)


func _input(event: InputEvent) -> void:
	if selection_state == SelectionState.INVENTORY:
		if event.is_action_pressed("ui_right"):
			select_slot(1)
		elif event.is_action_pressed("ui_left"):
			select_slot(-1)
		elif event.is_action_pressed("ui_down"):
			select_slot(9) # The grid is always 9 columns wide
		elif event.is_action_pressed("ui_up"):
			select_slot(-9)
		elif event.is_action_pressed("ui_accept"):
			_enter_button_selection()
	
	elif selection_state == SelectionState.BUTTONS:
		if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
			_select_button()
		elif event.is_action_pressed("ui_accept"):
			action_buttons[selected_button_index].pressed = true
		elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("Tab"):
			_exit_button_selection()

func select_slot(offset: int) -> void:
	if slots == null:
		return
	var new_index: int = selected_index + offset
	if new_index >= 0 and new_index < slots.size():
		if selected_index != -1:
			slots[selected_index].self_modulate = Color.WHITE
		selected_index = new_index
		slots[selected_index].self_modulate = Color(0.9, 0.7, 0.5, 1)
		_update_pointer()
		new_selection.emit()


func _enter_button_selection() -> void:
	if action_buttons.size() == 0:
		return
	selection_state = SelectionState.BUTTONS
	selected_button_index = 0
	action_buttons[selected_button_index].self_modulate = Color(0.9, 0.7, 0.5, 1)


func _select_button() -> void:
	action_buttons[selected_button_index].self_modulate = Color.WHITE
	var next_button_index: int = 1 - selected_button_index
	if action_buttons[next_button_index].disabled == true:
		return
	selected_button_index = next_button_index
	action_buttons[selected_button_index].self_modulate = Color(0.9, 0.7, 0.5, 1)


func _exit_button_selection() -> void:
	action_buttons[selected_button_index].self_modulate = Color.WHITE
	selection_state = SelectionState.INVENTORY
	select_slot(0)


func _update_pointer() -> void:
	pointer.global_position = slots[selected_index].global_position + Vector2(18, 18)
	pointer.visible = true


func _populate() -> void:
	if storage == null:
		print("Storage is unassigned. Creating empty storage control")
		return
	for i: int in range(storage.capacity):
		var slot: TextureRect = SLOT_SCENE.instantiate()
		slot_container.add_child(slot)
		slots.append(slot)

		var slot_item: Item = storage.items[i]
		slot.set_item(slot_item)


func add_button(btn_name: String) -> ActionButton:
	if action_buttons.size() >= 2:
		printerr("there are two buttons already.")
		return null
	var new_button: ActionButton = BUTTON_SCENE.instantiate()
	new_button.set_action(btn_name)
	button_container.add_child(new_button)
	action_buttons.append(new_button)
	return new_button


func get_selected_item() -> Item:
	if selected_index != -1:
		return slots[selected_index].item
	return null


func _on_item_added(new_item: Item) -> void:
	var index: int = slots.find(func(slot: TextureRect) -> int: return slot.item == null)
	var slot_to_upd: TextureRect = slots[index]
	slot_to_upd.set_item(new_item)


func _on_item_removed(removed_item: Item) -> void:
	var index: int = slots.find(removed_item)
	if index != 1:
		slots[index].reset()
		for i in range(index, slots.size() - 1):
			slots[i].set_item(slots[i + 1].item)
		
		slots[slots.size() - 1].reset()


func resize() -> void:
	slots.resize(storage.capacity)


func close_inventory() -> void:
	selection_state = SelectionState.INVENTORY
	action_buttons[selected_button_index].self_modulate = Color.WHITE
	slots[selected_index].self_modulate = Color.WHITE
	selected_index = -1
	selected_button_index = 0
	pointer.visible = false