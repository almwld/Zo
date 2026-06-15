## save_system.gd
## نظام الحفظ والتحميل - Save & Load System
## يدير جميع بيانات اللاعب المحفوظة باستخدام ConfigFile

extends Node

# ============================
# CONSTANTS / الثوابت
# ============================
const SAVE_PATH := "user://save_data.cfg"
const ACHIEVEMENTS_PATH := "user://achievements.cfg"

# ============================
# DATA STRUCTURES / هياكل البيانات
# ============================

## بيانات كل مرحلة - Per-level data
var level_data := {}
## إحصائيات الشخصيات - Character statistics
var character_stats := {}
## الإنجازات - Achievements
var achievements := {}
## الإعدادات - Settings
var settings := {}
## الإحصائيات العامة - Global stats
var global_stats := {}

# ============================
# SIGNALS / الإشارات
# ============================
signal data_saved
signal data_loaded
signal achievement_unlocked(achievement_id: String)

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	_initialize_defaults()
	load_all_data()

func _initialize_defaults() -> void:
	## تهيئة القيم الافتراضية للإعدادات
	settings = {
		"graphics_quality": 2,   # 0=low, 1=medium, 2=high
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"vibration": true,
		"language": "ar",
		"show_fps": false,
		"shadow_quality": 2,
		"particles_enabled": true
	}
	
	## تهيئة الإحصائيات العامة
	global_stats = {
		"total_gems_collected": 0,
		"total_enemies_evaded": 0,
		"total_wins": 0,
		"total_losses": 0,
		"best_win_streak": 0,
		"current_win_streak": 0,
		"total_play_time": 0.0,
		"highest_level_reached": 1,
		"unlocked_codes": []
	}
	
	## تهيئة إحصائيات الشخصيات الأربع
	for char_id in ["knight", "wizard", "princess", "thief"]:
		character_stats[char_id] = {
			"wins": 0,
			"best_time_ms": -1,
			"highest_score": 0,
			"ability_uses": 0
		}
	
	## تهيئة الإنجازات
	achievements = {
		"first_win": {"unlocked": false, "name": "أول انتصار", "desc": "أكمل مرحلتك الأولى"},
		"level_10": {"unlocked": false, "name": "المبتدئ", "desc": "أكمل 10 مراحل"},
		"level_50": {"unlocked": false, "name": "المحترف", "desc": "أكمل 50 مرحلة"},
		"level_100": {"unlocked": false, "name": "الخبير", "desc": "أكمل 100 مرحلة"},
		"level_500": {"unlocked": false, "name": "الأسطورة", "desc": "أكمل 500 مرحلة"},
		"gems_500": {"unlocked": false, "name": "جامع الجواهر", "desc": "اجمع 500 جوهرة"},
		"streak_10": {"unlocked": false, "name": "سلسلة انتصارات", "desc": "10 انتصارات متتالية"},
		"perfect_run": {"unlocked": false, "name": "الركض المثالي", "desc": "اجمع كل الجواهر في مرحلة واحدة"},
		"speedrun": {"unlocked": false, "name": "الركض السريع", "desc": "أكمل مرحلة في أقل من 10 ثوانٍ"},
		"no_damage": {"unlocked": false, "name": "لا مس", "desc": "أكمل 10 مراحل متتالية بدون الاصطدام بالعدو"},
		"all_chars": {"unlocked": false, "name": "البطل الكامل", "desc": "افوز بمرحلة بكل شخصية"},
		"void_master": {"unlocked": false, "name": "سيد الفراغ", "desc": "أكمل مرحلة من عالم الفراغ"},
	}

# ============================
# SAVE FUNCTIONS / دوال الحفظ
# ============================

