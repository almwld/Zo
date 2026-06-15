## ui_manager.gd
## مدير واجهة المستخدم - يتحكم في جميع عناصر HUD والشاشات
## UI Manager - controls all HUD elements and screens

extends CanvasLayer

# ============================
# HUD REFERENCES / مراجع HUD
# ============================
@onready var timer_label: Label = $HUD/TimerLabel
@onready var score_label: Label = $HUD/ScoreLabel
@onready var gems_label: Label = $HUD/GemsLabel
@onready var ability_button: Button = $HUD/AbilityButton
@onready var ability_cooldown_bar: ProgressBar = $HUD/AbilityCooldownBar
@onready var minimap_container: SubViewportContainer = $HUD/MinimapContainer
@onready var minimap_viewport: SubViewport = $HUD/MinimapContainer/SubViewport
@onready var joystick_container: Control = $HUD/JoystickContainer
@onready var pause_button: Button = $HUD/PauseButton
@onready var fog_vignette: ColorRect = $HUD/FogVignette

# مكونات الجمبستيك الافتراضي
@onready var joystick_base: Control = $HUD/JoystickContainer/JoystickBase
@onready var joystick_knob: Control = $HUD/JoystickContainer/JoystickBase/JoystickKnob

# ============================
# MINIMAP NODES / عناصر المينيماب
# ============================
var minimap_player_dot: Control
var minimap_enemy_dots: Array[Control] = []
var minimap_gem_dots: Array[Control] = []
var minimap_exit_dot: Control
var minimap_scale: float = 4.0

# ============================
# JOYSTICK STATE / حالة الجمبستيك
# ============================
var joystick_active: bool = false
var joystick_touch_id: int = -1
var joystick_origin: Vector2 = Vector2.ZERO
var joystick_radius: float = 80.0
var joystick_direction: Vector2 = Vector2.ZERO

# ============================
# REFERENCES / المراجع
# ============================
var player_ref: CharacterBody3D
var game_manager: Node
var world_config: DifficultyCurve.LevelConfig

# ============================
# SIGNALS / الإشارات
# ============================
signal joystick_moved(direction: Vector2)
signal ability_button_pressed
signal pause_pressed

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	game_manager = get_node_or_null("/root/GameManager")
	
	if game_manager:
		game_manager.timer_updated.connect(_on_timer_updated)
		game_manager.score_updated.connect(_on_score_updated)
		game_manager.gem_collected_signal.connect(_on_gem_collected)
	
	_setup_minimap()
	_setup_fog_vignette()
	_connect_buttons()
	
	# الحصول على إعدادات المرحلة
	if game_manager:
		world_config = game_manager.get_current_level_config()
		_update_ability_button()

func _connect_buttons() -> void:
	if ability_button:
		ability_button.pressed.connect(_on_ability_button_pressed)
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)

# ============================
# TIMER DISPLAY / عرض المؤقت
# ============================

func _on_timer_updated(time: float) -> void:
	if not timer_label:
		return
	
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var ms = int((time - int(time)) * 10)
	
	timer_label.text = "%02d:%02d.%01d" % [minutes, seconds, ms]
	
	# تحويل لون المؤقت للأحمر عند 10 ثوانٍ
	if time <= 10.0:
		timer_label.add_theme_color_override("font_color", Color.RED)
		# إضافة تأثير نبض
		var scale_tween = get_tree().create_tween()
		scale_tween.tween_property(timer_label, "scale", Vector2(1.2, 1.2), 0.2)
		scale_tween.tween_property(timer_label, "scale", Vector2(1.0, 1.0), 0.2)
	elif time <= 20.0:
		timer_label.add_theme_color_override("font_color", Color.ORANGE)
	else:
		timer_label.add_theme_color_override("font_color", Color.WHITE)

# ============================
# SCORE DISPLAY / عرض النقاط
# ============================

func _on_score_updated(score: int) -> void:
	if score_label:
		score_label.text = "النقاط: %d" % score
		# تأثير بصري عند زيادة النقاط
		var tween = get_tree().create_tween()
		tween.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.1)
		tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1)

