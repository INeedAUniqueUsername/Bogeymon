tool
extends Sprite

export(float) var magnitude = 0
export(float) var amount = 0 setget set_amount, get_amount
export(bool) var truncate = false

signal amount_changed()
func set_amount(a):
	if truncate:
		var step = pow(10, magnitude)
		var d = abs(a - amount)
		if d >= step:
			
	
			var am = amount
			
			amount = a
			emit_signal("amount_changed")
			
			var t = Tween.new()
			
			t.interpolate_method(self, "set_amount_direct", am, floor(a / step) * step, fmod(d / step, 10))
			add_child(t)
			t.start()
			t.connect("tween_all_completed", t, "queue_free")
			
			connect("amount_changed", t, "queue_free")
	else:
		amount = a
		set_rect_amount(fmod(a / pow(10, magnitude), 10))
func get_amount(): return amount
func set_amount_direct(a):
	#amount = a
	set_rect_amount(fmod(a / pow(10, magnitude), 10))

func set_rect_amount(amount):
	region_rect.position = Vector2(0, (10 - amount) * region_rect.size.y)
