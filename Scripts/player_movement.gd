extends CharacterBody2D

@export var char_speed: float = 50.0
@export var ray_length: int = 15
@export var base_tp_radius: float = 150.0

@onready var char_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D


var direction: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN
var state: String = "idle"

var min_tp_radius: float = 10.0

func _ready() -> void:
	animate()


func _physics_process(delta: float) -> void:
	move(delta)
	_cast_ray()
	if set_state() or set_direction():
		animate()


func move(_delta: float) -> void:
	direction = Input.get_vector("Left", "Right", "Up", "Down")
	
	# Убираем диагональное движение
	if direction.x != 0:
		direction.y = 0
	velocity = direction.normalized() * char_speed
	
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


func _cast_ray() -> void:
	raycast.target_position = cardinal_direction.normalized() * ray_length


func is_near_interactable() -> String:
	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		if collider is Interactable:
			return collider.message()
	
	return ""


func set_player_movement(stop_movement: bool) -> void:
	set_physics_process(!stop_movement) # Обратное, так как везде UI нам посылает true, если он открыт


func get_player_position() -> Vector2:
	return global_position


func get_random_position_in_radius(max_radius: float, min_radius: float = min_tp_radius) -> Vector2:
	if min_radius > max_radius:
		min_radius = max_radius
	var angle: float = randf_range(0, 2 * PI)
	var distance: float = randf_range(min_radius, max_radius)
	return global_position + Vector2(cos(angle), sin(angle)) * distance


func teleport_within_radius(radius: float = base_tp_radius) -> void:
	var max_attempts: int = 100
	var attempts: int = 0
	var pos: Vector2

	while attempts < max_attempts:
		pos = get_random_position_in_radius(radius)
		if is_position_free(pos):
			break
		attempts += 1
	
	if attempts < max_attempts:
		global_position = pos
	else:
		print("Didn't find valid positions for teleporting")


func is_position_free(pos: Vector2, include_areas: bool = true) -> bool:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = include_areas
	query.collide_with_bodies = true

	var res: Array = space_state.intersect_point(query)
	return res.is_empty() and GlobalManager.is_on_floor_check(pos)