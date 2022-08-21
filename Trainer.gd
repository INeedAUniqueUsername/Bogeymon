extends Sprite

onready var groundArea = $Ground

func _ready():
	$Area.connect("area_entered", self, "on_area_entered")
func on_area_entered(area):
	if 'projectile' in area:
		var p = area.projectile
		if !p.groundArea.overlaps_area($Ground):
			return
		var prev = $Anim.current_animation
		var prev_pos = $Anim.current_animation_position
		
		$Anim.stop()
		$Anim.play("Stagger")
		if yield($Anim, "animation_finished") == "Stagger":
			$Anim.play(prev)
			$Anim.seek(prev_pos)
