class_name CombatUI extends Control
## Display around stage and fighters during a battle.

var texts : Array[String] = ["Test1", "Test2"]
var healths : Array[float] = [90, 91]
var format_health_txt_display : String = "%.1f / %.1f HP"
var time_counter_val : int ## Current value of time counter. TODO

func _ready() -> void:
	#set_health(0, 1000, 90, 100)
	#set_health(1, 1000, 91, 101)
	time_counter_val = 0
	
func _physics_process(delta: float) -> void:
	$MarginContainer/Label0.text = texts[0]
	$MarginContainer/Label1.text = texts[1]
	time_counter_val = roundi(delta * 60)
	$MarginContainer/TimeCounter.text = "%s" % time_counter_val

func set_health(id : int, max_health: float, _old_health: float, new_health : float):
	print("run set_health from combat ui")
	texts[id] = format_health_txt_display % [new_health, max_health]
	healths[id] = new_health
