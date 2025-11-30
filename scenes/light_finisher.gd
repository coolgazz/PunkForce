extends Combo
class_name LightFinisher

@onready var manager = %ComboMan
@onready var timer: Timer = $Buffer


func Enter():
	print("CABOOOM")
	manager.player.velocity = Vector2.ZERO
	manager.timer.start()
	manager.anim.play("LightFinisher")
	manager.hitbox.angle = 0
	manager.hitbox.power = 400
	manager.player.velocity.x = 1000 * manager.hitbox.get_parent().scale.x
	


func Physics_update():
	if manager.timer.time_left<=0.45:
		manager.player.velocity.x = 0
	
	if manager.timer.time_left <=0.2:
		manager.combo_cancel()


func _on_buffer_timeout() -> void:
	pass
