class_name LaserBeam
extends ActionLeaf

@export var telegraph_time: float = 1.5
@export var fire_time: float = 2.0
@export var track_player_during_telegraph: bool = true

var timer := 0.0
var phase := "telegraph"

func tick(actor: Node, blackboard: Blackboard) -> int:
	if phase == "telegraph":
		if timer == 0.0:
			# Start telegraph visual
			actor.start_telegraph()
			timer = telegraph_time

		# Optional: aim at player during telegraph
		if track_player_during_telegraph:
			var player = blackboard.get("player")
			if player:
				actor.look_at(player.global_position)

		timer -= actor.get_process_delta_time()
		if timer <= 0.0:
			phase = "fire"
			timer = 0.0
		return RUNNING

	elif phase == "fire":
		if timer == 0.0:
			# Start firing
			actor.start_attack()
			timer = fire_time

		timer -= actor.get_process_delta_time()
		if timer <= 0.0:
			# Stop firing and cleanup
			actor.stop_attack()
			phase = "telegraph"
			timer = 0.0
			return SUCCESS

		return RUNNING
	return FAILURE # no-op
