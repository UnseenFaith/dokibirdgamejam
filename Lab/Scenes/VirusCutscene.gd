extends Node2D

var rhythm := preload("res://Lab/RhythmGame/RhythmGame.tscn")

func _ready() -> void:
	await get_tree().create_timer(1.5).timeout
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
	
