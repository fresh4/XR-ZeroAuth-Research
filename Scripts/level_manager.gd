extends Node3D

@export var player: Player; ## Node that represents the Player. Must be imported in editor.
@onready var headset: XRCamera3D = player.get_node("%Headset"); ## Get XR Camera from Player children.

# Default CSV column headers. Rotation and Position for the headset.
const headers: String = "rot_x, rot_y, rot_z, pos_x, pos_y, pos_z, flag\n";
var data: String = headers;

# Column headers for arm length calibration csv.
const calibration_headers: String = "rot_x, rot_y, rot_z, pos_x, pos_y, pos_z," + \
									"lh_pos_x, lh_pos_y, lh_pos_z, lh_rot_x, lh_rot_y, lh_rot_z," + \
									"rh_pos_x, rh_pos_y, rh_pos_z, rh_rot_x, rh_rot_y, rh_rot_z" + "\n";
var calibration_data: String = calibration_headers;
var is_calibrating_arm_length: bool = false;

var teleport_points: Array[Node3D] = []
var teleport_point_key_map: Array[int] = []

func _ready() -> void:
	Globals.recording_toggled.connect(_on_recording_toggled);
	call_deferred("recenter_headset");
	for i in get_tree().get_nodes_in_group("TeleportPoints"):
		teleport_points.append(i)
		teleport_point_key_map.append( len(teleport_point_key_map) + 49 )

func _physics_process(_delta: float) -> void:
	if Globals.is_recording:
		record_headset();
	if is_calibrating_arm_length:
		calibrate_arm_length();

# Handle input events.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("recenter_headset"):
		recenter_headset();
	if event.is_action_pressed("save_recording"):
		save_data();
	if event.is_action_pressed("calibrate_arm_length"):
		# Specifically record controller and headset position data for 5 seconds.
		print("Starting 5 second arm calibration. Stay still! ")
		is_calibrating_arm_length = true;
		await get_tree().create_timer(5).timeout
		is_calibrating_arm_length = false;
		save_data("arm_calibration_data.csv", calibration_data);
		calibration_data = calibration_headers;

func _unhandled_key_input(event: InputEvent) -> void:
	# Handles teleporting to the nth experiment spot
	if event is InputEventKey and event.keycode in teleport_point_key_map:
		if !teleport_point_key_map: return
		var idx: int = teleport_point_key_map.find(event.keycode)
		player.position = teleport_points[idx].global_position;
		player.rotation.y = teleport_points[idx].global_rotation.y;
		XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true);

# Resets position and orientation to the center of the room.
func recenter_headset():
	print("Recentering Headset.")
	player.position = Vector3(0,0,0); 
	player.rotation = Vector3(0,0,0);
	# Necessary since the headset camera is separate from the player origin node.
	# Built in function that resets and consolidates differences.
	XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true);

# Every (physics) frame we append the current positional states as a row in the csv.
func record_headset():
	data += str(headset.rotation.x) + ", " + str(headset.rotation.y) + ", " + str(headset.rotation.z) + ", "\
		 + str(headset.global_position.x) + ", " + str(headset.global_position.y) + ", " + str(headset.global_position.z) + ", "\
		 + Globals.flag + "\n";
		
# Every (physics) frame we append the current positional states as a row in the csv.
func calibrate_arm_length():
	var left_hand = player.left_hand_xr_node;
	var right_hand = player.right_hand_xr_node;
	calibration_data += str(headset.rotation.x) + ", " + str(headset.rotation.y) + ", " + str(headset.rotation.z) + ", "\
		 + str(headset.global_position.x) + ", " + str(headset.global_position.y) + ", " + str(headset.global_position.z) + ", "\
		 + str(left_hand.global_position.x) + ", " + str(left_hand.global_position.y) + ", " + str(left_hand.global_position.z) + ", "\
		 + str(left_hand.rotation.x) + ", " + str(left_hand.rotation.y) + ", " + str(left_hand.rotation.z) + ", "\
		 + str(right_hand.global_position.x) + ", " + str(right_hand.global_position.y) + ", " + str(right_hand.global_position.z) + ", "\
		 + str(right_hand.rotation.x) + ", " + str(right_hand.rotation.y) + ", " + str(right_hand.rotation.z) + "\n"

# Takes the csv formatted string and writes to file as an actual csv. 
# Opens the location it's saved in for convenience.
func save_data(filename = "headset_data.csv", values = data, popup: bool = true):
	var csv = FileAccess.open("user://" + filename, FileAccess.WRITE);
	csv.store_string(values);
	print("Saving " + filename + " in user directory. File size: " + str(csv.get_length()/1000.0) + "kb");
	if popup:
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://"));

func _on_recording_toggled():
	# If we start recording, reset the csv to record new information.
	if Globals.is_recording: data = headers;
	print("Recording headset metrics: " + str(Globals.is_recording));
