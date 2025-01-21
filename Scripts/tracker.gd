class_name Tracker extends Node3D

@onready var rb: XRToolsPickable = self.get_parent(); # The physics object that has the desired metrics.

# Default CSV column headers. Linear+angular velocity and position.
const headers: String = "lv_x, lv_y, lv_z, av_x, av_y, av_z, pos_x, pos_y, pos_z," + \
						"imu_pos_x, imu_pos_y, imu_pos_z, imu_rot_x, imu_rot_y, imu_rot_z," + \
						"lh_thumb_x, lh_thumb_y, lh_thumb_z," + \
						"lh_index_x, lh_index_y, lh_index_z," + \
						"lh_middle_x, lh_middle_y, lh_middle_z," + \
						"lh_ring_x, lh_ring_y, lh_ring_z," + \
						"lh_little_x, lh_little_y, lh_little_z," + \
						"rh_thumb_x, rh_thumb_y, rh_thumb_z," + \
						"rh_index_x, rh_index_y, rh_index_z," + \
						"rh_middle_x, rh_middle_y, rh_middle_z," + \
						"rh_ring_x, rh_ring_y, rh_ring_z," + \
						"rh_little_x, rh_little_y, rh_little_z" + "\n";
var data: String = headers; ## Current recorded data, defaults to empty csv with defined columns.
var idx: int = 1; ## File name index identifier.
var saved: bool = true; ## Whether or not we have already saved the data (to avoid writing to file every frame).
var picked_up: bool = false;

var player: Player = null;
var headset: XRCamera3D = null;
func _ready() -> void:
	Globals.recording_toggled.connect(_on_recording_toggle);
	rb.released.connect(_on_release);
	rb.picked_up.connect(_on_pickup);
	player = get_tree().get_first_node_in_group("Player");
	headset = player.get_node("%Headset");

func _physics_process(_delta: float) -> void:
	if not Globals.is_recording: return
	record_metrics();

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("save_recording"):
		#save_data();

# Every (physics) frame we append the current positional states as a row in the csv.
# Only if the physics object is not stationary to reduce unnecessary row entries.
func record_metrics():
	if picked_up:
		saved = false; # If the object begins to move, reset saved state to be able to record current journey.
		print(rb.name + " " + str(rb.linear_velocity.length()) + " " + str(rb.angular_velocity.length()));
		# Left hand/Right hand; idx 0 -> 4, thumb -> little finger
		var lh: Array[Vector3] = player.get_left_fingertip_transform();
		var rh: Array[Vector3] = player.get_right_fingertip_transform();

		data += str(rb.linear_velocity.x) + ", " + str(rb.linear_velocity.y) + ", " + str(rb.linear_velocity.z) + ", "\
			 + str(rb.angular_velocity.x) + ", " + str(rb.angular_velocity.y) + ", " + str(rb.angular_velocity.z) + ", "\
			 + str(rb.position.x) + ", " + str(rb.position.y) + ", " + str(rb.position.z) + ", "\
		 	 + str(headset.position.x) + ", " + str(headset.position.y) + ", " + str(headset.position.z) + ", "\
			 + str(headset.rotation.x) + ", " + str(headset.rotation.y) + ", " + str(headset.rotation.z) + ", "\
			 + str(lh[0].x) + ", " + str(lh[0].y) + ", " + str(lh[0].z) + ", "\
			 + str(lh[1].x) + ", " + str(lh[1].y) + ", " + str(lh[1].z) + ", "\
			 + str(lh[2].x) + ", " + str(lh[2].y) + ", " + str(lh[2].z) + ", "\
			 + str(lh[3].x) + ", " + str(lh[3].y) + ", " + str(lh[3].z) + ", "\
			 + str(lh[4].x) + ", " + str(lh[4].y) + ", " + str(lh[4].z) + ", "\
			 + str(rh[0].x) + ", " + str(rh[0].y) + ", " + str(rh[0].z) + ", "\
			 + str(rh[1].x) + ", " + str(rh[1].y) + ", " + str(rh[1].z) + ", "\
			 + str(rh[2].x) + ", " + str(rh[2].y) + ", " + str(rh[2].z) + ", "\
			 + str(rh[3].x) + ", " + str(rh[3].y) + ", " + str(rh[3].z) + ", "\
			 + str(rh[4].x) + ", " + str(rh[4].y) + ", " + str(rh[4].z) + "\n";

# Takes the csv formatted string and writes to file as an actual csv. 
# Happens for each physics object in the scene.
func save_data():
	var filename: String = str(rb.name) + "_" + str(idx) + ".csv";
	var csv = FileAccess.open("user://" + filename, FileAccess.WRITE);
	csv.store_string(data);
	#print("saving ", filename);
	print("Saving " + filename + " in user directory. File size: " + str(csv.get_length()/1000.0) + "kb");
	saved = true; # Set saved state when saved to avoid repeated execution of this function.
	idx += 1 # Append index such that next file isn't overwritten.

func is_moving() -> bool:
	var v_floor: float = .001; ## Minimum value for velocity to determine item is in motion.
	return (rb.angular_velocity.length() > v_floor and rb.linear_velocity.length() > v_floor);

func _on_recording_toggle():
	# If we start recording, reset the csv to record new information.
	if Globals.is_recording: data = headers;
	print("Recording " + str(rb.name) + " metrics: " + str(Globals.is_recording));

func _on_release(_what, _by) -> void:
	picked_up = false;
	save_data();

func _on_pickup(_what) -> void:
	picked_up = true;
