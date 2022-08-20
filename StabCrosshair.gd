extends Node2D

func _ready():
	rotation = randf() * 2 * PI
var attacking = false
func start_attacking():
	if attacking:
		return
	attacking = true
	$Anim.play("Attack")
	
export(bool) var attackReady = false
func _physics_process(delta):
	if attacking:
		return
	var d = 256
	if Input.is_key_pressed(KEY_LEFT):
		position.x -= d * delta
	if Input.is_key_pressed(KEY_UP):
		position.y -= d * delta
	if Input.is_key_pressed(KEY_RIGHT):
		position.x += d * delta
	if Input.is_key_pressed(KEY_DOWN):
		position.y += d * delta

var prevEnter = false
func _process(delta):
	var enter = Input.is_key_pressed(KEY_ENTER)
	if !attacking:
		if enter and !prevEnter:
			start_attacking()
	else:
		if enter and !prevEnter and attackReady:
			attack()
	prevEnter = enter

var target
var hit = false
var damage_hp
var sweet = false
func attack():
	attackReady = false
	if $Pivot/Aim/Area.overlaps_area($Crosshair/Area):
		var dist = $Pivot/Aim.global_position.distance_to($Crosshair.global_position)
		damage_hp = max(5, 20 - randi()%int(dist/4))
		
		for a in $Pivot/Aim/Area.get_overlapping_areas():
			if !('creature' in a):
				continue
			var c = a.creature
			if c != target:
				continue
			sweet = a.is_in_group("Sweet")
			c.take_damage(self)
			hit = true
			break
