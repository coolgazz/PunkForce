extends Panel

enum Stage { ROUND1, ROUND2, FINISHED }

const USER_CHOICES := {
	Stage.ROUND1: [
		{"code": "1a", "text": "Привет, rust_plate. Нужен апгрейд по живучести.\nСлышал, ты собираешь крэш-логи. Это чисто учебный дамп или с живых пациентов?"},
		{"code": "1b", "text": "Здравствуйте. Меня интересуют исходные медицинские данные ваших клиентов.\nЕсть ли у вас согласие на обработку персональных данных?"}
	],
	Stage.ROUND2: [
		{"code": "2a", "text": "Никаких бумаг, окей. Мне нужно, чтобы удары проходили по касательной, а кости не думали ломаться.\nГотов платить, не спрашивая, откуда дрова."},
		{"code": "2b", "text": "Я просто уточняю юридические риски. Хочу быть уверен, что всё в рамках закона."}
	]
}

const OPPONENT_RESPONSES := {
	"1a": "С живых, конечно.\nЛюди платят, чтобы не умереть второй раз.\nЕсли ты понял, что это не игрушка — уже плюс к карме.",
	"1b": "О, красиво зашёл.\nТак, значит, или шутник, или тот, кто очень любит бумажки.\nОдин шанс переписать тон, пока я не нажал “пожаловаться”.",
	"2a_after_1a": "Вот, другое дело.\nЗалью тебе урезанную версию кластера — этого хватит.\nА если выживешь пару крупных замесов — приходи за полной версией.",
	"2a_after_1b": "Ну хоть понял, где находишься.\nПрошивку дам, но без консультаций и без гарантий.\nПримешь на себя — дальше сам с собой разбирайся.",
	"2b": "Тебе явно не сюда.\nВ рамках закона — это в соседний раздел “белые клиники”.\nА тут — базар данных, а не форум юристов."
}

const SUCCESS_MESSAGE := "Прошивка “Анти-Боль-Кластер”:\n— поднимает порог боли;\n— учит тело подставлять “правильные” места под удар;\n— делает микродвижения для рикошета и скольжения.\nИтог: +1 к броне."

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
var _purchase_price := 0
var _purchase_completed := false


func _ready() -> void:
	_answer_button_one.pressed.connect(func(): _on_choice_pressed(0))
	_answer_button_two.pressed.connect(func(): _on_choice_pressed(1))
	_apply_stage_ui()


func _on_choice_pressed(index: int) -> void:
	if _input_locked:
		return

	if _stage == Stage.FINISHED and _purchase_price > 0 and not _purchase_completed:
		_handle_purchase()
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
	var purchase_price := 0
	if _stage == Stage.ROUND1:
		_last_round_one_choice = code
		response_text = OPPONENT_RESPONSES.get(code, "")
		next_stage = Stage.ROUND2
	elif _stage == Stage.ROUND2:
		if code == "2a":
			if _last_round_one_choice == "1a":
				response_text = OPPONENT_RESPONSES["2a_after_1a"]
				purchase_price = 2
			else:
				response_text = OPPONENT_RESPONSES["2a_after_1b"]
				purchase_price = 5
			show_success = true
		else:
			response_text = OPPONENT_RESPONSES["2b"]
		next_stage = Stage.FINISHED

	var on_fill := func() -> void:
		_append_opponent_message(response_text)
		_stage = next_stage
		_apply_stage_ui()
		_scroll_to_bottom()
		_input_locked = _stage == Stage.FINISHED
		if show_success:
			_queue_success_message(SUCCESS_MESSAGE, purchase_price)

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
		if _purchase_price <= 0 or _purchase_completed:
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
	var choices = USER_CHOICES.get(_stage, []).duplicate(true)
	if choices.size() >= 2:
		choices.shuffle()
	return choices


func _queue_success_message(success_message: String, purchase_price: int) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.6
	add_child(timer)
	var on_timeout := func() -> void:
		timer.queue_free()
		var on_sep_fill := func() -> void:
			_append_opponent_message(success_message)
			_show_purchase_button(purchase_price)
			_scroll_to_bottom()
		_append_separator(true, on_sep_fill)

	timer.timeout.connect(on_timeout)
	timer.start()


func _show_purchase_button(price: int) -> void:
	if price <= 0:
		return
	_purchase_price = price
	_purchase_completed = false
	_answer_button_one.visible = true
	_answer_button_two.visible = false
	_answer_button_one.text = "Купить: %d" % price
	_answer_button_one.disabled = false
	_input_locked = false


func _handle_purchase() -> void:
	if _purchase_completed or _purchase_price <= 0:
		return
	if _spend(_purchase_price):
		_purchase_completed = true
		_answer_button_one.text = "Куплено"
		_answer_button_one.disabled = true
		_purchase_price = 0


func _spend(amount: int) -> bool:
	var market := _get_market()
	if market and market.has_method("spend"):
		return market.spend(amount)
	return false


func _get_market() -> Node:
	return get_tree().get_root().get_node_or_null("Node2D/Market")
