extends KinematicBody
class_name FloatingBody

var default_speed := 0.03
var speed: float

func _ready() -> void:
	# Allow the level scene to override the global speed of the scene.
	# Uses default_speed as a fallback.
	if 'speed' in get_tree().current_scene:
		speed = get_tree().current_scene.speed
	else:
		speed = default_speed

func _physics_process(delta: float) -> void:
	move_and_slide(translation * speed)
