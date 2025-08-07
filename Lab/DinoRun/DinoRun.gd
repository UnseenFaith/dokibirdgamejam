## Description

class_name DinoRun
extends Start

var obstacle_types := [
	"res://Lab/DinoRun/Scenes/Crate.tscn",
	"res://Lab/DinoRun/Scenes/SingleTallCactus.tscn",
	"res://Lab/DinoRun/Scenes/DoubleTallCactus.tscn",
	"res://Lab/DinoRun/Scenes/TripleTallCactus.tscn",
	"res://Lab/DinoRun/Scenes/Barrel.tscn"
]
var obstacles: Array
var ground_height: int
var screen_size: Vector2i

var last_obstacle

var CURRENT_SPEED = 200

func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Floor.get_node("Parallax2D/Floor1").texture.get_height()
	$Floor/Parallax2D.autoscroll.x = -CURRENT_SPEED

func generate_obstacle() -> void:
	var obs_type = obstacle_types[randi() % obstacle_types.size()]
	var obs_x: int = $Obstacle.position.x 
	var obs_y: int = $Obstacle.position.y - 12
	var obs = SceneManager.loadSceneAndAddInstance(obs_type, self, Vector2(obs_x, obs_y))
	obs.speed = 200
	last_obstacle = obs
	print(obs.position)

func onObstacleTimer_timeout() -> void:
	generate_obstacle()
