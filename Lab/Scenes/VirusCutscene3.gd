extends Node2D

var credits := preload("res://Lab/Scenes/Intro/ExtraCredits.tscn")

func _ready() -> void:
	if Dialogic.VAR.firstGameWon:
		Dialogic.VAR.pieces += 1
	if Dialogic.VAR.secondGameWon:
		Dialogic.VAR.pieces += 1
	if Dialogic.VAR.thirdGameWon:
		Dialogic.VAR.pieces += 1
	
	if Dialogic.VAR.firstGameWon:
		$Virus1.visible = true
	if Dialogic.VAR.secondGameWon:
		$Virus2.visible = true
	
	var tv_tween := create_tween()
	tv_tween.tween_property($Background.material, "shader_parameter/progress", 0, 1.0)
	await tv_tween.finished
	
	var tween := create_tween()
	tween.tween_property($Doki.material, "shader_parameter/progress", 1.0, 1.0)
	tween.parallel().tween_property($VirusPiece/AnimatedSprite2D.material, "shader_parameter/progress", 1.0, 1.0)
	tween.tween_property($Crow.material, "shader_parameter/progress", 1.0, 1.0)
	tween.tween_property($Minty.material, "shader_parameter/progress", 1.0, 1.0)
	tween.tween_property($HoodedFigure.material, "shader_parameter/progress", 1.0, 1.0)

	await tween.finished


	
	await get_tree().create_timer(1.0).timeout
	if not Dialogic.VAR.thirdGameWon:
		$VirusPiece.disintegrate()
		await get_tree().create_timer(1.0).timeout
	else:
		$VirusPiece.throw_to(Vector2(355, -64.5))
		await get_tree().create_timer(1.0).timeout
	Dialogic.start("post-boss")
	
	if Dialogic.VAR.pieces == 3:
		await Dialogic.signal_event
		$Doki.play("tomato")

	await Dialogic.timeline_ended
	
	var tv_tween2 := create_tween()
	tv_tween2.tween_property($Doki, "visible", false, 0.0)
	tv_tween2.chain().tween_property($Crow, "visible", false, 0.0)
	tv_tween2.chain().tween_property($Minty, "visible", false, 0.0)
	tv_tween2.chain().tween_property($HoodedFigure, "visible", false, 0.0)
	tv_tween2.chain().tween_property($Virus1, "visible", false, 0.0)
	tv_tween2.chain().tween_property($Virus2, "visible", false, 0.0)
	tv_tween2.chain().tween_property($VirusPiece, "visible", false, 0.0)
	tv_tween2.chain().tween_property($Background.material, "shader_parameter/progress", 1.0, 1.0)
	await tv_tween2.finished
	
	SceneManager.transitionToScene(credits)
	
	
