extends Area
class_name Powerup

enum TYPES { SPEED, DISTANCE, POINTS }

export var amount := 5
export(TYPES) var type: int = TYPES.SPEED

func consume() -> void:
    queue_free()
