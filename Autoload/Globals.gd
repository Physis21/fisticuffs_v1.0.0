extends Node

func hitstun(mod, duration):
	# mod is the hitlag of the attack
	Engine.time_scale = mod / 50
	print("Engine time scale = %s" % Engine.time_scale)
	await get_tree().create_timer(duration * Engine.time_scale).timeout
	Engine.time_scale = 1
