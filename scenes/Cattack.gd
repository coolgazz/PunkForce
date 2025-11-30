extends State
class_name C_Attack
var GRAVITY = 600
var FRICTION = 980
var KnockBAck = 300
var attacked = false

@export var NPC: CharacterBody2D
@onready var cooldown = $"../AttackCooldown"

func Enter():
	if attacked:
		NPC.sprite.play("Hit1")
	else:
		NPC.sprite.play("Hit2")
	NPC.velocity = Vector2.ZERO
	cooldown.start()
func Physics_update():
	NPC.sprite.get_child(0).disabled = false
	pass
	


func _on_animated_sprite_2d_animation_finished() -> void:
	NPC.sprite.get_child(0).disabled = true
	Transitioned.emit(self, "idle")
