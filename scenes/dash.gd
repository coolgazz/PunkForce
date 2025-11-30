extends State
class_name Dash

var SPEED = 1500
@export var player:CharacterBody2D
@onready var timer: Timer = $Timer

func Enter():
	player.velocity = Vector2.ZERO
	timer.start()
	player.DashCount -= 1

func Physics_update():
	var direction = Input.get_vector("Left","Right","Up","Down")
	if direction:
		player.velocity = SPEED * direction
	

func _on_timer_timeout() -> void:
	Transitioned.emit(self, "idle")
	
func Exit():
	player.velocity = Vector2.ZERO
	
