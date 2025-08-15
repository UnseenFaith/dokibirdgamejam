extends Node2D
class_name Throwable

var throw_start: Vector2
var throw_end: Vector2
var throw_time := 0.0
var throw_duration := 0.5
var throw_peak := 100.0
var throwing := false

## Call this to make the node throw itself to a position
func throw_to(target_position: Vector2, duration := 0.5, peak := 100.0):
	throw_start = position
	throw_end = target_position
	throw_duration = duration
	throw_peak = peak
	throw_time = 0.0
	throwing = true

func _process(delta: float) -> void:
	if throwing:
		throw_time += delta
		var t := throw_time / throw_duration
		if t >= 1.0:
			t = 1.0
			throwing = false

		# Linear X/Y movement
		var pos = throw_start.lerp(throw_end, t)

		# Arc for the throw
		pos.y -= sin(t * PI) * throw_peak

		position = pos
