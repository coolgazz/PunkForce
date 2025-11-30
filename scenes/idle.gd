extends State
class_name C_Idle
var GRAVITY = 980
var FRICTION = 980
var SPEED = 100
var interrupted = false
@onready var stun: Timer = $"../StunTimer"
@onready var attack_cooldown: Timer = $"../AttackCooldown"
@export var NPC: CharacterBody2D

func Enter():
	SPEED = 100
	interrupted = false
	
func Physics_update():
	if !NPC.is_on_floor():
		NPC.velocity.y += GRAVITY * get_physics_process_delta_time()
	else:
		NPC.velocity = NPC.velocity.move_toward(Vector2.ZERO, FRICTION * get_physics_process_delta_time())
	if !interrupted and NPC.Player:
		var direction = (NPC.Player.position - NPC.position).normalized()
		NPC.velocity.x = direction.x * SPEED
		NPC.sprite.play("Walk")
		NPC.sprite.scale.x = -1.2 if NPC.position.x < NPC.Player.position.x else 1.2


func _on_hurt_box_area_entered(body: Area2D) -> void:
	if body.name == 'Hitbox2':
		NPC.HP -= 1
		NPC.sprite.play("Hurt")
		NPC.velocity.x = 0
		interrupted = true
		stun.start()
		NPC.velocity = body.get_launch_vector()
		if body.type == "AirStrike":
			NPC.Spike = true
			Transitioned.emit(self, "launched")
		if body.type == "HeavyLauncher":
			Transitioned.emit(self, "launched")
		if body.type == "HeavyFinisher":
			Transitioned.emit(self, "launched")
		print("OUCH")


func _on_stun_timer_timeout() -> void:
	interrupted = false


func _on_hit_range_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "Player" and attack_cooldown.is_stopped():
		print("Yeahhh bodyyy")
		Transitioned.emit(self, "attack")
