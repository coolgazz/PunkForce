extends Panel

enum Stage { ROUND1, ROUND2, FINISHED }

const ROUND1_CHOICES := [
	{"code": "1a", "text": "Если найдёшь такого кота — продай мне вторую копию.\nМой умеет только ложиться на клаву и ульт жать в стену."},
	{"code": "1b", "text": "Зачем кот, если можно написать скрипт на макросах и повесить на пробел?\nРаспознавание по пикселям и эвентам, и готово."}
]

const ROUND2_CHOICES_BY_ENTRY := {
	"1a": [
		{"code": "2a", "text": "Вчера мой встал на клавиатуру во время кат-сцены, скипнул сюжет и заодно открыл настройки.\nТеперь у меня звук только в левом ухе и субтитры на корейском."},
		{"code": "2b", "text": "Ладно, шутки шутками, но если вдруг у тебя реально будет какой-нибудь ИИ-бот для пробела — продашь? Я не шучу."}
	],
	"1b": [
		{"code": "2a", "text": "Окей, аргумент принят.\nЗначит, оптимальный билд — скрипт + кот как UI-дизайнер."},
		{"code": "2b", "text": "Могу собрать тебе прототип: камера + скрипт, который жмёт пробел, когда видит кота возле клавы.\nБудет “реактивный кот” как функция."}
	]
}

const OPPONENT_RESPONSES := {
	"1a": "Ха-ха, классика.\nМой вчера прошёл половину уровня, просто пытаясь поймать курсор.\nПотом нажал Alt+F4 носом, и мы оба ушли плакать.",
	"1b": "Потому что скрипт не мурчит и не падает спать на монитор.\nА без этого, брат, нет настоящего immersive experience.",
	"2a_after_1a": "Звучит как новый уровень сложности.\n“Кампания: Кот хакает твой интерфейс”.\nЗапили скрин, выложи в тред, я это в шапку добавлю.",
	"2a_after_1b": "Именно.\nСкрипт жмёт пробел по таймингам, кот жмёт всё остальное, а ты сидишь и делаешь вид, что это твой скилл.\nДобро пожаловать в Панк форс.",
	"2b_after_1a": "Если у меня будет такой бот, я сначала сам на нём в турик пойду.\nА потом меня забанят и я вернусь сюда постить котов.\nТак что не рассчитывай.",
	"2b_after_1b": "Сделай демку и назови её “Cat-as-a-Service”.\nНо учти: как только кот поймёт, что от него что-то зависит, он перестанет подходить к клавиатуре вообще."
}

const SUCCESS_MESSAGES := {
	"2a_after_1a": "Лог: кот-история услышана. Эффектов на персонажа нет.",
	"2a_after_1b": "Просто лор. Без статов и апгрейдов.",
	"2b_after_1a": "space_cat уточнил, что ничего не продаёт. Диалог закрыт.",
	"2b_after_1b": "space_cat ушёл постить гифки."
}

@onready var _messages_container: VBoxContainer = $MarginContainer/VBoxContainer/Panel/MarginContainer/Chat/ScrollContainer/VBoxContainer
@onready var _scroll: ScrollContainer = $MarginContainer/VBoxContainer/Panel/MarginContainer/Chat/ScrollContainer
@onready var _answer_button_one: Button = $MarginContainer/VBoxContainer/Answer_1
@onready var _answer_button_two: Button = $MarginContainer/VBoxContainer/Answer_2

var _answer_opponent_scene: PackedScene = preload("res://Market/answer_oponent.tscn")
var _answer_user_scene: PackedScene = preload("res://Market/answer_user.tscn")
var _separator_scene: PackedScene = preload("res://Market/separator_lable.tscn")

var _stage: Stage = Stage.ROUND1
var _last_round_one_choice: String = ""
var _input_locked := false
var _current_choices: Array = []
var _first_message_paid := false


func _ready() -> void:
	_answer_button_one.pressed.connect(func(): _on_choice_pressed(0))
	_answer_button_two.pressed.connect(func(): _on_choice_pressed(1))
	_apply_stage_ui()


