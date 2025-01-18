class_name Tracker extends Node3D

@onready var rb: RigidBody3D = self.get_parent(); # The physics object that has the desired metrics.

# Default CSV column headers. Linear+angular velocity and position.
const headers: String = "lv_x, lv_y, lv_z, av_x, av_y, av_z, pos_x, pos_y, pos_z\n";
var data: String = headers; ## Current recorded data, defaults to empty csv with defined columns.
var idx: int = 1; ## File name index identifier.
var floor: float = .0001; ## Minimum value for velocity to determine item is in motion.
var saved: bool = true; ## Whether or not we have already saved the data (to avoid writing to file every frame).

func _ready() -> void:
	Globals.recording_toggled.connect(_on_recording_toggle);

func _physics_process(_delta: float) -> void:
	if not Globals.is_recording: return
	record_metrics();
	# If the object has stopped moving, we want to save its journey to file.
	if not is_moving() and not saved:
		save_data();

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("save_recording"):
		#save_data();
	pass

# Every (physics) frame we append the current positional states as a row in the csv.
# Only if the physics object is not stationary to reduce unnecessary row entries.
func record_metrics():
	if is_moving():
		saved = false; # If the object begins to move, reset saved state to be able to record current journey.
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
	saved = true; # Set saved state when saved to avoid repeated execution of this function.
	idx += 1 # Append index such that next file isn't overwritten.

func is_moving() -> bool:
	return (abs(rb.linear_velocity.x) > floor or abs(rb.linear_velocity.y) > floor or abs(rb.linear_velocity.z) > floor) or \
	   (abs(rb.angular_velocity.x) > floor or abs(rb.angular_velocity.y) > floor or abs(rb.angular_velocity.z) > floor)

func _on_recording_toggle():
	# If we start recording, reset the csv to record new information.
	if Globals.is_recording: data = headers;
	print("Recording " + str(rb.name) + " metrics: " + str(Globals.is_recording));
