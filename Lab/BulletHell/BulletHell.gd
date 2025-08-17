extends Start

var virus3 := preload("res://Lab/Scenes/VirusCutscene3.tscn")

func _ready() -> void:
	super._ready()
	
	$BossEntity.set_process(false)
	$"Player-OverheadCombat/InputComponent".isEnabled = false
	$WorldBoundary.process_mode = Node.PROCESS_MODE_DISABLED
	
	var doki_tween := create_tween()
	doki_tween.tween_property($"Player-OverheadCombat", "position", Vector2(50, 182), 1.0)
	doki_tween.chain().tween_property($BossEntity, "position", Vector2(319, 174), 2.0)
	await doki_tween.finished
	
	Dialogic.start("pre-boss")
	await Dialogic.timeline_ended
	
	$Tutorial.visible = true
	var tut_tween := create_tween()
	tut_tween.tween_property($Tutorial, "visible", true, 0.0)
	tut_tween.chain().tween_property($Tutorial, "modulate", Color(255, 255, 255, 0), 1.0).set_delay(1.0)
	await tut_tween.finished
	
	
	$WorldBoundary.process_mode = Node.PROCESS_MODE_INHERIT
	$CanvasLayer.visible = true
	$AudioStreamPlayer.play()
	$BossEntity.set_process(true)
	$"Player-OverheadCombat/InputComponent".isEnabled = true


func onHealthComponent_healthDidZero() -> void:
	$BossEntity.set_process(false)
	$"Player-OverheadCombat/InputComponent".isEnabled = false
	$YouLost.visible = true
	Dialogic.VAR.thirdGameWon = false
	await get_tree().create_timer(2.0).timeout
	
	SceneManager.transitionToScene(virus3)
	pass # Replace with function body.


func onHealthComponent_healthDidZero2() -> void:
	$BossEntity.set_process(false)
	$"Player-OverheadCombat/InputComponent".isEnabled = false
	$YouWon.visible = true
	Dialogic.VAR.thirdGameWon = true
	await get_tree().create_timer(2.0).timeout
	
	SceneManager.transitionToScene(virus3)
