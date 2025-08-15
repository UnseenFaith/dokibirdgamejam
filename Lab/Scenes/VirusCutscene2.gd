extends Node2D

var rhythm := preload("res://Lab/RhythmGame/RhythmGame.tscn")

func _ready() -> void:
	#var tween := create_tween()
	#tween.tween_property($Doki.material, "shader_parameter/progress", 1.0, 0.5)
	#tween.tween_property($Crow.material, "shader_parameter/progress", 1.0, 0.5)
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
	pass
	
	#SceneManager.transitionToScene(rhythm)
	
