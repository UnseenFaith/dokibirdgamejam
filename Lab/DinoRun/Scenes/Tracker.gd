extends Node2D

signal finished()

func _process(_delta: float) -> void:
	print($Path2D/PathFollow2D.progress_ratio)
	if $Path2D/PathFollow2D.progress_ratio >= 0.99992477893829:
		finished.emit()
		self.process_mode = Node.PROCESS_MODE_DISABLED
