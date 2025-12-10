class_name Hitbox extends Area2D


@export var width : int = 300 ## Width of hitbox rectangle shape.
@export var height : int  = 400 ## Height of hitbox rectangle shape (px).
@export var damage : float  = 10. ## Damage caused by hitbox (px).
@onready var angle : int = 0 ## Angle at which the hitbox sends (degrees).
@onready var angle_flipper : int = 0  ## Value which defines the behavior of the knockback angle with respect to the parent player. Default value: 0.
@onready var base_kb : int = 100 ## Base knockback speed (px/frame), which is then modified by [kbToVelocity].
@export var kb_scaling : float = 1 ## Growth of the knockback with respect to percentage.
@export var duration : int = 60 ## Duration of the hitbox (frames).
@export var hitlag_modifier : float = 1. ## Modifies the hitlag time.
@export var type : String = "normal" ## Type of hitbox.
@onready var hitbox : CollisionShape2D = get_node("HitboxShape") ## [CollisionShape2D] child node of the hitbox.
@onready var parentState : String = get_parent().selfState ## State of the parent.

var framez : int = 0 ## Counts number of frames elapsed since instanciation.
var player_list : Array = [] ## List of player characters this hitbox cannot collide with.
var knockbackVal : float ## Knockback value after damage calculation.
var kbToVelocity : float = 5. ## Knockback to velocity (px/frame) converter.
var decayFactor : float = 0.051 ## Decay factor of knockback.

const DEGTORAD : float = PI / 180 ## Degree to radian converter.

## Sets the hitbox parameters. Is usually called after the hitbox is instanced 
func set_parameters(
	w : int, ## Width
	h : int, ## Height
	dam : float, ## Damage
	dur : int, ## Duration
	a : int, ## Angle
	af : int, ## Angle flipper
	bk : int, ## Base knockback
	ks : float, ## Knockback scaling
	t : String, ## Type of knockback
	p : Vector2, ## Position of hitbox
	hit : float, ## Hitlag modifier
	parent : CharacterBody2D=get_parent() ## Parent character
	) -> void:
	self.position = Vector2(0,0)
	player_list.append(parent)
	player_list.append(self)  # just in case
	width = w
	height = h
	damage = dam
	duration = dur
	angle = a
	angle_flipper = af
	base_kb = bk
	kb_scaling = ks
	type = t
	hitlag_modifier = hit
	self.position = p
	update_extents()
	self.area_entered.connect(hitbox_collide) # Manual connecting
	set_physics_process(true)
	pass

## Applies hit state to opposing character, along with hitstun and hit freeze
func hitbox_collide(area: Area2D) -> void:
	#print("Collision detected")
	var body = area.get_parent()
	if !(body in player_list):
		player_list.append(body)
		var charstate
		charstate = body.get_node("StateMachine")
		weight = body.weight
		body.health -= damage
		knockbackVal = getKnockback(body.percentage, damage, weight, base_kb, kb_scaling, 1)
		apply_turnaround(body)
		charstate.state = charstate.states.HITFREEZE
		charstate.hitfreeze(
			getHitlag(damage, hitlag_modifier),
			apply_angle_flipper(Vector2(body.velocity.x, body.velocity.y), body.global_position),
		)
		body.knockback = knockbackVal
		body.hitstun = getHitstun(knockbackVal)
		get_parent().connected = true
		body._frame()
		#print("knockbackVal = %s" % knockbackVal)
		
		Globals.hitstun_slowdown(getHitlag(damage, hitlag_modifier), getHitlag(damage, hitlag_modifier)/60)
		get_parent().hit_pause_dur = duration - framez
		get_parent().temp_pos = get_parent().position
		get_parent().temp_vel = get_parent().velocity

## Update the HitboxShape extents
func update_extents() -> void:
	hitbox.shape.extents = Vector2(width, height)
	
func _ready() -> void:
	hitbox.shape = RectangleShape2D.new()  # double check
	set_physics_process(false)  # don't want hitbox to do anything before this func is called
	#print("knockback = %s" % getKnockback(20, 100, 100, 100, 1, 1))
	pass

func _physics_process(delta: float) -> void:
	if framez < duration:
		framez += floor(delta * 60)
	elif framez == duration:
		#Engine.time_scale = 1 # if this is enabled, multi hits will jitter timescale
		queue_free()  # this waits for the current code to finish execution before deletion
		return
	if get_parent().selfState != parentState:  # check if we are still attacking
		Engine.time_scale = 1
		queue_free()
		return 

## Converts a knockback value to a hitstun value
func getHitstun(kbVal : float) -> int:
	return floor(kbVal / 10)

## Get hitlag from damage and hitlag modifier
func getHitlag(dam : float, hit : float) -> int:
	return floor(floor(floor(dam / 3) + 4) * hit)

# These variables are maybe not necessary
## Sample weight of opposing character.
@export var weight : float = 100
## Sample ratio of the knockback value after calculation.
@export var ratio : float  = 1
## Sample percentage of opposing character. 20 is the default for stamina mode in Melee
@export var percentage : float = 20

## Returns the knockback value
func getKnockback(p : float, d : float, w : float, bk : int, ks : float, r : float) -> float:
	percentage = p
	damage = d
	weight = w
	base_kb = bk
	kb_scaling = ks
	ratio = r
	# require 0.4% of SSBM knockback
	return ((((((percentage / 10) + (percentage * damage / 20)) * 1.4 * (200 / (weight + 100))) + 18) * kb_scaling) + base_kb) * ratio

