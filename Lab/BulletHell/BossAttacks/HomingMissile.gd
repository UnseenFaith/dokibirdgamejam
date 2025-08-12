## Description

class_name HomingMissile
extends Area2D

# Movement parameters
@export var speed: float = 200.0
@export var max_speed: float = 400.0
@export var acceleration: float = 300.0
@export var turn_rate: float = 90.0  # degrees per second
@export var max_turn_rate: float = 180.0

# Target tracking
var target: Node2D = null
var direction: Vector2 = Vector2.RIGHT
var distance_traveled: float = 0.0
@export var max_distance: float = 100400.0

# Damage
var damage: int = 3

func _ready() -> void:
	# Find the player as target
	target = get_tree().get_first_node_in_group("players")
	if not target:
		# Fallback: find any player entity
		var players = get_tree().get_nodes_in_group("players")
		if players.size() > 0:
			target = players[0]
	
	# Set initial direction toward target
	if target:
		direction = (target.global_position - global_position).normalized()
		rotation = atan2(direction.y, direction.x)
	
	# Start lifetime timer
	$LifetimeTimer.start()

func _physics_process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		# If no target, just move forward
		position += direction * speed * delta
		return
	
	# Calculate direction to target
	var direction_to_target = global_position.direction_to(target.global_position)
	
	# Calculate turn rate based on distance to target
	var distance_to_target = global_position.distance_to(target.global_position)
	var current_turn_rate = turn_rate
	if distance_to_target < 100:  # Close to target
		current_turn_rate = max_turn_rate
	
	# Gradually turn toward target
	var target_angle = atan2(direction_to_target.y, direction_to_target.x)
	var current_angle = atan2(direction.y, direction.x)
	var angle_difference = target_angle - current_angle
	
	# Normalize angle difference to -PI to PI
	while angle_difference > PI:
		angle_difference -= 2 * PI
	while angle_difference < -PI:
		angle_difference += 2 * PI
	
	# Apply turn rate limit
	var max_turn_this_frame = deg_to_rad(current_turn_rate * delta)
	if abs(angle_difference) > max_turn_this_frame:
		angle_difference = sign(angle_difference) * max_turn_this_frame
	
	# Update direction
	direction = direction.rotated(angle_difference)
	
	# Update rotation to match direction
	rotation = atan2(direction.y, direction.x)
	
	# Apply acceleration
	speed += acceleration * delta
	speed = clampf(speed, 50.0, max_speed)
	
	# Move
	var movement = direction * speed * delta
	position += movement
	distance_traveled += movement.length()
	
	# Check maximum distance
	if distance_traveled > max_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Check if we hit the player
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	elif body.is_in_group("player"):
		print("Damage!")
		# Try to find a damage receiving component
		#var damage_receiver := body.find_child("DamageReceivingComponent") as DamageReceivingComponent
		#if damage_receiver:
			#damage_receiver.processCollision(null, null)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Check if we hit a damage receiving area
	if area.has_method("processCollision"):
		area.processCollision(null, null)
		queue_free()

func onLifetimeTimer_timeout() -> void:
	target = null
	#queue_free()
