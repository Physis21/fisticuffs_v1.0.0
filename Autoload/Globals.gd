extends Node
## Contains functions used throughout the project

## Clamp a float absolute value between its max absolute value and 0
func clampf_abs_zero(x: float) -> float:
	if x > 0:
		return clampf(x, 0, x)
	elif x < 0:
		return clampf(x, x, 0)
	else:
		return 0.

## Apply engine time slowing during hitstun
func hitstun_slowdown(hitlag : int) -> void:
	var duration : float = float(hitlag) / 60
	Engine.time_scale = float(hitlag) / 50
	print("Engine time scale = %f" % Engine.time_scale)
	await get_tree().create_timer(duration * Engine.time_scale).timeout
	Engine.time_scale = 1
