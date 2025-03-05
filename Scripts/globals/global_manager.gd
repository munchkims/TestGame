extends Node

var player: Player

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
		return main_game.get_node_or_null("Player")
	return null


# Список функций, такой же как id предмета

func apple() -> void:
	player.change_current_health(1)


func orange() -> void:
	player.change_max_health(1)
	player.change_current_health(1)


func chili() -> void:
	print("chili was used!")


func olives() -> void:
	print("olives was used!")


func signalisation() -> void:
	print("signalisation was used!")


func teleport() -> void:
	print("teleport was used!")


func amulet() -> void:
	print("amulet was used!")

# Ну эта функция не должна в принципе быть, потом логику заполнения в ItemDb можно поменять с этим чеком.
func token() -> void:
	print("token was used!")
