extends Label

signal fill_complete

@export var fill_char := "-"
@export var fill_speed := 0.0001
@export var fill_length := 65

var _target_length := 0
var _current_length := 0
var _filling := false


func _ready() -> void:
	_target_length = fill_length
	text = ""
	set_process(false)


func _process(delta: float) -> void:
	if not _filling:
		return

	_current_length += int(ceil(fill_speed * delta))
	if _current_length >= _target_length:
		_current_length = _target_length
		_filling = false
		set_process(false)
		fill_complete.emit()

	text = fill_char.repeat(_current_length)


func start_fill(animated: bool) -> void:
	_target_length = fill_length

	_current_length = 0
	if animated:
		text = fill_char
		_filling = true
		set_process(true)
	else:
		_filling = false
		text = fill_char.repeat(_target_length)
		fill_complete.emit()
