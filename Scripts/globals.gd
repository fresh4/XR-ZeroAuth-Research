extends Node

signal recording_toggled;

var is_recording: bool = false;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_recording"):
		is_recording = !is_recording;
		recording_toggled.emit();
