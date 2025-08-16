extends Node2D

var gameframe = preload("res://Scenes/Launch/GameFrame.tscn")


func onCredits_cutsceneQuit() -> void:
	SceneManager.transitionToScene(gameframe)
