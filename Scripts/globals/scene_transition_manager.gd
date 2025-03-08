extends CanvasLayer

@onready var anim_player: AnimationPlayer = $AnimationPlayer
var saved_player: Player

var on_finished: Callable
var saved_door: String

var in_transition: bool = false


# При переходе в дом или из него
func change_scene(target_scene: PackedScene, target_door: String) -> void:
	var current_scene: Node = get_tree().current_scene
	saved_player = current_scene.get_node("Player")
	saved_player.disable_input()
	anim_player.play("fade_in")
	await anim_player.animation_finished
	current_scene.remove_child(saved_player)
	saved_door = target_door
	get_tree().change_scene_to_packed(target_scene)
	anim_player.play("fade_out")
	await anim_player.animation_finished
	saved_player.enable_input()


# При перезагрузке игры
func reload_game() -> void:
	anim_player.play("fade_in")
	await anim_player.animation_finished
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/main_game.tscn")
	# Так как глобальные скрипты не перезагружаются
	DataPersistence.reset()
	reset()
	anim_player.play("fade_out")
	

func reset() -> void:
	saved_player = null
	saved_door = ""
	in_transition = false


# Код ниже - это моя попытка сделать переход сцены без await, так как я слышала, что использовать await нежелательно
# Несмотря на то, что код работает, он все же медленнее функции change_scene
func change_level_scene(target_scene: PackedScene, target_door: String) -> void:
	if in_transition:
		return
	in_transition = true
	on_finished = Callable(self, "_on_animation_finished").bind(target_scene, target_door)
	anim_player.animation_finished.connect(on_finished)
	anim_player.play("fade_in")


func _on_animation_finished(animation: String, target_scene: PackedScene, target_door: String) -> void:
	if on_finished.is_null():
		printerr("on_finished callable is null.")
		return
	
	# TODO вытащить в функцию отдельную и сделать callable как вариант? либо сюда вытащить смену сцены
	if animation == "fade_in":
		var current_scene: Node = get_tree().current_scene
		saved_player = current_scene.get_node("Player")
		saved_player.disable_movement()
		current_scene.remove_child(saved_player)
		saved_door = target_door
		get_tree().change_scene_to_packed(target_scene)

		anim_player.play("fade_out")
	else:
		#print("disconnected the anim player")
		anim_player.animation_finished.disconnect(on_finished)
		saved_player.enable_movement()
		on_finished = Callable()
		in_transition = false