extends Area
class_name Powerup

enum TYPES { SPEED, DISTANCE }

export var amount := 1.0
export(TYPES) var type: int = TYPES.SPEED

func consume() -> void:
    queue_free()
