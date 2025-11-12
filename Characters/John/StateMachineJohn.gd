extends StateMachine
var id : int

# Called when the node enters the scene tree for the first time.
func _ready():
	id = get_parent().id
	# grounded states
	add_state('STAND')  # idle
	add_state('JUMP_SQUAT')
	add_state('SHORT_HOP')
	add_state('FULL_HOP')
	add_state('INIT_DASH')
	add_state('RUN')
	add_state('WALK')
	add_state('TURN')
	add_state('CROUCH')
	add_state('CROUCHING')
	add_state('LANDING')
	# hitstun states
	add_state('HITFREEZE')
	add_state('HITSTUN_AIR')
	add_state('HITSTUN_GROUND')
	# airborne states
	add_state('AIR')
	add_state('AIR_RISING')
	add_state('AIR_FALLING')
	add_state('AIR_FASTFALL')
	add_state('WALL_CLING')
	add_state('WALL_JUMP_SQUAT')
	add_state('WALL_SHORT_HOP')
	add_state('WALL_FULL_HOP')
	# attack states
	add_state('GROUND_ATTACK')
	add_state('AIR_ATTACK')
	add_state('S5A')
	add_state('S2A')
	add_state('S8A')
	add_state('J6A')
	# delays execution of code until there is an idle time in the main loop
	call_deferred("set_state", states.STAND)  
	pass

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)
	parent.apply_hit_pause(delta)
	