## Returns the rate at which the opponent will slow down after knockback
func getHorizontalDecay(a): 
	var decay = decayFactor * cos(a * DEGTORAD) # Rate of decay is 0.051. To get the Horizontal rate, multily by cos of angle
	decay = round(decay * 100000) / 100000 # Round to a whole number
	decay = decay * 1000 # Enlarge the rate of decay
	return decay
	
func getVerticalDecay(a):
	var decay = decayFactor * sin(a * DEGTORAD) 
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return abs(decay)
	
func getHorizontalVelocity(kbVal, a):
	var initialVelocity = kbVal * kbToVelocity
	var horizontalVelocity = initialVelocity * cos(a * DEGTORAD)
	horizontalVelocity = round(horizontalVelocity * 100000) / 100000
	return horizontalVelocity

func getVerticalVelocity(kbVal, a):
	var initialVelocity = kbVal * kbToVelocity
	var verticalVelocity = -initialVelocity * sin(a * DEGTORAD)  # up is negative y
	verticalVelocity = round(verticalVelocity * 100000) / 100000
	return verticalVelocity

func apply_angle_flipper(body_vel: Vector2, body_position: Vector2, hdecay=0, vdecay=0):
	var xangle
	var angleWithDir
	if get_parent().dir.val == 'right':
		xangle = -body_position.angle_to_point(get_parent().global_position) / DEGTORAD
		angleWithDir = angle
	elif get_parent().dir.val == 'left':
		xangle = body_position.angle_to_point(get_parent().global_position) / DEGTORAD
		angleWithDir = (180 - angle) % 360
	match angle_flipper:
		0:
			body_vel.x = (getHorizontalVelocity(knockbackVal, angleWithDir))
			body_vel.y = (getVerticalVelocity(knockbackVal, angleWithDir))
			hdecay = (getHorizontalDecay(angleWithDir))
			vdecay = (getVerticalDecay(angleWithDir))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])
		1:
			xangle = -get_parent().dir.xmult * self.global_position.angle_to_point(body_position) / DEGTORAD
			body_vel.x = (getHorizontalVelocity(knockbackVal, xangle+180))
			body_vel.y = (getVerticalVelocity(knockbackVal, -xangle))
			hdecay = (getHorizontalDecay(xangle+180))
			vdecay = (getVerticalDecay(xangle))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])
			# away
			# return angle
		2: 
			xangle = -get_parent().dir.xmult * body_position.angle_to_point(self.global_position) / DEGTORAD
			body_vel.x = (getHorizontalVelocity(knockbackVal, -xangle+180))
			body_vel.y = (getVerticalVelocity(knockbackVal, -xangle))
			hdecay = (getHorizontalDecay(xangle+180))
			vdecay = (getVerticalDecay(xangle))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])
			# away
			# return angle
	# 0 - sends at the exact knockback angle
	# 1 - sends away from center of the ennemy player
	# 2 - sends towards center of the ennemy player

func apply_angle_flipper_v0(body):
	var xangle
	var angleWithDir
	if get_parent().dir.val == 'right':
		xangle = -body.global_position.angle_to_point(get_parent().global_position) / DEGTORAD
		angleWithDir = angle
	elif get_parent().dir.val == 'left':
		xangle = body.global_position.angle_to_point(get_parent().global_position) / DEGTORAD
		angleWithDir = (180 - angle) % 360
	match angle_flipper:
		0:
			body.velocity.x = (getHorizontalVelocity(knockbackVal, angleWithDir))
			body.velocity.y = (getVerticalVelocity(knockbackVal, angleWithDir))
			body.hdecay = (getHorizontalDecay(angleWithDir))
			body.vdecay = (getVerticalDecay(angleWithDir))
		1:
			if get_parent().dir.val == 'right':
				xangle = -self.global_position.angle_to_point(body.get_parent().global_position) / DEGTORAD
			elif get_parent().dir.val == 'left':
				xangle = self.global_position.angle_to_point(body.get_parent().global_position) / DEGTORAD
			body.velocity.x = (getHorizontalVelocity(knockbackVal, xangle+180))
			body.velocity.y = (getVerticalVelocity(knockbackVal, -xangle))
			body.hdecay = (getHorizontalDecay(xangle+180))
			body.vdecay = (getVerticalDecay(xangle))
			# away
			# return angle
		2: 
			if get_parent().dir.val == 'right':
				xangle = -body.get_parent().global_position.angle_to_point(self.global_position) / DEGTORAD
			elif get_parent().dir.val == 'left':
				xangle = body.get_parent().global_position.angle_to_point(self.global_position) / DEGTORAD
			body.velocity.x = (getHorizontalVelocity(knockbackVal, -xangle+180))
			body.velocity.y = (getVerticalVelocity(knockbackVal, -xangle))
			body.hdecay = (getHorizontalDecay(xangle+180))
			body.vdecay = (getVerticalDecay(xangle))
			# away
			# return angle
	# 0 - sends at the exact knockback angle
	# 1 - sends away from center of the ennemy player
	# 2 - sends towards center of the ennemy player
	
func apply_turnaround(body):
	if body.velocity.x > 0:
		body.turn('left')
	elif body.velocity.x < 0:
		body.turn('right')
	else: # 0
		if get_parent().dir.val == 'right':
			body.turn('left')
		elif get_parent().dir.val == 'left':
			body.turn('right')
			
