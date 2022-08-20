extends Node2D

func _ready():
	var r = randf() * 2 * PI
	rotation = r
	$MainCrosshair.global_rotation = 0
onready var world = get_tree().get_nodes_in_group("World")[0]
var attacking = false
func start_attacking():
	if attacking:
		return
	attacking = true
	
	for i in range(5):
		var p = $Marker.duplicate()
		p.get_node("Anim").play("Attack")
		p.get_node("Wait").connect("tree_exiting", self, "set", ["marker", p])
		world.add_child(p)
		p.global_position = global_position
		yield(get_tree().create_timer(0.5), "timeout")
	$Anim.play("Disappear")
	
var marker
func _physics_process(delta):
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
		if enter and !prevEnter and is_instance_valid(marker):
			attack()
	prevEnter = enter

var target
var hit = false
var damage_hp
var sweet = false
func attack():
	var area = marker.get_node("Pivot/Sprite/Area")
	if area.overlaps_area(marker.get_node("Crosshair/Area")):
		var dist = marker.get_node("Pivot/Sprite").global_position.distance_to($Crosshair.global_position)
		damage_hp = max(5, 20 - randi()%int(dist/4))
		
		for a in area.get_overlapping_areas():
			if !('creature' in a):
				continue
			var c = a.creature
			if c != target:
				continue
			sweet = a.is_in_group("Sweet")
			c.take_damage(self)
			hit = true
			break
	marker = null
