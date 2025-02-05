extends Area3D

@onready var nail: StaticBody3D = self.get_parent();

var MAX_DIST: float = 0.055; ## The maximum vertical distance the nail is allowed to move in total.
var MAX_FORCE: float = 10.0; ## The maximum force applied that will be considered.

var initial_pos: Vector3 ## The nail's initial position.
var coefficient: float = MAX_DIST / MAX_FORCE; ## Value used to determine how much to actually move the nail on impact.

func _ready() -> void:
	initial_pos = nail.position;

func _on_body_entered(body: RigidBody3D) -> void:
	if body is not XRToolsPickable: return;
	var force: float = abs(body.mass * 0.5);
	if nail.position.y <= initial_pos.y - MAX_DIST: return; # Do not move if nail is already fully set.
	
	# Move nail on impact, to a maximum distance where the head is touching the table.
	var distance_to_move: float = force * coefficient;
	nail.position.y -= distance_to_move;
	nail.position.y = clampf(nail.position.y, initial_pos.y - MAX_DIST, initial_pos.y);
