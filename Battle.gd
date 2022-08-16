extends Node2D
var creatures = []
const Place = preload("res://Common.gd").Place
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
		b[i].connect("pressed", self, "use_move", [i])
	creature = creatures[0]
	
	
	var boxes = [$UI/LeftA, $UI/LeftB, $UI/RightA, $UI/RightB]
	for i in range(4):
		var c = creatures[i]
		if c:
			boxes[i].get_node("Name").text = creature.species
	update_menu()
	
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
		if i < len(creature.moves):
			var m = creature.moves[i]
			if creature.pp[m] > 0:
				button.text = creature.NameTable[m]
				button.disabled = false
				continue
		
		button.text = ""
		button.disabled = true

func use_move(i):
	$UI/CreatureMenu.hide()
	var Moves = creature.Moves
	match creature.moves[i]:
		Moves.SnapFreeze:
			creature.snap_freeze()