func get_transition(_delta):
	parent.move_and_slide()
	parent.states.text = str(state)
	var direction = get_rightleft(id)
	var dash_input = Input.is_action_pressed("dash_%s" % id)
	
	if Landing() == true:
		parent._frame()
		return states.LANDING
		
	if Falling() == true:
		return states.AIR_FALLING
	
	if Input.is_action_just_pressed("attack_A_%s" % id) && can_grounded_attack():
		parent._frame()
		return states.GROUND_ATTACK
	
	if Input.is_action_just_pressed("attack_A_%s" % id) && can_air_attack():
		parent._frame()
		return states.AIR_ATTACK
	
	match state:
		states.STAND:
			if Input.is_action_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_pressed("down_%s" % id):
				parent._frame()
				return states.CROUCH
			if direction == 'right' and not dash_input:
				parent.velocity.x = parent.WALKSPEED
				parent._frame()
				parent.turn('right')
				return states.WALK
			elif direction == 'left' and not dash_input:
				parent.velocity.x = -parent.WALKSPEED
				parent._frame()
				parent.turn('left')
				return states.WALK
			elif direction == 'right' and dash_input:
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn('right')
				return states.INIT_DASH
			elif direction == 'left' and dash_input:
				parent.velocity.x = -parent.RUNSPEED
				parent._frame()
				parent.turn('left')
				return states.INIT_DASH
			apply_traction(parent.TRACTION)
		states.JUMP_SQUAT:
			parent.velocity.x = lerpf(parent.velocity.x, 0.0, 0.08)
			if parent.previous_mov_input == 'neutral':
				if direction == 'right':
					parent.previous_mov_input = 'right'
				elif direction == 'left':
					parent.previous_mov_input = 'left'
			if parent.frame == parent.jump_squat:
				if not Input.is_action_pressed("jump_%s" % id):
					#parent.velocity.x = lerpf(parent.velocity.x, 0.0, 0.8)  # slow towards 0 at 8%
					parent._frame()
					return states.SHORT_HOP
				else:
					#parent.velocity.x = lerpf(parent.velocity.x, 0.0, 0.08)
					parent._frame()
					return states.FULL_HOP
		states.SHORT_HOP:
			parent.velocity.y = -parent.JUMPFORCE
			if parent.previous_mov_input == 'right':
				parent.velocity.x += parent.MAXAIRSPEED
			elif parent.previous_mov_input == 'left':
				parent.velocity.x -= parent.MAXAIRSPEED
			parent._frame()
			return states.AIR_RISING
		states.FULL_HOP:
			parent.velocity.y = -parent.MAXJUMPFORCE
			if parent.previous_mov_input == 'right':
				parent.velocity.x += parent.MAXAIRSPEED
			elif parent.previous_mov_input == 'left':
				parent.velocity.x -= parent.MAXAIRSPEED
			parent._frame()
			return states.AIR_RISING
		states.INIT_DASH:
			if Input.is_action_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_pressed("down_%s" % id):
				parent._frame()
				return states.CROUCH
			if parent.frame == parent.DASHFRAMES:
				return states.RUN
		states.RUN:
			if Input.is_action_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_pressed("down_%s" % id):
				parent._frame()
				return states.CROUCH
			if direction == 'left':
				if parent.velocity.x > 0:
					parent.turn('left')
					parent.velocity.x = -parent.RUNSPEED
					parent._frame()
					return states.INIT_DASH
				else:
					parent.velocity.x = -parent.RUNSPEED
					parent.turn('left')
			elif direction == 'right':
				if parent.velocity.x < 0:
					parent.turn('right')
					parent.velocity.x = parent.RUNSPEED
					parent._frame()
					return states.INIT_DASH
				else:
					parent.velocity.x = parent.RUNSPEED
					parent.turn('right')
			else:
				parent._frame()
				return states.STAND
		states.WALK:
			if Input.is_action_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_pressed("down_%s" % id):
				parent._frame()
				return states.CROUCH
			if direction == 'right' and dash_input:
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn('right')
				return states.INIT_DASH
			elif direction == 'left' and dash_input:
				parent.velocity.x = -parent.RUNSPEED
				parent._frame()
				parent.turn('left')
				return states.INIT_DASH
			elif direction == 'neutral':
				parent._frame()
				return states.STAND
		states.CROUCH:
			if Input.is_action_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_released("down_%s" % id):
				parent._frame()
				return states.STAND
			apply_traction(parent.TRACTION / 2)
			if parent.frame == 7:
				parent._frame()
				return states.CROUCHING
		states.CROUCHING:
			if Input.is_action_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_released("down_%s" % id):
				parent._frame()
				return states.STAND
			apply_traction(parent.TRACTION / 2)
		states.AIR:
			AIRMOVEMENT()
			if WallCling(direction) == true:
				return states.WALL_CLING
		states.AIR_RISING:
			AIRMOVEMENT()
			if WallCling(direction) == true:
				return states.WALL_CLING
			if parent.velocity.y > 0:
				parent._frame()
				return states.AIR_FALLING
		states.AIR_FALLING:
			AIRMOVEMENT()
			if WallCling(direction) == true:
				return states.WALL_CLING
			if parent.fastfall:
				return states.AIR_FASTFALL
			if parent.velocity.y < 0:
				parent._frame()
				return states.AIR_RISING
		states.AIR_FASTFALL:
			if WallCling(direction) == true:
				return states.WALL_CLING
			AIRMOVEMENT()
			if parent.velocity.y < 0:
				parent._frame()
				return states.AIR_RISING
		states.LANDING:
			if parent.frame <= parent.landing_frames + parent.lag_frames:
				if parent.frame == 1:
					pass
				apply_traction(parent.TRACTION / 2)
			else:
				if Input.is_action_pressed("jump_%s" % id):
					parent._frame()
					return states.JUMP_SQUAT
				if Input.is_action_pressed("down_%s" % id):
					parent.lag_frames = 0
					parent._frame()
					return states.CROUCH
				else:
					parent._frame()
					parent.lag_frames = 0
					return states.STAND
				#parent.lag_frames = 0
		states.WALL_CLING:
			if parent.frame == parent.wallcling_max or Input.is_action_pressed("down_%s" % id):  # after a while, stop wall cling
				return states.AIR_FALLING
			if Input.is_action_pressed("jump_%s" % id):
				parent._frame()
				return states.WALL_JUMP_SQUAT
		states.WALL_JUMP_SQUAT:
			if parent.previous_mov_input == 'neutral':
				if direction == 'right':
					parent.previous_mov_input = 'right'
				elif direction == 'left':
					parent.previous_mov_input = 'left'
			if parent.frame == parent.jump_squat:
				if not Input.is_action_pressed("jump_%s" % id):
					#parent.velocity.x = lerpf(parent.velocity.x, 0.0, 0.8)  # slow towards 0 at 8%
					parent._frame()
					return states.WALL_SHORT_HOP
				else:
					#parent.velocity.x = lerpf(parent.velocity.x, 0.0, 0.08)
					parent._frame()
					return states.WALL_FULL_HOP
		states.WALL_SHORT_HOP:
			parent.velocity.y = -parent.JUMPFORCE  # same strength as short hop
			if parent.previous_mov_input == 'right':
				parent.velocity.x += parent.MAXAIRSPEED
			elif parent.previous_mov_input == 'left':
				parent.velocity.x -= parent.MAXAIRSPEED
			parent._frame()
			parent.walljumped = true
			return states.AIR_RISING
		states.WALL_FULL_HOP:
			parent.velocity.y = -parent.MAXJUMPFORCE  # same strength as short hop
			if parent.previous_mov_input == 'right':
				parent.velocity.x += parent.MAXAIRSPEED
			elif parent.previous_mov_input == 'left':
				parent.velocity.x -= parent.MAXAIRSPEED
			parent._frame()
			parent.walljumped = true
			return states.AIR_RISING
		states.HITFREEZE:
			if parent.freezeframes  == 0:
				parent._frame()
				parent.velocity.x = kbx
				parent.velocity.y = kby
				parent.hdecay = hd
				parent.vdecay = vd
				if is_airborne():
					return states.HITSTUN_AIR
				else:
					return states.HITSTUN_GROUND
			parent.position = pos
		states.HITSTUN_GROUND:
			if is_airborne():
				return states.HITSTUN_AIR
			hitstun_movement()
			if parent.frame >= parent.hitstun:
				if parent.knockback >= 24:
					parent._frame()
					return states.STAND
				else:
					parent._frame()
					return states.STAND
		states.HITSTUN_AIR:
			#if parent.knockback >= 3:
				#var collision : KinematicCollision2D = parent.move_and_collide(parent.velocity * delta)
				#print("parent.hitstun = %s" % parent.hitstun)
				#print("parent.knockback = %s" % parent.knockback)
				#print("collision = %s" % collision)
				#if collision:
					#print("Player %s Bounced on something" % id)
					#print("Collision normal: ")
					#print(collision.get_normal())
					#parent.velocity = parent.velocity.bounce(collision.get_normal()) # * 0.8
					#parent.hitstun = round(parent.hitstun * 0.8)
			hitstun_movement()
			if parent.frame >= parent.hitstun:
				if parent.knockback >= 24:
					parent._frame()
					return states.AIR
				else:
					parent._frame()
					return states.AIR
		states.GROUND_ATTACK:
			if Input.is_action_pressed("up_%s" % id):
				parent._frame()
				return states.S8A
			if Input.is_action_pressed("down_%s" % id):
				parent._frame()
				return states.S2A
			if direction in ['right', 'left']:
				parent._frame()
				parent.turn(direction)
				return states.S5A
			parent._frame()
			return states.S5A
		states.AIR_ATTACK:
			if direction in ['right', 'left']:
				parent._frame()
				return states.J6A
			parent._frame()
			return states.J6A
		states.S5A:
			if parent.frame == 0:
				parent.s5A()
			if parent.frame >= 1:
				apply_traction(parent.TRACTION_ATTACK)
			if parent.s5A() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent._frame()
					return states.CROUCH
				else:
					parent._frame()
					return states.STAND
		states.S2A:
			if parent.frame == 0:
				parent.s2A()
			if parent.frame >= 1:
				apply_traction(parent.TRACTION_ATTACK)
			if parent.s2A() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent._frame()
					return states.CROUCHING
				else:
					parent._frame()
					return states.STAND
		states.S8A:
			if parent.frame == 0:
				parent.s8A()
			if parent.frame >= 1:
				apply_traction(parent.TRACTION_ATTACK)
			if parent.s8A() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent._frame()
					return states.CROUCH
				else:
					parent._frame()
					return states.STAND
		states.J6A:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.j6A()
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.AIR_ACCEL/5
					parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				if parent.velocity.x < 0:
					parent.velocity.x += parent.AIR_ACCEL/5
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x,0)
			if parent.j6A() == true:
				parent._frame()
				return states.AIR
				

