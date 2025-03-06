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
			new_player.player_dead.connect(_on_player_dead)
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
	print("teleport was used!")


func amulet() -> void:
	print("amulet was used!")

# Ну эта функция не должна в принципе быть, потом логику заполнения в ItemDb можно поменять с этим чеком.
func token() -> void:
	print("token was used!")


func reset() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/main_game.tscn")
	# Так как глобальные скрипты не перезагружаются
	DataPersistence.reset()
	SceneTransitionManager.reset()
	# Не можем сразу игрока получить, так как надо подождать, пока все инициализируется
	needs_reload = true
	

func post_scene_load() -> void:
	needs_reload = false
	player = _fetch_player()


func _on_player_dead() -> void:
	reset()