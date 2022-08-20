extends Node2D
var creatures = []
var index = 0 setget set_index, get_index

onready var sprite = $Y/Sprite

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
var prevKeys = {
	KEY_ENTER: false,
	KEY_ESCAPE: false,
	KEY_SHIFT: false
}
func _process(delta):
	var enter = Input.is_key_pressed(KEY_ENTER)
	var esc = Input.is_key_pressed(KEY_ESCAPE)
	var shift = Input.is_key_pressed(KEY_SHIFT)
	if prevKeys[KEY_ENTER] and !enter:
		select()
	elif Input.is_key_pressed(KEY_DOWN) and !busy:
		next()
	elif Input.is_key_pressed(KEY_UP) and !busy:
		prev()
	elif prevKeys[KEY_ESCAPE] and !esc and allowCancel:
		queue_free()
	elif prevKeys[KEY_SHIFT] and !shift and (!targets.empty() or allowCancel):
		queue_free()
	prevKeys = {
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
	
signal selection_changed()
var targets = []
#var allowSelect = true
func select():
	var c = creatures[index]
	if targets.has(c):
		targets.erase(c)
	else:
		targets.append(c)
	emit_signal("selection_changed")
	#allowSelect = false
	#yield(get_tree().create_timer(0.4), "timeout")
	#allowSelect = true
func cooldown():
	busy = true
	yield(get_tree().create_timer(0.5), "timeout")
	busy = false
