extends Node2D

onready var groundArea = $Ground

var sweet = false
var damage_hp = 20
var source
var hit = false
func _on_Area_area_entered(area):
	if 'creature' in area:
		if hit:
			return
		var c = area.creature
		if c.place.side == source.place.side:
			return
		if c.fainted:
			return
			
		if !$Ground.overlaps_area(c.groundArea):
			return
		hit = true
		if area.is_in_group("Sweet"):
			sweet = true
			
		c.take_damage(self)
		queue_free()
