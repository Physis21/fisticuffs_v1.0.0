extends Node2D

@onready var pause_menu = $CanvasLayer/PauseMenu
var paused = false

func _ready():
	pass

func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("dev_query"):
		print("John position: %s" %  $JOHN.position)
		print("John global position: %s" %  $JOHN.global_position)
