extends ActionLeaf

@export var wait_time: float = 1.0

var _elapsed: float = 0.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	# First tick: reset timer
	if _elapsed == 0.0:
		_elapsed = 0.0001  # mark started (tiny value so it doesn't instantly finish)
	
	_elapsed += get_process_delta_time()

	if _elapsed >= wait_time:
		_elapsed = 0.0
		return SUCCESS

	return RUNNING

func after_run(actor: Node, blackboard: Blackboard) -> void:
	_elapsed = 0.0
