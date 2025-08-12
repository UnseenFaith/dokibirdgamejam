extends Node2D

func _process(delta: float) -> void:
	$Path2D/PathFollow2D.progress_ratio += 0.01 * delta
	
