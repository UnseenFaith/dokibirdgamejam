extends Node2D

func _process(_delta: float) -> void:
	if $Path2D/PathFollow2D.progress_ratio == 1:
		self.process_mode = Node.PROCESS_MODE_DISABLED
