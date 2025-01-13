extends Node3D

@export var player: XROrigin3D;
@onready var headset: XRCamera3D = player.get_node("%Headset");

const headers: String = "rot_x, rot_y, rot_z, pos_x, pos_y, pos_z\n";
var data: String = headers;

func _ready() -> void:
	Globals.recording_toggled.connect(_on_recording_toggled);

func _physics_process(_delta: float) -> void:
	if Globals.is_recording:
		record_headset();

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("recenter_headset"):
		recenter_headset();
	if event.is_action_pressed("save_recording"):
		save_data();
		
func recenter_headset():
	print("Recentering Headset.")
	player.position = Vector3(0,0,0); 
	player.rotation = Vector3(0,0,0);
	XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true);
	
func record_headset():
	data += str(headset.rotation.x) + ", " + str(headset.rotation.y) + ", " + str(headset.rotation.z) + ", "\
		 + str(headset.position.x) + ", " + str(headset.position.y) + ", " + str(headset.position.z) + "\n";

func save_data():
	var filename: String = "headset_data.csv";
	var csv = FileAccess.open("user://" + filename, FileAccess.WRITE);
	csv.store_string(data);
	print("Saving " + filename + " in user directory. File size: " + str(csv.get_length()/1000) + "kb");
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://"));

func _on_recording_toggled():
	if Globals.is_recording: data = headers;
	print("Recording headset metrics: " + str(Globals.is_recording));
