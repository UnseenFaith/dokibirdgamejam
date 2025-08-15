## Description

class_name DinoRun
extends Start

var obstacle_types := [
	"res://Lab/DinoRun/Scenes/Crate.tscn",
	"res://Lab/DinoRun/Scenes/SingleTallCactus.tscn",
	"res://Lab/DinoRun/Scenes/DoubleTallCactus.tscn",
	"res://Lab/DinoRun/Scenes/TripleTallCactus.tscn",
	"res://Lab/DinoRun/Scenes/Barrel.tscn",
	"res://Lab/DinoRun/Scenes/Staircase.tscn",
	"res://Lab/DinoRun/Scenes/Birb.tscn",
]
var obstacles: Array
@onready var player := $"Player-Platformer"
@onready var screen_size := get_window().size
@onready var ground_height = $Floor.get_node("Dirt/Floor1").texture.get_height()
var last_obstacle

@onready var audio := $AudioStreamPlayer

var CURRENT_SPEED := 200

var cutscenePlayed = Settings.get('firstCutscenePlayed')

var gameEnded = false

func _ready() -> void:
	$"Player-Platformer/InputComponent".isEnabled = false
	$AnimationPlayer.play("cutscene")
	Dialogic.connect("signal_event", _dialog_event)
	Dialogic.connect("timeline_ended", timeline_ended)

func _dialog_event(parameter: String) -> void:
	$AnimationPlayer.play(parameter)

func _start_Dialogic() -> void:
		Dialogic.start("timeline")

func timeline_ended() -> void:
	if not gameEnded:
		$AnimationPlayer.stop()
		_start_game()
	else:
		print("Transition Back to Desktop Here")
	
func _start_game() -> void:
	$Floor/Dirt.autoscroll.x = - CURRENT_SPEED
	$Floor/Tumble.autoscroll.x = - CURRENT_SPEED
	$Background.process_mode = Node.PROCESS_MODE_INHERIT
	$Tracker.visible = true
	$Tracker/Path2D/PathFollow2D.progress_ratio = 0.0
	$Tracker.process_mode = Node.PROCESS_MODE_INHERIT
	$"Player-Platformer/DokiAnimationComponent".isEnabled = true
	$Enemy.monitoring = true
	$Enemy.position.x = 20
	$Enemy/AnimatedSprite2D.play("default")
	$"Player-Platformer/InputComponent".isEnabled = true
	$AudioStreamPlayer.play()
	$Tumbleweed.play()
	$AnimationPlayer.play("tutorial")
	$Crow.visible = false

func start_obstacles() -> void:
	$ObstacleTimer.start()

func _process(delta: float) -> void:
	$Tumbleweed.pitch_scale = randf_range(0.8, 1.2)
	if audio.playing:
		var current_time = audio.get_playback_position()
		var total_time = audio.stream.get_length()
		
		# Avoid division by zero if stream length is unknown
		if total_time > 0:
			$Tracker/Path2D/PathFollow2D.progress_ratio = (current_time / total_time)
		else:
			$Tracker/Path2D/PathFollow2D.progress_ratio = 0.0

func generate_obstacle(obst = null) -> void:
	var index
	if obst != null:
		index = obst
	else:
		index = randi() % obstacle_types.size()
	var obs_type = obstacle_types[index]
	var obs_x: int = $Obstacle.position.x
	var obs_y: int = $Obstacle.position.y - 12 if index != 6 else $Obstacle.position.y - 40
	var obs = SceneManager.loadSceneAndAddInstance(obs_type, self, Vector2(obs_x, obs_y))
	obs.speed = 200
	obs.z_index = 1
	obs.add_to_group("obstacles")
	last_obstacle = obs

func onObstacleTimer_timeout() -> void:
	generate_obstacle()
	if player.position.x < $Midpoint.position.x && player.bodyComponent.isOnFloor:
		player.velocity.x += 100


func onTracker_finished() -> void:
	print("Game Won!")
	
	$"Player-Platformer/InputComponent".isEnabled = false
	var tween = create_tween()
	$Crow.visible = true
	$Crow.position = Vector2(459, 120)
	tween.tween_property($Enemy, "position", Vector2(-50, 220), 2.0)
	tween.parallel().tween_property($"Player-Platformer", "position", $Midpoint.position, 1.0)
	tween.parallel().tween_property($Crow, "position", Vector2(195, 120), 2.0)
	
	await get_tree().create_timer(3.0).timeout
	
	$Floor/Dirt.autoscroll.x = 0
	$Floor/Tumble.visible = false
	$Background.process_mode = Node.PROCESS_MODE_DISABLED
	$Tracker.visible = false
	$"Player-Platformer/DokiAnimationComponent".isEnabled = false
	$"Player-Platformer/AnimatedSprite2D".play("idle")
	
	$AntiVirus.visible = true
	$AntiVirus/Player.play("virus")
	
	Dialogic.start("level1_outro")