func enter_state(new_state, _old_state):
	parent.states.text = str(new_state)
	match new_state:
		states.STAND:
			parent.play_animation('idle')
		states.WALK:
			parent.play_animation('5W')
		states.INIT_DASH:
			parent.play_animation('5Run')
			parent.play_dash_dust()
		states.RUN:
			parent.play_animation('6Run')
		states.JUMP_SQUAT:
			parent.play_animation('jSquat')
		states.SHORT_HOP:
			parent.play_animation('jSquat')
		states.FULL_HOP:
			parent.play_animation('jSquat')
		states.AIR:
			parent.play_animation('air')
		states.AIR_RISING:
			parent.play_animation('5JUp')
		states.AIR_FALLING:
			parent.play_animation('5JDown')
		states.AIR_FASTFALL:
			parent.play_animation('fastfall')
		states.WALL_CLING:
			parent.play_animation('wallCling')
		states.LANDING:
			parent.play_animation('jSquat')
			parent.play_landing_ripple()
		states.CROUCH:
			parent.play_animation('crouch')
		states.CROUCHING:
			parent.play_animation('crouching')
		states.HITFREEZE:
			parent.play_animation('8Hit')
		states.HITSTUN_AIR:
			parent.play_animation('j8Hit')
		states.HITSTUN_GROUND:
			pass # keep HITFREEZE animation
		states.GROUND_ATTACK:
			pass
		states.S5A:
			parent.play_animation('s5A')
		states.S2A:
			parent.play_animation('s2A')
		states.S8A:
			parent.play_animation('s8A')
		states.J6A:
			parent.play_animation('j6A')
	
func exit_state(_old_state, _new_state):
	pass
	
func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
	
func can_grounded_attack():
	if state_includes([states.STAND, states.WALK, states.RUN, states.CROUCH, states.CROUCHING]):
		return true

