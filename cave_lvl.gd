extends Node2D

@onready var Player: CharacterBody2D = $Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Player.Camera.limit_left = 15
	Player.Camera.limit_right = 1600
	


func _on_arena_1_body_entered(body: Node2D) -> void:
		if body.name == "Player":
			$Arena1/Spawner.Spawn_enemy()
			$Arena1/Spawner2.Spawn_enemy()
			$Arena1.queue_free()
