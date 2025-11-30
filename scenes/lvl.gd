extends Node2D

@onready var Arena1 = $Arena1
@onready var Player = $Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Player.Camera.limit_left = 0
	Player.Camera.limit_right = 2500


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$Arena1/Spawner.Spawn_enemy()
		$Arena1/Spawner2.Spawn_enemy()
		Arena1.queue_free()


func _on_end_lvl_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().change_scene_to_file("res://cave_lvl.tscn")


func _on_chapter_1_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Dialogic.start("ChapterA")
		$Chapter1.queue_free()
