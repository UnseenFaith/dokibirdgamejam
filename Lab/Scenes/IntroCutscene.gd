extends Start

var level1 := preload("res://Lab/DinoRun/DinoRun.tscn")

var shouldTransitionToNextLevel := false

func _ready() -> void:
	$AudioStreamPlayer.play()

func dialog_event(event: String) -> void:
	if event == "show_link":
		$Link.visible = true

	if event == "show_crow":
		$Crow.visible = true
	
	if event == "show_mint":
		$MintContainer.visible = true
		$AnimationPlayer.play("mint_enters")

func timeline_ended() -> void:
	if shouldTransitionToNextLevel == false:
		shouldTransitionToNextLevel = true
		$Link.connect("gui_input", onLink_guiInput)
		$X.connect("button_down", onX_buttonDown)
	else:
		SceneManager.transitionToScene(level1)
		GlobalInput.isPauseShortcutAllowed = true
		

func onLink_guiInput(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		$Link.visible = false
		$X.visible = false
		$Doki.visible = true
		$Background.visible = false
		Dialogic.start("intro2")

func onX_buttonDown() -> void:
	pass


func onLink_morphDone() -> void:
	Dialogic.connect("signal_event", dialog_event)
	Dialogic.connect("timeline_ended", timeline_ended)
	Dialogic.start("intro")