func save_all_data() -> void:
	## حفظ جميع البيانات
	var config := ConfigFile.new()
	
	# حفظ بيانات المراحل
	for level_id in level_data:
		var data = level_data[level_id]
		config.set_value("levels", str(level_id) + "_stars", data.get("stars", 0))
		config.set_value("levels", str(level_id) + "_best_time", data.get("best_time_ms", -1))
		config.set_value("levels", str(level_id) + "_best_score", data.get("best_score", 0))
		config.set_value("levels", str(level_id) + "_completed", data.get("completed", false))
	
	# حفظ إحصائيات الشخصيات
	for char_id in character_stats:
		var stats = character_stats[char_id]
		for key in stats:
			config.set_value("characters", char_id + "_" + key, stats[key])
	
	# حفظ الإعدادات
	for key in settings:
		config.set_value("settings", key, settings[key])
	
	# حفظ الإحصائيات العامة
	for key in global_stats:
		config.set_value("global", key, global_stats[key])
	
	var err := config.save(SAVE_PATH)
	if err == OK:
		emit_signal("data_saved")
		print("[SaveSystem] Data saved successfully / تم الحفظ بنجاح")
	else:
		push_error("[SaveSystem] Failed to save data / فشل الحفظ: " + str(err))
	
	_save_achievements()

func _save_achievements() -> void:
	## حفظ الإنجازات بشكل منفصل
	var config := ConfigFile.new()
	for ach_id in achievements:
		config.set_value("achievements", ach_id, achievements[ach_id]["unlocked"])
	config.save(ACHIEVEMENTS_PATH)

# ============================
# LOAD FUNCTIONS / دوال التحميل
# ============================

func load_all_data() -> void:
	## تحميل جميع البيانات المحفوظة
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	
	if err != OK:
		print("[SaveSystem] No save file found, using defaults / لا يوجد ملف حفظ")
		return
	
	# تحميل بيانات المراحل
	for key in config.get_section_keys("levels"):
		var parts = key.split("_")
		var level_id = int(parts[0])
		var field = "_".join(parts.slice(1))
		if not level_id in level_data:
			level_data[level_id] = {}
		level_data[level_id][field] = config.get_value("levels", key)
	
	# تحميل إحصائيات الشخصيات
	if config.has_section("characters"):
		for key in config.get_section_keys("characters"):
			var parts = key.split("_")
			var char_id = parts[0]
			var field = "_".join(parts.slice(1))
			if char_id in character_stats:
				character_stats[char_id][field] = config.get_value("characters", key)
	
	# تحميل الإعدادات
	if config.has_section("settings"):
		for key in config.get_section_keys("settings"):
			settings[key] = config.get_value("settings", key)
	
	# تحميل الإحصائيات العامة
	if config.has_section("global"):
		for key in config.get_section_keys("global"):
			global_stats[key] = config.get_value("global", key)
	
	_load_achievements()
	emit_signal("data_loaded")
	print("[SaveSystem] Data loaded / تم التحميل")

func _load_achievements() -> void:
	var config := ConfigFile.new()
	if config.load(ACHIEVEMENTS_PATH) == OK:
		for ach_id in achievements:
			if config.has_section_key("achievements", ach_id):
				achievements[ach_id]["unlocked"] = config.get_value("achievements", ach_id)

# ============================
# LEVEL DATA / بيانات المراحل
# ============================

func save_level_result(level_id: int, time_ms: int, score: int, gems: int, stars: int) -> void:
	## حفظ نتيجة مرحلة
	if not level_id in level_data:
		level_data[level_id] = {}
	
	var data = level_data[level_id]
	data["completed"] = true
	
	# تحديث أفضل وقت
	if data.get("best_time_ms", -1) == -1 or time_ms < data["best_time_ms"]:
		data["best_time_ms"] = time_ms
	
	# تحديث أفضل نقاط
	if score > data.get("best_score", 0):
		data["best_score"] = score
	
	# تحديث أعلى عدد نجوم
	if stars > data.get("stars", 0):
		data["stars"] = stars
	
	# تحديث الإحصائيات العامة
	global_stats["total_gems_collected"] += gems
	global_stats["total_wins"] += 1
	global_stats["current_win_streak"] += 1
	if global_stats["current_win_streak"] > global_stats["best_win_streak"]:
		global_stats["best_win_streak"] = global_stats["current_win_streak"]
	if level_id > global_stats["highest_level_reached"]:
		global_stats["highest_level_reached"] = level_id
	
	_check_achievements(level_id, time_ms, gems, stars)
	save_all_data()

