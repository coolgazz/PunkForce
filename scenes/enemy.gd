extends CharacterBody2D

@export var Player: CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var Spike = false
var HP = 10

func _physics_process(delta: float) -> void:
	move_and_slide()
	if HP <=0:
		queue_free()
			


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Player = body
