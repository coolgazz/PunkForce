extends State
class_name Fall

var SPEED = 300
var GRAVITY = 980
var JUMP_POWER = -400
var JUMP_COUNTER = 1
@export var player:CharacterBody2D
@onready var sprite: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"



func Physics_update():
	if Dialogic.current_timeline != null:
		Transitioned.emit(self, "dialogue")
	if !player.is_on_floor():
		player.velocity.y += GRAVITY * get_physics_process_delta_time()
	else:
		JUMP_COUNTER = 1
		Transitioned.emit(self, "idle")
	if player.velocity.y > 0:
		anim.play("Fall")
	elif player.velocity.y < 0:
		anim.play("Jump")
	
	var direction = Input.get_axis("Left", "Right")
	if direction:
		player.velocity.x = SPEED * direction
		sprite.scale.x = direction
	else:
		player.velocity.x = 0
	
	if Input.is_action_just_pressed("Dash") and player.DashCount > 0:
		Transitioned.emit(self, "dash")
	
	if Input.is_action_just_pressed("Heavy Attack"):
		player.current_action = "AirStrike"
		Transitioned.emit(self, "comboman")
	
	if Input.is_action_just_pressed("Jump") and JUMP_COUNTER> 0:
		print("DAAAAAAAMN")
		player.velocity.y = 0
		player.velocity.y = JUMP_POWER
		JUMP_COUNTER-=1
	
