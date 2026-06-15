## achievement_system.gd
## نظام الإنجازات - يتتبع تقدم اللاعب ويمنح الإنجازات
## Achievement System - tracks player progress and grants achievements

extends Node

# ============================
# ACHIEVEMENT DEFINITIONS / تعريفات الإنجازات
# ============================
const ACHIEVEMENTS := {
	# إنجازات التقدم - Progress Achievements
	"first_win": {
		"title_ar": "الخطوة الأولى",
		"title_en": "First Step",
		"desc_ar": "أكمل مرحلتك الأولى",
		"icon": "🏆",
		"points": 10
	},
	"level_10": {
		"title_ar": "المبتدئ",
		"title_en": "Beginner",
		"desc_ar": "أكمل 10 مراحل",
		"icon": "⭐",
		"points": 20
	},
	"level_50": {
		"title_ar": "المحترف",
		"title_en": "Professional",
		"desc_ar": "أكمل 50 مرحلة",
		"icon": "🌟",
		"points": 50
	},
	"level_100": {
		"title_ar": "الخبير",
		"title_en": "Expert",
		"desc_ar": "أكمل 100 مرحلة وأنهِ العالم الأول",
		"icon": "💫",
		"points": 100
	},
	"level_500": {
		"title_ar": "الأسطورة",
		"title_en": "Legend",
		"desc_ar": "أكمل 500 مرحلة",
		"icon": "🔥",
		"points": 200
	},
	"level_1000": {
		"title_ar": "سيد المتاهة",
		"title_en": "Maze Master",
		"desc_ar": "أكمل جميع المراحل الـ1000!",
		"icon": "👑",
		"points": 1000
	},
	# إنجازات الجواهر
	"gems_100": {
		"title_ar": "جامع الكنوز",
		"title_en": "Treasure Hunter",
		"desc_ar": "اجمع 100 جوهرة",
		"icon": "💎",
		"points": 30
	},
	"gems_500": {
		"title_ar": "ملك الجواهر",
		"title_en": "Gem King",
		"desc_ar": "اجمع 500 جوهرة",
		"icon": "💍",
		"points": 100
	},
	"gems_1000": {
		"title_ar": "إمبراطور الثروة",
		"title_en": "Wealth Emperor",
		"desc_ar": "اجمع 1000 جوهرة",
		"icon": "🏛",
		"points": 250
	},
	# إنجازات الأداء
	"perfect_run": {
		"title_ar": "الكمال",
		"title_en": "Perfection",
		"desc_ar": "اجمع كل الجواهر في مرحلة واحدة",
		"icon": "✨",
		"points": 50
	},
	"speedrun_10": {
		"title_ar": "البرق",
		"title_en": "Lightning",
		"desc_ar": "أكمل مرحلة في أقل من 10 ثوانٍ",
		"icon": "⚡",
		"points": 75
	},
	"speedrun_5": {
		"title_ar": "الضوء",
		"title_en": "Speed of Light",
		"desc_ar": "أكمل مرحلة في أقل من 5 ثوانٍ",
		"icon": "🌠",
		"points": 150
	},
	"no_hit_10": {
		"title_ar": "الظل",
		"title_en": "Shadow",
		"desc_ar": "أكمل 10 مراحل متتالية بدون الاصطدام بالعدو",
		"icon": "🥷",
		"points": 80
	},
	"streak_5": {
		"title_ar": "المتسلسل",
		"title_en": "On a Roll",
		"desc_ar": "5 انتصارات متتالية",
		"icon": "🔗",
		"points": 25
	},
	"streak_10": {
		"title_ar": "سلسلة ذهبية",
		"title_en": "Golden Chain",
		"desc_ar": "10 انتصارات متتالية",
		"icon": "⛓",
		"points": 60
	},
	"streak_50": {
		"title_ar": "القاهر",
		"title_en": "Conqueror",
		"desc_ar": "50 انتصاراً متتالياً",
		"icon": "⚔️",
		"points": 300
	},
	# إنجازات الشخصيات
	"win_all_chars": {
		"title_ar": "بطل متعدد",
		"title_en": "Multi-Hero",
		"desc_ar": "افوز بمرحلة بكل شخصية",
		"icon": "👥",
		"points": 40
	},
	"knight_master": {
		"title_ar": "سيد الفرسان",
		"title_en": "Knight Master",
		"desc_ar": "افوز بـ50 مرحلة كالفارس",
		"icon": "🛡",
		"points": 100
	},
	"wizard_master": {
		"title_ar": "الساحر الأعظم",
		"title_en": "Archmage",
		"desc_ar": "افوز بـ50 مرحلة كالساحر",
		"icon": "🧙",
		"points": 100
	},
	"princess_master": {
		"title_ar": "الأميرة القوية",
		"title_en": "Warrior Princess",
		"desc_ar": "افوز بـ50 مرحلة كالأميرة",
		"icon": "👸",
		"points": 100
	},
	"thief_master": {
		"title_ar": "اللص المحترف",
		"title_en": "Master Thief",
		"desc_ar": "افوز بـ50 مرحلة كاللص",
		"icon": "🗝",
		"points": 100
	},
	# إنجازات العوالم
	"world_1_clear": {
		"title_ar": "ربيع النصر",
		"title_en": "Spring Victory",
		"desc_ar": "أكمل جميع مراحل حديقة الربيع",
		"icon": "🌸",
		"points": 50
	},
	"world_5_clear": {
		"title_ar": "صاحب الظلام",
		"title_en": "Darkness Tamer",
		"desc_ar": "أكمل جميع مراحل غابة الظلام",
		"icon": "🌑",
		"points": 100
	},
	"world_10_clear": {
		"title_ar": "سيد الفراغ",
		"title_en": "Void Master",
		"desc_ar": "أكمل جميع مراحل عالم الفراغ",
		"icon": "🌌",
		"points": 500
	},
	# إنجازات خاصة
	"use_code": {
		"title_ar": "الغشاش",
		"title_en": "Cheater",
		"desc_ar": "استخدم شيفرة سرية",
		"icon": "🔓",
		"points": 5
	},
	"die_100": {
		"title_ar": "لا تستسلم",
		"title_en": "Never Give Up",
		"desc_ar": "تعرض للاصطياد 100 مرة (الكمية ليست بالسهولة!)",
		"icon": "💪",
		"points": 15
	},
}

