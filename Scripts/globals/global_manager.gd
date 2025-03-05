extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Получаем функцию, используя id предмета
func item_function(item_name: String) -> Callable:
	if has_method(item_name):
		return Callable(self, item_name)
	else:
		printerr("Function by this name not found: ", item_name)
		return Callable()


# Список функций, такой же как id предмета

func apple() -> void:
	print("apple was used!")


func orange() -> void:
	print("orange was used!")


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