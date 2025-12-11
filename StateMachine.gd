extends Node
class_name StateMachine

var state : String = "NULL" : set = set_state
var previous_state : String = "NULL"
var states : Dictionary = {}

@onready var parent = get_parent()

func _physics_process(delta: float) -> void:
	if state != null:
		state_logic(delta)
		var transition = get_transition(delta)
		if transition != null:
			set_state(transition)

func state_logic(_delta):
	pass
	
func get_transition(_delta):
	return null
	
func enter_state(_new_state, _old_state):
	pass

func exit_state(_old_state, _new_state):
	pass
	
func set_state(new_state : String):
	previous_state = state
	state = new_state
	if previous_state != null:
		exit_state(previous_state, new_state)
	if new_state != null:
		enter_state(new_state, previous_state)
		
func add_state(state_name):
	states[state_name] = state_name  # returns nb of entries in dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

## Decelerate character based on his current traction (with modifier)
func apply_traction(traction : int, mod : float =1.):
	var applied_traction = traction * mod
	if parent.velocity.x > 0:
		parent.velocity.x += -applied_traction
		parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
	if parent.velocity.x < 0:
		parent.velocity.x += applied_traction
		parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)

func is_airborne():
	return (not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding())
