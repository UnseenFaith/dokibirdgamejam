class_name LaserAttack
extends ActionLeaf

var cooldown: float = 0.0

func tick(actor:Node, blackboard:Blackboard) -> int:
	actor.rapid_fire()
	return SUCCESS