# ============================
# SIGNALS / الإشارات
# ============================
signal achievement_unlocked(achievement_id: String, data: Dictionary)

# ============================
# STATE / الحالة
# ============================
var save_system: Node
var unlocked_achievements: Dictionary = {}

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		save_system.achievement_unlocked.connect(_on_save_system_achievement)
		# تحميل الإنجازات المحفوظة
		unlocked_achievements = save_system.achievements

func _on_save_system_achievement(achievement_id: String) -> void:
	if achievement_id in ACHIEVEMENTS:
		emit_signal("achievement_unlocked", achievement_id, ACHIEVEMENTS[achievement_id])

# ============================
# CHECK ACHIEVEMENTS / التحقق من الإنجازات
# ============================

func check_after_win(level_id: int, time_ms: int, gems: int, gem_total: int, 
					  char_type: int, win_streak: int, total_wins: int, 
					  total_gems: int, no_enemy_hit: bool) -> void:
	## فحص شامل بعد كل نصر
	
	# إنجازات التقدم
	_try_unlock("first_win")
	if total_wins >= 10: _try_unlock("level_10")
	if total_wins >= 50: _try_unlock("level_50")
	if total_wins >= 100: _try_unlock("level_100")
	if total_wins >= 500: _try_unlock("level_500")
	if level_id >= 1000: _try_unlock("level_1000")
	
	# إنجازات الجواهر
	if total_gems >= 100: _try_unlock("gems_100")
	if total_gems >= 500: _try_unlock("gems_500")
	if total_gems >= 1000: _try_unlock("gems_1000")
	
	# الأداء
	if gems == gem_total: _try_unlock("perfect_run")
	if time_ms < 10000: _try_unlock("speedrun_10")
	if time_ms < 5000: _try_unlock("speedrun_5")
	
	# سلاسل الانتصارات
	if win_streak >= 5: _try_unlock("streak_5")
	if win_streak >= 10: _try_unlock("streak_10")
	if win_streak >= 50: _try_unlock("streak_50")
	
	# الشخصيات
	_check_character_achievements(char_type)
	
	# العوالم
	var world_id = ceili(float(level_id) / 100.0)
	if world_id >= 1 and _is_world_complete(1): _try_unlock("world_1_clear")
	if world_id >= 5 and _is_world_complete(5): _try_unlock("world_5_clear")
	if world_id >= 10 and _is_world_complete(10): _try_unlock("world_10_clear")

func _check_character_achievements(char_type: int) -> void:
	if not save_system:
		return
	
	var char_names := ["knight", "wizard", "princess", "thief"]
	var char_keys := ["knight_master", "wizard_master", "princess_master", "thief_master"]
	
	if char_type < char_names.size():
		var wins = save_system.character_stats[char_names[char_type]].get("wins", 0)
		if wins >= 50:
			_try_unlock(char_keys[char_type])
	
	# التحقق من الفوز بكل الشخصيات
	var all_won = true
	for cn in char_names:
		if save_system.character_stats[cn].get("wins", 0) == 0:
			all_won = false
			break
	if all_won:
		_try_unlock("win_all_chars")

func _is_world_complete(world_id: int) -> bool:
	if not save_system:
		return false
	return save_system.get_world_progress(world_id) >= 1.0

func _try_unlock(achievement_id: String) -> void:
	if not save_system:
		return
	if achievement_id in save_system.achievements and not save_system.achievements[achievement_id]["unlocked"]:
		save_system._try_unlock(achievement_id)

# ============================
# GETTERS / الحاصلات
# ============================

func get_achievement_data(achievement_id: String) -> Dictionary:
	return ACHIEVEMENTS.get(achievement_id, {})

func get_all_achievements_sorted() -> Array:
	var result := []
	for id in ACHIEVEMENTS:
		var data = ACHIEVEMENTS[id].duplicate()
		data["id"] = id
		data["unlocked"] = save_system.achievements.get(id, {}).get("unlocked", false) if save_system else false
		result.append(data)
	return result

func get_total_achievement_points() -> int:
	var total := 0
	if save_system:
		for id in save_system.achievements:
			if save_system.achievements[id].get("unlocked", false) and id in ACHIEVEMENTS:
				total += ACHIEVEMENTS[id].get("points", 0)
	return total
