extends PathFollow2D

var direction := 1

func _physics_process(delta):
	progress_ratio += 0.2 * delta * direction
	if progress_ratio >= 1:
		direction = -1
	if progress_ratio <= 0:
		direction = 1
	
