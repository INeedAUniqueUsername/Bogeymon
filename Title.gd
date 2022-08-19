extends Node2D

func _ready():
	for b in [$Prompt/Bold, $Prompt/Brash]:
		b.connect("pressed", self, "transition", [b.name])
	$Buttons/Play.connect("pressed", self, "play")
var version
func transition(version):
	Game.innovation = ["Bold", "Brash"].find(version)
	self.version = version
	get_node(version).show()
	$Anim.play("Selected")
	yield($Anim, "animation_finished")

func play():
	get_tree().change_scene("res://Battle.tscn")
	pass
