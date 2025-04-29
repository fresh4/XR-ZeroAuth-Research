extends Tracker

# When this object spawns, start recording the metrics of the given held object.
# When it collides, stop recording.
var ball: RigidBody3D;
var hit: bool = false;

func _ready() -> void:
	initialize();
	ball = get_parent();
	rb = get_tree().get_first_node_in_group("Paddle");
	ball.body_entered.connect(_on_collision);
	
	record();

func _physics_process(_delta: float) -> void:
	if not Globals.is_recording: return
	record_metrics();

func _on_collision(body: Node) -> void:
	if not body == rb: return;
	if hit: return;
	ball.gravity_scale = 1;
	hit = true;
	end_record();

func end_record() -> void:
	picked_up = false;
	if Globals.is_recording:
		save_data(ball.name + ".csv");
	Globals.send_socket_data("DROP " + rb.name)

func record() -> void:
	Globals.send_socket_data("PICKUP " + rb.name)
	picked_up = true;

# Saves file on node deletion.
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and not hit:
		end_record();
