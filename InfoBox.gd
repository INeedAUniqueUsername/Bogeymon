extends TextureRect
onready var nameLabel = $Name
onready var hpRoller = $HpRoller
onready var statusLabel = $Status

var creature


func shake():
	var p = get_global_rect().position
	for i in [16, -16, 16, -16, 8, -8, 8, -8, 4, -4, 4, -4, 2, -2, 2, -2, 1, -1, 1, -1, 0]:
		set_global_position(p + Vector2(i * 2, 0))
		yield(get_tree().create_timer(0.04), "timeout")
	set_global_position(p)
