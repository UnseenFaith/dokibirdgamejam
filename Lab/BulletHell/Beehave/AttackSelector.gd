class_name AttackSelector
extends ActionLeaf

@export var attack_cooldown: float = 5.0
var time_since_last_attack: float = 0.0
var available_attacks: Array

var all_attacks = ["laser", "missile", "spread", "explode"]

func tick(actor: Node, blackboard: Blackboard) -> int:
	# Check if cooldown has elapsed
	if time_since_last_attack < attack_cooldown:
		time_since_last_attack += get_physics_process_delta_time()
		return RUNNING
	
	# Reset cooldown
	time_since_last_attack = 0.0
	
	# If no attacks available, refill the pool
	if available_attacks.is_empty():
		available_attacks = all_attacks.duplicate()
	
	# Randomly pick from available attacks
	var random_index = randi() % available_attacks.size()
	var chosen_attack = available_attacks[random_index]
	
	# Remove the chosen attack from available pool
	available_attacks.remove_at(random_index)
	
	# Execute the chosen attack
	match chosen_attack:
		"laser":
			actor.laser_attack()
		"missile":
			actor.homing_missile_attack()
		"spread":
			actor.spread_shot_attack()
		"explode":
			actor.ring()
			#actor.screen_covering_attack()
	
	return SUCCESS
