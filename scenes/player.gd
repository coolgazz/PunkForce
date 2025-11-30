extends CharacterBody2D

var DashCount = 2
@onready var DashCooldown = $StateMachine/Dash/Cooldown
@onready var Camera:Camera2D = $Camera2D
@onready var Hearts:Sprite2D = $CanvasLayer/Hearts
var current_action: String = ""
var Arena = false
var HP = 3
var Ghost = "Cyber"


func _physics_process(delta: float) -> void:
	move_and_slide()
	if HP == 3:
		Hearts.frame_coords.y = 0
	elif HP == 2:
		Hearts.frame_coords.y = 1
	else:
		Hearts.frame_coords.y = 2
	
	if Ghost == "Clock":
		Hearts.frame_coords.x = 0
	elif Ghost == "Cyber":
		Hearts.frame_coords.x = 1
	elif Ghost == "Bio":
		Hearts.frame_coords.x = 2
	
	if DashCount <2 and DashCooldown.is_stopped():
		DashCooldown.start()
	if Input.is_action_just_pressed("ClockPunk"):
		Ghost = "Clock"
	elif Input.is_action_just_pressed("CyberPunk"):
		Ghost = "Cyber"
	elif Input.is_action_just_pressed("BioPunk"):
		Ghost = "Bio" 
		get_viewport().set_input_as_handled()
func entered_Arena():
	Camera.limit_left = position.x - 170
	Camera.limit_right = position.x + 170
	
	
func _on_cooldown_timeout() -> void:
	DashCount += 1
