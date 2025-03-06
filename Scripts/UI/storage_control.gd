extends Control
class_name StorageControl

var storage: ItemStorage

const SLOT_SCENE: Resource = preload("res://Scenes/UI/inv_slot.tscn")
const BUTTON_SCENE: Resource = preload("res://Scenes/UI/action_button.tscn")

const EMPTY_NAME: String = "Пусто"
const EMPTY_DESCRIPTION: String = "Пустая ячейка"

@onready var slot_container: GridContainer = $BG/SlotContainer
@onready var button_container: VBoxContainer = $BG/ButtonsBG/ButtonContainer
@onready var pointer: TextureRect = $BG/Pointer
@onready var inv_item_name: Label = $BG/InfoBG/ItemNameBg/ItemName
@onready var inv_item_desc: Label = $BG/InfoBG/ItemDescBg/ItemDescription

enum SelectionState {INVENTORY, BUTTONS}
var selection_state: SelectionState = SelectionState.INVENTORY

signal new_selection

var selected_index: int = -1
var selected_button_index: int = 0
var slots: Array
var action_buttons: Array


func _ready() -> void:
	visible = false
	set_process_input(false)
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
			select_slot(9) # Всегда 9 колонн в инвентаре - но в целом для сундуков эту цифру можно вынести в variable и от этого отталкиваться
		elif event.is_action_pressed("ui_up"):
			select_slot(-9)
		elif event.is_action_pressed("ui_accept"):
			_enter_button_selection()
	
	elif selection_state == SelectionState.BUTTONS:
		if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
			_select_button()
		elif event.is_action_pressed("ui_accept"):
			if action_buttons[selected_button_index].disabled == false:
				action_buttons[selected_button_index].emit_signal("pressed")
		elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("Tab"):
			_exit_button_selection()

func select_slot(offset: int) -> void:
	if slots == null:
		return
	# Это нужно для того, чтобы когда мы открываем инвентарь впервые, любая нажатая кнопка в первую очередь выбирала первый слот
	if selected_index == -1:
		offset = 1
	var new_index: int = selected_index + offset
	if new_index >= 0 and new_index < slots.size():
		if selected_index != -1:
			slots[selected_index].self_modulate = Color.WHITE
		selected_index = new_index
		slots[selected_index].self_modulate = Color(0.9, 0.7, 0.5, 1)
		_update_pointer()
		_update_info()
		new_selection.emit()


func _enter_button_selection() -> void:
	if action_buttons.size() == 0 || selected_index == -1:
		return
	selection_state = SelectionState.BUTTONS
	selected_button_index = 0
	if action_buttons[selected_button_index].disabled == true:
		selected_button_index = 1 - selected_button_index
	action_buttons[selected_button_index].self_modulate = Color(0.9, 0.7, 0.5, 1)


func _select_button() -> void:
	action_buttons[selected_button_index].self_modulate = Color.WHITE
	var next_button_index: int = 1 - selected_button_index
	if action_buttons[next_button_index].disabled == true:
		next_button_index = selected_button_index
	selected_button_index = next_button_index
	action_buttons[selected_button_index].self_modulate = Color(0.9, 0.7, 0.5, 1)


func _exit_button_selection() -> void:
	action_buttons[selected_button_index].self_modulate = Color.WHITE
	selection_state = SelectionState.INVENTORY
	select_slot(0)


func _update_pointer() -> void:
	pointer.global_position = slots[selected_index].global_position + Vector2(18, 18)
	pointer.visible = true


func _update_info() -> void:
	var selected_item: Item = slots[selected_index].item
	if selected_item != null:
		inv_item_name.text = selected_item.item_name
		inv_item_desc.text = selected_item.description
	else:
		inv_item_name.text = EMPTY_NAME
		inv_item_desc.text = EMPTY_DESCRIPTION


func _populate() -> void:
	if storage == null:
		print("Storage is unassigned. Creating empty storage control")
		return
	for i: int in range(storage.capacity):
		var slot: TextureRect = SLOT_SCENE.instantiate()
		slot_container.add_child(slot)
		slots.append(slot)

		var slot_item: Item = storage.storage[i]
		slot.set_item(slot_item)


func add_button(btn_name: String) -> ActionButton:
	if action_buttons.size() >= 2:
		printerr("there are two buttons already.")
		return null
	var new_button: ActionButton = BUTTON_SCENE.instantiate()
	button_container.add_child(new_button)
	new_button.set_action(btn_name)
	action_buttons.append(new_button)
	return new_button


func remove_all_buttons() -> void:
	for i in range(action_buttons.size() - 1, -1, -1):
		action_buttons[i].queue_free()
		action_buttons.remove_at(i)
	selection_state = SelectionState.INVENTORY
	selected_button_index = 0


func get_selected_item() -> Item:
	if selected_index != -1:
		return slots[selected_index].item
	return null


func _on_item_added(new_item: Item) -> void:
	var index: int = _find_null_slot()
	if index == -1:
		printerr("Some inventory mismatch. Tried adding more items than there is capacity")
		return
	var slot_to_upd: TextureRect = slots[index]
	slot_to_upd.set_item(new_item)


func _on_item_removed(removed_item: Item) -> void:
	var index: int = _find_slot_by_item(removed_item)
	if index != -1:
		# var del_slot: TextureRect = slots[index]
		# slots.remove_at(index)
		# del_slot.queue_free()
		# var slot: TextureRect = SLOT_SCENE.instantiate()
		# slot_container.add_child(slot)
		# slots.append(slot)
		# var slot_item: Item = storage.storage[index]
		# slot.set_item(slot_item)
		slots[index].reset()
		for i in range(index, slots.size() - 1):
			# if i + 1 == -1:
			# 	continue
			slots[i].reset()
			slots[i].set_item(slots[i + 1].item)
		
		slots[slots.size() - 1].reset()
		#slots[slots.size() - 1].visible = false


func _find_null_slot() -> int:
	for i in range(slots.size()):
		if slots[i].item == null:
			return i
	
	return -1


func _find_slot_by_item(ref_item: Item) -> int:
	for i in range(slots.size()):
		if slots[i].item == ref_item:
			return i
	return -1


func resize() -> void:
	slots.resize(storage.capacity)


func toggle_visibility() -> void:
	visible = !visible
	if not visible:
		_close_inventory()
	else:
		set_process_input(true)


func _close_inventory() -> void:
	selection_state = SelectionState.INVENTORY
	set_process_input(false)
	if selected_button_index != -1:
		action_buttons[selected_button_index].self_modulate = Color.WHITE
	if selected_index != -1:
		slots[selected_index].self_modulate = Color.WHITE
	selected_index = -1
	selected_button_index = 0
	pointer.visible = false
