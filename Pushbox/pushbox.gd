class_name Pushbox extends Area2D
### Implements collision between player characters (not floors and walls).

@export var width : float = 300 ## Width of [CollisionShape2D] and [ShapeCast2D] rectangle.
@export var height : float = 400 ## Height of [CollisionShape2D] and [ShapeCast2D] rectangle.
@onready var pushbox : CollisionShape2D = get_node("PushboxShape")
@onready var shapecast : ShapeCast2D = get_node("ShapeCast2D")
@onready var parentState : String = get_parent().selfState ## State of character (not that of its state machine).

var right_side_xpos : float = self.global_position.x + width ## X position of [ShapeCast2D] right side.
var left_side_xpos : float = self.global_position.x - width ## X position of [ShapeCast2D] left side.
var player_list : Array = []  ## List of player characters this pushox cannot collide with.

func _ready() -> void:
	pushbox.shape = RectangleShape2D.new()  # double check
	shapecast.shape = RectangleShape2D.new()
	set_physics_process(false)  # don't want pushbox to do anything before this func is called

func _physics_process(_delta: float) -> void:
	update_side_pos()
	if shapecast.is_colliding():
		var area = shapecast.get_collider(0)
		pushbox_overlap(area)

## Sets pushbox width, height, position.
func set_parameters(w : float, h : float, p : Vector2, parent=get_parent()):
	player_list.append(parent)
	player_list.append(self)  # just in case
	self.position = Vector2(0,0)
	width = w
	height = h
	self.position = p
	update_extents()
	#self.area_entered.connect(pushbox_overlap) # Manual connecting
	set_physics_process(true)

## Implements pushing of characters with respect to the shapecast boundaries
func pushbox_overlap(area : Area2D) -> void:
	var body = area.get_parent()
	if !(body in player_list):
		var area_right_side_xpos = area.global_position.x + width
		var area_left_side_xpos = area.global_position.x - width
		var right_gap = abs(right_side_xpos - area_left_side_xpos)
		var left_gap = abs(left_side_xpos - area_right_side_xpos)
		var adjustement
		if right_gap < left_gap:
			adjustement = -right_gap
		elif right_gap > left_gap:
			adjustement = left_gap
		else: # parent is basically on top of body, exactly at center
			if get_parent().dir.val == "left":
				adjustement = -right_gap
			else:
				adjustement = left_gap
		# Apply weight
		var parent_weight = get_parent().weight
		var weighted_adjustement = adjustement * parent_weight / (body.weight + parent_weight)
		get_parent().position.x += adjustement - weighted_adjustement
		body.position.x -= weighted_adjustement
		

func update_extents():
	pushbox.shape.extents = Vector2(width, height)
	shapecast.shape.extents = Vector2(width, height)

func update_side_pos():
	right_side_xpos = self.global_position.x + width
	left_side_xpos = self.global_position.x - width
