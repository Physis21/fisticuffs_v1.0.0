class_name John extends CharacterBody2D
## First test character.

# from fox stats

# JOHN's main attributes
const WALKSPEED : int = 300 ## Walking speed (px/frame).
const RUNSPEED : int = 800 ## Running speed (px/frame).
const DASHFRAMES : int = 16 ## Duration (in frames) of the dash animation.
const JUMPFORCE : int = 900 ## Vertical speed induced by short hop (px/frame).
const MAXJUMPFORCE : int = 1200 ## Vertical speed induced by jump (px/frame).
const MAXAIRSPEED : int = 300 ## Maximum horizontal air speed.
const AIR_ACCEL : int = 10 ## Maximum horizontal air acceleration.
const FALLACCEL : int = 60 ## Falling acceleration (gravity) of the character.
const FALLINGSPEED : int = 800 ## Falling speed
const MAXFALLSPEED : int = 800 ## Fastfall falling speed
const TRACTION : int = 400 * 2 ## Decelleration due to grounded traction (px/frame²)
const TRACTION_ATTACK : float = 25 ## Traction due to grounded attacks (px/frame²)
const PUSH_FORCE = 100 
#const MIN_PUSH_FORCE = 10

# Global variables
var frame : int = 0 ## Frame counter. Is added 1 each _physics_process().
var dir : Movement.CharDirection = Movement.CharDirection.new() ## Direction of character.

# Attributes
## Character identifier, in order to differentiate simultaneous characters.
@export var id : int
## The higher the percentage, the further the character is knocked back after an attack.
@export var percentage : float = 20
## Character health, starts at maximum by default.
@export var health : float = 1000
## Number of times the character must be KO'ed to.
@export var stocks : int = 3
## Weight of the character (used to compute knockback values).
@export var weight : float = 100.
## Number of frames the character is frozen. Is updated when struck by hitbox.
var freezeframes : int = 0

# Buffers
var wallcling_max : int = 90 ## Maximum number of frames the wallcling can be held.
const WALLCLING_COOLDOWN : int= 30 ## Number of frames during which wallcling is deactivated after walljump.
var wallcling_timer : int = 0 ## Timer for wallcling after a walljump.

# Knockback
var hdecay : float ## Knockback horizontal decay.
var vdecay : float ## Knockback vertical decay.
var knockback : float ## Knockback value.
var hitstun : int ## Number of frames the character is stuck in hitstun.
var connected: bool ## Checks whether an attack has connected.

# Ground Variables

# Air Variables
var walljumped : bool = false ## True if the character has walljumped while airborne. Becomes false again after they touch the ground.
var fastfall : bool = false ## True if the character has fastfalled while airborne. Becomes false again after they touch the ground.
var jump_squat : int = 5 ## Number of frames of jump squat.
var lag_frames:  int = 0 ## Number of lag frames after an action.
var landing_frames : int = 3 ## Number of landing lag frames.
var previous_mov_input = Movement.InptDirection.new() ## Previous movement input.

@export var pushbox: PackedScene ## Pushbox.
@export var hitbox: PackedScene ## Character hitboxes.
var selfState : String ## State of the character.

# Temporary variables
var hit_pause : int = 0 ## Counter for hit pause duration.
var hit_pause_dur : int = 0 ## Duration of the hit pause.
var temp_pos = Vector2(0,0) ## Stored position of character during hit pause.
var temp_vel = Vector2(0,0) ## Stored velocity of character during hit pause.

# Effects
@export var DashDust: PackedScene
@export var LandingRipple: PackedScene

# Onready Variables
@onready var GroundL : RayCast2D= $Raycasts/GroundL ## (Left) raycast checking for ground.
@onready var GroundR : RayCast2D = $Raycasts/GroundR ## (Right) raycast checking for ground.
@onready var WallL : RayCast2D = $Raycasts/WallL ## (Left) raycast checking for wall.
@onready var WallR : RayCast2D = $Raycasts/WallR ## (Right) raycast checking for ground.
@onready var displayedState : Label = $State ## Displayed state of the character.
@onready var anim : AnimationPlayer = $Sprite/AnimationPlayer
@onready var effectMarkers : Array[Node] = get_tree().get_nodes_in_group("EffectMarkers")
var stageScene = null  # initialized in _ready()

# Preload collision shapes
var standing_cshape = preload("res://Characters/John/cshapes/standing.tres")
var crouching_cshape = preload("res://Characters/John/cshapes/crouching.tres")
var standing_collision_dia = preload("res://Characters/John/cshapes/standingCollisionDia.tres")

var effectMarkerPosX : Dictionary = {} ## Stores the spawn positions of effect animations.

