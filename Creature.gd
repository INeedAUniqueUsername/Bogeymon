extends Node2D

export(String) var species
export(String) var nickname
enum Moves {
	None,
	SnapFreeze,
	BrickThrow,
	Sunblast
}
var NameTable = {
	Moves.SnapFreeze: "Snap Freeze",
	Moves.BrickThrow: "Brick Throw",
	Moves.Sunblast: "Sunblast"
}
var DescTable = {
	Moves.SnapFreeze: "Casts a freezing orb at the target. Press Enter to detonate the orb when it reaches the target",
	Moves.BrickThrow: "Throws a brick at the target. Can hit sweetspots for double damage. You have 2.5 seconds to aim before throwing.",
	Moves.Sunblast: "Fires a burning ray of sunlight straight ahead. Can hit eyespots for double damage."
}
var PpTable = {
	Moves.None: 0,
	Moves.SnapFreeze: 15,
	Moves.BrickThrow: 15,
	Moves.Sunblast: 15
}

export(Array, Moves) var moves = [Moves.None, Moves.None, Moves.None, Moves.None]

var pp = {}

const Common = preload("res://Common.gd")
const Place = Common.Place

onready var groundArea = $Ground
var place : Place setget set_place, get_place
func set_place(p):
	place = p
	global_position = p.location.global_position
func get_place(): return place
var cpu = false
var allowJump = true
func _ready():
	for m in moves:
		pp[m] = PpTable[m]
onready var world = get_tree().get_nodes_in_group("World")[0]
signal hp_changed()
signal damaged(proj)
var hp = 100
var hp_max = 100
func snap_freeze(target):
	var cast = load("res://IceBeamCast.tscn").instance()
	world.add_child(cast)
	cast.global_position = $Sprite/FireBeam.global_position
	yield(cast, "tree_exited")
	
	var c = load("res://IceBeamProjectile.tscn").instance()
	c.source = self
	world.add_child(c)
	c.global_position = global_position
	c.global_position.x = $Sprite/FireBeam.global_position.x
	c.get_node("Sprite").global_position.y = $Sprite/FireBeam.global_position.y
	var t = Tween.new()
	
	var dest = c.global_position + (target.global_position - global_position).normalized() * (512 * 4)
	t.interpolate_property(c, "global_position", c.global_position, dest, 2.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	world.add_child(t)
	t.start()
	t.connect("tween_all_completed", t, "queue_free")
	t.connect("tween_all_completed", c, "detonate")
	var explosion = yield(c, "detonated")
	var hit = c.hit
	
	yield(explosion, "tree_exited")

	if !hit:
		miss()
func brick_throw(target):
	var c = load("res://BrickThrowCrosshair.tscn").instance()
	world.add_child(c)
	var init = target.global_position + polar2cartesian(128, randf() * 2 * PI)
	c.global_position = init
	
	var a = load("res://BrickThrowAim.tscn").instance()
	a.source = self
	a.crosshair = c
	a.global_position = global_position
	world.add_child(a)
	
	yield(get_tree().create_timer(2.5), "timeout")
	
	var dest = a.global_position
	a.crosshair = null
	a.done()
	
	c = load("res://Brick.tscn").instance()
	c.source = self
	world.add_child(c)
	
	var t = Tween.new()
	t.interpolate_property(c, "global_position", global_position, dest, 0.8, Tween.TRANS_LINEAR)
	world.add_child(t)
	t.start()
	t.connect("tween_all_completed", t, "queue_free")
	
	yield(c, "tree_exiting")
	
	if !c.hit:
		miss()
	
	yield(get_tree().create_timer(1), "timeout")
func sunblast():
	var b = load("res://Sunblast.tscn").instance()
	b.source = self
	world.add_child(b)
	b.global_scale = [Vector2(1, 1), Vector2(-1, 1)][place.side]
	b.global_position = global_position
	b.global_position.x = $Sprite/FireBeam.global_position.x
	b.get_node("Sprite").global_position.y = $Sprite/FireBeam.global_position.y
	yield(b, "tree_exited")
	
func miss():
	var m = load("res://RatingMiss.tscn").instance()
	world.add_child(m)
	m.global_position = global_position
	
var jumpReady = true
func jump():
	$Jump.play("Jump")
	jumpReady = false
	yield(get_tree().create_timer(1.0), "timeout")
	jumpReady = true

func take_damage(proj):
	
	if 'sweet' in proj and proj.sweet:
		var s = load("res://RatingSweet.tscn").instance()
		get_tree().get_nodes_in_group("World")[0].add_child(s)
		s.global_position = global_position
	else:
		var s = load("res://RatingCool.tscn").instance()
		get_tree().get_nodes_in_group("World")[0].add_child(s)
		s.global_position = global_position
		
	
	var hp_prev = hp
	emit_signal("damaged", proj)
	
	var mult = 2 if 'sweet' in proj and proj.sweet else 1
	hp -= proj.damage_hp * mult
	emit_signal("hp_changed")
	$Hurt.play("Hurt")
