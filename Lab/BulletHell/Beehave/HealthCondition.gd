class_name HealthCondition extends ConditionLeaf

@export var healthComponent: HealthComponent
@export_range(0, 100, 1) var healthToCheck: int = 50

func tick(actor:Node, blackboard:Blackboard) -> int:
	if not healthComponent:
		var entity = actor as Entity
		healthComponent = entity.findFirstComponentSubclass(HealthComponent)
	var percentage = healthComponent.health.percentage
	print(percentage)
	if percentage > healthToCheck:
		return SUCCESS
	return FAILURE
