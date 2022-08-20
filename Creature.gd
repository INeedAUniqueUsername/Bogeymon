extends Node2D

export(String) var species
export(String) var nickname
enum Moves {
	None,
	SnapFreeze,
	BrickThrow,
	Sunblast,
	DungBowl,
	Lunge,
	Feather
}
var NameTable = {
	Moves.SnapFreeze: "Snap Freeze",
	Moves.BrickThrow: "Brick Throw",
	Moves.Sunblast: "Sunblast",
	Moves.DungBowl: "Dung Bowl",
	Moves.Lunge: "Lunge",
	Moves.Feather: "Feather"
}
var DescTable = {
	Moves.SnapFreeze: "Casts a freezing orb at the target. Press Enter to detonate the orb when it reaches the target",
	Moves.BrickThrow: "Throws a brick at the target. Can hit sweetspots for double damage. You have 2.5 seconds to aim before throwing.",
	Moves.Sunblast: "Fires a burning ray of sunlight straight ahead. Can hit eyespots for double damage.",
	Moves.DungBowl: "Rolls a large ball of dung. Press Enter to accelerate the ball and use Up/Down to aim."
}
var PpTable = {
	Moves.None: 0,
	Moves.SnapFreeze: 15,
	Moves.BrickThrow: 15,
	Moves.Sunblast: 15,
	Moves.DungBowl: 10,
	Moves.Lunge: 10,
	Moves.Feather: 10
}

var StrikeMoves = [Moves.SnapFreeze]

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

var allowStrike = false
func _ready():
	for m in moves:
		pp[m] = PpTable[m]
onready var world = get_tree().get_nodes_in_group("World")[0]

func summon():
	if $Pose and $Pose.has_animation("Summon"):
		$Pose.play("Summon")
		yield($Pose, "animation_finished")
		$Pose.play("Idle")
		var s = load("res://SummonSparkles.tscn").instance()
		world.add_child(s)
		s.global_position = $Center.global_position

func get_forward():
	return Vector2([1, -1][place.side], 0)
func get_scale():
	return Vector2([1, -1][place.side], 1)
signal hp_changed()
signal damaged(proj)
export(int) var hp_max = 40
onready var hp = hp_max
var hurt_rate = 5.0
func use_snap_freeze(target: Node2D, attackers: Array = [], projectile : Node2D = null):
	var c = load("res://IceBeamProjectile.tscn").instance()
	c.source = self
	world.add_child(c)
	c.global_position = global_position
	c.global_position.x = $Sprite/FireBeam.global_position.x
	c.get_node("Sprite").global_position.y = $Sprite/FireBeam.global_position.y
	
	if is_instance_valid(projectile):
		c.armed = false
		projectile.connect("tree_exiting", c, "arm")
	if !attackers.empty():
		_snap_freeze(target, c)
		
		var next = attackers.front()
		attackers = attackers.slice(1, len(attackers))
		yield(get_tree().create_timer(0.5), "timeout")
		yield(next.use_snap_freeze(target, attackers, c), "completed")
	else:
		yield(_snap_freeze(target, c), "completed")
func _snap_freeze(target, c):
	yield(c.get_node("Anim"), "animation_finished")
	
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
	var dist = (target.global_position - global_position).length()
	var init = target.global_position + polar2cartesian(dist/32, randf() * 2 * PI)
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
	b.global_scale = get_scale()
	b.global_position = global_position
	b.global_position.x = $Sprite/FireBeam.global_position.x
	b.get_node("Sprite").global_position.y = $Sprite/FireBeam.global_position.y
	yield(b, "tree_exited")
	
func dung_bowl():
	var disp = get_forward() * 1024
	
	var t = Game.inc_tw(world, self, "global_position", -disp, 1)
	yield(t, "tween_all_completed")
	
	
	var ball = load("res://Dungball.tscn").instance()
	world.add_child(ball)
	ball.global_position = $DungBallPos.global_position
	ball.source = self
	ball.direction = get_forward()
	Game.inc_tw(world, ball, "global_position", disp, 1)
	
	t = Game.inc_tw(world, self, "global_position", disp, 1)
	yield(t, "tween_all_completed")
	
	ball.charge()
	get_tree().create_timer(2.5).connect("timeout", ball, "roll")
	yield(get_tree().create_timer(5), "timeout")
	
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
	
var fainted = false
func faint():
	fainted = true
	if $Pose:
		$Pose.play("Faint")
	
func take_damage(proj):
	if 'sweet' in proj and proj.sweet:
		var s = load("res://RatingSweet.tscn").instance()
		get_tree().get_nodes_in_group("World")[0].add_child(s)
		s.global_position = global_position
	else:
		var s = load("res://RatingCool.tscn").instance()
		get_tree().get_nodes_in_group("World")[0].add_child(s)
		s.global_position = global_position
		
	
	emit_signal("damaged", proj)
	
	if fainted:
		return
	var hp_prev = hp
	
	var mult = 2 if 'sweet' in proj and proj.sweet else 1
	if proj.is_in_group("Falloff"):
		var dist = (proj.groundArea.global_position - global_position).length()
		var div = max(1, log(dist) / 3)
		mult /= div
	hp -= proj.damage_hp * mult
	hp = max(hp, 0)
	
	
	hurt_rate += 5
	
	emit_signal("hp_changed")
	$Hurt.play("Hurt")
	if $Pose:
		$Pose.play("Hurt")
		yield($Pose, "animation_finished")
		if !fainted:
			$Pose.play("Idle")
