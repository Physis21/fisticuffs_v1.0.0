class_name StageCamera extends Camera2D
## Script for camera behavior in stages.

@onready var p1 = get_tree().get_first_node_in_group("Players") ## First player.

func _ready() -> void:
	pass

## At the moment, the camera is centered on the first player.
func _physics_process(_delta) -> void:
	self.position = p1.position
