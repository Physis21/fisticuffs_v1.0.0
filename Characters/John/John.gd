extends CharacterBody2D

# from fox stats

# Global variables
var frame = 0
var dir = 'right'  # direction

# Attributes
@export var id : int
@export var percentage = 20
@export var health = 1000
@export var stocks = 3
@export var weight = 100
var freezeframes = 0

# Buffers
var wallcling_max = 90
var wallcling_cooldown = 30
var wallcling_timer = 0

# Knockback
var hdecay
var vdecay
var knockback
var hitstun
var connected: bool

# Ground Variables

# Air Variables
var walljumped : bool = false
var fastfall : bool = false
var jump_squat : int = 5
var lag_frames:  int = 0
var landing_frames : int = 3
var previous_mov_input : String = 'neutral'

# Hitboxes
@export var hitbox: PackedScene
var selfState

# Temporary variables
var hit_pause = 0
var hit_pause_dur = 0
var temp_pos = Vector2(0,0)
var temp_vel = Vector2(0,0)

# Effects
@export var DashDust: PackedScene
@export var LandingRipple: PackedScene

# Onready Variables
@onready var GroundL = $Raycasts/GroundL
@onready var GroundR = $Raycasts/GroundR
@onready var WallL = $Raycasts/WallL
@onready var WallR = $Raycasts/WallR
@onready var states = $State
@onready var anim = $Sprite/AnimationPlayer
@onready var effectMarkers = get_tree().get_nodes_in_group("EffectMarkers")
var stageScene = null  # initialized in _ready()

# Preload collision shapes
var standing_cshape = preload("res://Characters/John/cshapes/standing.tres")
var crouching_cshape = preload("res://Characters/John/cshapes/crouching.tres")
var standing_collision_dia = preload("res://Characters/John/cshapes/standingCollisionDia.tres")

# JOHN's main attributes
const WALKSPEED : int = 300 # 200.0 * 2
const RUNSPEED : int = 800 # 390 * 2
const DASHFRAMES : int = 16
const GRAVITY : int = 1800 * 2
const JUMPFORCE : int = 900 # actually a speed (pxl / frame)
const MAXJUMPFORCE : int = 1200 # actually a speed
const MAXAIRSPEED : int = 300 # 300 * 2
const AIR_ACCEL : int = 10
const FALLACCEL : int = 60
const FALLINGSPEED : int = 800 # 900 * 2
const MAXFALLSPEED : int = 800 # fastfall speed
const TRACTION : int = 400 * 2 # acceleration
const TRACTION_ATTACK : float = 25 # acceleration
const PUSH_FORCE = 200
#const MIN_PUSH_FORCE = 10
var effectMarkerPosX : Dictionary = {}

func create_hitbox(width, height, damage, duration, angle, angle_flipper, bk, ks, type, points, hitlag=1):
	var hitbox_instance = hitbox.instantiate()
	self.add_child(hitbox_instance)
	# rotate the points
	if dir == 'right':
		hitbox_instance.set_parameters(
			width, height, damage, duration, angle, angle_flipper,
			bk, ks, type, points, hitlag
			)
	else:
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(
			width, height, damage, duration, angle, angle_flipper,
			bk, ks, type, flip_x_points, hitlag
			)
	return hitbox_instance
	
func updateframes(delta):
	frame += floor(delta * 60) # to be unaffected by Engine.timescale (instead of +1)
	if wallcling_timer > 0:
		wallcling_timer -= floor(delta * 60)
	wallcling_timer = clampf(wallcling_timer, 0, wallcling_timer)
	if freezeframes > 0:
		freezeframes -= floor(delta * 60) 
	freezeframes = clampf(freezeframes, 0, freezeframes)

func turn(direction):
	# character faces right by default
	var flip = true
	if direction == 'right':  # face right
		dir = 'right'
		flip = false
	elif direction == 'left':  # face left
		dir = 'left'
		flip = true		
	$Sprite.set_flip_h(flip)
	for em in effectMarkers:
		em.position.x = effectMarkerPosX[em.name] * ((-int(flip) * 2) + 1)
		
		

func _frame():
	frame = 0
	
func play_animation(animation_name):
	anim.play(animation_name)
	
func play_dash_dust():
	var DashDustInst = DashDust.instantiate()
	DashDustInst.turn(self.dir)
	DashDustInst.global_position = $EffectMarkers/DashDustMarker.global_position
	stageScene.add_child(DashDustInst)
	
func play_landing_ripple():
	var LandingRippleInst = LandingRipple.instantiate()
	LandingRippleInst.turn(self.dir)
	LandingRippleInst.global_position = $EffectMarkers/LandingRippleMarker.global_position
	stageScene.add_child(LandingRippleInst)

# called when the node enters the scene_tree for the first time
func _ready():
	for em in effectMarkers:
		effectMarkerPosX[em.name] = em.position.x
	stageScene = get_tree().current_scene
	turn(dir)
	pass

func _physics_process(_delta):
	$Frames.text = str(frame)
	selfState = states.text
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is CharacterBody2D:
			print("c normal = %s" % -c.get_normal())
			c.get_collider().velocity += -c.get_normal() * PUSH_FORCE
	
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
		create_hitbox(40, 20, 8, 9, 0, 0, 160, 1, 'normal', Vector2(64, -25), 1)
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
