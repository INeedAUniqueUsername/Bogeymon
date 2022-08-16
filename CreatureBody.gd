extends Area2D

export(NodePath) var creature
func _ready():
	creature = get_node(creature)
