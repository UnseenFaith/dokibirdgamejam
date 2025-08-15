extends Node2D


@export_range(1,3,1) var piece: int = 1
var throw_start := Vector2.ZERO
var throw_end := Vector2.ZERO
var throw_time := 0.0
var throw_duration := 0.5
var throw_peak := 100.0
var throwing := false

func _ready() -> void:
	$AnimatedSprite2D.frame = piece - 1
	

func disintegrate() -> void:
	$AnimatedSprite2D.play("disintegrate_" + str(piece))
	await $AnimatedSprite2D.animation_finished
	queue_free()

func throw_to(target_position: Vector2, duration := 0.5, peak := 100.0):
	throw_start = position
	throw_end = target_position
	throw_duration = duration
	throw_peak = peak
	throw_time = 0.0
	throwing = true

func _process(delta):
	if throwing:
		throw_time += delta
		var t = throw_time / throw_duration
		if t >= 1.0:
			t = 1.0
			throwing = false

		# Move along a parabola
		var pos = throw_start.lerp(throw_end, t)
		pos.y -= sin(t * PI) * throw_peak
		position = pos
