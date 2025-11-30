extends Combo
class_name HeavyLauncher

@onready var manager = %ComboMan
@onready var timer: Timer = $Buffer


func Enter():
	print("CABOOOM")
	manager.player.velocity = Vector2.ZERO
	manager.timer.start()
	manager.anim.play("HeavyLauncher")
	manager.hitbox.angle = 80
	manager.hitbox.power = 200
	manager.player.velocity.y = -150
	manager.player.velocity.x = 150 * manager.hitbox.get_parent().scale.x
	manager.hitbox.type = "HeavyLauncher"


func Physics_update():
	
	if manager.timer.time_left <=0.3:
		manager.combo_cancel()


func _on_buffer_timeout() -> void:
	pass
