tool
extends Line2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


export(Vector2) var start setget set_start, get_start
func set_start(p):
	set_point_position(0, p)
func get_start(): return get_point_position(0)

export(Vector2) var end setget set_end, get_end
func set_end(p):
	set_point_position(1, p)
func get_end(): return get_point_position(1)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
