extends Spatial

enum STATE { MOVING, WAITING }

var mouse_sensitivity := 0.01
var min_vertical_rotation := -75.0
var max_vertical_rotation := +75.0
var ray_length := 100.0
var distance_from_objects := 0.5

var current_state: int = STATE.WAITING
var current_ray_result = null

var movement_progress := 0.0
var movement_starting_transform: Transform
var movement_target: FloatingBody
var movement_rel_offset: Vector3

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
                current_state = STATE.MOVING
                movement_progress = 0.0
                movement_starting_transform = global_transform
                movement_target = current_ray_result.collider
                var collider_center := movement_target.global_transform.origin
                var position := current_ray_result.position as Vector3
                var normal := current_ray_result.normal as Vector3
                var target_pos := position + (normal * distance_from_objects)
                movement_rel_offset = target_pos - collider_center
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
    elif current_state == STATE.MOVING:
        movement_progress = min(movement_progress + delta, 1.0)
        var target := Transform(
            movement_starting_transform.basis,
            movement_target.global_transform.origin + movement_rel_offset
        )
        global_transform = movement_starting_transform.interpolate_with(
            target,
            movement_progress
        )
        if movement_progress >= 1.0:
            current_state = STATE.WAITING
