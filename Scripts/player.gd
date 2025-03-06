extends Node2D
class_name Player

@onready var player_stats: PlayerStats = $PlayerStats
@onready var player_storage: ItemStorage = $PlayerStorage
@onready var player_storage_control: Control = $PlayerHUD/PlayerInventory
@onready var player_main_HUD: Control = $PlayerHUD/MainHUD
@onready var player_movement: CharacterBody2D = $PlayerMovement
@onready var health_component: HealthComponent = $HealthComponent

signal player_dead


var stored_door: Door

func _ready() -> void:
	player_storage_control.create_player_inventory(player_storage)
	player_storage_control.item_removed.connect(_on_item_removed)
	player_main_HUD.update_health(health_component.current_health)
	player_main_HUD.update_health(health_component.max_health, true)
	health_component.health_depleted.connect(_on_health_depleted)
	health_component.health_changed.connect(Callable(player_main_HUD, "update_health"))
	player_stats.key_number_changed.connect(Callable(player_main_HUD, "update_key_number"))
	player_main_HUD.update_key_number(player_stats.keys)
	player_main_HUD.popup_window.connect(Callable(player_storage_control, "_door_popup_open"))
	player_main_HUD.door_answer.connect(_on_door_answer)
	player_main_HUD.popup_window.connect(Callable(player_movement, "set_player_movement"))
	player_storage_control.inventory_open.connect(Callable(player_movement, "set_player_movement"))
	

func has_key() -> bool:
	if player_stats.key_count() > 0:
		return true
	return false


func add_key() -> void:
	player_stats.add_key()


func remove_key() -> void:
	player_stats.remove_key()


func add_item(item: Item) -> bool:
	if player_storage.add_item(item):
		return true
	else:
		return false


# Пока что функция эта не принимает аргументов, но можно сделать оверрайд
func teleport_player() -> void:
	player_movement.teleport_within_radius()


func _on_item_removed(item_removed: Item) -> void:
	player_storage.remove_item(item_removed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		# Временное решение, а так при большем количестве времени я бы централизовала UI, чтобы максимально было эффективно переключаться
		if player_storage_control.player_inventory.visible == true:
			return
		var received_text: String = player_movement.is_near_interactable()
		if received_text != "":
			player_main_HUD.show_pop_up(received_text)


# По сути можно было бы обойтись и без этих функций, но этот выбор был сделан ради энкапсуляции
func change_current_health(amount: int) -> void:
	health_component.change_health(amount)


func change_max_health(amount: int) -> void:
	health_component.change_max_health(amount)


func door_popup(door: Door) -> void:
	stored_door = door
	player_main_HUD.show_door_popup()


func _on_door_answer(yes_open: bool) -> void:
	if yes_open:
		remove_key()
		stored_door.enter()
	else:
		print("The player decided not to open the door.")
	
	stored_door = null


# Возможно, конечно, перезагрузку вручную сделать
func _on_health_depleted() -> void:
	print("you die!")
	player_dead.emit()