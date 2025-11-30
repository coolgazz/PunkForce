extends Panel

enum Stage { ROUND1, ROUND2, FINISHED }

const ROUND1_CHOICES := [
	{"code": "1a", "text": "Йо, old_schooler.\n“Кибер-Барс” помню только из страшилок старших.\nТы его реально держал в руках или просто легенды пересказываешь?"},
	{"code": "1b", "text": "Сколько можно форсить этот “Кибер-Барс”.\nОчередная сказка для стариков, как вы на пеньке компилили?"}
]

const ROUND2_CHOICES_BY_ENTRY := {
	"1a": [
		{"code": "2a", "text": "Нормальная история, честно.\nА по сути — никакого волшебства, просто криво распаянный перегрев, да?\nИли всё-таки чип реально что-то умел?"},
		{"code": "2b", "text": "Короче, звучит как очередной “у друга был знакомый, у которого всё летало”.\nПойду лучше куплю нормальный патч, чем слушать байки."}
	],
	"1b": [
		{"code": "2a", "text": "Ладно, не хотел тебя триггерить.\nПросто мы уже выросли на эмуляторах, а не на этих полумёртвых платах.\nЕсли у тебя есть хоть какой-то скрин/фото, закинь в тред, я хотя бы посмотрю на легенду."},
		{"code": "2b", "text": "Да расслабься, дед.\nМир давно ушёл вперёд, никому не нужна твоя железка из каменного века."}
	]
}

const OPPONENT_RESPONSES := {
	"1a": "О, наконец-то не школьник с вопросом “где скачать”.\nВидел живьём один раз — в корпусе, весь на изоленте и молитвах.\nПросил хозяина дампнуть — сказал “да ну его, ещё дом спалю”.\nТак что да, наполовину легенда, наполовину глюк коллективной памяти.",
	"1b": "Ну привет, молодой и дерзкий.\nТы ещё скажи, что раньше и электричества не было.\nЯ тут вообще-то просто ностальгию трясу, а не курс лекций читаю.",
	"2a_after_1a": "Умел одно — греться и умирать красиво.\nЛюди сами додумывали остальное: “мне показалось, что он сам на врага навёлся”, “мне показалось, что выстрел быстрее пошёл”.\nПо факту — чистый культ железки.\nНо, знаешь, иногда культ — это всё, что остаётся.",
	"2a_after_1b": "Вот, другое дело.\nФото у меня как раз и нет — тогда не до камеры было, честно.\nНо если кто-то в треде оживёт и скинет — сам первым лайкну.\nА тебе совет: не всё старьё — мусор. Иногда в нём душа есть, а не фпс.",
	"2b_after_1a": "Да и иди.\nЯ же говорю — ностальгия, а не магазин.\nНо потом не удивляйся, когда лет через десять ты тоже начнёшь рассказывать, как “раньше лаги были честнее”.",
	"2b_after_1b": "Окей, молодой.\nВ чёрный список тебя кидать не буду — вдруг подрастёшь.\nНо на ЛС можешь больше не рассчитывать, базар закрыт."
}

const SUCCESS_MESSAGE_AFTER_1A := "Атмосферный лор.\nНикакого апгрейда, просто тёпленькая ламповость."
const SUCCESS_MESSAGE_AFTER_1B := "old_schooler смягчился.\nАпгрейда нет, но можешь считать, что old_schooler_respect = true."

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
	var show_success := false
	var success_message := ""
	if _stage == Stage.ROUND1:
		_last_round_one_choice = code
		response_text = OPPONENT_RESPONSES.get(code, "")
		next_stage = Stage.ROUND2
	elif _stage == Stage.ROUND2:
		if code == "2a":
			if _last_round_one_choice == "1a":
				response_text = OPPONENT_RESPONSES["2a_after_1a"]
				success_message = SUCCESS_MESSAGE_AFTER_1A
			else:
				response_text = OPPONENT_RESPONSES["2a_after_1b"]
				success_message = SUCCESS_MESSAGE_AFTER_1B
			show_success = true
		else:
			if _last_round_one_choice == "1a":
				response_text = OPPONENT_RESPONSES["2b_after_1a"]
			else:
				response_text = OPPONENT_RESPONSES["2b_after_1b"]
		next_stage = Stage.FINISHED

	var on_fill := func() -> void:
		_append_opponent_message(response_text)
		_stage = next_stage
		_apply_stage_ui()
		_scroll_to_bottom()
		_input_locked = _stage == Stage.FINISHED
		if show_success:
			_queue_success_message(success_message)

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
