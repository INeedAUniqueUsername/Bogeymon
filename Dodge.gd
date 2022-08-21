extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var creature : Node2D
# Called when the node enters the scene tree for the first time.
func _ready():
	dodge()
func dodge():
	if randi()%2 == 0:
		yield(creature.walk(creature.global_position + polar2cartesian(rand_range(64, 128), 2 * PI * randf()), self), "completed")
	else:
		yield(get_tree().create_timer(0.2), "timeout")
	dodge()
