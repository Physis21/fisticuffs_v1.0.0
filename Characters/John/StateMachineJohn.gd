extends StateMachine
@export var id = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	add_state('STAND')  # idle
	add_state('JUMP_SQUAT')
	add_state('SHORT_HOP')
	add_state('FULL_HOP')
	add_state('DASH')
	add_state('WALK')
	add_state('CROUCH')  # not done yet
	# delays execution of code until there is an idle time in the main loop
	call_deferred("set_state", states.STAND)  
	pass

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)
	
func get_transition(delta):
	# TODO: CONTINUE HERE
	parent.move_and_slide()
	parent.state.text = str(state)
	match state:
		states.STAND:
			if Input.get_action_strength("right_%s" % id) == 1:
				parent.velocity.x = parent.WALKSPEED
				parent._frame()
				parent.turn(false)
				return states.WALK
			if Input.get_action_strength("left_%s" % id) == 1:
				parent.velocity.x = -parent.WALKSPEED
				parent._frame()
				parent.turn(true)
				return states.WALK
			if parent.velocity.x > 0 and state == states.STAND:
				parent.velocity.x += -parent.TRACTION * 1
				parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
			if parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION * 1
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
		states.JUMP_SQUAT:
			pass
		states.SHORT_HOP:
			pass
		states.FULL_HOP:
			pass
		states.DASH:
			pass
		states.WALK:
			if Input.is_action_pressed("left_%s" % id):
				if parent.velocity.x > 0:
					parent._frame()
				parent.velocity.x = -parent.WALKSPEED
			elif Input.is_action_pressed("right_%s" % id):
				if parent.velocity.x < 0:
					parent._frame()
				parent.velocity.x = parent.WALKSPEED
			else:
				return states.STAND
		states.CROUCH:
			pass

func enter_state(new_state, old_state):
	pass
	
func exit_state(old_state, new_state):
	pass
	
func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
