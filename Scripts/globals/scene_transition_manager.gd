extends CanvasLayer

@onready var anim_player: AnimationPlayer = $AnimationPlayer
var saved_player: Player

var on_finished: Callable
var saved_door: String

var in_transition: bool = false


func change_scene(target_scene: PackedScene, target_door: String) -> void:
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
	
	if animation == "fade_in":
		var current_scene: Node = get_tree().current_scene
		saved_player = current_scene.get_node("Player")
		current_scene.remove_child(saved_player)
		saved_door = target_door
		get_tree().change_scene_to_packed(target_scene)

		anim_player.play("fade_out")
	else:
		#print("disconnected the anim player")
		anim_player.animation_finished.disconnect(on_finished)
		on_finished = Callable()
		in_transition = false