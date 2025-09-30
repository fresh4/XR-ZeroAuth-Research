extends Node3D

@onready var area: Area3D = %Area3D

var tool: XRToolsPickable = null

func _ready() -> void:
	area.body_entered.connect(on_tool_entered)
	area.body_exited.connect(on_tool_exited)

func _process(_delta: float) -> void:
	if tool:
		rotation.z = tool.rotation.z

func on_tool_entered(body: Node3D) -> void:
	tool = body as XRToolsPickable

func on_tool_exited(_body: Node3D) -> void:
	tool = null