func can_air_attack():
	if state_includes([states.AIR, states.AIR_RISING, states.AIR_FALLING, states.AIR_FASTFALL, states.WALL_CLING]):
		return true

func AIRMOVEMENT():
	var direction = get_rightleft(id)
	if parent.velocity.y < parent.FALLINGSPEED:
		parent.velocity.y += parent.FALLACCEL
	if Input.is_action_pressed("down_%s" % id) and parent.velocity.y > -100 and not parent.fastfall:
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall == true:
		#parent.set_collision_layer_value(0, false)  # go through platforms
		parent.velocity.y = parent.MAXFALLSPEED
		
	if absf(parent.velocity.x) >= absi(parent.MAXAIRSPEED):
		if parent.velocity.x > 0 :
			if direction == 'left':
				parent.velocity.x += -parent.AIR_ACCEL
			#elif Input.is_action_pressed("right_%s" % id):
				#parent.velocity.x = parent.velocity.x
		if parent.velocity.x < 0 :
			if direction == 'right':
				parent.velocity.x += parent.AIR_ACCEL
			#elif Input.is_action_pressed("left_%s" % id):
				#parent.velocity.x = parent.velocity.x				
	if absf(parent.velocity.x) < absi(parent.MAXAIRSPEED):
		var air_accel : int
		if parent.previous_mov_input == 'neutral':
			air_accel = parent.AIR_ACCEL
		else:
			air_accel = parent.AIR_ACCEL / 3
		if direction == 'left':
			parent.velocity.x += -air_accel
		if direction == 'right':
			parent.velocity.x += air_accel
	
	#if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
		#if parent.velocity.x < 0:
			#parent.velocity.x += parent.AIR_ACCEL / 5
		#if parent.velocity.x > 0:
			#parent.velocity.x += -parent.AIR_ACCEL / 5
			
			
func Landing():
	if state_includes([states.AIR, states.AIR_RISING, states.AIR_FALLING, states.AIR_FASTFALL, states.J6A]):
		if (parent.GroundL.is_colliding() or parent.GroundR.is_colliding()) and parent.velocity.y >= 0:
			#var collider = parent.GroundL.get_collider()
			parent._frame()
			if parent.velocity.y >= 0:
				parent.velocity.y = 0
			parent.fastfall = false
			parent.walljumped = false
			parent.previous_mov_input = 'neutral'
			return true
		elif (parent.GroundR.is_colliding()) and parent.velocity.y >= 0:
			#var collider2 = parent.GroundR.get_collider()
			parent._frame()
			if parent.velocity.y >= 0:
				parent.velocity.y = 0
			parent.fastfall = false
			parent.walljumped = false
			parent.previous_mov_input = 'neutral'
			return true

func Falling():
	if state_includes([states.INIT_DASH, states.RUN, states.WALK, states.STAND, states.CROUCH, states.CROUCHING, states.RUN, states.LANDING, states.JUMP_SQUAT]):
		if is_airborne():
			return true
			
func WallCling(direction):
	if is_airborne() and parent.wallcling_timer == 0:
		if parent.WallL.is_colliding() and direction == 'right' and parent.walljumped == false:
			#var collider = parent.WallL.get_collider()
			parent._frame()
			parent.wallcling_timer = parent.wallcling_cooldown
			parent.velocity.y = 0
			parent.velocity.x = 0
			parent.fastfall = false
			parent.previous_mov_input = 'right'
			parent.turn('right')
			return true
		if parent.WallR.is_colliding() and direction == 'left' and parent.walljumped == false:
			#var collider2 = parent.WallR.get_collider()
			parent._frame()
			parent.wallcling_timer = parent.wallcling_cooldown
			parent.velocity.y = 0
			parent.velocity.x = 0
			parent.fastfall = false
			parent.previous_mov_input = 'left'
			parent.turn('left')
			return true

var kbx
var kby
var hd
var vd
var pos

func hitfreeze(duration, knockbackVal):
	pos = parent.position
	parent.freezeframes = duration
	kbx = knockbackVal[0]
	kby = knockbackVal[1]
	hd = knockbackVal[2]
	vd = knockbackVal[3]
	pass

func hitstun_movement():
	if parent.velocity.y < 0:
		parent.velocity.y += parent.vdecay * 0.5 * Engine.time_scale
		parent.velocity.y = clampf(parent.velocity.y, parent.velocity.y, 0)
	if parent.velocity.x < 0:
		parent.velocity.x -= (parent.hdecay) * 0.4 * Engine.time_scale
		parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
	if parent.velocity.x > 0:
		parent.velocity.x -= (parent.hdecay) * 0.4 * Engine.time_scale
		parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == '5W':
		parent.play_animation('6W')
	#if anim_name == '5Run':
		#parent.play_animation('6Run')
