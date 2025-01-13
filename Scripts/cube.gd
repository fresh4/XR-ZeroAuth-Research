class_name Cube extends Node3D

@onready var rb: RigidBody3D = self.get_child(0);

const headers: String = "lv_x, lv_y, lv_z, av_x, av_y, av_z, pos_x, pos_y, pos_z\n";
var data: String = headers;

func _ready() -> void:
	Globals.recording_toggled.connect(_on_recording_toggle);

func _physics_process(_delta: float) -> void:
	if not Globals.is_recording: return
	if rb.linear_velocity > Vector3.ZERO or rb.angular_velocity > Vector3.ZERO:
		data += str(rb.linear_velocity.x) + ", " + str(rb.linear_velocity.y) + ", " + str(rb.linear_velocity.z) + ", "\
			 + str(rb.angular_velocity.x) + ", " + str(rb.angular_velocity.y) + ", " + str(rb.angular_velocity.z) + ", "\
			 + str(rb.position.x) + ", " + str(rb.position.y) + ", " + str(rb.position.z) + "\n";

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save_recording"):
		save_data();

func save_data():
	var filename: String = str(rb.name) + ".csv";
	var csv = FileAccess.open("user://" + filename, FileAccess.WRITE);
	csv.store_string(data);
	print("Saving " + filename + " in user directory. File size: " + str(csv.get_length()/1000) + "kb");
	#OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://"));

func _on_recording_toggle():
	if Globals.is_recording: data = headers;
	print("Recording" + str(rb.name) + "metrics: " + str(Globals.is_recording));
