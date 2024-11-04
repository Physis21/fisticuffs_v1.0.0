extends CharacterBody2D

# from fox stats

# Ground Variables

# Air Variables
var fastfall = false
var jump_squat = 5
var lag_frames = 0
var landing_frames = 0

# Onready Variables
@onready var GroundL = $Raycasts/GroundL
@onready var GroundR = $Raycasts/GroundR
@onready var states = $State
@onready var anim = $Sprite/AnimationPlayer

# JOHN's main attributes
const WALKSPEED = 200 # 200.0 * 2
const DASHSPEED = 400 # 390 * 2
const GRAVITY = 1800 * 2
const JUMPFORCE = 700 # 500 * 2
const MAXJUMPFORCE = 1000 # 1000 * 2
const MAXAIRSPEED = 300 * 2
const AIR_ACCEL = 25 * 2
const FALLSPEED = 40 # 60 * 2
const FALLINGSPEED = 600 # 900 * 2
const MAXFALLSPEED = 600 # 900 * 2
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
		$Sprite.position.x = -7
	else:  # face left
		dir = -1
		$Sprite.position.x = 7
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
