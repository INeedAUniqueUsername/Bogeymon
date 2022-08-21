extends Node2D

func _ready():
	$Buttons/Play.connect("pressed", self, "play")
	
	if Game.innovation != null:
		get_node(Game.get_version_name()).show()
		$Buttons.show()
		$Select.hide()
		$Prompt.hide()
		$Buttons/Play.texture_normal = [
			load("res://BigButtonNormalCyan.png"),
			load("res://BigButtonNormalPink.png")
		][Game.innovation]
	
		return
	
	for b in [$Prompt/Bold, $Prompt/Brash]:
		b.connect("pressed", self, "transition", [b.name])
var version
func transition(version):
	Game.innovation = ["Bold", "Brash"].find(version)
	$Buttons/Play.texture_normal = [
		load("res://BigButtonNormalCyan.png"),
		load("res://BigButtonNormalPink.png")
	][Game.innovation]
	
	self.version = version
	get_node(version).show()
	$Anim.play("Selected")
	yield($Anim, "animation_finished")
	$Buttons.show()
func play():
	get_tree().change_scene("res://PartyBuilder.tscn")
	pass
