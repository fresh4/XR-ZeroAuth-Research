extends Node

# A listenable event that fires whenever the recording state changes.
signal recording_toggled; 

# Constants for socket communication
const HOST: String = "127.0.0.1"
const PORT: int = 6000

# Global variable that keeps track of recording states between different scripts.
var is_recording: bool = false; 
var socket: PacketPeerUDP = PacketPeerUDP.new()

func _ready() -> void:
	socket.connect_to_host(HOST, PORT)
	if socket.is_socket_connected():
		print("Established UDP connection to " + HOST + ":" + str(PORT))
		print("NOTE: UDP is connectionless, so there's no guarantee the host is alive.")

func _exit_tree() -> void:
	socket.close()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_recording"):
		is_recording = !is_recording;
		recording_toggled.emit();
	elif event.is_action_pressed("reset"):
		get_tree().reload_current_scene();
		is_recording = false;

func send_socket_data(msg: String):
	if not socket.is_socket_connected(): return
	socket.put_packet(msg.to_ascii_buffer())
