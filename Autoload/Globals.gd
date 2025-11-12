extends Node

# Functions

func hitstun(mod, duration):
	# mod is the hitlag of the attack
	Engine.time_scale = mod / 50
	print("Engine time scale = %s" % Engine.time_scale)
	await get_tree().create_timer(duration * Engine.time_scale).timeout
	Engine.time_scale = 1
	
func get_dir_input(id): # Apply SOCD
	var output = Direction.new()
	if Input.is_action_pressed("right_%s" % id) and Input.is_action_pressed("left_%s" % id):
		output.turn('neutral')
	elif Input.is_action_pressed("right_%s" % id):
		output.turn('right')
	elif Input.is_action_pressed("left_%s" % id):
		output.turn('left')
	else:
		output.turn('neutral')
	return output
		
# Classes

class Direction:
	var val = 'right'
	var flip = false
	func turn(turnVal : String):
		if turnVal == 'right':
			val = 'right'
			flip = false
		elif turnVal == 'left':
			val = 'left'
			flip = true
		
