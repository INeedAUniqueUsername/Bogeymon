extends Node2D

onready var digits = [$D4, $D3, $D2, $D1, $D0]

signal roller_stopped()

var amount = 0
var currentTween = null
func stop_current_tween():
	if is_instance_valid(currentTween):
		currentTween.queue_free()
		currentTween = null
		
var spin_rate = 10.0
func set_spin_rate(r):
	spin_rate = float(r)
func set_amount(a, spin_rate = null):
	stop_current_tween()
	
	a = max(a, 0)
	
	if !spin_rate:
		spin_rate = self.spin_rate
	
	var t = Tween.new()
	add_child(t)
	t.interpolate_method(self, "set_amount_inter", apparent_amount, a, abs(a - apparent_amount) / spin_rate)
	t.start()
	t.connect("tween_all_completed", t, "queue_free")
	t.connect("tween_all_completed", self, "emit_signal", ["roller_stopped"])
	currentTween = t
	amount = a
	
var apparent_amount = 0
func set_amount_inter(a):
	apparent_amount = a
	for c in digits:
		c.set_amount(a)
