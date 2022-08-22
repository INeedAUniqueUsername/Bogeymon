extends Node2D

export(NodePath) var source
var groundArea
var active = true

func _ready():
	if source is NodePath:
		source = get_node(source)
	groundArea = source.groundArea
	$Area.connect("area_entered", self, "on_area_entered")
var damage_hp = 20
var sweet = false
var hit = false
func on_area_entered(area: Area2D):
	if !active:
		return
	if 'creature' in area:
		if hit:
			return
		var c = area.creature
		if c.place.side == source.place.side:
			return
		if !source.groundArea.overlaps_area(c.groundArea):
			return
		if c.fainted:
			return
		if area.is_in_group("Sweet"):
			sweet = true
		hit = true
		c.take_damage(self)
