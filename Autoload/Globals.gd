extends Node

# Functions

func clampf_abs_zero(x):
	if x > 0:
		return clampf(x, 0, x)
	elif x < 0:
		return clampf(x, x, 0)

func hitstun(mod, duration):
	# mod is the hitlag of the attack
	Engine.time_scale = mod / 50
	print("Engine time scale = %s" % Engine.time_scale)
	await get_tree().create_timer(duration * Engine.time_scale).timeout
	Engine.time_scale = 1
