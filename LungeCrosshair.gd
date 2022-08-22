extends Node2D

var source
var target
var slither = 0

signal lunged()
func _ready():
	yield($Anim, "animation_finished")
	lunge()

func lunge():
	locked = true
	emit_signal("lunged")
var locked = false
onready var direction = source.get_forward()

var prevEnter = false
func _physics_process(delta):
	if locked:
		return
	if source.cpu:
		var off = (target.global_position - global_position)
		if off.length() < 64:
			lunge()
		approach(delta, off.normalized())
		return
		
	var enter = Input.is_key_pressed(KEY_ENTER)
	if !enter and prevEnter:
		lunge()
		return
	prevEnter = enter
		
	var dest = Vector2(0, 0)
	var dir = {
		KEY_UP: Vector2(0, -1),
		KEY_RIGHT: Vector2(1, 0),
		KEY_DOWN: Vector2(0, 1),
		KEY_LEFT: Vector2(-1, 0),
	}
	
	for k in dir:
		if Input.is_key_pressed(k):
			dest += dir[k]
	#if direction.length_squared() != 0:
	if dest.length_squared() != 0:
		approach(delta, dest)
func approach(delta: float, dest: Vector2):
	dest = dest.normalized()
	var deltaAngle = atan2(dest.y, dest.x) - atan2(direction.y, direction.x)
	deltaAngle = atan2(sin(deltaAngle), cos(deltaAngle))
	direction = direction.rotated(sign(deltaAngle) * min(abs(deltaAngle), 2 * PI * delta))
	slither += delta
	global_position += delta * (64+256) * direction.rotated(sin(slither * 2 * PI / 1) * 0.66 * PI / 2)
