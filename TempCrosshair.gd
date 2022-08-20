extends Node2D

onready var initColor = $Sprite.self_modulate
var selectColor
func dismiss() -> void:
	$Anim.play("Disappear")
func show_selected(arrow, target) -> void:
	var targets: Array = arrow.targets
	var b = targets.has(target)
	$Sprite.modulate = {
		true: selectColor,
		false: initColor
	}[b]
