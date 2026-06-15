## difficulty_curve.gd
## منحنى الصعوبة - يحدد معاملات كل مرحلة من 1 إلى 1000+
## Difficulty Curve - determines parameters for each level 1-1000+

extends Resource
class_name DifficultyCurve

# ============================
# DIFFICULTY DATA / بيانات الصعوبة
# ============================

## جدول الصعوبة لكل 10 مراحل - Difficulty table per 10 levels
## [timer_seconds, enemy_speed_multiplier, gem_count, dead_ends]
const DIFFICULTY_TABLE := [
	# مراحل   وقت  سرعة  جواهر  مسدودات
	[  1,  60, 1.00, 10, 3 ],   # 1-10
	[ 11,  58, 1.10,  9, 4 ],   # 11-20
	[ 21,  56, 1.20,  9, 4 ],   # 21-30
	[ 31,  54, 1.30,  8, 5 ],   # 31-40
	[ 41,  52, 1.40,  8, 5 ],   # 41-50
	[ 51,  50, 1.50,  7, 6 ],   # 51-60
	[ 61,  48, 1.60,  7, 6 ],   # 61-70
	[ 71,  46, 1.70,  6, 7 ],   # 71-80
	[ 81,  44, 1.80,  6, 7 ],   # 81-90
	[ 91,  40, 2.00,  5, 8 ],   # 91-100
]

## الخوارزميات حسب مرحلة العالم - Algorithms per world range
enum MazeAlgorithm {
	RECURSIVE_BACKTRACKER,  # عوالم 1-2
	PRIMS,                  # عوالم 3-4
	ELLERS,                 # عوالم 5-6
	GROWING_TREE,           # عوالم 7-8
	ALDOUS_BRODER_WILSON    # عوالم 9-10
}

# ============================
# LEVEL CONFIG CLASS / كلاس إعدادات المرحلة
# ============================

class LevelConfig:
	var level_id: int
	var world_id: int           # 1-10
	var world_level: int        # 1-100 داخل العالم
	var timer_seconds: float
	var enemy_speed_mult: float
	var gem_count: int
	var dead_ends: int
	var maze_width: int
	var maze_height: int
	var maze_algorithm: int
	var world_theme: String
	var enemy_type: String
	var gem_color: Color
	var ambient_color: Color
	var fog_density: float
	var extra_enemies: int      # أعداء إضافية في المراحل المتأخرة

# ============================
# MAIN FUNCTION / الدالة الرئيسية
# ============================

static func get_level_config(level_id: int) -> LevelConfig:
	## الحصول على إعدادات مرحلة محددة
	var config := LevelConfig.new()
	config.level_id = level_id
	
	# تحديد العالم والمرحلة داخله
	config.world_id = ceili(float(level_id) / 100.0)
	config.world_id = clamp(config.world_id, 1, 10)
	config.world_level = ((level_id - 1) % 100) + 1
	
	# تطبيق الصعوبة بناءً على المرحلة داخل العالم
	var diff = _get_difficulty_row(config.world_level)
	config.timer_seconds = diff[1]
	config.enemy_speed_mult = diff[2]
	config.gem_count = diff[3]
	config.dead_ends = diff[4]
	
	# تعديل إضافي بناءً على رقم العالم
	var world_bonus_time = max(0, (10 - config.world_id) * 2)
	config.timer_seconds += world_bonus_time
	config.enemy_speed_mult *= (1.0 + (config.world_id - 1) * 0.05)
	
	# تحديد حجم المتاهة وخوارزميتها
	_apply_maze_settings(config)
	
	# تحديد ثيم العالم
	_apply_world_theme(config)
	
	# أعداء إضافية في المراحل المتأخرة
	config.extra_enemies = max(0, (config.world_id - 5))
	
	return config

static func _get_difficulty_row(world_level: int) -> Array:
	## الحصول على صف الصعوبة
	for i in range(DIFFICULTY_TABLE.size() - 1, -1, -1):
		if world_level >= DIFFICULTY_TABLE[i][0]:
			return DIFFICULTY_TABLE[i]
	return DIFFICULTY_TABLE[0]

static func _apply_maze_settings(config: LevelConfig) -> void:
	## تطبيق إعدادات المتاهة حسب رقم العالم
	match config.world_id:
		1, 2:  # عوالم 1-200
			config.maze_width = 25
			config.maze_height = 25
			config.maze_algorithm = MazeAlgorithm.RECURSIVE_BACKTRACKER
		3, 4:  # عوالم 201-400
			config.maze_width = 28
			config.maze_height = 28
			config.maze_algorithm = MazeAlgorithm.PRIMS
		5, 6:  # عوالم 401-600
			config.maze_width = 30
			config.maze_height = 30
			config.maze_algorithm = MazeAlgorithm.ELLERS
		7, 8:  # عوالم 601-800
			config.maze_width = 32
			config.maze_height = 32
			config.maze_algorithm = MazeAlgorithm.GROWING_TREE
		9, 10:  # عوالم 801-1000
			config.maze_width = 35
			config.maze_height = 35
			config.maze_algorithm = MazeAlgorithm.ALDOUS_BRODER_WILSON

