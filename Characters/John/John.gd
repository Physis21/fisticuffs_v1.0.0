class_name John extends fightChar
## First test character.

# Buffers
var wallcling_max : int = 90 ## Maximum number of frames the wallcling can be held.
const WALLCLING_COOLDOWN : int = 30 ## Number of frames during which wallcling is deactivated after walljump.
var wallcling_timer : int = 0 ## Timer for wallcling after a walljump.
# Ground Variables

# Air Variables
var walljumped : bool = false ## True if the character has walljumped while airborne. Becomes false again after they touch the ground.

# Effects
@export_group("Effect scenes")
@export var DashDust: PackedScene
@export var LandingRipple: PackedScene

# Onready Variables
@onready var GroundL : RayCast2D = $Raycasts/GroundL ## (Left) raycast checking for ground.
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
	$HurtBoxes.scale.x = dir.xmult
		
		

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
	set_health(MAXHEALTH)
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
func s5A(): #! always true each frame the attack is active
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
