extends Area2D
export(NodePath) var projectile
func _ready():
	projectile = get_node(projectile)
