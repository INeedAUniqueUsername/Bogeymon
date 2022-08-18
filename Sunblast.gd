extends Node2D
var source
var damage_hp = 10
var sweet = false
var hit = false
func _on_Damage_area_entered(area):
	if 'creature' in area:
		if hit:
			return
		var c = area.creature
		if c == source:
			return
		if area == c.groundArea:
			return
		if !$Ground.overlaps_area(c.groundArea):
			return
		hit = true
		$Sprite/Line.stopped = true
		
		if area.is_in_group("Eyes"):
			sweet = true
		c.take_damage(self)
