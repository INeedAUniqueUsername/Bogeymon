extends Node2D

func _ready():
	var r = randf() * 2 * PI
	rotation = r
	$MainCrosshair.global_rotation = 0
onready var world = get_tree().get_nodes_in_group("World")[0]
var source

var marker_count = 0
var last_marker = null
func place_marker_next():
	place_marker(marker_count)
func place_marker(i):
	if marker_count == 5:
		return
	if marker_count > i:
		return
	clone_marker()
	marker_count += 1
	if marker_count < 5:
		yield(get_tree().create_timer(0.5), "timeout")
		place_marker(i + 1)
	else:
		$Anim.play("Disappear")
		yield(last_marker, "tree_exiting")
		queue_free()
		
func clone_marker():
	var p = $Marker.duplicate()
		
	var r = randf() * 2 * PI
	p.rotate(r)
	p.get_node("Crosshair").rotate(-r)
	
	p.get_node("Anim").play("Attack")
	p.get_node("Wait").connect("tree_exiting", self, "set_current_marker", [p])
	world.add_child(p)
	p.global_position = global_position
	
	var pa = p.get_node("Pivot/Sprite/Area")
	var ca = p.get_node("Crosshair/Area")
	pa.connect("area_entered", self, "on_marker_entered", [ca])
	
	last_marker = p
	return p
func on_marker_entered(area, ca):
	if !source.cpu:
		return
	if area != ca:
		return
	if randi()%2 == 0:
		attack()
func set_current_marker(m):
	self.current_marker = m
var current_marker
func _physics_process(delta):
	if source.cpu:
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
	if marker_count < 5:
		if enter and !prevEnter:
			place_marker_next()
	else:
		if enter and !prevEnter and is_instance_valid(current_marker):
			attack()
	prevEnter = enter

var target
var hit = false
var damage_hp
var sweet = false
func attack():
	var area = current_marker.get_node("Pivot/Sprite/Area")
	
	var crosshair = current_marker.get_node("Crosshair")
	if area.overlaps_area(crosshair.get_node("Area")):
		var dist = current_marker.get_node("Pivot/Sprite").global_position.distance_to(crosshair.global_position)
		damage_hp = max(4, 12 - randi()%int(max(dist/4, 1)))
		
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
	current_marker.queue_free()
	current_marker = null
