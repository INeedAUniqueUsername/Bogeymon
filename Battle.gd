extends Node2D
var creatures = []
const Place = preload("res://Common.gd").Place


onready var boxes = [$UI/LeftA, $UI/LeftB, $UI/RightA, $UI/RightB]
func _ready():	
	var places = {
		$LeftA: Place.new(0, 0, $LeftA),
		$LeftB: Place.new(0, 1, $LeftB),
		$RightA: Place.new(1, 0, $RightA),
		$RightB: Place.new(1, 1, $RightB)
	}
	for holder in get_tree().get_nodes_in_group("Place"):
		if holder.get_child_count() == 0:
			creatures.append(null)
			continue
		var c = holder.get_child(0)
		creatures.append(c)
		c.place = places[holder]
	$UI/CreatureMenu/Attack.connect("pressed", self, "show_move_list")
	var b = $UI/CreatureMenu/MoveList.get_children()
	for i in range(len(b)):
		b[i].connect("pressed", self, "choose_move", [i])
	creature = creatures[0]
	
	for i in range(4):
		var c = creatures[i]
		if c:
			c.connect("hp_changed", self, "creature_hp_changed", [c])
			var box = boxes[i]
			box.get_node("Name").text = creature.species
			
	while true:
		for c in creatures:
			if !c:
				continue
			if c.cpu:
				continue
			creature = c
			update_menu()
			yield(self, "creature_done")
			
func creature_hp_changed(c):
	boxes[creatures.find(c)].get_node("HpBar").set_amount(c.hp, c.hp_max)
			
signal creature_done()
func show_move_list():
	var m = $UI/CreatureMenu/MoveList
	if m.visible:
		m.hide()
	else:
		m.show()
var creature = null
func update_menu():
	var cm = $UI/CreatureMenu
	cm.show()
	cm.set_global_position(creature.global_position)
	$UI/CreatureMenu/MoveList.hide()
	var b = $UI/CreatureMenu/MoveList.get_children()
	for i in range(len(b)):
		var button = b[i]
		var m = creature.moves[i]
		if m != creature.Moves.None and creature.pp[m] > 0:
			button.get_node("Label").text = creature.NameTable[m]
			button.disabled = false
			continue
		
		button.get_node("Label").text = ""
		button.disabled = true
func choose_move(i):
	$UI/CreatureMenu.hide()
	var Moves = creature.Moves
	var m = creature.moves[i]
	
	var msg = "%s used %s" % [creature.species, creature.NameTable[m]]
	match m:
		Moves.SnapFreeze:
			
			yield(showMessage(msg), "completed")
			yield(creature.snap_freeze(), "completed")
			hideMessage()
		Moves.BrickThrow:
			
			
			yield(showMessage(msg), "completed")
			yield(creature.brick_throw(), "completed")
			hideMessage()
	emit_signal("creature_done")
	
var dialogVisible = false
func showMessage(text):
	var dt = $UI/Dialog/Text
	if !dialogVisible:
		dt.text = text
		$UI/Dialog/Anim.play("Show")
		yield($UI/Dialog/Anim, "animation_finished")
	
	dialogVisible = true
	
	var t = Tween.new()
	t.interpolate_property(dt, "visible_characters", 0, len(text), len(text) / 24.0)
	add_child(t)
	t.connect("tween_all_completed", t, "queue_free")
	t.start()
	yield(t, "tween_all_completed")
func hideMessage():
	$UI/Dialog/Anim.play("Hide")
	yield($UI/Dialog/Anim, "animation_finished")
	dialogVisible = false
