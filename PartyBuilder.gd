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

func quit():
	Game.evacuate_creatures()
	get_tree().change_scene("res://Title.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Cancel.connect("pressed", self, "quit")
	$StartGame.connect("pressed", self, "start_game")
	$RandomBattle.connect("pressed", self, "random_battle")
	
	var ver = Game.innovate()
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
		
	update_team()
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
	var i = len(Game.player_team)
	if i == 6:
		return
	bogey = bogey.duplicate()
	Game.player_team.append(bogey)
	update_team()
	
func remove_bogeymon(index):
	Game.player_team.remove(index)
	update_team()
	
func update_team():
	var ch = $Team.get_children()
	for b in ch:
		if b.get_child_count() == 2:
			b.remove_child(b.get_child(1))
	
	var i = 0
	for c in Game.player_team:
		c.show()
		var b = ch[i]
		b.add_child(c)
		c.position = Vector2(b.rect_size.x/2, b.rect_size.y * 3/4.0)
		i += 1
	$StartGame.disabled = len(Game.player_team) < 6
	$RandomBattle.disabled = Game.player_team.empty()
func start_game():
	if len(Game.player_team) < 6:
		return
		remove_and_skip()
	Game.pvp = false
	Game.campaign = true
	Game.level = 0
	Game.player_team = Game.player_team.duplicate()
	Game.evacuate_creatures()
	get_tree().change_scene("res://Battle.tscn")
func random_battle():
	
	if Game.player_team.empty():
		return
	Game.pvp = false
	Game.campaign = false
	Game.player_team = Game.player_team.duplicate()
	Game.opponent_team = []
	Game.evacuate_creatures()
	randomize()
	for i in range(6):
		Game.opponent_team.append(bogeys[randi()%len(bogeys)].duplicate())
	get_tree().change_scene("res://Battle.tscn")
