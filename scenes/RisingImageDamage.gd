extends Node2D
class_name RisingImageDamage

@export var rise_time: float = 1.5
@export var hold_time: float = 5
@export var fall_time: float = 1.5

@export var damage_interval: float = 2.0   # было 1.0
@export var damage_amount: float = 1.0
@export var flash_duration: float = 1.0    # было 0.1


static var _active: RisingImageDamage = null

var _player: Node
var _texture_path: String

var _sprite: Sprite2D
var _damage_timer: Timer

var _start_pos: Vector2
var _target_pos: Vector2
var _hp_nodes: Array[Node] = []

static var _hit_shader: Shader = null

func _get_hit_shader() -> Shader:
	if _hit_shader == null:
		_hit_shader = Shader.new()
		_hit_shader.code = """
			shader_type canvas_item;
			uniform float hit : hint_range(0.0, 1.0) = 0.0;
			void fragment() {
				vec4 tex = texture(TEXTURE, UV);
				// смешиваем цвет текстуры с белым
				vec4 white = vec4(vec3(1.0), tex.a);
				COLOR = mix(tex, white, hit);
			}
		"""
	return _hit_shader


# ===== ПУБЛИЧНЫЙ ВХОД: ВЫЗОВ ЭФФЕКТА =====
static func cast(player: Node, texture_path: String) -> void:
	if _active and is_instance_valid(_active):
		return

	if player == null:
		push_warning("RisingImageDamage.cast: player is null")
		return

	var tree := player.get_tree()
	if tree == null:
		push_warning("RisingImageDamage.cast: player is not in SceneTree")
		return

	var inst := RisingImageDamage.new()
	inst._player = player
	inst._texture_path = texture_path

	# Вешаем эффект в текущую сцену (в мир)
	tree.current_scene.add_child(inst)
	_active = inst


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_sprite()
	if _sprite:
		_animate_up()
	else:
		queue_free()


# ===== СОЗДАЕМ СПРАЙТ В МИРЕ, ЦЕНТРУЕМ ПО КАМЕРЕ =====
func _create_sprite() -> void:
	var tex: Texture2D = load(_texture_path)
	if tex == null:
		push_error("RisingImageDamage: cannot load texture at path: " + _texture_path)
		return

	_sprite = Sprite2D.new()
	_sprite.texture = tex
	_sprite.centered = true
	_sprite.z_index = 0     # картинка позади остальных
	_sprite.scale = Vector2(3, 3)
	add_child(_sprite)

	var viewport := get_viewport()
	var cam := viewport.get_camera_2d()
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var tex_size: Vector2 = tex.get_size()

	# Экранные координаты: снизу по центру и центр экрана
	var bottom_screen := Vector2(viewport_size.x * 0.5, viewport_size.y + tex_size.y * 0.5)
	var center_screen := viewport_size * 0.5

	if cam:
		# Перевод из экранных координат в мировые с учетом камеры
		var inv := cam.get_canvas_transform().affine_inverse()
		_start_pos = inv * bottom_screen
		_target_pos = inv * center_screen
	else:
		# Фоллбек, если по какой-то причине камеры нет
		var inv_vp := viewport.get_canvas_transform().affine_inverse()
		_start_pos = inv_vp * bottom_screen
		_target_pos = inv_vp * center_screen

	_sprite.global_position = _start_pos


# ===== АНИМАЦИЯ ВВЕРХ / ВИСЕНИЕ / ВНИЗ =====
func _animate_up() -> void:
	var tween := create_tween()

	# Подъем снизу до центра
	tween.tween_property(_sprite, "global_position", _target_pos, rise_time)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# В центре — начинаем наносить урон
	tween.tween_callback(_on_reached_center)

	# Держим в центре hold_time секунд
	tween.tween_interval(hold_time)

	# Останавливаем урон
	tween.tween_callback(_on_hold_finished)

	# Опускаем обратно
	tween.tween_property(_sprite, "global_position", _start_pos, fall_time)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Удаляем эффект
	tween.tween_callback(_on_finished)


# ===== ФАЗА УРОНА =====
func _on_reached_center() -> void:
	_collect_hp_nodes()

	_damage_timer = Timer.new()
	_damage_timer.wait_time = damage_interval
	_damage_timer.one_shot = false
	add_child(_damage_timer)
	_damage_timer.timeout.connect(_on_damage_tick)
	_damage_timer.start()


func _on_hold_finished() -> void:
	if _damage_timer and is_instance_valid(_damage_timer):
		_damage_timer.stop()


func _on_finished() -> void:
	_active = null
	queue_free()


# ===== ПОИСК НОД С hp =====
func _has_hp_property(obj: Object) -> bool:
	for prop in obj.get_property_list():
		if prop.name == "hp":
			return true
	return false


func _collect_hp_nodes() -> void:
	_hp_nodes.clear()
	var root := get_tree().root
	_collect_hp_in_subtree(root)


func _collect_hp_in_subtree(node: Node) -> void:
	if node != _player and _has_hp_property(node):
		_hp_nodes.append(node)

	for child in node.get_children():
		if child is Node:
			_collect_hp_in_subtree(child)


# ===== НАНЕСЕНИЕ УРОНА =====
func _on_damage_tick() -> void:
	for victim in _hp_nodes.duplicate():
		if not is_instance_valid(victim):
			_hp_nodes.erase(victim)
			continue

		if victim == _player:
			continue

		if not _has_hp_property(victim):
			_hp_nodes.erase(victim)
			continue

		var hp_val = victim.get("HP")
		var t := typeof(hp_val)
		if t != TYPE_INT and t != TYPE_FLOAT:
			continue

		victim.set("HP", hp_val - damage_amount)

		_flash_node_white(victim)


# ===== ВСПЫШКА БЕЛЫМ =====
func _flash_node_white(victim: Node) -> void:
	# Collect every CanvasItem under the victim to flash them together
	var items: Array[CanvasItem] = []

	if victim is CanvasItem:
		items.append(victim as CanvasItem)
	else:
		_collect_canvas_items(victim, items)

	if items.is_empty():
		return

	for ci in items:
		if not is_instance_valid(ci):
			continue

		var original_material: Material = ci.material

		var mat := ShaderMaterial.new()
		mat.shader = _get_hit_shader()
		mat.set_shader_parameter("hit", 1.0)
		ci.material = mat
		ci.queue_redraw()

		var tween := create_tween()
		tween.tween_interval(flash_duration)
		tween.tween_callback(func (target := ci, restore_material := original_material):
			if is_instance_valid(target):
				target.material = restore_material
				target.queue_redraw())


func _collect_canvas_items(node: Node, out: Array[CanvasItem]) -> void:
	for child in node.get_children():
		if child is CanvasItem:
			out.append(child as CanvasItem)
		# Рекурсивно спускаемся ниже
		if child.get_child_count() > 0:
			_collect_canvas_items(child, out)
