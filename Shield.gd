extends Node

export(float) var defend_factor = 0


var ready = true
var strength = 1.0
func defend():
	if !ready:
		return
	ready = false
	$Anim.play("Defend")
	yield($Anim, "animation_finished")
	strength *= 0.5
	ready = true

func get_defend_power():
	var p = defend_factor * strength
	return p
