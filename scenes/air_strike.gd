extends Combo
class_name AirStrike

@onready var manager = %ComboMan
var type = "AirStrike"

func Enter():
	print("CABOOOM")
	manager.player.velocity = Vector2.ZERO
	manager.timer.start()
	manager.anim.play("AirStrike")
	manager.hitbox.angle = 285
	manager.hitbox.power = 500
	manager.hitbox.type = "AirStrike"


func Physics_update():
	if manager.timer.time_left<=0.45:
		manager.player.velocity.y += 600 * get_physics_process_delta_time()
	
	if manager.timer.time_left <=0.2:
		manager.combo_cancel()

	
