extends Node2D
var source
var damage_hp = 10
func _on_Damage_area_entered(area):
	if 'creature' in area:
		var c = area.creature
		if c == source:
			return
		if !$Ground.overlaps_area(c.groundArea):
			return
		c.take_damage(self)
