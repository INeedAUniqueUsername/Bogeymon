extends Node2D

export(String) var species
export(String) var nickname
enum Moves {
	None,
	SnapFreeze,
	BrickThrow
}
var NameTable = {
	Moves.SnapFreeze: "Snap Freeze",
	Moves.BrickThrow: "Brick Throw",
}
var PpTable = {
	Moves.None: 0,
	Moves.SnapFreeze: 15,
	Moves.BrickThrow: 15,
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
var hp = 100
var hp_max = 100


func snap_freeze():
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
	t.interpolate_property(c, "global_position", c.global_position, c.global_position + global_transform.x * (512 * 3), 3.0, Tween.TRANS_LINEAR)
	world.add_child(t)
	t.start()
	t.connect("tween_all_completed", t, "queue_free")
	t.connect("tween_all_completed", c, "detonate")
	var explosion = yield(c, "detonated")
	yield(explosion, "tree_exited")
	
func brick_throw():
	var c = load("res://Brick.tscn").instance()
	c.source = self
	world.add_child(c)
	c.global_position = global_position
	
	var t = Tween.new()
	t.interpolate_property(c, "global_position", c.global_position, c.global_position + global_transform.x * (512 * 2.5), 0.8, Tween.TRANS_LINEAR)
	world.add_child(t)
	t.start()
	t.connect("tween_all_completed", t, "queue_free")
	
	yield(c, "tree_exited")
	
var jumpReady = true
func jump():
	$Jump.play("Jump")
	jumpReady = false
	yield(get_tree().create_timer(1.0), "timeout")
	jumpReady = true

func take_damage(proj):
	hp -= proj.damage_hp
	emit_signal("hp_changed")
	$Hurt.play("Hurt")
