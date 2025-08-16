extends Node2D

func _ready() -> void:
	var tv_tween := create_tween()
	tv_tween.tween_property($Throne1.material, "shader_parameter/progress", 0.0, 1.0)
	await tv_tween.finished
	var doki_tween := create_tween()
	doki_tween.tween_property($Doki.material, "shader_parameter/progress", 1.0, 1.5)
	await doki_tween.finished
	var crow_tween := create_tween()
	crow_tween.tween_property($Crow.material, "shader_parameter/progress", 1.0, 1.5)
	await crow_tween.finished
	
	$AnimationPlayer.play("intro")
	await $AnimationPlayer.animation_finished
	
	Dialogic.start("dad_confrontation")
	await Dialogic.signal_event
	$HoodedFigure.play("dog")
	await Dialogic.timeline_ended
	rumble_shake()

func rumble_shake(intensity: float = 8.0, duration: float = 0.6, interval: float = 0.05) -> void:
	var tween := create_tween()
	var elapsed := 0.0
	var original = $PlayerCamera.offset

	tween.set_loops()  # keep looping until we stop it

	tween.tween_method(
		func(_t):
			# Random jitter each interval
			$PlayerCamera.offset = original + Vector2(
				randf_range(-intensity, intensity),
				randf_range(-intensity, intensity)
			), 
		0.0, 1.0, interval
	)

	# Stop after duration
	await get_tree().create_timer(duration).timeout
	tween.kill()

	# Smoothly reset to neutral
	var reset := create_tween()
	reset.tween_property($PlayerCamera, "offset", original, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
