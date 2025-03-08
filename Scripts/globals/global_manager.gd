extends Node

var player: Player
var needs_reload: bool = false

func _ready() -> void:
	player = _fetch_player()
	

# Получаем функцию, используя id предмета
func item_function(item_name: String) -> Callable:
	if has_method(item_name):
		return Callable(self, item_name)
	else:
		printerr("Function by this name not found: ", item_name)
		return Callable()


func _fetch_player() -> Player:
	var main_game: Node = get_tree().get_root().get_node("MainGame")
	if main_game:
		var new_player: Player = main_game.get_node_or_null("Player")
		if new_player:
			new_player.changed_state.connect(_on_player_changed_state)
			return new_player
	return null


# Список функций, и названия должны быть такими же как id предмета

func apple() -> void:
	player.change_current_health(1)


func orange() -> void:
	player.change_max_health(1)
	player.change_current_health(1)


func chili() -> void:
	player.change_current_health(-1)


func olives() -> void:
	player.change_max_health(-10)


func signalisation() -> void:
	DataPersistence.reset_doors()


func teleport() -> void:
	player.teleport_player()


func amulet() -> void:
	player.change_current_health(-9)
	player.change_max_health(1)


func reset() -> void:
	SceneTransitionManager.reload_game()
	# Не можем сразу игрока получить, так как надо подождать, пока все инициализируется
	needs_reload = true
	

func post_scene_load() -> void:
	needs_reload = false
	player = _fetch_player()


func is_on_floor_check(pos: Vector2) -> bool:
	var current_lvl: Node = get_tree().current_scene
	var current_floor: TileMapLayer = current_lvl.tile_layer
	var local_position: Vector2 = current_floor.to_local(pos)
	var tile_coords: Vector2i = current_floor.local_to_map(local_position)
	var source_id: int = current_floor.get_cell_source_id(tile_coords)
	return source_id != -1


func _on_player_changed_state(p_state: Player.Player_State) -> void:
	if p_state == Player.Player_State.DEAD:
		reset()
