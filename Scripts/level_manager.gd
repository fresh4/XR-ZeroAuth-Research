extends Node3D

@export var player: Player; ## Node that represents the Player. Must be imported in editor.
@onready var headset: XRCamera3D = player.get_node("%Headset"); ## Get XR Camera from Player children.

# Default CSV column headers. Rotation and Position for the headset.
const headers: String = "rot_x, rot_y, rot_z, pos_x, pos_y, pos_z";
var data: String = headers;

func _ready() -> void:
	Globals.recording_toggled.connect(_on_recording_toggled);
	call_deferred("recenter_headset");

func _physics_process(_delta: float) -> void:
	if Globals.is_recording:
		record_headset();

# Handle input events.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("recenter_headset"):
		recenter_headset();
	if event.is_action_pressed("save_recording"):
		save_data();

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
		 + str(headset.position.x) + ", " + str(headset.position.y) + ", " + str(headset.position.z) + "\n";

# Takes the csv formatted string and writes to file as an actual csv. 
# Opens the location it's saved in for convenience.
func save_data():
	var filename: String = "headset_data.csv";
	var csv = FileAccess.open("user://" + filename, FileAccess.WRITE);
	csv.store_string(data);
	print("Saving " + filename + " in user directory. File size: " + str(csv.get_length()/1000.0) + "kb");
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://"));

func _on_recording_toggled():
	# If we start recording, reset the csv to record new information.
	if Globals.is_recording: data = headers;
	print("Recording headset metrics: " + str(Globals.is_recording));
