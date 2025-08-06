extends Node2D

func _physics_process(delta: float) -> void:
	position.x -= 100 * delta


func onVisibleOnScreenNotifier2d_screenExited() -> void:
	queue_free() # Replace with function body.
