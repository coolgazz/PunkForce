extends Combo
class_name HeavyFinisher

@onready var manager = %ComboMan
@onready var timer: Timer = $Buffer


func Enter():
	print("CABOOOM")
	manager.player.velocity = Vector2.ZERO
	manager.timer.start()
	manager.anim.play("HeavyFinisher")
	manager.hitbox.angle = 80
	manager.hitbox.power = 350
	manager.player.velocity.x = 1000 * manager.hitbox.get_parent().scale.x
	manager.hitbox.type = "HeavyFinisher"

func Physics_update():
	if manager.timer.time_left<=0.45:
		manager.player.velocity.x = 0
	
	if manager.timer.time_left <=0.3:
		manager.combo_cancel()


func _on_buffer_timeout() -> void:
	pass
