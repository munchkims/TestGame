extends CharacterBody2D

@export var char_speed: float = 50.0

@onready var char_sprite: AnimatedSprite2D = $AnimatedSprite2D


var direction: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN
var state: String = "idle"

func _physics_process(delta: float) -> void:
	move(delta)
	if set_state() or set_direction():
		animate()


func move(_delta: float) -> void:
	direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * char_speed
	
	move_and_slide()


func animate() -> void:
	char_sprite.play(state + "_" + anim_dir())


func set_direction() -> bool:
	var new_dir: Vector2 = cardinal_direction
	if direction == Vector2.ZERO:
		return false

	if direction.y == 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif direction.x == 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	return true


func set_state() -> bool:
	var new_state: String = "idle" if direction == Vector2.ZERO else "run"
	if new_state == state:
		return false
	state = new_state
	return true

func anim_dir() -> String:
	match cardinal_direction:
		Vector2.DOWN:
			return "down"
		Vector2.UP:
			return "up"
		Vector2.LEFT:
			return "left"
		Vector2.RIGHT:
			return "right"
		_:
			printerr("no direction found.")
			return ""
