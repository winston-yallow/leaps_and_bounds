extends Control

var previous_mouse_mode

func _ready() -> void:
    visible = false

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        visible = !visible
        get_tree().paused = visible
        if visible:
            previous_mouse_mode = Input.get_mouse_mode()
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        else:
            Input.set_mouse_mode(previous_mouse_mode)
