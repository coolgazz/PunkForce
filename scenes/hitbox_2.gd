extends Area2D

@export var angle:int = 0
@export var power: int = 0
@export var disabled: bool = true
var type = ""

func _process(delta: float) -> void:
	if disabled == true:
		get_child(0).disabled = true
	else:
		get_child(0).disabled = false
		

func get_launch_vector():
	#Converts angle to radians
	var laun_angle = angle * PI / 180
	
	#Get X and Y components of vector
	var fx = power * cos(laun_angle)
	var fy = -power * sin(laun_angle)
	
	#Returns the vector of fx and fy
	match get_parent().scale.x < 0:
		true:
			return Vector2(fx*-1,fy)
		false:
			return Vector2(fx,fy)
