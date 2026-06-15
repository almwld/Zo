## stage_select.gd
## شاشة اختيار المراحل - خريطة تفاعلية لـ 1000 مرحلة
## Stage Select - Interactive map for 1000 levels

extends Control

# ============================
# WORLD DATA / بيانات العوالم
# ============================
const WORLD_NAMES := [
	"🌸 حديقة الربيع", "🍂 غابة الخريف", "❄ مملكة الجليد",
	"🏜 صحراء الرمال", "🌑 غابة الظلام", "🔥 أرض النار",
	"🌊 أتلانتس", "✨ عالم الأحلام", "🌀 عالم الفوضى",
	"🌌 عالم الفراغ"
]

const WORLD_COLORS := [
	Color(0.6, 0.9, 0.5), Color(0.8, 0.4, 0.1), Color(0.7, 0.85, 1.0),
	Color(0.95, 0.8, 0.3), Color(0.15, 0.1, 0.2), Color(0.8, 0.2, 0.0),
	Color(0.0, 0.5, 0.8), Color(0.5, 0.1, 0.8), Color(0.5, 0.5, 0.5),
	Color(0.1, 0.0, 0.2)
]

# ============================
# REFERENCES / المراجع
# ============================
@onready var world_tabs: TabContainer = $WorldTabs
@onready var back_button: Button = $TopBar/BackButton
@onready var cheat_code_input: LineEdit = $CheatCodePanel/LineEdit
@onready var cheat_submit: Button = $CheatCodePanel/SubmitButton
@onready var progress_label: Label = $TopBar/ProgressLabel

var save_system: Node
var game_manager: Node
var level_buttons: Array = []

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	save_system = get_node_or_null("/root/SaveSystem")
	game_manager = get_node_or_null("/root/GameManager")
	
	_build_world_tabs()
	_connect_signals()
	_update_progress_label()

func _connect_signals() -> void:
	if back_button:
		back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	if cheat_submit:
		cheat_submit.pressed.connect(_on_cheat_submit)

func _build_world_tabs() -> void:
	## بناء تاب لكل عالم (10 عوالم)
	if not world_tabs:
		return
	
	for world_idx in range(10):
		var tab_content = _create_world_tab(world_idx + 1)
		world_tabs.add_child(tab_content)
		world_tabs.set_tab_title(world_idx, WORLD_NAMES[world_idx])

func _create_world_tab(world_id: int) -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.name = "World_%02d" % world_id
	
	var grid := GridContainer.new()
	grid.columns = 10
	scroll.add_child(grid)
	
	var start_level = (world_id - 1) * 100 + 1
	var world_color = WORLD_COLORS[world_id - 1]
	
	# إنشاء 100 زر لكل عالم
	for i in range(100):
		var level_id = start_level + i
		var btn = _create_level_button(level_id, world_color)
		grid.add_child(btn)
		level_buttons.append(btn)
	
	return scroll

func _create_level_button(level_id: int, world_color: Color) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(70, 70)
	btn.name = "Level_%d" % level_id
	
	var is_completed = save_system.level_data.get(level_id, {}).get("completed", false) if save_system else false
	var is_unlocked = save_system.is_level_unlocked(level_id) if save_system else (level_id == 1)
	var stars = save_system.get_level_stars(level_id) if save_system else 0
	
	if not is_unlocked:
		# مرحلة مقفلة
		btn.text = "🔒\n%d" % level_id
		btn.modulate = Color(0.5, 0.5, 0.5)
		btn.disabled = true
	elif is_completed:
		# مرحلة مكتملة
		var star_str = "★" * stars + "☆" * (3 - stars)
		btn.text = "%d\n%s" % [level_id, star_str]
		btn.modulate = world_color
	else:
		# مرحلة متاحة
		btn.text = "▶\n%d" % level_id
		btn.modulate = world_color * 0.7
	
	btn.pressed.connect(func(): _on_level_selected(level_id, is_unlocked))
	return btn

func _on_level_selected(level_id: int, is_unlocked: bool) -> void:
	if not is_unlocked:
		_show_locked_message(level_id)
		return
	
	if game_manager:
		game_manager.start_level(level_id)
	else:
		get_tree().change_scene_to_file("res://scenes/gameplay.tscn")

func _show_locked_message(level_id: int) -> void:
	var req_level = level_id - 1
	_show_toast("أكمل المرحلة %d أولاً لفتح المرحلة %d" % [req_level, level_id])

func _update_progress_label() -> void:
	if not progress_label or not save_system:
		return
	
	var total_completed = 0
	for i in range(1, 1001):
		if save_system.level_data.get(i, {}).get("completed", false):
			total_completed += 1
	
	progress_label.text = "تقدمك: %d / 1000 (%.1f%%)" % [total_completed, float(total_completed) / 10.0]

func _on_cheat_submit() -> void:
	if not cheat_code_input or not save_system:
		return
	
	var code = cheat_code_input.text.strip_edges().to_upper()
	if save_system.apply_cheat_code(code):
		_show_toast("✅ تم تطبيق الشيفرة: " + code)
		_rebuild_all_buttons()
	else:
		_show_toast("❌ شيفرة غير صالحة أو مستخدمة مسبقاً")
	
	cheat_code_input.text = ""

func _rebuild_all_buttons() -> void:
	## إعادة بناء الأزرار بعد تطبيق الشيفرة
	for btn in level_buttons:
		if is_instance_valid(btn):
			btn.queue_free()
	level_buttons.clear()
	
	for child in world_tabs.get_children():
		child.queue_free()
	
	_build_world_tabs()
	_update_progress_label()

func _show_toast(message: String) -> void:
	var toast := Label.new()
	toast.text = message
	toast.add_theme_color_override("font_color", Color.WHITE)
	toast.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	toast.position.y -= 100
	add_child(toast)
	
	var tween = get_tree().create_tween()
	tween.tween_property(toast, "modulate:a", 0.0, 3.0)
	tween.tween_callback(toast.queue_free)
