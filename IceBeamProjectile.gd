extends Node2D

onready var groundArea = $Area
var source

var damage_hp = 20

var hit = false

var hitCreatures = []
signal detonated(explosion)
func detonate():
	var e = load("res://IceBeamExplosion.tscn").instance()
	get_tree().get_nodes_in_group("World")[0].add_child(e)
	e.global_position = $Sprite.global_position
	
	for a in $Area.get_overlapping_areas():
		if !('creature' in a):
			continue
		var c = a.creature
		if hitCreatures.has(c):
			continue
		hitCreatures.append(c)
		c.take_damage(self)
		hit = true
	emit_signal("detonated", e)
	queue_free()
	
export(bool) var moving = false
func arm():
	yield(get_tree().create_timer(0.2), "timeout")
	armed = true
var armed = true
func _process(delta):
	if source.cpu:
		return
	if Input.is_key_pressed(KEY_ENTER) and armed and moving:
		detonate()
func nop(delta):
	
	var d = 256
	if Input.is_key_pressed(KEY_UP):
		position.y -= d * delta
	if Input.is_key_pressed(KEY_DOWN):
		position.y += d * delta
