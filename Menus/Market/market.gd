extends Popup

var _currency: int = 15

@onready var _board: Panel = $Panel/MarginContainer/VBoxContainer/Board
@onready var _chat_meat_patch: Panel = $Panel/MarginContainer/VBoxContainer/Chat_meat_patch
@onready var _chat_rust_plate: Panel = $Panel/MarginContainer/VBoxContainer/Chat_rust_plate
@onready var _chat_lag_h8r: Panel = $Panel/MarginContainer/VBoxContainer/Chat_lag_h8r
@onready var _chat_old_schooler: Panel = $Panel/MarginContainer/VBoxContainer/Chat_old_schooler
@onready var _chat_space_cat: Panel = $Panel/MarginContainer/VBoxContainer/Chat_space_cat

@onready var _board_buttons := {
	"space_cat": $Panel/MarginContainer/VBoxContainer/Board/MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer5/HBoxContainer/Button,
	"rust_plate": $Panel/MarginContainer/VBoxContainer/Board/MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer2/HBoxContainer/Button,
	"lag_h8r": $Panel/MarginContainer/VBoxContainer/Board/MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer3/HBoxContainer/Button,
	"old_schooler": $Panel/MarginContainer/VBoxContainer/Board/MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer4/HBoxContainer/Button,
	"meat_patch": $Panel/MarginContainer/VBoxContainer/Board/MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer/HBoxContainer/Button,
}

@onready var _chats := {
	"space_cat": _chat_space_cat,
	"rust_plate": _chat_rust_plate,
	"lag_h8r": _chat_lag_h8r,
	"old_schooler": _chat_old_schooler,
	"meat_patch": _chat_meat_patch,
}


func _ready() -> void:
	
	_board_buttons["space_cat"].pressed.connect(func(): _open_chat("space_cat"))
	_board_buttons["rust_plate"].pressed.connect(func(): _open_chat("rust_plate"))
	_board_buttons["lag_h8r"].pressed.connect(func(): _open_chat("lag_h8r"))
	_board_buttons["old_schooler"].pressed.connect(func(): _open_chat("old_schooler"))
	_board_buttons["meat_patch"].pressed.connect(func(): _open_chat("meat_patch"))

	close_requested.connect(_on_close_requested)

	popup_centered() # Popup скрывается при старте; вручную показываем окно

	_update_currency_labels()
	_show_board()
	_setup_controller()
	show()


func _open_chat(key: String) -> void:
	_hide_all_chats()
	_board.visible = false

	var chat: Control = _chats.get(key, null)
	if chat:
		chat.visible = true


func _show_board() -> void:
	_hide_all_chats()
	_board.visible = true


func _hide_all_chats() -> void:
	for chat in _chats.values():
		if chat is Control:
			chat.visible = false


func _on_close_requested() -> void:
	_handle_toggle_or_hide()


func spend(amount: int) -> bool:
	if amount <= 0:
		return true
	if _currency < amount:
		return false
	_currency -= amount
	_update_currency_labels()
	return true


func _update_currency_labels() -> void:
	var labels: Array[Label] = [
		$Panel/MarginContainer/VBoxContainer/Board/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Label2,
		$Panel/MarginContainer/VBoxContainer/Chat_meat_patch/MarginContainer/VBoxContainer/HBoxContainer/Label2,
		$Panel/MarginContainer/VBoxContainer/Chat_rust_plate/MarginContainer/VBoxContainer/HBoxContainer/Label2,
		$Panel/MarginContainer/VBoxContainer/Chat_lag_h8r/MarginContainer/VBoxContainer/HBoxContainer/Label2,
		$Panel/MarginContainer/VBoxContainer/Chat_old_schooler/MarginContainer/VBoxContainer/HBoxContainer/Label2,
		$Panel/MarginContainer/VBoxContainer/Chat_space_cat/MarginContainer/VBoxContainer/HBoxContainer/Label2,
	]

	for label in labels:
		if label:
			label.text = "Баланс: %d" % _currency

func _setup_controller() -> void:
	var controller_hbox: HBoxContainer = $Panel/MarginContainer/VBoxContainer/Controller/HBoxContainer
	if controller_hbox == null:
		return

	var button2: Button = controller_hbox.get_node_or_null("Button2")
	var button3: Button = controller_hbox.get_node_or_null("Button3")

	if button2:
		button2.pressed.connect(func(): hide())

	if button3:
		button3.pressed.connect(_handle_toggle_or_hide)


func _handle_toggle_or_hide() -> void:
	if _is_chat_visible():
		_show_board()
	else:
		hide()


func _is_chat_visible() -> bool:
	for chat in _chats.values():
		if chat is Control and chat.visible:
			return true
	return false