func _on_gem_collected(total: int) -> void:
	if gems_label and world_config:
		gems_label.text = "💎 %d/%d" % [total, world_config.gem_count]

# ============================
# ABILITY BUTTON / زر القدرة
# ============================

func _update_ability_button() -> void:
	if not ability_button or not world_config:
		return
	
	# تحديث نص ولون زر القدرة حسب الشخصية
	var char_type = game_manager.selected_character if game_manager else 0
	match char_type:
		0:  # الفارس
			ability_button.text = "⚡"
			ability_button.modulate = Color(0.2, 0.8, 0.2)
		1:  # الساحر
			ability_button.text = "🌀"
			ability_button.modulate = Color(0.2, 0.4, 1.0)
		2:  # الأميرة
			ability_button.text = "⏳"
			ability_button.modulate = Color(1.0, 0.8, 0.2)
		3:  # اللص
			ability_button.text = "👁"
			ability_button.modulate = Color(0.2, 0.2, 0.2)

func update_ability_cooldown(percent: float) -> void:
	## تحديث شريط انتظار القدرة (0.0 - 1.0)
	if ability_cooldown_bar:
		ability_cooldown_bar.value = percent * 100.0
	
	if ability_button:
		ability_button.disabled = percent < 1.0

func _on_ability_button_pressed() -> void:
	emit_signal("ability_button_pressed")

func _on_pause_pressed() -> void:
	emit_signal("pause_pressed")

# ============================
# VIRTUAL JOYSTICK / الجمبستيك الافتراضي
# ============================

func _input(event: InputEvent) -> void:
	_handle_joystick_input(event)

func _handle_joystick_input(event: InputEvent) -> void:
	if not joystick_base:
		return
	
	if event is InputEventScreenTouch:
		var touch = event as InputEventScreenTouch
		
		if touch.pressed:
			# التحقق أن اللمس في منطقة الجمبستيك (النصف الأيسر السفلي)
			var screen_size = get_viewport().get_visible_rect().size
			if touch.position.x < screen_size.x * 0.5 and touch.position.y > screen_size.y * 0.5:
				joystick_active = true
				joystick_touch_id = touch.index
				joystick_origin = touch.position
				joystick_base.global_position = touch.position - joystick_base.size / 2
		else:
			if touch.index == joystick_touch_id:
				joystick_active = false
				joystick_touch_id = -1
				joystick_direction = Vector2.ZERO
				if joystick_knob:
					joystick_knob.position = joystick_base.size / 2 - joystick_knob.size / 2
				emit_signal("joystick_moved", Vector2.ZERO)
	
	elif event is InputEventScreenDrag:
		var drag = event as InputEventScreenDrag
		if drag.index == joystick_touch_id and joystick_active:
			var offset = drag.position - joystick_origin
			var clamped = offset.clamp(
				Vector2(-joystick_radius, -joystick_radius),
				Vector2(joystick_radius, joystick_radius)
			)
			
			if offset.length() > joystick_radius:
				clamped = offset.normalized() * joystick_radius
			
			joystick_direction = clamped / joystick_radius
			
			if joystick_knob:
				joystick_knob.position = joystick_base.size / 2 - joystick_knob.size / 2 + clamped
			
			emit_signal("joystick_moved", joystick_direction)

# ============================
# MINIMAP / الخريطة المصغرة
# ============================

func _setup_minimap() -> void:
	if not minimap_container:
		return
	
	# إنشاء نقطة اللاعب
	minimap_player_dot = _create_minimap_dot(Color.GREEN, 6.0)
	minimap_viewport.add_child(minimap_player_dot)
	
	# إنشاء نقطة الخروج
	minimap_exit_dot = _create_minimap_dot(Color(1.0, 0.8, 0.0), 8.0)
	minimap_viewport.add_child(minimap_exit_dot)

func _create_minimap_dot(color: Color, size: float) -> Control:
	var dot = ColorRect.new()
	dot.size = Vector2(size, size)
	dot.color = color
	return dot

