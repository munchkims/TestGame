extends Node2D
class_name Player

@onready var player_stats: PlayerStats = $PlayerStats
@onready var player_storage: ItemStorage = $PlayerStorage
@onready var player_storage_control: Control = $PlayerHUD/MainHUD/PlayerInventory
@onready var player_main_HUD: Control = $PlayerHUD/MainHUD
@onready var player_movement: CharacterBody2D = $PlayerMovement
@onready var health_component: HealthComponent = $HealthComponent

#signal player_dead
# Мне нужно подписаться под hud state UI и от этого менять states а потом я подпишусь player movement на player state и от этого будет зависеть что происходит
signal changed_state(current_state: Player_State)
enum Player_State {ALIVE, UI_OPEN, DEAD}
var current_state: Player_State = Player_State.ALIVE

var stored_door: Door

var item_spawn_radius: float = 25.0


func _ready() -> void:
	player_storage_control.create_player_inventory(player_storage) # Создаем инвентарь (storage control), используя инстанцию хранилища
	player_storage_control.item_removed.connect(_on_item_removed) # Подключаем сигнал для взаимодействия с хранилищем
	player_storage_control.item_discarded.connect(_on_item_discarded) # Если нужно выкинуть предмет
	player_main_HUD.update_health(health_component.current_health) # Передаем информацию HUD про начальное здоровье
	player_main_HUD.update_health(health_component.max_health, true)
	health_component.health_depleted.connect(_on_health_depleted) # Подключаемся, чтобы знать, когда ОЗ будет 0
	health_component.health_changed.connect(Callable(player_main_HUD, "update_health")) # Подключаем health component напрямую к HUD, чтобы он передавал информацию по изменению состояния
	player_stats.key_number_changed.connect(Callable(player_main_HUD, "update_key_number")) # То же с ключамми
	player_main_HUD.update_key_number(player_stats.keys) # Обновляем состояние ключей в HUD (на случай, если когда-то будем начинать не с 0)
	player_main_HUD.door_answer.connect(_on_door_answer) # HUD будет знать, что ответил игрок про дверь (да/нет), поэтому нам надо получить эту информацию
	player_main_HUD.ui_state_changed.connect(_on_ui_changed) # Сделим за состоянием UI, чтобы предупреждать остальные слушающие скрипты (как movement)
	changed_state.connect(Callable(player_movement, "_on_player_state_changed")) # Ну и вот сам movement уже подписывается на состояние игрока
	

func has_key() -> bool:
	if player_stats.key_count() > 0:
		return true
	return false


func add_key() -> void:
	player_stats.add_key()


func remove_key() -> void:
	player_stats.remove_key()


# Добавляем вещи в инвентарь
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


# Отключаем возможность двигаться, если включается UI, и наоборот
func _on_ui_changed(hud_state: PlayerMainHUD.HUD_State) -> void:
	if current_state == Player_State.DEAD:
		return
	match hud_state:
		PlayerMainHUD.HUD_State.DOOR_POPUP, PlayerMainHUD.HUD_State.IN_INVENTORY:
			current_state = Player_State.UI_OPEN
			changed_state.emit(current_state)
		PlayerMainHUD.HUD_State.NONE:
			current_state = Player_State.ALIVE
			changed_state.emit(current_state)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		if current_state == Player_State.UI_OPEN:
			return
		var received_text: String = player_movement.is_near_interactable()
		if received_text != "":
			player_main_HUD.show_pop_up(received_text)


# По сути можно было бы обойтись и без этих функций, но этот выбор был сделан ради энкапсуляции
func change_current_health(amount: int) -> void:
	health_component.change_health(amount)


func change_max_health(amount: int) -> void:
	health_component.change_max_health(amount)


# Отключаем и движение, и инвентарь и интеракции
func disable_input() -> void:
	player_movement.set_player_movement(false)
	player_main_HUD.disable_input(true)


func enable_input() -> void:
	player_movement.set_player_movement(true)
	player_main_HUD.disable_input(false)


# При столкновении с дверью, показывает дверь и сохраняет ее, чтобы в случае положительного ответа использовать функцию двери enter()
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


func _on_item_discarded(inv_item: InventoryItem) -> void:
	var pos: Vector2 = _choose_spawn_point(player_movement, item_spawn_radius)
	if pos == Vector2.ZERO:
		inv_item.queue_free()
		print("Didn't find a position to drop the item. BACK TO THE INVENTORY!")
		return
	inv_item.global_position = pos
	DataPersistence.save_spawned_item(inv_item.uuid, inv_item.item_data, inv_item.global_position)
	player_storage_control.remove_item(inv_item.item_data)


func _on_health_depleted() -> void:
	print("you die!")
	disable_input()
	current_state = Player_State.DEAD
	changed_state.emit(current_state)


# Выбираем место, куда выкинуть предмет. Ограничение минимального радиуса для того, чтобы игрок не подобрал его сразу
func _choose_spawn_point(player_body: CharacterBody2D, radius: float) -> Vector2:
	var max_attempts: int = 100
	var attempts: int = 0
	var pos: Vector2

	while attempts < max_attempts:
		pos = player_body.get_random_position_in_radius(radius, 20)
		if player_body.is_position_free(pos):
			break
		attempts += 1
	
	if attempts < max_attempts:
		return pos

	return Vector2.ZERO