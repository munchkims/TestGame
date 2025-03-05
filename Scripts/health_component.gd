extends Node2D
class_name HealthComponent

@export var current_health: int = 10
@export var max_health: int = 10

signal health_changed(number: int, on_max_health: bool)
signal health_depleted()

func change_health(amount: int) -> void:
    current_health += amount
    if current_health <= 0:
        current_health = 0
        health_depleted.emit()
    if current_health > max_health:
        current_health = max_health
    health_changed.emit(current_health, false)


# Я сначала думала сделать одну функцию, но выглядело некрасиво, да и когда другие функции делают колл, все же лучше, чтобы было понятно
func change_max_health(amount: int) -> void:
    max_health += amount
    if max_health <= 0:
        max_health = 0
        health_depleted.emit()
    health_changed.emit(max_health, true)