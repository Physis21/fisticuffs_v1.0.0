extends StateMachine
@export var id = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	add_state('STAND')  # idle
	add_state('JUMP_SQUAT')
	add_state('SHORT_HOP')
	add_state('FULL_HOP')
	add_state('DASH')
	add_state('RUN')
	add_state('WALK')
	add_state('CROUCH')
	add_state('AIR')
	add_state('LANDING')
	# delays execution of code until there is an idle time in the main loop
	call_deferred("set_state", states.STAND)  
	pass

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)
	
func get_transition(delta):
	parent.move_and_slide()
	parent.state.text = str(state)
	
	if Landing() == true:
		parent._frame()
		return states.LANDING
	else:
		return states.STAND
		
	if Falling() == true:
		return states.AIR
	
	match state:
		states.STAND:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
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
			if parent.frame == parent.jump_squat:
				if not Input.is_action_pressed("jump_%s" % id):
					parent.velocity.x = lerp(parent.velocity.x, 0, 0.08)  # slow towards 0 at 8%
					parent._frame()
					return states.SHORT_HOP
				else:
					parent.velocity.x = lerp(parent.velocity.x, 0.0, 0.08)
					parent._frame()
					return states.FULL_HOP
		states.SHORT_HOP:
			parent.velocity.y = -parent.JUMPFORCE
			parent._frame()
			return states.AIR
		states.FULL_HOP:
			parent.velocity.y = -parent.MAXJUMPFORCE
			parent._frame()
			return states.AIR
		states.DASH:
			pass
		states.WALK:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
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
		states.AIR:
			AIRMOVEMENT()
		states.LANDING:
			if parent.frame <= parent.landing_frames + parent.lag_frames:
				if parent.frame == 1:
					pass
				if parent.velocity.x > 0:
					parent.velocity.x = parent.velocity.x - parent.TRACTION / 2
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				if parent.velocity.x < 0:
					parent.velocity.x = parent.velocity.x + parent.TRACTION / 2
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
				if Input.is_action_just_pressed("jump_%s" % id):
					parent._frame()
					return states.JUMP_SQUAT
			else:
				if Input.is_action_just_pressed("down_%s" % id):
					parent.lag_frames = 0
					parent._frame()
					return states.CROUCH
				else:
					parent._frame()
					parent.lag_frames = 0
					return states.STAND
				parent.lag_frames = 0

func enter_state(new_state, old_state):
	pass
	
func exit_state(old_state, new_state):
	pass
	
func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
	
func AIRMOVEMENT():
	if parent.velocity.y < parent.FALLINGSPEED:
		parent.velocity.y += parent.FALLSPEED
	if Input.is_action_pressed("down_%s" % id) and parent.velocity.y > -150 and not parent.fastfall:
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall == true:
		parent.set_collision_mask_bit(2, false)
		parent.velocity.y = parent.MAXFALLSPEED
		
	if abs(parent.velocity.x) >= abs(parent.MAXAIRSPEED):
		if parent.velocity.x > 0 :
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x += -parent.AIR_ACCEL
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x = parent.velocity.x
		if parent.velocity.x < 0 :
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x += -parent.velocity.x
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x = parent.AIR_ACCEL
				
	if abs(parent.velocity.x) < abs(parent.MAXAIRSPEED):
		if Input.is_action_pressed("left_%s" % id):
			parent.velocity.x += -parent.AIR_ACCEL
		if Input.is_action_pressed("righ_%s" % id):
			parent.velocity.x += parent.AIR_ACCEL
	
	if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
		if parent.velocity.x < 0:
			parent.velocity.x += parent.AIR_ACCEL / 5
		if parent.velocity.x > 0:
			parent.velocity.x += -parent.AIR_ACCEL / 5
			
			
func Landing():
	if state_includes([states.AIR]):
		if (parent.GroundL.is_colliding()) and parent.velocity.y > 0:
			var collider = parent.GroundL.get_collider()
			print("colliding GroundL")
			parent.frame = 0
			if parent.velocity.y > 0:
				print("set y velocity to 0")
				parent.velocity.y = 0
			parent.fastfall = false
			return true
		elif (parent.GroundR.is_colliding()) and parent.velocity.y > 0:
			var collider2 = parent.GroundR.get_collider()
			print("colliding GroundR")
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true

func Falling():
	if state_includes([states.RUN, states.WALK, states.STAND, states.CROUCH, states.DASH, states.LANDING, states.JUMP_SQUAT]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true
