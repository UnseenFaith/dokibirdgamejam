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
	
	
