class_name fightChar extends CharacterBody2D
## Base class of all fighting characters.

signal health_update(id, max_health, old_health, new_health) ## Character health is updated

# Character attributes to set.
@export_group("Constant attributes")
@export var MAXHEALTH : float ## Maximum health.
@export var WEIGHT : float ## Weight of the character (used to compute knockback values).
@export var WALKSPEED : float ## Walking speed (px/frame).
@export var RUNSPEED : float ## Running speed (px/frame).
@export var DASHFRAMES : int ## Duration (in frames) of the dash animation.
@export var JUMPFORCE : int ## Vertical speed induced by short hop (px/frame).
@export var MAXJUMPFORCE : float ## Vertical speed induced by jump (px/frame).
@export var MAXAIRSPEED : float ## Maximum horizontal air speed.
@export var AIR_ACCEL : float ## Maximum horizontal air acceleration.
@export var FALLACCEL : float ## Falling acceleration (gravity) of the character.
@export var FALLINGSPEED : float ## Falling speed
@export var MAXFALLSPEED : float ## Fastfall falling speed
@export var TRACTION : float ## Decelleration due to grounded traction (px/frame²)
@export var TRACTION_ATTACK : float ## Traction due to grounded attacks (px/frame²)

# Global variables
var frame : int = 0 ## Frame counter. Is added 1 each _physics_process().
var dir : Movement.CharDirection  = Movement.CharDirection.new() ## Direction of character.

# Variable attributes
@export_group("Variable attributes")
@export var id : int = 0 ## Character identifier, in order to differentiate simultaneous characters.
@export var percentage : float = 20 ## The higher the percentage, the further the character is knocked back after an attack.
@export var health : float = MAXHEALTH : set = set_health ## Character health, starts at maximum by default.
@export var stocks : int = 3 ## Number of times the character must be KO'ed to.
var freezeframes : int = 0 ## Number of frames the character is frozen. Is updated when struck by hitbox.

# Knockback
var hdecay : float ## Knockback horizontal decay.
var vdecay : float ## Knockback vertical decay.
var knockback : float ## Knockback value.
var hitstun : int ## Number of frames the character is stuck in hitstun.
var connected: bool ## Checks whether an attack has connected.

# Ground Variables

# Air Variables
var fastfall : bool = false ## True if the character has fastfalled while airborne. Becomes false again after they touch the ground.
@export var jump_squat : int = 5 ## Number of frames of jump squat.
var lag_frames:  int = 0 ## Number of lag frames after an action.
var landing_frames : int = 3 ## Number of landing lag frames.
var previous_mov_input = Movement.InptDirection.new() ## Previous movement input.

@export_group("Collision")
@export var pushbox: PackedScene ## Pushbox.
@export var hitbox: PackedScene ## Character hitboxes.
var selfState : String ## State of the character.

# Temporary variables
var hit_pause : int = 0 ## Counter for hit pause duration.
var hit_pause_dur : int = 0 ## Duration of the hit pause.
var temp_pos = Vector2(0,0) ## Stored position of character during hit pause.
var temp_vel = Vector2(0,0) ## Stored velocity of character during hit pause.

func set_health(new_health : float) -> void:
	health_update.emit(id, MAXHEALTH, health, new_health)
	health = new_health
	pass
