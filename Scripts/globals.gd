extends Node

# A listenable event that fires whenever the recording state changes.
signal recording_toggled; 

# Global variable that keeps track of recording states between different scripts.
var is_recording: bool = false; 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_recording"):
		is_recording = !is_recording;
		recording_toggled.emit();
	elif event.is_action_pressed("reset"):
		get_tree().reload_current_scene();
		is_recording = false;
