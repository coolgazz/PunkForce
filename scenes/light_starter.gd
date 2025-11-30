extends Combo
class_name LightStarter

@onready var manager = %ComboMan
@onready var timer: Timer = manager.timer
var light_input = false

func Enter():
	print("yooooooo")
	manager.player.velocity = Vector2.ZERO
	manager.timer.start()
	manager.anim.play("LightStarter")
	manager.hitbox.angle = 0
	manager.hitbox.power = 200
	manager.player.velocity.x = 1000 * manager.hitbox.get_parent().scale.x

	

func Physics_update():
	if manager.timer.time_left<=0.45:
		manager.player.velocity.x = 0
		
	if Input.is_action_just_pressed("Light Attack"):
		light_input = true
	
	if manager.timer.time_left <=0.2 and light_input:
		print("DAMNNNNNN")
		light_input = false
		Combated.emit("secondlight")
		
		
		
	
func Exit():
	pass
	#hitbox.disabled = true

		


func _on_buffer_timeout() -> void:
	pass
