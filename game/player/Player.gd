extends Spatial

enum STATE { JUMPING, WAITING }

var mouse_sensitivity := 0.01
var min_vertical_rotation := -75.0
var max_vertical_rotation := +75.0
var ray_length := 100.0
var distance_from_objects := 0.5

var speed := 10.0

var points := 0

var current_state: int = STATE.WAITING
var current_ray_target = null

var jump_progress := 0.0
var jump_from: DynamicTransform
onready var jump_target := DynamicTransform.new(
    global_transform,
    get_tree().current_scene
)
var jump_speed: float

onready var cam_pivot := $CameraPivot
onready var cam: Camera = $CameraPivot/ClippedCamera

onready var target_preview: Spatial = $TargetPreview
onready var detector: Area = $Detector
onready var stats: Label = $CanvasLayer/InfoOverlay/Stats

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    update_stats_label()
    detector.connect("area_entered", self, "on_detection")

func update_stats_label() -> void:
    stats.text = 'speed: {speed}\njump_distance: {ray_length}'.format({
        'speed': speed,
        'ray_length': ray_length
    })

func on_detection(other: Node) -> void:
    if other is Powerup:
        match other.type:
            Powerup.TYPES.DISTANCE:
                ray_length += other.amount
            Powerup.TYPES.SPEED:
                speed += other.amount
            Powerup.TYPES.POINTS:
                points += other.amount
            _: # Immediately return without stats update when no match was found
                return
        other.consume()
        update_stats_label()

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
        elif event.is_action_pressed("start_jump"):
            if current_ray_target != null:
                current_state = STATE.JUMPING
                jump_progress = 0.0
                jump_from = DynamicTransform.new(
                    global_transform,
                    jump_target.anchor
                )
                jump_target = current_ray_target
                var distance := global_transform.origin.distance_to(
                    jump_target.get_global_transform().origin
                )
                jump_speed = (1 / distance) * speed
                target_preview.visible = false
            else:
                print("No jump target found")

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
        if result and result.collider != jump_target.anchor:
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
        
        global_transform.origin = jump_target.get_global_transform().origin
    
    elif current_state == STATE.JUMPING:
        
        jump_progress = min(
            jump_progress + (delta * jump_speed), 1.0
        )
        global_transform = jump_from.get_global_transform().interpolate_with(
            jump_target.get_global_transform(),
            jump_progress
        )
        if jump_progress >= 1.0:
            current_state = STATE.WAITING
