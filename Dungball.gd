extends Node2D

onready var groundArea = $Ground

var charging = false
var rolling = false

onready var speed = 12

var direction
var prevEnter = false
func _process(delta):
	$Sprite.rotate(speed * delta * sign(direction.x))
	
	if charging:
		
		$Line2D.set_point_position(1, 1024 * direction)
		if source.cpu:
			if randi()%16 == 0:
				speed += 2
			return
		var enter = Input.is_key_pressed(KEY_ENTER)
		if enter and !prevEnter:
			speed += 2
			
		if Input.is_key_pressed(KEY_UP):
			rotate_towards(delta, Vector2(0, -1))
		if Input.is_key_pressed(KEY_DOWN):
			rotate_towards(delta, Vector2(0, 1))
			
		prevEnter = enter
	elif rolling:
		global_position += direction * abs($Sprite.position.y) * speed * delta

func rotate_towards(delta, dest):
	var off = dest - direction
	var angle = atan2(off.y, off.x)
	direction = direction.rotated(sign(angle) * min(abs(angle), delta * PI/16))

func charge():
	$Line2D.show()
	charging = true
func roll():
	$Line2D.hide()
	charging = false
	rolling = true
	damage_hp = speed / 3
	get_tree().create_timer(4).connect("timeout", self, "queue_free")


var sweet = false
var damage_hp = 10
var source
var hit = false
var hitCreatures = []
func _on_area_entered(area : Area2D):
	
	if !rolling:
		return
	#NOTE: Ground must make contact before body, otherwise hit doesn't register
	#workaround: ground area must be wider than body
	if 'creature' in area:
		#if hit: return
		var c = area.creature
		if c == source:
			return
		if c.place.side == source.place.side:
			return
		if !$Ground.overlaps_area(c.groundArea):
			return
		if hitCreatures.has(c):
			return
		hitCreatures.append(c)
		
		hit = true
		if area.is_in_group("Sweet"):
			sweet = true
			
		c.take_damage(self)
