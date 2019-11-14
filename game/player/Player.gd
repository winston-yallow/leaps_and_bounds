extends Spatial

enum STATE { MOVING, WAITING }

var mouse_sensitivity := 0.01
var min_vertical_rotation := -75.0
var max_vertical_rotation := +75.0
var ray_length := 100.0
var distance_from_objects := 0.5

var speed := 15.0

var current_state: int = STATE.WAITING
var current_ray_target = null

var movement_progress := 0.0
var movement_from: Transform
onready var movement_target := DynamicTransform.new(global_transform, self)
var movement_speed: float

onready var cam_pivot := $CameraPivot
onready var cam: Camera = $CameraPivot/ClippedCamera

onready var target_preview: Spatial = $TargetPreview
onready var detector: Area = $Detector
onready var stats: Label = $CanvasLayer/InfoOverlay/Stats

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    stats.text = 'speed: {speed}\njump_distance: {ray_length}'.format({
        'speed': speed,
        'ray_length': ray_length
    })
    detector.connect("area_entered", self, "on_detection")

func on_detection(other: Node) -> void:
    if other is Powerup:
        match other.type:
            Powerup.TYPES.DISTANCE:
                ray_length += other.amount
            Powerup.TYPES.SPEED:
                speed += other.amount

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
            if current_ray_target != null:
                current_state = STATE.MOVING
                movement_progress = 0.0
                movement_from = global_transform
                movement_target = current_ray_target
                var distance := global_transform.origin.distance_to(
                    movement_target.get_global_transform().origin
                )
                movement_speed = (1 / distance) * speed
                target_preview.visible = false
            else:
                print("No movement target found")

func _physics_process(delta: float) -> void:
    
    if current_state == STATE.WAITING:
        
        var space_state := get_world().direct_space_state
        var direction := -cam.global_transform.basis.z.normalized()
        # Start 0.05 units away from the clipped camera position to prevent
        # colliding with objects behind the camera:
        var clip_offset := (cam.get_clip_offset() as float) + 0.05
        var from := cam.global_transform.origin + (direction * clip_offset)
        var to := from + (direction * ray_length)
        var result := space_state.intersect_ray(from, to)
        if result and result.collider != movement_target.anchor:
            current_ray_target = DynamicTransform.new(
                Transform(
                    global_transform.basis,
                    result.position + (result.normal * distance_from_objects)
                ),
                result.collider
            )
            target_preview.global_transform = current_ray_target.get_global_transform()
            target_preview.visible = true
        else:
            current_ray_target = null
            target_preview.visible = false
        
        global_transform.origin = movement_target.get_global_transform().origin
    
    elif current_state == STATE.MOVING:
        
        movement_progress = min(
            movement_progress + (delta * movement_speed), 1.0
        )
        var target := movement_target.get_global_transform()
        global_transform = movement_from.interpolate_with(
            target,
            movement_progress
        )
        if movement_progress >= 1.0:
            current_state = STATE.WAITING
