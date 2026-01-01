class_name CombatUI extends Control
## Display around stage and fighters during a battle.

@onready var seconds_timer : Timer = $SecondsTimer ## Timer updating time counter at each second.
@onready var health_bar_right : HealthBar = $HealthBarRight ## Right-hand health bar. Temporary if I enable >2 players.
@onready var health_bar_left : HealthBar = $HealthBarLeft ## Left-hand health bar. Temporary if I enable >2 players.

var health_texts : Array[String] = ["Test1", "Test2"] ## Text display of health.
var healths : Array[float] = [90, 91] ## Displayed health values.
var format_health_txt_display : String = "%.1f / %.1f HP" ## Formatter for [health_texts].
var time_counter_val : int = 0 ## Current value of time counter.

func _ready() -> void:
	time_counter_val = 0
	seconds_timer.start()
	health_bar_left.flip_fill_mode(true)
	
func _physics_process(_delta: float) -> void:
	$MarginContainer/HealthTxt0.text = health_texts[0]
	$MarginContainer/HealthTxt1.text = health_texts[1]
	$MarginContainer/TimeCounter.text = "%s" % time_counter_val

## Set health for text and health bar display.
func set_health(id : int, max_health: float, _old_health: float, new_health : float) -> void:
	print("run set_health from combat ui")
	health_texts[id] = format_health_txt_display % [new_health, max_health]
	healths[id] = new_health
	if id == 1:
		health_bar_right.set_health(new_health)
	if id == 0:
		health_bar_left.set_health(new_health)

## Initialize combat ui using player information 
func start_game(players_group : Array) -> void:
	for player : fightChar in players_group:
		player.health_update.connect(set_health)
		player.health = player.MAXHEALTH
		if player.id == 1:
			$CharNames/Name1.text = player.char_name
			health_bar_right.init_health(player.MAXHEALTH)
		if player.id == 0:
			$CharNames/Name0.text = player.char_name
			health_bar_left.init_health(player.MAXHEALTH)

func _on_seconds_timer_timeout() -> void:
	time_counter_val += 1
	pass # Replace with function body.
