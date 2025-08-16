extends Node2D

var throne := preload("res://Lab/Scenes/ThroneRoom.tscn")

func _ready() -> void:
	var tv_tween := create_tween()
	tv_tween.tween_property($Background.material, "shader_parameter/progress", 0, 1.0)
	await tv_tween.finished
	
	var tween := create_tween()
	tween.tween_property($Doki.material, "shader_parameter/progress", 1.0, 1.0)
	tween.parallel().tween_property($VirusPiece/AnimatedSprite2D.material, "shader_parameter/progress", 1.0, 1.0)
	tween.tween_property($Crow.material, "shader_parameter/progress", 1.0, 1.0)
	await tween.finished

	if Dialogic.VAR.firstGameWon:
		$Virus1.visible = true
	
	await get_tree().create_timer(1.0).timeout
	if not Dialogic.VAR.secondGameWon:
		$VirusPiece.disintegrate()
		await get_tree().create_timer(1.0).timeout
	else:
		$VirusPiece.throw_to(Vector2(353, -77))
		await get_tree().create_timer(1.0).timeout
	Dialogic.start("virus_desktop_2")
	Dialogic.connect("timeline_ended", timeline_ended)
	Dialogic.connect("signal_event", dialogic_signal)

func dialogic_signal(param: String) -> void:
	if param == "hooded_figure_enters":
		var tween := create_tween()
		tween.tween_property($HoodedFigure.material, "shader_parameter/progress", 1.0, 0.2)
		await get_tree().create_timer(1.0).timeout

func timeline_ended() -> void:
	$AnimationPlayer.play("chase_hooded_figure")
	await $AnimationPlayer.animation_finished
	
	SceneManager.transitionToScene(throne)
	
