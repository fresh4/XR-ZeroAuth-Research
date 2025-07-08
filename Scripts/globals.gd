extends Node

# A listenable event that fires whenever the recording state changes.
signal recording_toggled; 
signal msg_received(msg);

var server = UDPServer.new();
# Constants for socket communication
const HOST: String = "127.0.0.1"
const PORT: int = 6000

# Global variable that keeps track of recording states between different scripts.
var is_recording: bool = false; 
var socket: PacketPeerUDP = PacketPeerUDP.new()

var flag = "";

func _ready() -> void:
	server.listen(PORT);

	socket.connect_to_host(HOST, PORT)
	if socket.is_socket_connected():
		print("Established UDP connection to " + HOST + ":" + str(PORT))
		print("NOTE: UDP is connectionless, so there's no guarantee the host is alive.")

func _physics_process(_delta: float) -> void:
	listen();

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

func listen() -> void:
	server.poll();
	if server.is_connection_available():
		var peer = Globals.server.take_connection();
		var packet = peer.get_packet();
		var msg = packet.get_string_from_utf8().replace("\n", "");
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()]);
		print("Received data: %s" % [packet.get_string_from_utf8()]);
		msg_received.emit(msg);
