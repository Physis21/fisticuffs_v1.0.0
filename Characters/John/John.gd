extends CharacterBody2D

# from fox stats

# Ground Variables

# Air Variables
var fastfall : bool = false
var jump_squat : int = 5
var lag_frames:  int = 0
var landing_frames : int = 3
var previous_mov_input : String = 'neutral'

# Onready Variables
@onready var GroundL = $Raycasts/GroundL
@onready var GroundR = $Raycasts/GroundR
@onready var states = $State
@onready var anim = $Sprite/AnimationPlayer

# JOHN's main attributes
const WALKSPEED = 200 # 200.0 * 2
const DASHSPEED = 400 # 390 * 2
const GRAVITY = 1800 * 2
const JUMPFORCE = 900 # 500 * 2
const MAXJUMPFORCE = 1200 # 1000 * 2
const MAXAIRSPEED = 300 # 300 * 2
const AIR_ACCEL = 10
const FALLSPEED = 60 # 60 * 2
const FALLINGSPEED = 800 # 900 * 2
const MAXFALLSPEED = 800 # 900 * 2
const TRACTION = 200 * 2

@onready var state = $State

var frame = 0
func updateframes(delta):
	frame += 1

func turn(direction):
	# flipped compared to tutorial because his fox faces left
	var dir = 0
	if direction:  # face right
		dir = +1
	else:  # face left
		dir = -1
	$Sprite.set_flip_h(direction)

func _frame():
	frame = 0
	
func play_animation(animation_name):
	anim.play(animation_name)

# called when the node enters the scene_tree for the first time
func _ready():
	pass

func _physics_process(delta):
	$Frames.text = str(frame)
