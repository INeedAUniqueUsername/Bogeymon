extends Node2D

onready var initColor = $Sprite.self_modulate
var selectColor
func dismiss() -> void:
	$Anim.play("Disappear")

func show_selected_single(arrow, target) -> void:
	$Sprite.modulate = {
		true: selectColor,
		false: initColor
	}[arrow.target == target]
func show_selected_multi(arrow, target) -> void:
	var targets: Array = arrow.targets
	var b = targets.has(target)
	$Sprite.modulate = {
		true: selectColor,
		false: initColor
	}[b]
