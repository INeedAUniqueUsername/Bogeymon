extends Node2D
var source
var crosshair = null
func _physics_process(delta):
	if source:
		var off = source.global_position - global_position
		
		var x = [0, 0.05,  0.2, 0.350, 0.500, 0.650, 0.800, 0.950, 1]
		var y = [0, -128, -288,  -352,  -384,  -352,  -288,  -128, 0]
		
		for i in range(len(x)):
			$Line2D.set_point_position(i, off * x[i] + Vector2(0, y[i]))
	if crosshair:
		global_position += (crosshair.global_position - global_position) / 30.0
func done():
	$Anim.play("Done")
