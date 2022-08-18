extends Node2D

var source

var damage_hp = 15

var hit = false
signal detonated(explosion)
func detonate():
	var e = load("res://IceBeamExplosion.tscn").instance()
	get_tree().get_nodes_in_group("World")[0].add_child(e)
	e.global_position = $Sprite.global_position
	
	for a in $Area.get_overlapping_areas():
		if 'creature' in a:
			a.creature.take_damage(self)
			hit = true
	emit_signal("detonated", e)
	queue_free()
func _process(delta):
	if source.cpu:
		return
	if Input.is_key_pressed(KEY_ENTER):
		detonate()
func nop(delta):
	
	var d = 256
	if Input.is_key_pressed(KEY_UP):
		position.y -= d * delta
	if Input.is_key_pressed(KEY_DOWN):
		position.y += d * delta
