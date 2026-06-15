## game_manager.gd
## مدير اللعبة - المتحكم المركزي الذي يربط جميع الأنظمة
## Game Manager - central controller linking all systems

extends Node

# ============================
# AUTOLOAD SINGLETON / النمط المفرد
# ============================
# يُضاف في Project > Project Settings > Autoload

# ============================
# ENUMS / التعدادات
# ============================
enum GameState { MAIN_MENU, CHARACTER_SELECT, STAGE_SELECT, PLAYING, PAUSED, RESULT, SETTINGS }

# ============================
# EXPORTS
# ============================
@export var save_system_path: NodePath

# ============================
# NODE REFERENCES / مراجع العقد
# ============================
var save_system: Node
var current_player: CharacterBody3D
var world_manager_node: Node
var ui_manager_node: Node
var camera_controller_node: Node

# ============================
# GAME STATE / حالة اللعبة
# ============================
var game_state: GameState = GameState.MAIN_MENU
var selected_character: int = 0  # CharacterType
var current_level: int = 1

# ============================
# TIMER SYSTEM / نظام المؤقت
# ============================
var timer_remaining: float = 60.0
var timer_running: bool = false
var total_elapsed_time: float = 0.0

# ============================
# SCORE SYSTEM / نظام النقاط
# ============================
var current_score: int = 0
var gems_collected: int = 0
var gems_total: int = 10
var enemy_hits: int = 0
var no_enemy_hits_this_run: bool = true

# ============================
# PATH VISUALIZATION / مسار اللص
# ============================
var path_markers: Array[MeshInstance3D] = []
var path_visible: bool = false

# ============================
# CAMERA SHAKE / اهتزاز الكاميرا
# ============================
var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var original_camera_offset: Vector3

# ============================
# SIGNALS / الإشارات
# ============================
signal game_started(level: int)
signal game_won(score: int, stars: int)
signal game_lost(reason: String)
signal timer_updated(time: float)
signal score_updated(score: int)
signal gem_collected_signal(total: int)
signal level_changed(level: int)

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# الحصول على SaveSystem من Autoload
	save_system = get_node_or_null("/root/SaveSystem")
	if not save_system:
		push_error("[GameManager] SaveSystem not found in Autoload!")
	
	# الاستجابة لإنجاز الإنجازات
	if save_system:
		save_system.achievement_unlocked.connect(_on_achievement_unlocked)
	
	print("[GameManager] Ready / جاهز")

func _process(delta: float) -> void:
	if game_state != GameState.PLAYING:
		return
	
	_update_timer(delta)
	_update_camera_shake(delta)

# ============================
# SCENE MANAGEMENT / إدارة المشاهد
# ============================

func go_to_main_menu() -> void:
	game_state = GameState.MAIN_MENU
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func go_to_character_select() -> void:
	game_state = GameState.CHARACTER_SELECT
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")

func go_to_stage_select() -> void:
	game_state = GameState.STAGE_SELECT
	get_tree().change_scene_to_file("res://scenes/stage_select.tscn")

func select_character(char_type: int) -> void:
	selected_character = char_type
	print("[GameManager] Character selected: " + str(char_type))

func start_level(level_id: int) -> void:
	## بدء مرحلة محددة
	if save_system and not save_system.is_level_unlocked(level_id):
		push_warning("[GameManager] Level %d is locked!" % level_id)
		return
	
	current_level = level_id
	_reset_level_stats()
	game_state = GameState.PLAYING
	
	get_tree().change_scene_to_file("res://scenes/gameplay.tscn")
	emit_signal("game_started", level_id)
	emit_signal("level_changed", level_id)

func _reset_level_stats() -> void:
	var config = DifficultyCurve.get_level_config(current_level)
	timer_remaining = config.timer_seconds
	timer_running = false
	total_elapsed_time = 0.0
	current_score = 0
	gems_collected = 0
	gems_total = config.gem_count
	enemy_hits = 0
	no_enemy_hits_this_run = true
	Engine.time_scale = 1.0

func begin_playing() -> void:
	## يُستدعى عندما تنتهي مرحلة التحميل
	timer_running = true
	print("[GameManager] Level %d started / بدأت المرحلة %d" % [current_level, current_level])

# ============================
# TIMER / المؤقت
# ============================

