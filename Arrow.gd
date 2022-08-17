extends Node2D
var creatures = []
var index = 0 setget set_index, get_index
func set_index(i):
	if creatures.empty():
		index = -1
		return
	i = (i + len(creatures)) % len(creatures)
	index = i
	global_position = creatures[i].global_position
func get_index(): return index

var allowCancel = true
var target = null
func _ready():
	set_index(0)

func _process(delta):
	if Input.is_key_pressed(KEY_ENTER):
		target = creatures[index]
		done()
	elif Input.is_key_pressed(KEY_DOWN):
		set_index(index + 1)
	elif Input.is_key_pressed(KEY_UP):
		set_index(index - 1)
	elif Input.is_key_pressed(KEY_ESCAPE) and allowCancel:
		done()

signal done()
func done():
	emit_signal("done")
	queue_free()
