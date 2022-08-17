tool
extends Sprite

export(float) var magnitude = 0
export(float) var amount = 0 setget set_amount, get_amount
export(bool) var truncate = false
var prevDigit = 0
var prevAmount = 0
func set_amount(a):
	var adj = fmod(a / pow(10, magnitude), 10)
	#var adj = pow(10, magnitude)
	if truncate:
		var fl = floor(adj)
		if fl != prevDigit:
			var t = Tween.new()
			
			t.interpolate_method(self, "set_rect_amount", prevDigit, fl, 0.4)
			add_child(t)
			t.start()
			t.connect("tween_all_completed", t, "queue_free")
			
			prevDigit = fl
			prevAmount = adj
	else:
		set_rect_amount(adj)
	amount = a
func get_amount(): return amount

func set_rect_amount(amount):
	region_rect.position = Vector2(0, (10 - amount) * region_rect.size.y)
