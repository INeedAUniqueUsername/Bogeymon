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
	var buttons = $UI/CreatureMenu/MoveList.get_children()
	for i in range(4):
		var b = buttons[i]
		b.connect("pressed", self, "choose_move", [i])
		b.connect("mouse_entered", self, "show_move_desc", [i])
		b.connect("mouse_exited", $UI/CreatureMenu/MoveList/Description, "hide")
	for i in range(4):
		var c = creatures[i]
		if c:
			c.connect("hp_changed", self, "creature_hp_changed", [c])
			c.connect("damaged", self, "creature_damaged", [c])
			var box = boxes[i]
			box.nameLabel.text = c.species
			box.hpRoller.set_amount(c.hp)
		boxes[i].hpRoller.connect("roller_stopped", self, "on_roller_stopped", [i])
	while true:
		for c in creatures:
			if !c:
				continue
			if c.cpu:
				continue
			creature = c
			update_menu()
			yield(self, "creature_done")
func on_roller_stopped(i):
	var box = boxes[i]
	if !box.hpRoller.amount == 0:
		return
	box.statusLabel.text = "Knocked out!"
func creature_hp_changed(c):
	boxes[creatures.find(c)].hpRoller.set_amount(c.hp)
func creature_damaged(proj, c):
	for i in [16, -16, 16, -16, 8, -8, 8, -8, 4, -4, 4, -4, 2, -2, 2, -2, 1, -1, 1, -1, 0]:
		$Camera2D.position = Vector2(0, i * 2)
		yield(get_tree().create_timer(0.04), "timeout")
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
	for i in range(4):
		var button = b[i]
		var m = creature.moves[i]
		if m != creature.Moves.None and creature.pp[m] > 0:
			button.get_node("Label").text = creature.NameTable[m]
			button.disabled = false
			continue
		
		button.get_node("Label").text = ""
		button.disabled = true
		
func request_target(targets, allowCancel = true):
	var arrow = load("res://TargetArrow.tscn").instance()
	arrow.creatures = targets
	arrow.allowCancel = allowCancel
	arrow.global_position = creature.global_position
	add_child(arrow)
	
	
	for c in targets:
		var ch = load("res://TempCrosshair.tscn").instance()
		ch.global_position = c.global_position
		add_child(ch)
		arrow.connect("tree_exiting", ch.get_node("Anim"), "play", ["Disappear"])
	$UI/SelectTarget.show()
	yield(arrow, "tree_exiting")
	$UI/SelectTarget.hide()
	return arrow.target
	
func get_opposing_creatures():
	var result = []
	for c in creatures:
		if !c:
			continue
		if c.place.side == creature.place.side:
			continue
		print("opponent:" + str(c))
		result.append(c)
	return result
func show_move_desc(i):
	
	var Moves = creature.Moves
	var m = creature.moves[i]
	if m == 0:
		return
	var desc = $UI/CreatureMenu/MoveList/Description
	desc.get_node("Label").text = creature.DescTable[m]
	desc.show()
func choose_move(i):
	
	$UI/CreatureMenu.hide()
	if yield(handle_move(i), "completed"):
		return
	
	$UI/CreatureMenu.show()
func handle_move(i):
	
	var Moves = creature.Moves
	var m = creature.moves[i]
	
	
	var msg = "%s used %s!" % [creature.species, creature.NameTable[m].to_upper()]
	
	match m:
		Moves.SnapFreeze:
			var target = yield(request_target(get_opposing_creatures(), true), "completed")
			if !target:
				return
				
			yield(showMessage(msg), "completed")
			yield(creature.snap_freeze(target), "completed")
		Moves.BrickThrow:
			var target = yield(request_target(get_opposing_creatures(), true), "completed")
			if !target:
				return
				
			yield(showMessage(msg), "completed")
			yield(creature.brick_throw(target), "completed")
		Moves.Sunblast:
			yield(showMessage(msg), "completed")
			yield(creature.sunblast(), "completed")
		_:
			assert(false)
	hideMessage()
	emit_signal("creature_done")
	
	return true
	
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
