extends Node2D

func _physics_process(delta):
	var d = 256
	if Input.is_key_pressed(KEY_LEFT):
		position.x -= d * delta
	if Input.is_key_pressed(KEY_UP):
		position.y -= d * delta
	if Input.is_key_pressed(KEY_RIGHT):
		position.x += d * delta
	if Input.is_key_pressed(KEY_DOWN):
		position.y += d * delta
