extends Node

@export var id: String = "";
@export var frequency: int = 0;

@onready var frame_rate = ProjectSettings.get_setting("physics/common/physics_ticks_per_second");

const PORT = 6000;

var parent: Node3D;
var mesh: MeshInstance3D;
var highlight_mesh: MeshInstance3D;
var time: float = 0;

func _ready() -> void:
	Globals.msg_received.connect(highlight_object);
	parent = get_parent();
	mesh = parent.get_child(1);
	highlight_mesh = parent.get_child(4);
	highlight_mesh.visible = false;

func _physics_process(delta: float) -> void:
	time += delta;
	var c = (127.5 + 127.5 * sin(2 * PI * frequency * time))/255;
	var color = Color(c,c,c);
	mesh.material_override.albedo_color = color;

func highlight_object(msg) -> void:
	highlight_mesh.visible = str(msg) == str(id);
