extends State
class_name ComboMan

@export var player:CharacterBody2D
@onready var timer: Timer = $ComboBuffer
@onready var hitbox: Area2D = $"../../AnimatedSprite2D/Hitbox2"
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"

var combos:Dictionary = {}
var current_combo: Combo

func _ready() -> void:
	for child in find_children("*","Node",true):
		if child is Combo:
			combos[child.name.to_lower()] = child
			child.Combated.connect(on_combo_transition)
	print("______________________________________________________")
	print(combos)
	print("______________________________________________________")

func on_combo_transition(new_state_name):
	var new_combo = combos.get(new_state_name.to_lower())
	print(new_combo)
	
	if !new_combo:
		return
	
	if current_combo:
		current_combo.Exit()
	
	new_combo.Enter()
	current_combo = new_combo


func Enter():
	if player.current_action == "Light":
		current_combo = combos["lightstarter"]
	elif player.current_action == "Heavy":
		current_combo = combos["heavystarter"]
	elif player.current_action == "AirStrike":
		current_combo = combos["airstrike"]
	print(player.current_action)
	timer.start()
	combos[current_combo.name.to_lower()].Enter()
func Physics_update():
	if current_combo:
		current_combo.Physics_update()
	
	
func combo_cancel():
	hitbox.type = ''
	Transitioned.emit(self, 'idle')

func _on_combo_buffer_timeout() -> void:
	hitbox.type = ''
	Transitioned.emit(self, "idle")
