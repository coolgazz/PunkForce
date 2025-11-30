extends State
class_name E_Attack
var GRAVITY = 600
var FRICTION = 980
var KnockBAck = 300

@export var NPC: CharacterBody2D
@onready var cooldown = $"../AttackCooldown"

func Enter():
	NPC.sprite.play("Hit")
	NPC.velocity = Vector2.ZERO
	cooldown.start()
func Physics_update():
	NPC.sprite.get_child(0).disabled = false
	pass
	


func _on_animated_sprite_2d_animation_finished() -> void:
	NPC.sprite.get_child(0).disabled = true
	Transitioned.emit(self, "idle")
