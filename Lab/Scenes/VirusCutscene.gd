extends Node2D

var rhythm := preload("res://Lab/RhythmGame/RhythmGame.tscn")

func _ready() -> void:
	var tv_tween := create_tween()
	tv_tween.tween_property($Background.material, "shader_parameter/progress", 0, 1.0)
	await tv_tween.finished
	
	$AudioStreamPlayer.play()
	
	var tween := create_tween()
	tween.tween_property($Doki.material, "shader_parameter/progress", 1.0, 1.0)
	tween.parallel().tween_property($VirusPiece/AnimatedSprite2D.material, "shader_parameter/progress", 1.0, 1.0)
	tween.tween_property($Crow.material, "shader_parameter/progress", 1.0, 1.0)
	await tween.finished
	
	Dialogic.start("virus_desktop_1")
	Dialogic.connect("timeline_ended", timeline_ended)
	Dialogic.connect("signal_event", dialogic_signal)

func dialogic_signal(param: String) -> void:
	if param == "slot_in":
		$AnimationPlayer.play("intro")
		await $AnimationPlayer.animation_finished
	if param == "disintegrate":
		$VirusPiece.disintegrate()
		$Doki.flip_h = true
		$Doki.play("idle")
	

func timeline_ended() -> void:
	$AnimationPlayer.play("outro")
	await $AnimationPlayer.animation_finished
	SceneManager.transitionToScene(rhythm)
	
