extends Node
var innovation = 0
func innovate(index):
	return (index + innovation) % 2
func tw(world: Node2D, subject: Node2D, prop: String, start, end, dur: float, trans = Tween.TRANS_LINEAR, easing = 0) -> Tween:
	var t = Tween.new()
	t.interpolate_property(subject, prop, start, end, dur, trans, easing)
	world.add_child(t)
	t.start()
	t.connect("tween_all_completed", t, "queue_free")
	return t
func inc_tw(world: Node2D, subject: Node2D, prop: String, inc, dur: float, trans = Tween.TRANS_LINEAR, easing = 0) -> Tween:
	var t = Tween.new()
	var start = subject.get(prop)
	t.interpolate_property(subject, prop, start, start + inc, dur, trans, easing)
	world.add_child(t)
	t.start()
	t.connect("tween_all_completed", t, "queue_free")
	return t
