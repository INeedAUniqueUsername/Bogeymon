extends Node2D

var amount = 0
func set_amount(a):
	for c in get_children():
		c.set_amount(a)
	amount = a
