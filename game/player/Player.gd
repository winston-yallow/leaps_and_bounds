extends Spatial

enum STATE { MOVING, WAITING }

var mouse_sensitivity := 0.01
var min_vertical_rotation := -75.0
var max_vertical_rotation := +75.0

var current_state: int = STATE.WAITING

onready var cam_pivot := $CameraPivot

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if current_state == STATE.WAITING and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		cam_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		cam_pivot.rotation_degrees.x = clamp(
			cam_pivot.rotation_degrees.x,
			min_vertical_rotation,
			max_vertical_rotation
		)