## Creates a hitbox at specified location, with defined caracteristics
func create_pushbox(width : float, height : float, points : Vector2):
	var pushbox_instance = pushbox.instantiate()
	self.add_child(pushbox_instance)
	var flip_x_points = Vector2(dir.xmult * points.x, points.y)
	# rotate the points
	pushbox_instance.set_parameters(width, height, flip_x_points)
	return pushbox_instance
	
## Creates a hitbox at specified location, with defined caracteristics
func create_hitbox(
	width : float,
	height : float,
	damage : float, 
	duration : int, 
	angle : float, 
	angle_flipper : int, 
	bk : float, 
	ks : float, 
	type : String, 
	points : Vector2, 
	hitlag : float = 1.
	) -> Hitbox:
	var hitbox_instance = hitbox.instantiate()
	self.add_child(hitbox_instance)
	var flip_x_points = Vector2(dir.xmult * points.x, points.y)
	# rotate the points
	hitbox_instance.set_parameters(
		width, height, damage, duration, angle, angle_flipper,
		bk, ks, type, flip_x_points, hitlag
		)
	return hitbox_instance

## Updates counters such as [frame].
func updateframes(delta : float) -> void:
	frame += floor(delta * 60) # to be unaffected by Engine.timescale (instead of +1)
	if wallcling_timer > 0:
		wallcling_timer -= floor(delta * 60)
	wallcling_timer = clampi(wallcling_timer, 0, wallcling_timer)
	if freezeframes > 0:
		freezeframes -= floor(delta * 60) 
	freezeframes = clampi(freezeframes, 0, freezeframes)

## Turns the character sprite and effect Markers.
func turn(dirVal : String) -> void:
	# character faces right by default
	var flip = true
	dir.set_val(dirVal)
	$Sprite.set_flip_h(dir.flip)
	for em in effectMarkers:
		em.position.x = effectMarkerPosX[em.name] * dir.xmult
		
		

func _frame():
	frame = 0

## Play a character animation.
func play_animation(animation_name : String) -> void:
	anim.play(animation_name)

## Play a character effect.
func play_effect(effect_name : String) -> void:
	match effect_name:
		'DashDust':
			var DashDustInst = DashDust.instantiate()
			DashDustInst.turn(self.dir.val)
			DashDustInst.global_position = $EffectMarkers/DashDustMarker.global_position
			stageScene.add_child(DashDustInst)
		'LandingRipple':
			var LandingRippleInst = LandingRipple.instantiate()
			LandingRippleInst.turn(self.dir.val)
			LandingRippleInst.global_position = $EffectMarkers/LandingRippleMarker.global_position
			stageScene.add_child(LandingRippleInst)

# called when the node enters the scene_tree for the first time
func _ready():
	previous_mov_input.set_val('neutral')
	for em in effectMarkers:
		effectMarkerPosX[em.name] = em.position.x
	stageScene = get_tree().current_scene
	turn('right')
	create_pushbox(25, 79.5, Vector2(0,6.5))
	pass

func _physics_process(_delta):
	$Frames.text = str(frame)
	selfState = displayedState.text
	#for i in get_slide_collision_count():
		#var c = get_slide_collision(i)
		#if c.get_collider() is CharacterBody2D:
			#print("c normal = %s" % c.get_normal())
			#c.get_collider().velocity += -c.get_normal() * PUSH_FORCE

## Freezes the character during hit pause.
func apply_hit_pause(delta):
	if hit_pause < hit_pause_dur:
		self.position = temp_pos
		hit_pause += floor((1 * delta) * 60)
	else:
		if temp_vel != Vector2(0,0):
			self.velocity.x = temp_vel.x
			self.velocity.y = temp_vel.y
			temp_vel = Vector2(0,0)
		hit_pause_dur = 0
		hit_pause = 0
			
	
# Attacks
func s5A():
	if frame == 9:
		create_hitbox(40, 20, 8, 9, 10, 0, 160, 1, 'normal', Vector2(64, -25), 1)
	if frame >= 26:
		return true
		
func s2A():
	if frame == 6:
		create_hitbox(40, 20, 8, 9, 0, 0, 75, 1, 'normal', Vector2(64, -10), 1)
	if frame >= 16:
		return true
		
func s8A():
	if frame == 10:
		create_hitbox(20, 40, 8, 9, 75, 0, 180, 1, 'normal', Vector2(40, -70), 1)
	if frame >= 27:
		return true

func j6A():
	if frame == 18:
		create_hitbox(45, 30, 8, 9, -20, 0, 160, 1, 'normal', Vector2(60, -10), 1)
	if frame >= 37:
		return true
