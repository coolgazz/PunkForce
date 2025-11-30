extends Popup

@export_file("*.tscn") var continue_scene_path := ""
@export var continue_delay_seconds := 4.0
@export var exit_delay_seconds := 4

const CONTINUE_MESSAGE := """Не устраивает, как всё легло.
Гони повтор, я ещё раз ввалюсь и сделаю красиво."""
const EXIT_MESSAGE := """На этот раунд хватит.
Я пошла перегружать голову и собирать себя по кускам."""

@onready var _messages_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/Chat_anonimus/MarginContainer/VBoxContainer/Panel/MarginContainer/Chat/ScrollContainer/VBoxContainer
@onready var _scroll: ScrollContainer = $Panel/MarginContainer/VBoxContainer/Chat_anonimus/MarginContainer/VBoxContainer/Panel/MarginContainer/Chat/ScrollContainer
@onready var _continue_button: Button = $Panel/MarginContainer/VBoxContainer/Chat_anonimus/MarginContainer/VBoxContainer/Answer_1
@onready var _exit_button: Button = $Panel/MarginContainer/VBoxContainer/Chat_anonimus/MarginContainer/VBoxContainer/Answer_2

var _answer_user_scene: PackedScene = preload("res://Market/answer_user.tscn")
var _separator_scene: PackedScene = preload("res://Market/separator_lable.tscn")

var _action_in_progress := false


func _ready() -> void:
	_continue_button.pressed.connect(_on_continue_pressed)
	_exit_button.pressed.connect(_on_exit_pressed)


func _on_continue_pressed() -> void:
	if _action_in_progress:
		return
	_action_in_progress = true
	_append_user_message(CONTINUE_MESSAGE)
	_start_timer(continue_delay_seconds, func() -> void:
		if continue_scene_path.is_empty():
			_action_in_progress = false
			return
		get_tree().change_scene_to_file(continue_scene_path)
	)


func _on_exit_pressed() -> void:
	if _action_in_progress:
		return
	_action_in_progress = true
	_append_user_message(EXIT_MESSAGE)
	_start_timer(exit_delay_seconds, func() -> void:
		get_tree().quit()
	)


func _append_user_message(text: String) -> void:
	_append_filled_separator()
	var message: VBoxContainer = _answer_user_scene.instantiate()
	var label: RichTextLabel = message.get_node("HBoxContainer/RichTextLabel")
	label.text = text
	_messages_container.add_child(message)
	_scroll_to_bottom()


func _append_filled_separator() -> void:
	var separator := _separator_scene.instantiate()
	_messages_container.add_child(separator)
	if separator.has_method("start_fill"):
		separator.call("start_fill", false)


func _scroll_to_bottom() -> void:
	_scroll.call_deferred("set", "scroll_vertical", _scroll.get_v_scroll_bar().max_value)


func _start_timer(delay_seconds: float, on_timeout: Callable) -> void:
	var wait_time = max(delay_seconds, 0.0)
	var timer := get_tree().create_timer(wait_time)
	timer.timeout.connect(on_timeout)
