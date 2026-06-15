## result_screen.gd
## شاشة النتيجة - تعرض نتيجة الفوز أو الخسارة
## Result Screen - shows win or loss result

extends CanvasLayer

# ============================
# NODE REFERENCES / مراجع العقد
# ============================
@onready var result_title: Label = $Panel/VBox/TitleLabel
@onready var score_label: Label = $Panel/VBox/ScoreLabel
@onready var time_label: Label = $Panel/VBox/TimeLabel
@onready var gems_label: Label = $Panel/VBox/GemsLabel
@onready var stars_container: HBoxContainer = $Panel/VBox/StarsContainer
@onready var reason_label: Label = $Panel/VBox/ReasonLabel
@onready var retry_button: Button = $Panel/VBox/RetryButton
@onready var next_button: Button = $Panel/VBox/NextButton
@onready var menu_button: Button = $Panel/VBox/MenuButton
@onready var confetti_particles: GPUParticles3D = $ConfettiParticles
@onready var result_audio: AudioStreamPlayer = $ResultAudio
@onready var achievement_popup: Panel = $AchievementPopup

# ============================
# STATE / الحالة
# ============================
var is_win: bool = false
var final_score: int = 0
var current_level: int = 1
var stars: int = 0

# ============================
# SETUP / الإعداد
# ============================
func setup_result(won: bool, score: int, star_count: int, time_left: float, 
				  gems: int, gem_total: int, level_id: int) -> void:
	is_win = won
	final_score = score
	stars = star_count
	current_level = level_id
	
	_display_result(won, score, star_count, time_left, gems, gem_total)
	_animate_entrance()

func _ready() -> void:
	_connect_buttons()
	
	# الاستماع لإنجازات جديدة
	var save_sys = get_node_or_null("/root/SaveSystem")
	if save_sys:
		save_sys.achievement_unlocked.connect(_show_achievement_popup)

func _connect_buttons() -> void:
	if retry_button:
		retry_button.pressed.connect(_on_retry)
	if next_button:
		next_button.pressed.connect(_on_next_level)
	if menu_button:
		menu_button.pressed.connect(_on_menu)

func _display_result(won: bool, score: int, star_count: int, time_left: float, 
					  gems: int, gem_total: int) -> void:
	if won:
		# ===== شاشة الفوز =====
		result_title.text = "🎉 تهانينا! 🎉"
		result_title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
		
		score_label.text = "النقاط: %d" % score
		time_label.text = "الوقت المتبقي: %.1f ث" % time_left
		gems_label.text = "الجواهر: %d / %d 💎" % [gems, gem_total]
		
		_show_stars(star_count)
		
		if reason_label:
			reason_label.visible = false
		if next_button:
			next_button.visible = true
		
		# تأثيرات الفوز
		if confetti_particles:
			confetti_particles.emitting = true
		if result_audio:
			result_audio.stream = load("res://audio/victory.ogg")
			result_audio.play()
	
	else:
		# ===== شاشة الخسارة =====
		result_title.text = "😔 للأسف!"
		result_title.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
		
		score_label.text = "النقاط المحققة: %d" % score
		time_label.text = "لم تكمل المرحلة"
		gems_label.text = "الجواهر: %d / %d 💎" % [gems, gem_total]
		
		_show_stars(0)
		
		if next_button:
			next_button.visible = false
		
		if result_audio:
			result_audio.stream = load("res://audio/failure.ogg")
			result_audio.play()

func _show_stars(count: int) -> void:
	if not stars_container:
		return
	
	# حذف النجوم القديمة
	for child in stars_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	# إضافة النجوم الجديدة
	for i in range(3):
		var star := Label.new()
		star.text = "★" if i < count else "☆"
		star.add_theme_font_size_override("font_size", 48)
		star.add_theme_color_override("font_color", 
			Color(1.0, 0.8, 0.0) if i < count else Color(0.5, 0.5, 0.5))
		stars_container.add_child(star)
		
		# تأثير ظهور النجوم
		star.scale = Vector2.ZERO
		var tween = get_tree().create_tween()
		tween.tween_interval(i * 0.3)
		tween.tween_property(star, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BOUNCE)

func _animate_entrance() -> void:
	var panel = $Panel
	if panel:
		panel.scale = Vector2(0.0, 0.0)
		var tween = get_tree().create_tween()
		tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BOUNCE)

# ============================
# BUTTON HANDLERS / معالجات الأزرار
# ============================
func _on_retry() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.start_level(current_level)
	else:
		get_tree().change_scene_to_file("res://scenes/gameplay.tscn")

func _on_next_level() -> void:
	var next = current_level + 1
	if next > 1000:
		_show_completion_message()
		return
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.start_level(next)

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _show_completion_message() -> void:
	result_title.text = "👑 أكملت جميع المراحل! 👑"
	score_label.text = "أنت بطل المتاهة الحقيقي!"

func _show_achievement_popup(achievement_id: String) -> void:
	if not achievement_popup:
		return
	
	var ach_sys = get_node_or_null("/root/AchievementSystem")
	if not ach_sys:
		return
	
	var data = ach_sys.get_achievement_data(achievement_id)
	if data.is_empty():
		return
	
	var title_lbl = achievement_popup.get_node_or_null("Title")
	if title_lbl:
		title_lbl.text = data.get("icon", "🏆") + " " + data.get("title_ar", "إنجاز جديد!")
	
	achievement_popup.visible = true
	
	var tween = get_tree().create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(achievement_popup, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): 
		achievement_popup.visible = false
		achievement_popup.modulate.a = 1.0
	)
