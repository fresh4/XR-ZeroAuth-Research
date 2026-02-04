extends Node3D

enum Experiment { HOLD, MOVE }

@export var models: Array[PackedScene]
@export_category("Info Labels")
@export var time_label: Label3D
@export var idx_label: Label3D
@export_category("Timer Settings")
@export var timer_duration: int = 3.0;
@export var timer: Timer
@export_category("Move Experiment Settings")
@export var move_experiment_node: Node3D
@export var move_experiment_spawn: Node3D

var MAX_PROGRESS: int

var player: Player
var unused_models: Array[PackedScene]
var current_model: XRToolsPickable
var current_experiment: Experiment = Experiment.HOLD
var progress_idx: int = 0
var spawn_point: Node3D = self

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	unused_models = models.duplicate()
	time_label.text = str(timer_duration)
	timer.wait_time = timer_duration
	
	MAX_PROGRESS = len(models)
	if move_experiment_node:
		move_experiment_node.hide()
	progress_next_model()

func _process(delta: float) -> void:
	if current_experiment == Experiment.HOLD:
		time_label.text = "%.2f" % (timer.time_left)

func progress_next_model() -> void:
	if current_model:
		current_model.queue_free()
		current_model = null
	
	progress_idx += 1
	if progress_idx - 1 == MAX_PROGRESS:
		if current_experiment == Experiment.HOLD:
			current_experiment = Experiment.MOVE
			time_label.text = ""
		elif current_experiment == Experiment.MOVE:
			finish()
			return
		progress_idx = 1
		move_experiment_node.show()
		unused_models = models.duplicate()
		if move_experiment_spawn: spawn_point = move_experiment_spawn
	
	var _model: PackedScene = unused_models.pick_random()
	unused_models.erase(_model)
	current_model = _model.instantiate()
	current_model.picked_up.connect(handle_pickup)
	current_model.dropped.connect(handle_drop)
	spawn_point.add_child(current_model)
	current_model.name = current_model.name + ("_HOLD" if current_experiment == Experiment.HOLD else "_MOVE")
	
	if idx_label:
		idx_label.text = str(progress_idx) + "/" + str(MAX_PROGRESS)

func handle_pickup(obj: XRToolsPickable) -> void:
	if current_experiment == Experiment.HOLD:
		timer.start(timer_duration)
		timer.paused = false
	elif current_experiment == Experiment.MOVE:
		pass

func handle_drop(obj: XRToolsPickable) -> void:
	await get_tree().create_timer(0.1).timeout;
	if obj.is_picked_up(): return;
	if current_experiment == Experiment.HOLD:
		timer.start(timer_duration)
		timer.paused = true
		progress_next_model()
	elif current_experiment == Experiment.MOVE:
		progress_next_model()
		pass

func finish() -> void: 
	time_label.text = "Done!"
	move_experiment_node.hide()
