extends Node2D
var creatures = []
var index = 0 setget set_index, get_index

var tween = null
func set_index(i):
	if !creatures or creatures.empty():
		index = -1
		return
	i = (i + len(creatures)) % len(creatures)
	index = i
	print("creatures: " + str(len(creatures)))
	print("index: " + str(i))
	print("creatures: " + str(creatures[i]))
	
	if is_instance_valid(tween):
		tween.queue_free()
		tween = null
		
	tween = Tween.new()
	tween.interpolate_property(self, "global_position", global_position, creatures[i].global_position, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	add_child(tween)
	tween.start()
func get_index(): return index

var allowCancel = true
var target = null
func _ready():
	set_index(0)

var busy = false

var prevKey = {
	KEY_ENTER: false,
	KEY_ESCAPE: false,
	KEY_SHIFT: false
}
func _process(delta):
	var enter = Input.is_key_pressed(KEY_ENTER)
	var esc = Input.is_key_pressed(KEY_ESCAPE)
	var shift = Input.is_key_pressed(KEY_SHIFT)
	if !enter and prevKey[KEY_ENTER]:
		select()
	elif Input.is_key_pressed(KEY_DOWN) and !busy:
		next()
	elif Input.is_key_pressed(KEY_UP) and !busy:
		prev()
	elif !esc and prevKey[KEY_ESCAPE] and allowCancel:
		queue_free()
	elif !shift and prevKey[KEY_SHIFT] and allowCancel:
		queue_free()
	prevKey = {
		KEY_ENTER: enter,
		KEY_ESCAPE: esc,
		KEY_SHIFT: shift
	}
func next():
	set_index(index + 1)
	cooldown()
func prev():
	set_index(index - 1)
	cooldown()
func select():
	target = creatures[index]
	queue_free()
func cooldown():
	busy = true
	yield(get_tree().create_timer(0.5), "timeout")
	busy = false
