class_name HealthBar extends ProgressBar
## ProgressBar display of character health values.

@onready var timer = $Timer ## Timer counting when the red health dissapears.
@onready var damage_bar = $DamageBar ## Displays temporary red health.

#@export var player_nb = 2

signal health_zero ## Signal the health has reached 0.

var health = 0 : set = set_health ## Current health value.

## Sets progress bar value according to [new_health],
## and emits the [health_zero] signal if health reaches zero.
func set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	if health <= 0:
		init_health(max_value)
		health_zero.emit()
	elif health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

## Set the initial health for a full health bar.
func init_health(initial_health):
	health = initial_health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

## Flip the fill mode of both Health and Damage bars.
func flip_fill_mode(yn: bool):
	if yn == false:
		self.fill_mode = 0
		damage_bar.fill_mode = 0
	else:
		self.fill_mode = 1
		damage_bar.fill_mode = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	damage_bar.value = health
