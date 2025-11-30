extends State
class_name Idle

var SPEED = 300
var GRAVITY = 980
var JUMP_POWER = -400
var JUMP_COUNTER
@export var player:CharacterBody2D
@onready var sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"
#@onready var timestop = preload("res://time_stop.tscn")

func Enter():
	anim.play("Idle")
	

func Physics_update():
	if Dialogic.current_timeline != null:
		Transitioned.emit(self, "dialogue")
	if !player.is_on_floor():
		Transitioned.emit(self, "Fall")	
	
	var direction = Input.get_axis("Left", "Right")
	if direction:
		anim.play("Run")
		player.velocity.x = SPEED * direction
		sprite.scale.x = direction
	else:
		anim.play("Idle")
		player.velocity.x = 0
	if Input.is_action_just_pressed("Jump"):
		player.velocity.y = JUMP_POWER
	if Input.is_action_just_pressed("Dash") and player.DashCount > 0:
		Transitioned.emit(self, "dash")
	if Input.is_action_just_pressed("Light Attack"):
		player.current_action = "Light"
		Transitioned.emit(self, "comboman")
	if Input.is_action_just_pressed("Heavy Attack"):
		player.current_action = "Heavy"
		Transitioned.emit(self, "comboman")
	if Input.is_action_just_pressed("PunkForce"):
		if player.Ghost == "Clock":
			TimeStop.start(player, 2.0)
		if player.Ghost == "Bio":
			RisingImageDamage.cast(player,"res://Assets/BioGhost.png")
