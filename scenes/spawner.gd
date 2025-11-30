extends Marker2D

@onready var Enemy = preload("res://scenes/enemy.tscn")


func Spawn_enemy():
	var enem = Enemy.instantiate()
	enem.position = global_position 
	get_parent().get_parent().add_child(enem)
	
