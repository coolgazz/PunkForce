# TimeStop.gd
extends Node
class_name TimeStop

const DEFAULT_DURATION := 3.0

# Чтобы не запускать несколько стоп-таймов одновременно
static var _active_controller: TimeStop = null

var _excluded_root: Node = get_parent()
var _duration: float = DEFAULT_DURATION
var _original_paused: bool = false   # чтобы вернуть исходное состояние паузы
var _stored_process_modes := {}      # Node -> исходный process_mode для персонажа и его детей

func _init() -> void:
	# Сам контроллер тоже должен работать, пока всё на паузе
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


static func start(excluded_root: Node, duration: float = DEFAULT_DURATION) -> void:
	# Если уже есть активный стоп-тайм — второй не запускаем
	if _active_controller and is_instance_valid(_active_controller):
		return

	if excluded_root == null:
		push_warning("TimeStop.start: excluded_root is null")
		return

	var tree := excluded_root.get_tree()
	if tree == null:
		push_warning("TimeStop.start: excluded_root is not in SceneTree")
		return

	var controller: TimeStop = TimeStop.new()
	controller._excluded_root = excluded_root
	controller._duration = duration
	tree.root.add_child(controller)
	_active_controller = controller


func _ready() -> void:
	_apply_time_stop()


func _apply_time_stop() -> void:
	if _excluded_root == null:
		queue_free()
		return

	var tree := get_tree()
	if tree == null:
		queue_free()
		return

	# 1. Запоминаем, была ли уже пауза
	_original_paused = tree.paused

	# 2. Делаем так, чтобы персонаж и его дети продолжали работать в паузе
	_mark_subtree_when_paused(_excluded_root)

	# 3. Ставим дерево на паузу — все, кроме отмеченных, замирают
	tree.paused = true

	# 4. Создаём затемнение экрана
	_create_overlay()

	# 5. Таймер на duration секунд
	var timer := Timer.new()
	timer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	timer.one_shot = true
	timer.wait_time = _duration
	add_child(timer)
	timer.timeout.connect(_on_time_stop_timeout)
	timer.start()


func _mark_subtree_when_paused(node: Node) -> void:
	# Рекурсивно помечаем персонажа и всех его детей как работающих во время паузы
	if node in _stored_process_modes:
		return

	_stored_process_modes[node] = node.process_mode
	node.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	for child in node.get_children():
		if child is Node:
			_mark_subtree_when_paused(child)


func _create_overlay() -> void:
	var canvas_layer := CanvasLayer.new()
	canvas_layer.name = "TimeStopOverlay"
	canvas_layer.layer = 100  # поверх всего
	canvas_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(canvas_layer)

	var rect := ColorRect.new()
	rect.color = Color(0, 0, 0, 0.5) # полупрозрачное затемнение
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	rect.anchor_left = 0.0
	rect.anchor_top = 0.0
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.offset_left = 0.0
	rect.offset_top = 0.0
	rect.offset_right = 0.0
	rect.offset_bottom = 0.0

	canvas_layer.add_child(rect)


func _on_time_stop_timeout() -> void:
	var tree := get_tree()

	# 1. Возвращаем паузу в исходное состояние
	if tree:
		tree.paused = _original_paused

	# 2. Возвращаем process_mode персонажа и его детей
	for node in _stored_process_modes.keys():
		if is_instance_valid(node):
			node.process_mode = _stored_process_modes[node]
	_stored_process_modes.clear()

	_active_controller = null
	queue_free()