static func _apply_world_theme(config: LevelConfig) -> void:
	## تطبيق ثيم العالم على الإعدادات البصرية
	match config.world_id:
		1:  # حديقة الربيع - Spring Garden
			config.world_theme = "spring"
			config.enemy_type = "giant_bee"
			config.gem_color = Color(1.0, 0.7, 0.8)       # وردي
			config.ambient_color = Color(1.0, 0.95, 0.8)   # ذهبي دافئ
			config.fog_density = 0.01
		2:  # غابة الخريف - Autumn Forest
			config.world_theme = "autumn"
			config.enemy_type = "fire_wolf"
			config.gem_color = Color(1.0, 0.5, 0.1)       # برتقالي
			config.ambient_color = Color(1.0, 0.6, 0.2)
			config.fog_density = 0.02
		3:  # مملكة الجليد - Ice Kingdom
			config.world_theme = "ice"
			config.enemy_type = "ice_bear"
			config.gem_color = Color(0.7, 0.9, 1.0)       # أزرق فاتح
			config.ambient_color = Color(0.8, 0.9, 1.0)
			config.fog_density = 0.03
		4:  # صحراء الرمال - Sand Desert
			config.world_theme = "desert"
			config.enemy_type = "giant_scorpion"
			config.gem_color = Color(1.0, 0.9, 0.3)       # ذهبي
			config.ambient_color = Color(1.0, 0.85, 0.5)
			config.fog_density = 0.015
		5:  # غابة الظلام - Dark Forest
			config.world_theme = "dark"
			config.enemy_type = "ghost"
			config.gem_color = Color(0.5, 0.0, 1.0)       # بنفسجي
			config.ambient_color = Color(0.1, 0.0, 0.2)
			config.fog_density = 0.05
		6:  # أرض النار - Fire Land
			config.world_theme = "fire"
			config.enemy_type = "fire_demon"
			config.gem_color = Color(1.0, 0.2, 0.0)       # أحمر
			config.ambient_color = Color(0.8, 0.2, 0.0)
			config.fog_density = 0.04
		7:  # أتلانتس - Atlantis
			config.world_theme = "ocean"
			config.enemy_type = "giant_shark"
			config.gem_color = Color(0.0, 0.8, 1.0)       # أزرق
			config.ambient_color = Color(0.0, 0.4, 0.6)
			config.fog_density = 0.06
		8:  # عالم الأحلام - Dream World
			config.world_theme = "dream"
			config.enemy_type = "nightmare"
			config.gem_color = Color(0.8, 0.0, 1.0)       # أرجواني
			config.ambient_color = Color(0.3, 0.0, 0.5)
			config.fog_density = 0.03
		9:  # عالم الفوضى - Chaos World
			config.world_theme = "chaos"
			config.enemy_type = "chaos_beast"
			config.gem_color = Color(randf(), randf(), randf())  # عشوائي
			config.ambient_color = Color(randf_range(0.3, 1.0), randf_range(0.0, 0.5), randf_range(0.0, 1.0))
			config.fog_density = randf_range(0.01, 0.08)
		10:  # عالم الفراغ - The Void
			config.world_theme = "void"
			config.enemy_type = "void_entity"
			config.gem_color = Color(1.0, 1.0, 1.0)       # أبيض
			config.ambient_color = Color(0.0, 0.0, 0.0)   # أسود
			config.fog_density = 0.08

# ============================
# STAR RATING / تقييم النجوم
# ============================

static func calculate_stars(level_id: int, time_remaining: float, gems_collected: int, gem_count: int) -> int:
	## حساب عدد النجوم بناءً على الأداء
	var config = get_level_config(level_id)
	var star_count := 0
	
	# نجمة واحدة: الإكمال فقط
	star_count = 1
	
	# نجمتان: جمع نصف الجواهر أو أكثر
	if float(gems_collected) / float(gem_count) >= 0.5:
		star_count = 2
	
	# ثلاث نجوم: جمع كل الجواهر + وقت متبقي > 20% من الوقت الكلي
	if gems_collected == gem_count and time_remaining > config.timer_seconds * 0.2:
		star_count = 3
	
	return star_count

# ============================
# BONUS SCORE / النقاط الإضافية
# ============================

static func calculate_score(gems_collected: int, time_remaining: float, 
							 no_enemy_hits: bool, world_id: int) -> int:
	## حساب النقاط الكاملة
	var base_score := gems_collected * 10
	var time_bonus := int(time_remaining * 2.0)
	var gem_bonus := gems_collected * 5
	var world_bonus := world_id * 10  # مكافأة للعوالم المتقدمة
	var no_hit_bonus := 50 if no_enemy_hits else 0
	
	return base_score + time_bonus + gem_bonus + world_bonus + no_hit_bonus
