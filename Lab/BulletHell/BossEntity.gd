## Description

class_name BossEntity
extends Entity

var laser := preload("res://Lab/BulletHell/BossAttacks/LaserPairs.tscn")
var homing_missile := preload("res://Lab/BulletHell/BossAttacks/HomingMissile.tscn")
var exploding_bullet := preload("res://Lab/BulletHell/BossAttacks/ExplodingBullet.tscn")
var bullet_enemy := preload("res://Lab/BulletHell/BulletEnemyEntity.tscn")


@export var isAttacking := false

@onready var healthComponent := $HealthComponent as HealthComponent

#region Parameters
@export var isEnabled: bool = true:
	set(newValue):
		isEnabled = newValue # Don't bother checking for a change
		# PERFORMANCE: Set once instead of every frame
		self.set_process(isEnabled)
		self.set_process_input(isEnabled)
#endregion


#region State
enum Phase { PHASE1, PHASE2 }
var current_phase := Phase.PHASE1

enum State { IDLE, MOVING, ATTACKING, CHOOSE_ATTACK }
var current_state := State.IDLE

var attack_cooldown := 2.0
var attack_timer := 0.0
#endregion

func _ready() -> void:
	# Apply setters because Godot doesn't on initialization
	self.set_process(isEnabled)
	self.set_process_input(isEnabled)
	# Placeholder: Add any code needed to configure and prepare the component.

func _process(delta: float) -> void: # NOTE: If you need to process movement or collisions, use `_physics_process()`
	$State/CurrentState.text = State.keys()[current_state]
	
	var health := healthComponent.health.percentage
	if health <= 51.0 and current_phase != Phase.PHASE2:
		current_phase = Phase.PHASE2
		# Transition Boss here, pop out guns, pop out dog, etc..
	
	match current_state:
		State.IDLE:
			attack_timer -= delta
			if attack_timer <= 0.0:
				current_state = State.CHOOSE_ATTACK
		State.CHOOSE_ATTACK:
			if current_phase == Phase.PHASE1:
				choose_attack_phase1()
			elif current_phase == Phase.PHASE2:
				choose_attack_phase2()
			
			attack_timer = attack_cooldown
			current_state = State.IDLE
		State.ATTACKING:
			pass

#region ATTACK SELECTION FUNCTIONS
func choose_attack_phase1():
	var attacks = [laser_attack, ring_attack, homing_missile_attack]
	var attack = attacks.pick_random()
	attack.call()

func choose_attack_phase2():
	var attacks = [laser_attack, ring_attack, homing_missile_attack]
	#var attacks = [spread_shot_attack, needle, ring, homing_missile_attack]
	var attack = attacks.pick_random()
	attack.call()
#endregion 

#region BOSS ATTACKS
func laser_attack() -> void:
	current_state = State.ATTACKING
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
	current_state = State.ATTACKING
	var offset := randf_range(0, TAU) # TAU = 2*PI, a full circle in radians
	for i in range(0, 360, 10):
		var child_bullet := bullet_enemy.instantiate() as Entity
		var angle := deg_to_rad(i) + offset
		child_bullet.position = position
		child_bullet.rotation = angle
		var lm := child_bullet.find_child("LinearMotionComponent") as LinearMotionComponent
		if lm:
			lm.initialSpeed = 100
			lm.maximumSpeed = 100
		get_parent().add_child(child_bullet)

func homing_missile_attack() -> void:
	current_state = State.ATTACKING
	var missile_count := 3
	var fire_delay := 0.3
	
	for i in range(missile_count):
		spawn_homing_missile()
		if i < missile_count - 1: # Don't wait after the last missile
			await get_tree().create_timer(fire_delay).timeout
	
	await get_tree().create_timer(3.0).timeout
	

func spawn_homing_missile() -> void:
	var missile := homing_missile.instantiate() as HomingMissile
	missile.position = self.position
	
	# Set initial direction toward player
	var player := get_tree().get_first_node_in_group("players") as PlayerEntity
	if player:
		var direction := (player.global_position - missile.global_position).normalized()
		missile.rotation = atan2(direction.y, direction.x)
	
	get_parent().add_child(missile)

func spread_shot_attack() -> void:
	isAttacking = true
	var waves := 6
	var wave_delay := 0.4
	
	for wave in range(waves):
		spawn_wave(wave)
		if wave < waves - 1:
			await get_tree().create_timer(wave_delay).timeout
	await get_tree().create_timer(3.0).timeout

func spawn_wave(wave: int) -> void:
	var bullet_count := 24
	var spread_angle := 150.0
	var base_angle := 180.0
	
	var wave_positions := [
		Vector2(426, 178),
		Vector2(426, 128),
		Vector2(426, 228),
		Vector2(426, 108),
		Vector2(426, 158),
		Vector2(426, 208),
	]
	
	var spawn_position := wave_positions[wave % wave_positions.size()] as Vector2
	for i in range(bullet_count):
		var angle := base_angle - (spread_angle / 2) + (i * spread_angle / (bullet_count - 1))
		spawn_spread_bullet(angle, spawn_position)
	isAttacking = false

	
func ring() -> void:
	isAttacking = true
	var bullet := exploding_bullet.instantiate()
	bullet.position = global_position
	get_parent().add_child(bullet)
	isAttacking = false

	
func spawn_spread_bullet(angle_degrees: float, spawn_pos: Vector2) -> void:
	var bullet := bullet_enemy.instantiate()
	bullet.position = spawn_pos
	bullet.rotation = deg_to_rad(angle_degrees)
	
	# Slow down the bullet
	var linear_motion := bullet.find_child("LinearMotionComponent") as LinearMotionComponent
	if linear_motion:
		linear_motion.initialSpeed = 60.0 # Very slow
		linear_motion.maximumSpeed = 100.0
	
	get_parent().add_child(bullet)
	

func needle() -> void:
	isAttacking = true
	var player := get_tree().get_first_node_in_group("players") as PlayerEntity
	var base_angle := (player.position - global_position).angle()
	for offset_deg: int in [-10, -5, 0, 5, 10]:
		var bullet := bullet_enemy.instantiate()
		bullet.position = global_position
		bullet.rotation = base_angle + deg_to_rad(offset_deg)
		var lm := bullet.find_child("LinearMotionComponent") as LinearMotionComponent
		if lm:
			lm.initialSpeed = 180
			lm.maximumSpeed = 180
		get_parent().add_child(bullet)
	isAttacking = false

#endregion



#region UTILITY
func moveTo(toPosition: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", toPosition, 1.0)
#endregion

	






	






func rapid_fire() -> void:
	pass
	#$AnimationPlayer.play("rapid_fire")
	#await $AnimationPlayer.animation_finished
