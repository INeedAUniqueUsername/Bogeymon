extends Node2D

var field_pos = 0
var allowJump = true
func _ready():
	pass
func _process(delta):
	if allowJump and jumpReady and Input.is_key_pressed([KEY_Z, KEY_X][field_pos]):
		jump()
var jumpReady = true
func jump():
	$Anim.play("Jump")
	jumpReady = false
	yield(get_tree().create_timer(1.0), "timeout")
	jumpReady = true
