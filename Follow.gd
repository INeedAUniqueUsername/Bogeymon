extends Node2D

var follow : Node2D
func _physics_process(delta):
	if follow:
		global_position = follow.global_position
