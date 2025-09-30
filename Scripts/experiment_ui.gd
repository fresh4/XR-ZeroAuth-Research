extends MeshInstance3D

@export var hand_detection_area: Area3D

func _ready() -> void:
	hand_detection_area.area_entered.connect(on_hand_entered)
	hand_detection_area.area_exited.connect(on_hand_exited)

func on_hand_entered(_area: Area3D) -> void:
	material_override.set("albedo_color", "#80f54b")

func on_hand_exited(_area: Area3D) -> void:
	material_override.set("albedo_color", "#ffffff")
