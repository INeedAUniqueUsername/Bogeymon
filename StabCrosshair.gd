extends Node2D

var source
func _ready():
	$OuterPivot.rotation = randf() * 2 * PI
var attacking = false
func start_attacking():
	if attacking:
		return
	attacking = true
	$Anim.play("Attack")
	
export(bool) var attackReady = false
func _physics_process(delta):
	if source.cpu:
		return
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
	if source.cpu:
		return
	
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
	if $OuterPivot/InnerPivot/Aim/Area.overlaps_area($Crosshair/Area):
		var dist = $OuterPivot/InnerPivot/Aim.global_position.distance_to($Crosshair.global_position)
		damage_hp = max(5, 20 - randi()%int(dist/4))
		
		for a in $OuterPivot/InnerPivot/Aim/Area.get_overlapping_areas():
			if !('creature' in a):
				continue
			var c = a.creature
			if c != target:
				continue
			sweet = a.is_in_group("Sweet")
			c.take_damage(self)
			hit = true
			break


func _on_area_entered(area):
	if source.cpu and area == $Crosshair/Area:
		get_tree().create_timer(randf() * 0.05).connect("timeout", self, "attack")
