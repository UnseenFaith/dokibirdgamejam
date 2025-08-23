extends Node2D

var gameframe = preload("res://Scenes/Launch/GameFrame.tscn")

func _ready() -> void:
	var img: Image
	if Dialogic.VAR.pieces == 3:
		img = load("res://Lab/Scenes/image.png").get_image()
	else:
		img = load("res://Lab/Scenes/Intro/scene.png").get_image()
	img.resize(640, 360, Image.INTERPOLATE_NEAREST)
	$TextureRect.texture = ImageTexture.create_from_image(img)

	var tv_tween := create_tween()
	tv_tween.tween_property($TextureRect.material, "shader_parameter/progress", 0.0, 1.0)
	await tv_tween.finished
	
	$TextureRect.visible = false
	
	if Dialogic.VAR.pieces == 3:
		$Sprite2D.visible = true
	else:
		$Sprite2D2.visible = true

	$AudioStreamPlayer.play()

func onCredits_cutsceneQuit() -> void:
	SceneManager.transitionToScene(gameframe)
