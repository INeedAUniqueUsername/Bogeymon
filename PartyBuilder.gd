extends Control

var Bogeymon = preload("res://Creature.gd").Bogeymon

var DescTable = {
	Bogeymon.Stoneborn: "Known as the Stubborn Stone Bogeymon, Stoneborn is a very, very, very stubborn tortoise who lives its entire life under a rock. Its only friend is a stick in the mud that is confirmed to have no opinions whatsoever.",
	Bogeymon.Scarabold: "Known as the Dungeon Beetle Bogeymon, Scarabold is a battle-hardened beetle that lives in the dungeons of abandoned castles. Its heavily armored carapace is made of bricks as well as iron. Beware its bowling attack.",
	Bogeymon.Crowscare: "Known as the Fearsome Crow Bogeymon, Crowscare wears a sweater that doesn't really fit it and a hat that it randomly found in the cornfields. It likes to show up and stand still around weird places during the night."
}

var bogeys = {
	Bogeymon.Stoneborn: preload("res://Stoneborn.tscn").instance(),
	Bogeymon.Scarabold: preload("res://Scarabold.tscn").instance(),
	Bogeymon.Crowscare: preload("res://Crowscare.tscn").instance()
}

func _ready():
	versus = Game.pvp
	
	$Cancel.connect("pressed", self, "quit")
	$StartGame.connect("pressed", self, "start_game")
	$RandomBattle.connect("pressed", self, "random_battle")
	$VersusMode.connect("pressed", self, "set_versus")
	
	for b in bogeys:
		var r = $Pool.get_node(Bogeymon.keys()[b]) as NinePatchRect
		
		var bogey = bogeys[b].duplicate()
		r.add_child(bogey)
		bogey.position = Vector2(r.rect_size.x/2, r.rect_size.y * 3/4.0)
		var button = r.get_node("Button")
		button.connect("mouse_entered", self, "show_bogeymon", [bogeys[b]])
		button.connect("pressed", self, "add_bogeymon", [bogeys[b]])
		
	var i = 0
	for b in $Team.get_children():
		b.get_node("Button").connect("pressed", self, "remove_bogeymon", [i])
		i += 1
		
	update_menu()
func show_bogeymon(bogey):
	$Info/Name.text = bogey.species
	$Info/Desc.text = DescTable[bogey.bogey]
	var s = "Moves: "
	for m in bogey.moves:
		if m == bogey.Moves.None:
			continue
		s += bogey.NameTable[m] + ", "
	$Info/Moves.text = s
func add_bogeymon(bogey):
	var team = get_current_team()
	var i = len(team)
	if i == 6:
		return
	bogey = bogey.duplicate()
	team.append(bogey)
	update_team()
	
func remove_bogeymon(index):
	
	get_current_team().remove(index)
	update_team()
	
func update_menu():
	var ver = Game.innovate({false: 0, true: 1}[versus])
	var rects = [$Back, $Info]
	rects.append_array($Team.get_children())
	rects.append_array($Pool.get_children())
	var tex = [load("res://TopBarCyan.png"), load("res://TopBarPink.png")]
	for r in rects:
		r.texture = tex[ver]
		
	for b in [$Cancel, $StartGame]:
		b.texture_normal = [
			preload("res://ButtonNormalCyan.png"), preload("res://ButtonNormalPink.png")
		][ver]
		b.texture_disabled = [
			preload("res://ButtonDisabledCyan.png"), preload("res://ButtonDisabledPink.png")
		][ver]
	for b in [$VersusMode, $RandomBattle]:
		
		b.texture_normal = [
			preload("res://LongButtonNormalCyan.png"), preload("res://LongButtonNormalPink.png")
		][ver]
		b.texture_disabled = [
			preload("res://LongButtonDisabledCyan.png"), preload("res://LongButtonDisabledPink.png")
		][ver]
	
	$League.visible = !versus
	
	if versus:
		$RandomBattle.get_node("Label").text = "CPU Player"
		$VersusMode.get_node("Label").text = "Versus Mode"
	else:
		$RandomBattle.get_node("Label").text = "Random Battle"
		$VersusMode.get_node("Label").text = "Story Mode"
	update_team()
func get_current_team():
	return { true: Game.opponent_team, false: Game.player_team }[versus]
func update_team():
	Game.evacuate_creatures()
	var ch = $Team.get_children()
	for r in ch:
		while r.get_child_count() > 1:
			r.remove_child(r.get_child(1))
	var i = 0
	
	var team = get_current_team()
	
	for c in team:
		c.show()
		var b = ch[i]
		b.add_child(c)
		c.position = Vector2(b.rect_size.x/2, b.rect_size.y * 3/4.0)
		i += 1
		
	if versus:
		$StartGame.disabled = team.empty()
		$RandomBattle.disabled = team.empty()
		return
	$StartGame.disabled = len(team) < 6
	$RandomBattle.disabled = team.empty()
	
	

var versus = false
var cpu = false

func quit():
	Game.evacuate_creatures()
	get_tree().change_scene("res://Title.tscn")
func set_versus():
	versus = !versus
	update_menu()
		
func start_game():
	if versus:
		Game.pvp = true
		Game.campaign = false
		Game.evacuate_creatures()
		get_tree().change_scene("res://Battle.tscn")
		return
	
	
	if len(Game.player_team) < 6:
		return
	Game.pvp = false
	Game.campaign = true
	Game.level = 0
	Game.player_team = Game.player_team.duplicate()
	Game.evacuate_creatures()
	get_tree().change_scene("res://Battle.tscn")
func random_battle():	
	if versus:
		Game.pvp = false
		Game.campaign = false
		Game.evacuate_creatures()
		get_tree().change_scene("res://Battle.tscn")
		return
	
	
	Game.pvp = false
	Game.campaign = false
	Game.evacuate_creatures()
	randomize()
	
	Game.opponent_team = []
	for i in range(6):
		Game.opponent_team.append(bogeys[randi()%len(bogeys)].duplicate())
	get_tree().change_scene("res://Battle.tscn")
