extends MeshInstance3D

@export var detection_area: Area3D

func _ready() -> void:
	detection_area.body_entered.connect(on_area_entered)

func on_area_entered(_body: RigidBody3D) -> void:
	var cur_albedo: Color = material_override.get("albedo_color") as Color
	cur_albedo.a = clampf(cur_albedo.a - 0.1, 0, 1)
	material_override.set("albedo_color", cur_albedo)
