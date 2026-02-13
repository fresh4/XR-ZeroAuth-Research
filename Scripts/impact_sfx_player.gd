extends AudioStreamPlayer

var parent: RigidBody3D

func _ready() -> void:
	parent = get_parent()
	parent.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	play()
