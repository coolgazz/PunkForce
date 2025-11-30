extends Combo
class_name HeavyStarter

@onready var manager = %ComboMan
@onready var timer: Timer = manager.timer
var light_input = false
var heavy_input = false


func Enter():
	manager.player.velocity = Vector2.ZERO
	manager.timer.start()
	manager.anim.play("HeavyStarter")
	manager.hitbox.angle = 80
	manager.hitbox.power = 200
	manager.player.velocity.x = 1000 * manager.hitbox.get_parent().scale.x

	

func Physics_update():
	if manager.timer.time_left<=0.45:
		manager.player.velocity.x = 0
		
	if Input.is_action_just_pressed("Light Attack"):
		light_input = true
		heavy_input = false
	
	if Input.is_action_just_pressed("Heavy Attack"):
		heavy_input = true
		light_input = false
		
	
	if manager.timer.time_left <=0.2 and heavy_input:
		light_input = false
		heavy_input = false
		Combated.emit("heavylauncher")
	if manager.timer.time_left <=0.2 and light_input:
		light_input = false
		heavy_input = false
		Combated.emit("lightfinisher")
		
		
	
func Exit():
	pass
	#hitbox.disabled = true

		


func _on_buffer_timeout() -> void:
	pass
