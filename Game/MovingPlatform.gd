extends Node2D

@onready var player := $AnimationPlayer
@onready var tile_map_layer := $TileMapLayer
@onready var platform_collision_area := $PlatformCollisionArea

func _ready() -> void:
	#player.play("platform")
	pass
