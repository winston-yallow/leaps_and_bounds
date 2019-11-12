extends Resource
class_name DynamicTransform

var anchor: Spatial
var relative_transform: Transform

func _init(world_transform: Transform, anchor_obj: Spatial) -> void:
    anchor = anchor_obj
    relative_transform = anchor.global_transform.affine_inverse() * world_transform

func get_global_transform() -> Transform:
    return anchor.global_transform * relative_transform
