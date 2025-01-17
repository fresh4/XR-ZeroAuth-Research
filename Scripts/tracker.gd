class_name Tracker extends Node3D

@onready var rb: RigidBody3D = self.get_parent(); # The physics object that has the desired metrics.

# Default CSV column headers. Linear+angular velocity and position.
const headers: String = "lv_x, lv_y, lv_z, av_x, av_y, av_z, pos_x, pos_y, pos_z\n";
var data: String = headers;
var idx: int = 1;
var floor: float = .0001;

func _ready() -> void:
	Globals.recording_toggled.connect(_on_recording_toggle);

func _physics_process(_delta: float) -> void:
	if not Globals.is_recording: return
	record_metrics();
	if not is_moving():
		save_data();

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save_recording"):
		save_data();

# Every (physics) frame we append the current positional states as a row in the csv.
# Only if the physics object is not stationary to reduce unnecessary row entries.
func record_metrics():
	if is_moving():
		print(rb.name + " " + str(rb.linear_velocity));
		data += str(rb.linear_velocity.x) + ", " + str(rb.linear_velocity.y) + ", " + str(rb.linear_velocity.z) + ", "\
			 + str(rb.angular_velocity.x) + ", " + str(rb.angular_velocity.y) + ", " + str(rb.angular_velocity.z) + ", "\
			 + str(rb.position.x) + ", " + str(rb.position.y) + ", " + str(rb.position.z) + "\n";

# Takes the csv formatted string and writes to file as an actual csv. 
# Happens for each physics object in the scene.
func save_data():
	var filename: String = str(rb.name) + "_" + str(idx) + ".csv";
	var csv = FileAccess.open("user://" + filename, FileAccess.WRITE);
	csv.store_string(data);
	print("Saving " + filename + " in user directory. File size: " + str(csv.get_length()/1000.0) + "kb");
	#OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://"));

func is_moving() -> bool:
	return (abs(rb.linear_velocity.x) > floor or abs(rb.linear_velocity.y) > floor or abs(rb.linear_velocity.z) > floor) or \
	   (abs(rb.angular_velocity.x) > floor or abs(rb.angular_velocity.y) > floor or abs(rb.angular_velocity.z) > floor)
		

func _on_recording_toggle():
	# If we start recording, reset the csv to record new information.
	if Globals.is_recording: data = headers;
	print("Recording" + str(rb.name) + "metrics: " + str(Globals.is_recording));