func _on_choice_pressed(index: int) -> void:
	if _input_locked or _stage == Stage.FINISHED:
		return

	if index < 0 or index >= _current_choices.size():
		return

	if _stage == Stage.ROUND1 and not _first_message_paid:
		if not _spend(1):
			return
		_first_message_paid = true

	_input_locked = true

	var choice = _current_choices[index]
	var code: String = choice.get("code", "")
	var text: String = choice.get("text", "")

	_append_separator(false)
	_append_user_message(text)
	_scroll_to_bottom()

	var response_text := ""
	var next_stage: Stage = _stage
	var success_key := ""
	if _stage == Stage.ROUND1:
		_last_round_one_choice = code
		response_text = OPPONENT_RESPONSES.get(code, "")
		next_stage = Stage.ROUND2
	elif _stage == Stage.ROUND2:
		if code == "2a":
			if _last_round_one_choice == "1a":
				response_text = OPPONENT_RESPONSES["2a_after_1a"]
				success_key = "2a_after_1a"
			else:
				response_text = OPPONENT_RESPONSES["2a_after_1b"]
				success_key = "2a_after_1b"
		else:
			if _last_round_one_choice == "1a":
				response_text = OPPONENT_RESPONSES["2b_after_1a"]
				success_key = "2b_after_1a"
			else:
				response_text = OPPONENT_RESPONSES["2b_after_1b"]
				success_key = "2b_after_1b"
		next_stage = Stage.FINISHED

	var on_fill := func() -> void:
		_append_opponent_message(response_text)
		_stage = next_stage
		_apply_stage_ui()
		_scroll_to_bottom()
		_input_locked = _stage == Stage.FINISHED
		if _stage == Stage.FINISHED:
			_queue_success_message(SUCCESS_MESSAGES.get(success_key, ""))

	_append_separator(true, on_fill)


func _append_user_message(text: String) -> void:
	var message: VBoxContainer = _answer_user_scene.instantiate()
	var label: RichTextLabel = message.get_node("HBoxContainer/RichTextLabel")
	label.text = text
	_messages_container.add_child(message)


func _append_opponent_message(text: String) -> void:
	var message: VBoxContainer = _answer_opponent_scene.instantiate()
	var label: RichTextLabel = message.get_node("HBoxContainer/RichTextLabel")
	label.text = text
	_messages_container.add_child(message)


func _append_separator(animated: bool, on_filled: Callable = Callable()):
	var separator = _separator_scene.instantiate()
	_messages_container.add_child(separator)
	if on_filled.is_valid():
		separator.fill_complete.connect(on_filled)
	separator.start_fill(animated)


func _apply_stage_ui() -> void:
	if _stage == Stage.FINISHED:
		_answer_button_one.disabled = true
		_answer_button_two.disabled = true
		_input_locked = true
		return

	_current_choices = _build_stage_choices()
	if _current_choices.size() >= 2:
		_answer_button_one.text = _current_choices[0].get("text", "")
		_answer_button_two.text = _current_choices[1].get("text", "")

	_answer_button_one.disabled = false
	_answer_button_two.disabled = false
	_input_locked = false


func _scroll_to_bottom() -> void:
	_scroll.call_deferred("set", "scroll_vertical", _scroll.get_v_scroll_bar().max_value)


func _build_stage_choices() -> Array:
	var choices: Array = []
	if _stage == Stage.ROUND1:
		choices = ROUND1_CHOICES.duplicate(true)
	elif _stage == Stage.ROUND2:
		choices = ROUND2_CHOICES_BY_ENTRY.get(_last_round_one_choice, ROUND2_CHOICES_BY_ENTRY.get("1a", [])).duplicate(true)

	if choices.size() >= 2:
		choices.shuffle()
	return choices


func _queue_success_message(success_message: String) -> void:
	if success_message.is_empty():
		return

	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.6
	add_child(timer)
	var on_timeout := func() -> void:
		timer.queue_free()
		var on_sep_fill := func() -> void:
			_append_opponent_message(success_message)
			_scroll_to_bottom()
		_append_separator(true, on_sep_fill)

	timer.timeout.connect(on_timeout)
	timer.start()


func _spend(amount: int) -> bool:
	var market := _get_market()
	if market and market.has_method("spend"):
		return market.spend(amount)
	return false


func _get_market() -> Node:
	return get_tree().get_root().get_node_or_null("Node2D/Market")
