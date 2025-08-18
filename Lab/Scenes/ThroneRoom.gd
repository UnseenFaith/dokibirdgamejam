extends Node2D

var boss := preload("res://Lab/BulletHell/BulletHell.tscn")

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
	await Dialogic.signal_event
	rumble_shake(8, 3, 0.01)
	var flash_tween := create_tween()
	flash_tween.tween_property($Flash, "self_modulate", Color(255, 255, 255, 1), 3)
	flash_tween.chain().tween_property($Throne, "visible", true, 0.1)
	flash_tween.chain().tween_property($HoodedFigure, "visible", false, 0.1)
	flash_tween.chain().tween_property($Doki, "position", $Doki.position + Vector2(-20, 0), 0.1)
	flash_tween.chain().tween_property($Crow, "position", $Crow.position + Vector2(-20, 0), 0.1)
	flash_tween.chain().tween_property($Throne1, "visible", false, 0.1)
	flash_tween.chain().tween_property($Flash, "self_modulate", Color(255, 255, 255, 0), 2)
	await flash_tween.finished
	
	await Dialogic.signal_event
	var jump_tween := create_tween()
	jump_tween.tween_callback(Callable($Doki, "throw_to").bind($Crow.position + Vector2(-35, 0), 0.5, 100, false))
	await jump_tween.finished
	
	await Dialogic.signal_event
	var throw_duration := 0.5

	var real_jump := create_tween()
	real_jump.tween_callback(Callable($Doki, "throw_to").bind($Crow.position, throw_duration))
	real_jump.chain().tween_interval(throw_duration) 
	real_jump.chain().tween_property($Crow, "visible", false, 0.0)
	real_jump.chain().tween_property($DokiCrow, "visible", true, 0.0)
	real_jump.chain().tween_property($DokiCrow, "position", Vector2(441, -15), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.5)

	await real_jump.finished
	await Dialogic.timeline_ended
	SceneManager.transitionToScene(boss)

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
