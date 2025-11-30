extends State
class_name E_Launched
var GRAVITY = 600
var FRICTION = 980
var KnockBAck = 300

@export var NPC: CharacterBody2D

func Enter():
	print("NOOOOOOOOOOO")

func Physics_update():
	
	if !NPC.is_on_floor():
		NPC.velocity.y += GRAVITY * get_physics_process_delta_time()
	else:
		if NPC.Spike:
			NPC.HP -= 1
			NPC.sprite.play("Hurt")
			NPC.velocity.y-=KnockBAck
			NPC.Spike = false
		else:
			Transitioned.emit(self,"idle")
	