func update_minimap(player_pos: Vector3, enemy_positions: Array, gem_positions: Array, 
					maze_width: int, maze_height: int) -> void:
	## تحديث الخريطة المصغرة
	if not minimap_viewport:
		return
	
	var map_size = minimap_viewport.size
	var scale_x = map_size.x / float(maze_width * 4)
	var scale_y = map_size.y / float(maze_height * 4)
	
	# تحديث موقع اللاعب
	if minimap_player_dot:
		minimap_player_dot.position = Vector2(
			player_pos.x * scale_x - 3,
			player_pos.z * scale_y - 3
		)
	
	# تحديث موقع الخروج
	if minimap_exit_dot:
		minimap_exit_dot.position = Vector2(
			(maze_width - 1) * 4 * scale_x - 4,
			(maze_height - 1) * 4 * scale_y - 4
		)
	
	# تحديث مواقع الأعداء
	_update_minimap_dots(enemy_positions, minimap_enemy_dots, Color.RED, 5.0, scale_x, scale_y)
	
	# تحديث مواقع الجواهر
	_update_minimap_dots(gem_positions, minimap_gem_dots, Color.CYAN, 4.0, scale_x, scale_y)

func _update_minimap_dots(positions: Array, dots: Array, color: Color, 
							size: float, sx: float, sy: float) -> void:
	# حذف الزيادة
	while dots.size() > positions.size():
		if is_instance_valid(dots.back()):
			dots.back().queue_free()
		dots.pop_back()
	
	# إضافة الناقص
	while dots.size() < positions.size():
		var dot = _create_minimap_dot(color, size)
		minimap_viewport.add_child(dot)
		dots.append(dot)
	
	# تحديث المواقع
	for i in range(positions.size()):
		if is_instance_valid(dots[i]):
			var pos = positions[i] as Vector3
			dots[i].position = Vector2(pos.x * sx - size/2, pos.z * sy - size/2)

# ============================
# FOG VIGNETTE / ضباب الحواف
# ============================

func _setup_fog_vignette() -> void:
	if not fog_vignette:
		return
	
	fog_vignette.color = Color(0, 0, 0, 0)
	fog_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_fog_vignette(wall_proximity: float) -> void:
	## تكثيف الضباب عند الاقتراب من الجدران (0.0 - 1.0)
	if fog_vignette:
		var alpha = wall_proximity * 0.5
		fog_vignette.color = Color(0, 0, 0, alpha)

# ============================
# ACHIEVEMENT NOTIFICATION / إشعار الإنجاز
# ============================

func show_achievement_notification(title: String, description: String) -> void:
	var notification = Label.new()
	notification.text = "🏆 " + title + "\n" + description
	notification.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	notification.set_anchors_and_offsets_preset(Control.PRESET_TOP_CENTER)
	notification.position.y = 100
	add_child(notification)
	
	var tween = get_tree().create_tween()
	tween.tween_property(notification, "position:y", 50, 0.3)
	tween.tween_interval(2.0)
	tween.tween_property(notification, "modulate:a", 0.0, 0.5)
	tween.tween_callback(notification.queue_free)

# ============================
# PAUSE MENU / قائمة الإيقاف
# ============================

func show_pause_menu() -> void:
	var pause_overlay = CanvasLayer.new()
	pause_overlay.name = "PauseMenu"
	pause_overlay.layer = 10
	add_child(pause_overlay)
	
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(300, 400)
	pause_overlay.add_child(panel)
	
	# أزرار الإيقاف
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var resume_btn = Button.new()
	resume_btn.text = "متابعة"
	resume_btn.pressed.connect(func():
		pause_overlay.queue_free()
		game_manager.resume_game() if game_manager else null
	)
	vbox.add_child(resume_btn)
	
	var quit_btn = Button.new()
	quit_btn.text = "القائمة الرئيسية"
	quit_btn.pressed.connect(func():
		game_manager.go_to_main_menu() if game_manager else null
	)
	vbox.add_child(quit_btn)

func _on_pause_pressed() -> void:
	emit_signal("pause_pressed")
	show_pause_menu()
	game_manager.pause_game() if game_manager else null
