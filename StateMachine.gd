extends Node
class_name StateMachine

var state = null : set = set_state
var previous_state = null
var states = {}

@onready var parent = get_parent()

func _physics_process(delta: float) -> void:
	if state != null:
		state_logic(delta)
		var transition = get_transition(delta)
		if transition != null:
			set_state(transition)

func state_logic(delta):
	pass
	
func get_transition(delta):
	return null
	
func enter_state(new_state, old_state):
	pass

func exit_state(old_state, new_state):
	pass
	
func set_state(new_state):
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
func _process(delta):
	pass
	
func get_rightleft(id): # Apply SOCD
	if Input.is_action_pressed("right_%s" % id) and Input.is_action_pressed("left_%s" % id):
		return 'neutral'
	elif Input.is_action_pressed("right_%s" % id):
		return 'right'
	elif Input.is_action_pressed("left_%s" % id):
		return 'left'
	else:
		return 'neutral'
		
func apply_traction(traction):
	if parent.velocity.x > 0:
		parent.velocity.x += -traction
		parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
	if parent.velocity.x < 0:
		parent.velocity.x += traction
		parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
		
