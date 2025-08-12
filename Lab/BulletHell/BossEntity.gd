## Description

class_name BossEntity
extends Entity

var laser = preload("res://Lab/BulletHell/BossAttacks/LaserPairs.tscn")
var homing_missile = preload("res://Lab/BulletHell/BossAttacks/HomingMissile.tscn")
var exploding_bullet = preload("res://Lab/BulletHell/BossAttacks/ExplodingBullet.tscn")
var bullet_enemy = preload("res://Lab/BulletHell/BulletEnemyEntity.tscn")


#region Parameters
@export var isEnabled: bool = true:
	set(newValue):
		isEnabled = newValue # Don't bother checking for a change
		# PERFORMANCE: Set once instead of every frame
		self.set_process(isEnabled)
		self.set_process_input(isEnabled)
#endregion


#region State
var property: int ## Placeholder
#endregion


func _ready() -> void:
	# Apply setters because Godot doesn't on initialization
	self.set_process(isEnabled)
	self.set_process_input(isEnabled)
	# Placeholder: Add any code needed to configure and prepare the component.


func _input(event: InputEvent) -> void:
	pass # Placeholder: Handle one-shot input events such as jumping or firing.


func _process(delta: float) -> void: # NOTE: If you need to process movement or collisions, use `_physics_process()`
	pass # Placeholder: Perform any per-frame updates.
	

func laser_attack() -> void:
	var returnPosition := self.position
	spawn_laser_attack()
	await get_tree().create_timer(1.0).timeout
	self.position.y -= 50
	spawn_laser_attack()
	await get_tree().create_timer(1.0).timeout
	self.position.y += 50
	spawn_laser_attack()
	await get_tree().create_timer(1.0).timeout
	self.position.y += 50
	spawn_laser_attack()
	await get_tree().create_timer(1.0).timeout
	self.position.y -= 50
	spawn_laser_attack()
	await get_tree().create_timer(1.0).timeout
	self.position = returnPosition

func spawn_laser_attack() -> void:
	var attack := laser.instantiate()
	attack.position = self.position
	get_parent().add_child(attack)
	
func ring_attack() -> void:
	var offset = randf_range(0, TAU) # TAU = 2*PI, a full circle in radians
	for i in range(0, 360, 10):
		var child_bullet = bullet_enemy.instantiate()
		var angle = deg_to_rad(i) + offset
		child_bullet.position = position
		child_bullet.rotation = angle
		var lm = child_bullet.find_child("LinearMotionComponent")
		if lm:
			lm.initialSpeed = 100
			lm.maximumSpeed = 100
		get_parent().add_child(child_bullet)

func homing_missile_attack() -> void:
	"""Fire a burst of homing missiles at the player"""
	var missile_count = 3
	var fire_delay = 0.3
	
	for i in range(missile_count):
		spawn_homing_missile()
		if i < missile_count - 1: # Don't wait after the last missile
			await get_tree().create_timer(fire_delay).timeout
	
	await get_tree().create_timer(3.0).timeout

func spawn_homing_missile() -> void:
	var missile := homing_missile.instantiate()
	missile.position = self.position
	
	# Set initial direction toward player
	var player = get_tree().get_first_node_in_group("players")
	if player:
		var direction = (player.global_position - missile.global_position).normalized()
		missile.rotation = atan2(direction.y, direction.x)
	
	get_parent().add_child(missile)
	

func spread_shot_attack() -> void:
	var waves = 6
	var wave_delay = 0.4
	
	for wave in range(waves):
		spawn_wave(wave)
		if wave < waves - 1:
			await get_tree().create_timer(wave_delay).timeout
	await get_tree().create_timer(3.0).timeout

func spawn_wave(wave) -> void:
	var bullet_count = 24
	var spread_angle = 150.0
	var base_angle = 180.0
	
	var wave_positions = [
		Vector2(426, 178),
		Vector2(426, 128),
		Vector2(426, 228),
		Vector2(426, 108),
		Vector2(426, 158),
		Vector2(426, 208),
	]
	
	var spawn_position = wave_positions[wave % wave_positions.size()]
	for i in range(bullet_count):
		var angle = base_angle - (spread_angle / 2) + (i * spread_angle / (bullet_count - 1))
		spawn_spread_bullet(angle, spawn_position)
	
	
func spawn_spread_bullet(angle_degrees: float, spawn_pos: Vector2) -> void:
	var bullet := bullet_enemy.instantiate()
	bullet.position = spawn_pos
	bullet.rotation = deg_to_rad(angle_degrees)
	
	# Slow down the bullet
	var linear_motion = bullet.find_child("LinearMotionComponent")
	if linear_motion:
		linear_motion.initialSpeed = 60.0 # Very slow
		linear_motion.maximumSpeed = 100.0
	
	get_parent().add_child(bullet)
	

func needle() -> void:
	var player = get_tree().get_first_node_in_group("players")
	var base_angle = (player.position - global_position).angle()
	for offset_deg in [-10, -5, 0, 5, 10]:
		var bullet = bullet_enemy.instantiate()
		bullet.position = global_position
		bullet.rotation = base_angle + deg_to_rad(offset_deg)
		var lm = bullet.find_child("LinearMotionComponent")
		if lm:
			lm.initialSpeed = 180
			lm.maximumSpeed = 180
		get_parent().add_child(bullet)
	
func ring() -> void:
	var bullet = exploding_bullet.instantiate()
	bullet.position = global_position
	get_parent().add_child(bullet)


func screen_covering_attack() -> void:
	var viewport = get_viewport()
	if not viewport:
		return
	
	var screen_size = viewport.get_visible_rect().size
	var bullet_density = 0.8 # How dense the bullets are (0.0 to 1.0)
	var bullet_size = 8.0 # Approximate bullet size for spacing
	
	# Calculate how many bullets we can fit
	var max_bullets_x = int(screen_size.x / (bullet_size * 2))
	var max_bullets_y = int(screen_size.y / (bullet_size * 2))
	
	var actual_bullets_x = int(max_bullets_x * bullet_density)
	var actual_bullets_y = int(max_bullets_y * bullet_density)
	
	# Create bullets in a grid pattern
	for x in range(actual_bullets_x):
		for y in range(actual_bullets_y):
			var bullet := bullet_enemy.instantiate()
			
			# Position bullets with some randomness
			var pos_x = (screen_size.x / actual_bullets_x) * x + randf_range(-10, 10)
			var pos_y = (screen_size.y / actual_bullets_y) * y + randf_range(-10, 10)
			bullet.position = Vector2(pos_x, pos_y)
			
			# All bullets move left slowly
			bullet.rotation = PI
			
			# Slow movement
			var linear_motion = bullet.find_child("LinearMotionComponent")
			if linear_motion:
				linear_motion.initialSpeed = 50.0
				linear_motion.maximumSpeed = 80.0
			
			get_parent().add_child(bullet)
	
	await get_tree().create_timer(5.0).timeout
