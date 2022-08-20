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
	
	var last = null
	for i in range(5):
		var p = $Marker.duplicate()
		
		var r = randf() * 2 * PI
		p.rotate(r)
		p.get_node("Crosshair").rotate(-r)
		
		p.get_node("Anim").play("Attack")
		p.get_node("Wait").connect("tree_exiting", self, "set", ["marker", p])
		world.add_child(p)
		p.global_position = global_position
		
		if i == 4:
			$Anim.play("Disappear")
		else:
			yield(get_tree().create_timer(0.5), "timeout")
		last = p
	yield(last, "tree_exiting")
	queue_free()
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
	
	var crosshair = marker.get_node("Crosshair")
	if area.overlaps_area(crosshair.get_node("Area")):
		var dist = marker.get_node("Pivot/Sprite").global_position.distance_to(crosshair.global_position)
		damage_hp = max(4, 10 - randi()%int(dist/6))
		
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
