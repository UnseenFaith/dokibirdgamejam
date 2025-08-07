## A subclass of [Entity] specialized for player-controlled characters.
## ALERT: Game-specific subclasses which extend [PlayerEntity] MUST call `_super.ready()` etc. if those methods are overridden.

class_name PlayerEntity
extends Entity


#region Shortcuts
# Quick access to common components
# DESIGN: Not cached, because components may change during runtime.
# NOTE: Use `.get(StringName)` instead of direct access to avoid crash if missing.
# PERFORMANCE: Use direct access on Dictionary for better performance instead of `getComponent()`

var actionsComponent: ActionsComponent:
	get: return self.components.get(&"ActionsComponent")

var bodyComponent: CharacterBodyComponent:
	get: return self.components.get(&"CharacterBodyComponent")

var healthComponent: HealthComponent:
	get: return self.components.get(&"HealthComponent")

var inventoryComponent: InventoryComponent:
	get: return self.components.get(&"InventoryComponent")

var statsComponent: StatsComponent:
	get: return self.components.get(&"StatsComponent")

var upgradesComponent: UpgradesComponent:
	get: return self.components.get(&"UpgradesComponent")

#endregion


func _enter_tree() -> void:
	super._enter_tree()
	self.add_to_group(Global.Groups.players, true) # persistent


func _ready() -> void:
	printLog("􀆅 [b]_ready()")
	GameState.addPlayer(self)
	GameState.playerReady.emit(self)


func _exit_tree() -> void:
	super._exit_tree()
	GameState.removePlayer(self)

var up_time = 0.0
var jump_time = 0.0
var down_time = 0.0


func _physics_process(delta: float) -> void:
	if body.is_on_floor():
		print(jump_time)
		print(up_time)
		print(down_time)
		jump_time = 0.0
		up_time = 0.0
		down_time = 0.0
	
	if not body.is_on_floor():
		jump_time += delta
		if body.velocity.y < 0:
			up_time += delta
		elif body.velocity.y > 0:
			down_time += delta
		
