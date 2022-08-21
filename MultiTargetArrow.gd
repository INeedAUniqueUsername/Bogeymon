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

var prevKey = {}
var currKey = {
	KEY_ENTER: false,
	KEY_ESCAPE: false,
	KEY_SHIFT: false,
	KEY_UP: false,
	KEY_LEFT: false,
	KEY_DOWN: false,
	KEY_RIGHT: false
}
func update_key():
	for k in currKey:
		prevKey[k] = currKey[k]
		currKey[k] = Input.is_key_pressed(k)
func is_released(k):
	return !currKey[k] and prevKey[k]
func _process(delta):
	update_key()
	if is_released(KEY_ENTER):
		select()
	elif is_released(KEY_DOWN) or is_released(KEY_RIGHT):
		next()
	elif is_released(KEY_UP) or is_released(KEY_LEFT):
		prev()
	elif is_released(KEY_ESCAPE) and allowCancel:
		queue_free()
	elif is_released(KEY_SHIFT) and (!targets.empty() or allowCancel):
		queue_free()
func next():
	set_index(index + 1)
func prev():
	set_index(index - 1)
	
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
