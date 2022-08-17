extends Node2D


var source
func _on_Area_area_entered(area):
	if 'creature' in area:
		var c = area.creature
		if c == source:
			return
		if !$Ground.overlaps_area(c.groundArea):
			return
		c.take_damage(self)
		queue_free()
