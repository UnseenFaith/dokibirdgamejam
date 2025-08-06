## A [DamageReceivingComponent] that blocks damage from the front direction but allows damage from the back.
## Extends the base DamageReceivingComponent to add directional shielding functionality.
## Requirements: [HealthComponent] (or subclass)

class_name DirectionalShieldingReceivingComponent
extends DamageReceivingComponent

#region Parameters

## The angle in degrees that defines the "front" direction. 0 = right, 90 = down, 180 = left, 270 = up
@export_range(0, 359, 1) var frontDirection: float = 0

## The angle range in degrees that defines the "front" area. Attacks within this range will be blocked.
## For example, 90 means attacks from -45 to +45 degrees from the front direction will be blocked.
@export_range(0, 180, 5) var frontAngleRange: float = 90

## Should the shield block all damage from the front, or just reduce it?
@export var shouldBlockCompletely: bool = true

## If not blocking completely, what percentage of damage should be reduced? (0-100)
@export_range(0, 100, 5) var damageReductionPercent: int = 75

## Should this component emit a signal when blocking an attack?
@export var shouldEmitBlockSignal: bool = true

#endregion


#region State
var blockedAttacksCount: int = 0
var totalAttacksCount: int = 0
#endregion


#region Signals

## Emitted when an attack is blocked from the front
signal didBlockAttack(damageComponent: DamageComponent, attackDirection: Vector2)

## Emitted when an attack passes through from the back
signal didAllowAttack(damageComponent: DamageComponent, attackDirection: Vector2)

#endregion


## Override the processDamage method to add directional shielding logic
func processDamage(damageComponent: DamageComponent, damageAmount: int, attackerFactions: int = 0, friendlyFire: bool = false) -> bool:
	if not isEnabled or not checkFactions(attackerFactions, friendlyFire): return false
	
	totalAttacksCount += 1
	
	# Calculate the direction from the attacker to this entity
	var attackDirection: Vector2 = calculateAttackDirection(damageComponent)
	
	# Check if the attack is coming from the front
	var isFromFront: bool = isAttackFromFront(attackDirection)
	
	if debugMode:
		printDebug("Attack direction: " + str(attackDirection) + ", isFromFront: " + str(isFromFront))
	
	if isFromFront:
		# Block the attack from the front
		blockedAttacksCount += 1
		blockAttack(damageComponent, attackDirection, damageAmount)
		return true # Return true to indicate we "processed" the damage (by blocking it)
	else:
		# Allow the attack to pass through from the back
		allowAttack(damageComponent, attackDirection)
		# Call the parent's processDamage method to handle the damage normally
		return super.processDamage(damageComponent, damageAmount, attackerFactions, friendlyFire)


## Calculate the direction vector from the attacker to this entity
func calculateAttackDirection(damageComponent: DamageComponent) -> Vector2:
	var attackerPosition: Vector2 = damageComponent.parentEntity.global_position
	var ourPosition: Vector2 = parentEntity.global_position
	
	return (ourPosition - attackerPosition).normalized()


## Check if the attack direction is within the front angle range
func isAttackFromFront(attackDirection: Vector2) -> bool:
	# Convert the attack direction to an angle
	var attackAngle: float = rad_to_deg(attackDirection.angle())
		
	# Normalize angles to 0-360 range
	attackAngle = fmod(attackAngle + 360, 360)
	var normalizedFrontDirection: float = fmod(frontDirection + 360, 360)
	
	# Calculate the angle difference
	var angleDifference: float = abs(attackAngle - normalizedFrontDirection)
	if angleDifference > 180:
		angleDifference = 360 - angleDifference
	
	# Check if the attack is within the front angle range
	return angleDifference <= frontAngleRange / 2


## Block the attack from the front
func blockAttack(damageComponent: DamageComponent, attackDirection: Vector2, originalAmount: int) -> void:
	if shouldEmitBlockSignal:
		didBlockAttack.emit(damageComponent, attackDirection)
	
	if debugMode:
		printDebug("BLOCKED attack from front! Direction: " + str(attackDirection))
	
	# If we're not blocking completely, apply damage reduction
	if not shouldBlockCompletely:
		var reducedDamage: int = int(originalAmount * (100 - damageReductionPercent) / 100.0)
		if reducedDamage > 0 and healthComponent:
			healthComponent.damage(reducedDamage)
			if debugMode:
				printDebug("Applied reduced damage: " + str(reducedDamage) + " (original: " + str(originalAmount) + ")")
	
	# Remove the bullet if it should be removed on collision
	if damageComponent.removeEntityOnCollisionWithReceiver:
		damageComponent.isEnabled = false
		damageComponent.removeFromEntity.call_deferred()
		damageComponent.requestDeletionOfParentEntity()


## Allow the attack to pass through from the back
func allowAttack(damageComponent: DamageComponent, attackDirection: Vector2) -> void:
	if shouldEmitBlockSignal:
		didAllowAttack.emit(damageComponent, attackDirection)
	
	if debugMode:
		printDebug("ALLOWED attack from back! Direction: " + str(attackDirection))


## Get the current shield statistics
func getShieldStats() -> Dictionary:
	return {
		"blocked_attacks": blockedAttacksCount,
		"total_attacks": totalAttacksCount,
		"block_rate": (float(blockedAttacksCount) / max(totalAttacksCount, 1)) * 100
	}


## Reset the shield statistics
func resetStats() -> void:
	blockedAttacksCount = 0
	totalAttacksCount = 0


func onPlatformerPatrolComponent_didTurn() -> void:
	# Flip the front direction when the patrol component turns
	# If patrolDirection is -1 (left), frontDirection should be 180 (facing left)
	# If patrolDirection is +1 (right), frontDirection should be 0 (facing right)
	
	var patrolComponent: PlatformerPatrolComponent = parentEntity.findFirstComponentSubclass(PlatformerPatrolComponent)
	if patrolComponent:
		if patrolComponent.patrolDirection < 0:
			# Moving left, face left
			frontDirection = 0
			$"../Sprite2D".flip_h = true
		else:
			# Moving right, face right
			frontDirection = 180
			$"../Sprite2D".flip_h = false

	else:
		print("Warning: No PlatformerPatrolComponent found")
