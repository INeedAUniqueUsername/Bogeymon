extends Node
var innovation = null
func innovate(index = 0):
	if innovation == null:
		innovation = 0
	return (index + innovation) % 2
func get_version_name():
	return ["Bold", "Brash"][innovation]
func tw_new(world: Node2D) -> Tween:
	var t := Tween.new()
	world.add_child(t)
	t.start()
	t.connect("tween_all_completed", t, "queue_free")
	return t
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

func vector_to(start: Node2D, end: Node2D):
	return end.global_position - start.global_position


var campaign = true
var player_team : Array = []

var opponent_team : Array = [
	preload("res://Stoneborn.tscn").instance(),
	preload("res://Stoneborn.tscn").instance(),
	preload("res://Stoneborn.tscn").instance(),
	preload("res://Stoneborn.tscn").instance(),
	preload("res://Stoneborn.tscn").instance(),
	preload("res://Stoneborn.tscn").instance(),
]

var levelTable = generateLevelTable()
var levelCount
func generateLevelTable():
	var stoneborn = preload("res://Stoneborn.tscn")
	var scarabold = preload("res://Scarabold.tscn")
	var crowscare = preload("res://Crowscare.tscn")
	var r = [
		[stoneborn.instance(), stoneborn.instance(), stoneborn.instance()],
		[stoneborn.instance(), scarabold.instance(), stoneborn.instance()],
		[stoneborn.instance(), scarabold.instance(), scarabold.instance(), stoneborn.instance()],
		[scarabold.instance(), crowscare.instance(), scarabold.instance(), stoneborn.instance(), stoneborn.instance()],
		[stoneborn.instance(), crowscare.instance(), crowscare.instance(), scarabold.instance(), stoneborn.instance(), scarabold.instance()],
		[crowscare.instance(), crowscare.instance(), stoneborn.instance(), scarabold.instance(), stoneborn.instance(), scarabold.instance()]
	]
	levelCount = len(r)
	return r

var level = 0

func evac(c):
	var p = c.get_parent()
	if p:
		p.remove_child(c)
func evacuate_creatures():
	for c in player_team:
		evac(c)
	for c in opponent_team:
		evac(c)

var pvp = false
