extends Node2D

var source

signal detonated(explosion)
func detonate():
	var e = load("res://IceBeamExplosion.tscn").instance()
	get_tree().get_nodes_in_group("World")[0].add_child(e)
	e.global_position = $Sprite.global_position
	
	for a in $Area.get_overlapping_areas():
		if 'creature' in a:
			a.creature.take_damage(self)
	
	emit_signal("detonated", e)
	queue_free()
func _process(delta):
	if source.cpu:
		return
	if Input.is_key_pressed(KEY_G):
		detonate()
