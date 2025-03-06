extends Node2D
class_name PlayerStats

# Я изначально думала добавить сюда же здоровье, но решила, что лучше раздельно его иметь, чтобы этот компонент можно было использовать на врагах, допустим
var keys: int = 0

signal key_number_changed(key_count: int)

func key_count() -> int:
    return keys

# Если расширять идею, то, возможно, имеет смысл добавить аргумент int, если когда-то понадобится больше ключей за раз
func add_key() -> void:
    keys += 1
    key_number_changed.emit(keys)


func remove_key() -> void:
    keys -= 1
    if keys < 0:
        keys = 0
    key_number_changed.emit(keys)