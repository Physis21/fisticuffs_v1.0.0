extends Area2D

@export var width = 300
@export var height = 400
@onready var pushbox = get_node("PushboxShape")
@onready var parentState = get_parent().selfState

var player_list = []  # list of player characters this pushox cannot collide with

func _ready() -> void:
	pushbox.shape = RectangleShape2D.new()  # double check
	set_physics_process(false)  # don't want pushbox to do anything before this func is called

func _physics_process(_delta: float) -> void:
	pass

func set_parameters(w, h, p, parent=get_parent()):
	self.position = Vector2(0,0)
	width = w
	height = h
	update_extents()
	self.position = p
	set_physics_process(true)

func update_extents():
	pushbox.shape.extents = Vector2(width, height)
