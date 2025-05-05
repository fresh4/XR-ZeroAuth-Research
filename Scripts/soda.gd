extends GPUParticles3D

@onready var ray_cast_3d: RayCast3D = %RayCast3D

var parent: XRToolsPickable;
var current_glass: Area3D = null;

func _ready() -> void:
	parent = get_parent();
	emitting = false;

func _physics_process(_delta: float) -> void:
	ray_cast_3d.global_rotation_degrees.z = 0;
	if abs(parent.rotation_degrees.x) > 80 or abs(parent.rotation_degrees.z) > 80:
		ray_cast_3d.enabled = true
		emitting = true
	else:
		ray_cast_3d.enabled = false
		emitting = false
	
	if ray_cast_3d.is_colliding():
		# Found a collision
		var area: Area3D = ray_cast_3d.get_collider();
		# If it's a different glass, start filling it up
		if area != current_glass:
			area.area_entered.emit();
			current_glass = area;
	else:
		# No collision AND we current have a current glass, disconnect.
		if current_glass:
			current_glass.area_exited.emit();
			current_glass = null;
