extends Area
class_name Powerup

enum TYPES { SPEED, DISTANCE, POINTS }

export var amount := 5.0
export(TYPES) var type: int = TYPES.SPEED

func consume() -> void:
    queue_free()
