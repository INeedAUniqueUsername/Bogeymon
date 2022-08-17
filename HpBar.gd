extends Sprite

onready var width = region_rect.size.x

func set_amount(hp, hp_max):
	
	var hp_prev = hp_max * region_rect.size.x / width
	
	var amount = 1.0 * hp / hp_max
	
	var t = Tween.new()
	t.interpolate_property(self, "region_rect:size:x", region_rect.size.x, region_rect.size.x * amount, 1.0)
	add_child(t)
	t.start()
	t.connect("tween_all_completed", t, "queue_free")
