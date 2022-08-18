extends Node2D

var sweet = false
var damage_hp = 15
var source
var hit = false
func _on_Area_area_entered(area):
	if 'creature' in area:
		if hit:
			return
		var c = area.creature
		if c == source:
			return
		if !$Ground.overlaps_area(c.groundArea):
			return
		hit = true
		if area.is_in_group("Sweet"):
			sweet = true
			
		c.take_damage(self)
		queue_free()
