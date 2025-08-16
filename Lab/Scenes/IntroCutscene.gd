extends Start

var level1 := preload("res://Lab/DinoRun/DinoRun.tscn")

var shouldTransitionToNextLevel := false

func _ready() -> void:
	$AudioStreamPlayer.play()

func dialog_event(event: String) -> void:
	if event == "show_link":
		$Link.visible = true

	if event == "show_crow":
		var tween := create_tween()
		tween.tween_property($Crow.material, "shader_parameter/progress", 1.0, 0.5)
		await tween.finished
	
	if event == "show_mint":
		var tween := create_tween()
		tween.tween_property($MintContainer.material, "shader_parameter/progress", 1.0, 0.5)
		await tween.finished
	
	if event == "hooded_jump":
		var tween := create_tween()
		tween.tween_property($MintContainer, "position", $MintContainer.position + Vector2(60, 0), 1.0)
		await tween.finished
		
		var sprites := [$MintContainer/Mint, $MintContainer/Dragoon3, $MintContainer/Dragoon4, $MintContainer/Dragoon1, $MintContainer/Dragoon2, $MintContainer/Dog]
		var local = $MintContainer.to_local($DinoRun.global_position)
		var tween2 := create_tween()
		for sprite in sprites:
			tween2.tween_callback(Callable(sprite, "throw_to").bind(local))
			tween2.tween_interval(0.3)
		await tween2.finished
	
	if event == "doki_jump":
		var tween := create_tween()
		$Doki.play("run")
		tween.tween_property($Doki, "position", $Doki.position + Vector2(-150, 0), 0.7)
		tween.chain().tween_callback(Callable($Doki, "throw_to").bind($DinoRun.position))
		tween.tween_property($Crow, "position", $Crow.position + Vector2(-150, 0), 0.9)
		tween.chain().tween_callback(Callable($Crow, "throw_to").bind($DinoRun.position))
		
		await tween.finished


func timeline_ended() -> void:
	if shouldTransitionToNextLevel == false:
		shouldTransitionToNextLevel = true
		$Link.connect("gui_input", onLink_guiInput)
	else:
		SceneManager.transitionToScene(level1)
		GlobalInput.isPauseShortcutAllowed = true
		

func onLink_guiInput(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		$Link.visible = false
		
		var tween := create_tween()
		tween.tween_property($Shader.material, "shader_parameter/progress", 1.0, 1.0)
		await tween.finished
		
		$Shader2.visible = true
		$Shader.visible = false
		
		$Background2.visible = true
		$Background.visible = false
		$PlayerCamera.enabled = true
		$Doki.visible = true
	
		var tween2 := create_tween()
		tween2.tween_property($Shader2.material, "shader_parameter/progress", 0.0, 1.0)
		await tween2.finished

		Dialogic.start("intro2")


func onLink_morphDone() -> void:
	Dialogic.connect("signal_event", dialog_event)
	Dialogic.connect("timeline_ended", timeline_ended)
	Dialogic.start("intro")
