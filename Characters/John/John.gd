extends CharacterBody2D

# from fox stats
var frame = 0
var dir = 'right'  # direction

# Ground Variables

# Air Variables
var fastfall : bool = false
var jump_squat : int = 5
var lag_frames:  int = 0
var landing_frames : int = 3
var previous_mov_input : String = 'neutral'

# Hitboxes
@export var hitbox: PackedScene
var selfState

# Onready Variables
@onready var GroundL = $Raycasts/GroundL
@onready var GroundR = $Raycasts/GroundR
@onready var states = $State
@onready var anim = $Sprite/AnimationPlayer

# JOHN's main attributes
const WALKSPEED : int = 200 # 200.0 * 2
const RUNSPEED : int = 800 # 390 * 2
const GRAVITY : int = 1800 * 2
const JUMPFORCE : int = 900 # 500 * 2
const MAXJUMPFORCE : int = 1200 # 1000 * 2
const MAXAIRSPEED : int = 300 # 300 * 2
const AIR_ACCEL : int = 10
const FALLSPEED : int = 60 # 60 * 2
const FALLINGSPEED : int = 800 # 900 * 2
const MAXFALLSPEED : int = 800 # 900 * 2
const TRACTION : int = 400 * 2

func create_hitbox(width, height, damage, duration, hoz_proj, ver_proj, type, points, hitlag=1):
	var hitbox_instance = hitbox.instance()
	self.add_child(hitbox_instance)
	# rotate the points
	if dir == 'right':
		hitbox_instance.set_parameters(width, height, damage, duration, hoz_proj, ver_proj, type, points, hitlag)
	else:
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(width, height, damage, duration, hoz_proj, ver_proj, type, flip_x_points, hitlag)
	return hitbox_instance
	
func updateframes(delta):
	frame += 1

func turn(direction):
	# flipped compared to tutorial because his fox faces left
	var flip = true
	if direction == 'right':  # face right
		dir = 'right'
		flip = false
	elif direction == 'left':  # face left
		dir = 'left'
		flip = true		
	$Sprite.set_flip_h(flip)

func _frame():
	frame = 0
	
func play_animation(animation_name):
	anim.play(animation_name)

# called when the node enters the scene_tree for the first time
func _ready():
	turn(dir)
	pass

func _physics_process(delta):
	$Frames.text = str(frame)
	selfState = states.text
	
# Attacks
func s5A():
	if frame == 9:
		create_hitbox(40, 20, 8, 9, 100, 0, 'normal', Vector2(64, 32), 1)
	if frame >= 26:
		return true