func _update_timer(delta: float) -> void:
	if not timer_running:
		return
	
	timer_remaining -= delta
	total_elapsed_time += delta
	
	if timer_remaining <= 0.0:
		timer_remaining = 0.0
		timer_running = false
		_trigger_game_over("انتهى الوقت - Time's Up!")
	
	emit_signal("timer_updated", timer_remaining)

func add_time(seconds: float) -> void:
	timer_remaining += seconds
	print("[GameManager] Added %.1f seconds" % seconds)

func deduct_time(seconds: float) -> void:
	timer_remaining -= seconds
	timer_remaining = max(0.0, timer_remaining)
	
	if timer_remaining <= 0.0:
		_trigger_game_over("انتهى الوقت - Time's Up!")

# ============================
# SCORE / النقاط
# ============================

func add_score(points: int) -> void:
	current_score += points
	emit_signal("score_updated", current_score)

func deduct_score(points: int) -> void:
	current_score = max(0, current_score - points)
	emit_signal("score_updated", current_score)

# ============================
# GEM COLLECTION / جمع الجواهر
# ============================

func collect_gem() -> void:
	gems_collected += 1
	add_score(10)
	add_time(1.0)
	
	emit_signal("gem_collected_signal", gems_collected)
	print("[GameManager] Gem collected: %d/%d" % [gems_collected, gems_total])

# ============================
# TREE COLLISION / الاصطدام بالشجرة
# ============================

func on_player_hit_tree() -> void:
	deduct_time(0.5)
	deduct_score(1)

# ============================
# ENEMY COLLISION / الاصطدام بالعدو
# ============================

func on_player_caught_by_enemy() -> void:
	enemy_hits += 1
	no_enemy_hits_this_run = false
	deduct_time(15.0)
	shake_camera(0.5, 0.4)
	
	# إعادة اللاعب لنقطة البداية
	if current_player and world_manager_node:
		var start_pos = world_manager_node.get_start_position()
		current_player.global_position = start_pos
	
	print("[GameManager] Player caught! Hits: %d" % enemy_hits)
	
	if timer_remaining <= 0.0:
		_trigger_game_over("اصطادك العدو وانتهى وقتك!")

# ============================
# WIN / الفوز
# ============================

func on_player_reached_exit() -> void:
	if game_state != GameState.PLAYING:
		return
	
	timer_running = false
	game_state = GameState.RESULT
	Engine.time_scale = 1.0
	
	# حساب النقاط النهائية
	var bonus = int(timer_remaining * 2.0) + (gems_collected * 5)
	var total_score = current_score + bonus
	var stars = DifficultyCurve.calculate_stars(
		current_level,
		timer_remaining,
		gems_collected,
		gems_total
	)
	
	current_score = total_score
	
	# حفظ النتيجة
	if save_system:
		var time_ms = int(total_elapsed_time * 1000)
		save_system.save_level_result(current_level, time_ms, total_score, gems_collected, stars)
	
	emit_signal("game_won", total_score, stars)
	print("[GameManager] WIN! Score: %d, Stars: %d" % [total_score, stars])
	
	# الانتقال لشاشة النتائج بعد تأخير بسيط
	await get_tree().create_timer(1.5).timeout
	_show_result_screen(true, total_score, stars)

# ============================
# GAME OVER / الخسارة
# ============================

func _trigger_game_over(reason: String) -> void:
	if game_state != GameState.PLAYING:
		return
	
	timer_running = false
	game_state = GameState.RESULT
	Engine.time_scale = 1.0
	
	# تحديث الإحصائيات
	if save_system:
		save_system.global_stats["total_losses"] += 1
		save_system.global_stats["current_win_streak"] = 0
		save_system.save_all_data()
	
	emit_signal("game_lost", reason)
	print("[GameManager] GAME OVER: " + reason)
	
	await get_tree().create_timer(1.0).timeout
	_show_result_screen(false, current_score, 0)

func _show_result_screen(won: bool, score: int, stars: int) -> void:
	## الانتقال لشاشة النتائج مع تمرير البيانات
	get_tree().change_scene_to_file("res://scenes/result_screen.tscn")
	
	# نقل البيانات للشاشة التالية
	await get_tree().process_frame
	var result_screen = get_tree().current_scene
	if result_screen and result_screen.has_method("setup_result"):
		result_screen.setup_result(
			won, score, stars,
			timer_remaining if won else 0.0,
			gems_collected, gems_total,
			current_level
		)

