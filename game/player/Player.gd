extends Spatial

enum STATE { MOVING, WAITING }

var mouse_sensitivity := 0.01
var min_vertical_rotation := -75.0
var max_vertical_rotation := +75.0
var ray_length := 100.0

var current_state: int = STATE.WAITING
var current_ray_result = null

onready var cam_pivot := $CameraPivot
onready var cam: Camera = $CameraPivot/ClippedCamera

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
    if current_state == STATE.WAITING:
        if event is InputEventMouseMotion:
            rotate_y(-event.relative.x * mouse_sensitivity)
            cam_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
            cam_pivot.rotation_degrees.x = clamp(
                cam_pivot.rotation_degrees.x,
                min_vertical_rotation,
                max_vertical_rotation
            )
        elif event.is_action_pressed("start_move"):
            if current_ray_result != null:
                print(current_ray_result)
            else:
                print("No movement target found")

func _physics_process(delta: float) -> void:
    if current_state == STATE.WAITING:
        var space_state := get_world().direct_space_state
        var from := cam.global_transform.origin
        var to := from - (cam.global_transform.basis.z.normalized() * ray_length)
        var result := space_state.intersect_ray(from, to)
        if result and result.collider is FloatingBody:
            current_ray_result = result
        else:
            current_ray_result = null
