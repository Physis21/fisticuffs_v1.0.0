class_name TestStage extends Node2D
## Starter script for a stage.

@onready var combat_ui = $CanvasLayer/CombatUi ## Combat UI in canvas layer.
@onready var pause_menu = $CanvasLayer/PauseMenu ## Pause menu in canvas layer.
var paused : bool = false ## Check whether menu is paused or not.
var players_group ## Array containing all players.

signal init_combat_ui(_players_group : Array) ## Signal to combat UI to initialize the game

func _ready():
	# ! The combat UI should _enter_tree() after the characters
	players_group = get_tree().get_nodes_in_group("Players")
	init_combat_ui.connect(combat_ui.start_game)
	init_combat_ui.emit(players_group)

func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("dev_query"):
		print("John position: %s" %  $JOHN0.position)
		print("John global position: %s" %  $JOHN0.global_position)
		$JOHN0.health -= 10
		print("Hurt John by 10 HP")
		

## For signal debugging purposes
func _print_signal(id, max_health, old_health, new_health):
	print(id, max_health, old_health, new_health)
	