func is_level_unlocked(level_id: int) -> bool:
	## التحقق من فتح المرحلة
	if level_id == 1:
		return true
	return level_data.get(level_id - 1, {}).get("completed", false)

func get_level_stars(level_id: int) -> int:
	return level_data.get(level_id, {}).get("stars", 0)

func get_level_best_time(level_id: int) -> int:
	return level_data.get(level_id, {}).get("best_time_ms", -1)

func get_world_progress(world_id: int) -> float:
	## نسبة تقدم العالم (0.0 - 1.0)
	var start_level = (world_id - 1) * 100 + 1
	var completed = 0
	for i in range(start_level, start_level + 100):
		if level_data.get(i, {}).get("completed", false):
			completed += 1
	return float(completed) / 100.0

# ============================
# ACHIEVEMENTS / الإنجازات
# ============================

func _check_achievements(level_id: int, time_ms: int, gems: int, stars: int) -> void:
	## التحقق من الإنجازات بعد إكمال مرحلة
	_try_unlock("first_win")
	
	var total_completed = _count_completed_levels()
	if total_completed >= 10: _try_unlock("level_10")
	if total_completed >= 50: _try_unlock("level_50")
	if total_completed >= 100: _try_unlock("level_100")
	if total_completed >= 500: _try_unlock("level_500")
	
	if global_stats["total_gems_collected"] >= 500:
		_try_unlock("gems_500")
	
	if global_stats["current_win_streak"] >= 10:
		_try_unlock("streak_10")
	
	if gems == 10 and stars == 3:
		_try_unlock("perfect_run")
	
	if time_ms < 10000:  # أقل من 10 ثوانٍ
		_try_unlock("speedrun")
	
	if level_id >= 901:
		_try_unlock("void_master")

func _try_unlock(achievement_id: String) -> void:
	## محاولة فتح إنجاز
	if achievement_id in achievements and not achievements[achievement_id]["unlocked"]:
		achievements[achievement_id]["unlocked"] = true
		emit_signal("achievement_unlocked", achievement_id)
		print("[Achievement] Unlocked / فُتح إنجاز: " + achievements[achievement_id]["name"])

func _count_completed_levels() -> int:
	var count = 0
	for id in level_data:
		if level_data[id].get("completed", false):
			count += 1
	return count

# ============================
# CHEAT CODES / الشيفرات
# ============================

func apply_cheat_code(code: String) -> bool:
	## تطبيق شيفرة للوصول لمرحلة معينة
	var codes := {
		"SPRING100": 100,   # فتح نهاية عالم الربيع
		"AUTUMN200": 200,   # فتح نهاية عالم الخريف
		"ICE300": 300,
		"DESERT400": 400,
		"DARK500": 500,
		"FIRE600": 600,
		"OCEAN700": 700,
		"DREAM800": 800,
		"CHAOS900": 900,
		"VOID1000": 1000,
		"ALLMAZE999": 999   # فتح كل المراحل
	}
	
	if code in codes and not code in global_stats["unlocked_codes"]:
		global_stats["unlocked_codes"].append(code)
		if code == "ALLMAZE999":
			# فتح كل المراحل
			for i in range(1, 1001):
				if not i in level_data:
					level_data[i] = {}
				level_data[i]["completed"] = true
		else:
			# فتح حتى المرحلة المحددة
			var target = codes[code]
			for i in range(1, target + 1):
				if not i in level_data:
					level_data[i] = {}
				level_data[i]["completed"] = true
		save_all_data()
		return true
	return false

# ============================
# SETTINGS / الإعدادات
# ============================

func set_setting(key: String, value) -> void:
	settings[key] = value
	save_all_data()

func get_setting(key: String, default_val = null):
	return settings.get(key, default_val)

func reset_all_data() -> void:
	## إعادة ضبط كل البيانات
	level_data.clear()
	_initialize_defaults()
	save_all_data()
	print("[SaveSystem] All data reset / تم إعادة الضبط")