# ============================
# THIEF ABILITY - PATH DISPLAY / قدرة اللص
# ============================

func show_path_to_exit(player_cell: Vector2i) -> void:
	## عرض أقصر مسار للخروج (قدرة اللص)
	_clear_path_markers()
	
	if not world_manager_node:
		return
	
	var config = world_manager_node.get_current_config()
	var goal = Vector2i(config.maze_width - 1, config.maze_height - 1)
	
	# الحصول على المولد
	var gen: MazeGenerator = world_manager_node.maze_generator
	if not gen:
		return
	
	var path = gen.find_shortest_path(player_cell, goal)
	
	# رسم المسار بخطوط ذهبية
	for cell in path:
		var marker = MeshInstance3D.new()
		var plane = PlaneMesh.new()
		plane.size = Vector2(0.5, 0.5)
		marker.mesh = plane
		
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.8, 0.0, 0.8)
		mat.emission_enabled = true
		mat.emission = Color(1.0, 0.8, 0.0)
		mat.emission_energy_multiplier = 2.0
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		marker.material_override = mat
		
		marker.position = Vector3(cell.x * 4.0, 0.05, cell.y * 4.0)
		get_tree().current_scene.add_child(marker)
		path_markers.append(marker)
	
	path_visible = true
	
	# إخفاء المسار بعد 5 ثوانٍ
	await get_tree().create_timer(5.0).timeout
	_clear_path_markers()

func _clear_path_markers() -> void:
	for marker in path_markers:
		if is_instance_valid(marker):
			marker.queue_free()
	path_markers.clear()
	path_visible = false

# ============================
# CAMERA SHAKE / اهتزاز الكاميرا
# ============================

func shake_camera(duration: float, intensity: float) -> void:
	shake_intensity = intensity
	shake_timer = duration

func _update_camera_shake(delta: float) -> void:
	if shake_timer <= 0.0 or not current_player:
		shake_intensity = 0.0
		return
	
	shake_timer -= delta
	
	var cam = current_player.camera_3d
	if cam:
		var offset = Vector3(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity),
			0.0
		)
		cam.h_offset = offset.x
		cam.v_offset = offset.y

# ============================
# PAUSE / الإيقاف المؤقت
# ============================

func pause_game() -> void:
	if game_state == GameState.PLAYING:
		game_state = GameState.PAUSED
		get_tree().paused = true

func resume_game() -> void:
	if game_state == GameState.PAUSED:
		game_state = GameState.PLAYING
		get_tree().paused = false

# ============================
# ACHIEVEMENTS / الإنجازات
# ============================

func _on_achievement_unlocked(achievement_id: String) -> void:
	## عرض إشعار الإنجاز
	print("[GameManager] Achievement unlocked: " + achievement_id)
	# سيُعرض عبر UIManager

# ============================
# QUALITY SETTINGS / إعدادات الجودة
# ============================

func apply_graphics_quality(level: int) -> void:
	## 0 = منخفض, 1 = متوسط, 2 = عالي
	match level:
		0:  # منخفض - Low
			RenderingServer.directional_shadow_atlas_set_size(1024, true)
			ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_converge", 1)
			ProjectSettings.set_setting("rendering/environment/volumetric_fog/volume_size", 32)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 0)
			print("[Quality] Low quality applied")
		1:  # متوسط - Medium
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
			ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_converge", 3)
			ProjectSettings.set_setting("rendering/environment/volumetric_fog/volume_size", 64)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 1)
			print("[Quality] Medium quality applied")
		2:  # عالي - High
			RenderingServer.directional_shadow_atlas_set_size(4096, true)
			ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_converge", 5)
			ProjectSettings.set_setting("rendering/environment/volumetric_fog/volume_size", 128)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 2)
			print("[Quality] High quality applied")
	
	# حفظ الإعداد
	if save_system:
		save_system.set_setting("graphics_quality", level)

# ============================
# GETTERS / الحاصلات
# ============================

func get_current_level_config() -> DifficultyCurve.LevelConfig:
	return DifficultyCurve.get_level_config(current_level)

func get_world_for_level(level_id: int) -> int:
	return ceili(float(level_id) / 100.0)
