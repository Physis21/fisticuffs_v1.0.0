extends Area2D

@onready var parent = get_parent()
@export var width = 300
@export var height = 400
@export var damage = 50
@onready var vertical_projection = 0
@onready var horizontal_projection = 100
@export var duration = 1500
@export var hitlag_modifier = 1
@export var type = 'normal'
@onready var hitbox = get_node("HitboxShape")
@onready var parentState = get_parent().selfState
var framez = 0.0
var player_list = []  # list of player characters this hitbox cannot collide with

func set_parameters(w,h,dam,dur,hp,vp,t,p,hit,parent=get_parent()):
	self.position = Vector2(0,0)
	player_list.append(parent)
	player_list.append(self)  # just in case
	width = w
	height = h
	damage = dam
	duration = dur
	vertical_projection = vp
	horizontal_projection = hp
	type = t
	hitlag_modifier = hit
	self.position = p
	update_extents()
	#connect("area_entered", self, "Hitbox_collide")
	set_physics_process(true)
	
	pass
	
func update_extents():
	hitbox.shape.extents = Vector2(width, height)
	
func _ready() -> void:
	hitbox.shape = RectangleShape2D.new()  # double check
	set_physics_process(false)  # don't want hitbox to do anything before this func is called
	pass

func _physics_process(delta: float):
	if framez < duration:
		framez += 1
	elif framez == duration:
		Engine.time_scale = 1
		queue_free()  # this waits for the current code to finish execution before deletion
		return
	if get_parent().selfState != parentState:  # check if we are still attacking
		Engine.time_scale = 1
		queue_free()
		return 
