class_name HomingMissileAttack
extends ActionLeaf
func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.homing_missile_attack()
	return SUCCESS
