## character_select.gd
## شاشة اختيار الشخصية - Character Selection Screen

extends Node3D

# ============================
# CHARACTER DATA / بيانات الشخصيات
# ============================
const CHARACTERS := [
	{
		"id": 0,
		"name_ar": "الفارس الأخضر",
		"name_en": "Sir Cedric",
		"ability_ar": "اندفاع السرعة ⚡",
		"desc_ar": "يندفع بسرعة 50% أكبر لمدة 3 ثوانٍ",
		"stats": {"speed": 4, "ability": 3, "armor": 5},
		"color": Color(0.2, 0.6, 0.2),
		"icon": "🛡"
	},
	{
		"id": 1,
		"name_ar": "الساحر الأزرق",
		"name_en": "Archmage Zephyros",
		"ability_ar": "اختراق الجدار 🌀",
		"desc_ar": "يخترق شجرة واحدة ويمر عبرها",
		"stats": {"speed": 3, "ability": 5, "armor": 2},
		"color": Color(0.1, 0.3, 0.9),
		"icon": "🧙"
	},
	{
		"id": 2,
		"name_ar": "الأميرة الذهبية",
		"name_en": "Princess Elara",
		"ability_ar": "إبطاء الزمن ⏳",
		"desc_ar": "تُبطئ كل شيء بنسبة 60% لمدة 4 ثوانٍ",
		"stats": {"speed": 3, "ability": 4, "armor": 3},
		"color": Color(1.0, 0.8, 0.2),
		"icon": "👸"
	},
	{
		"id": 3,
		"name_ar": "اللص الأسود",
		"name_en": "Shadow Veil",
		"ability_ar": "رؤية المسار 👁",
		"desc_ar": "يرى أقصر طريق للخروج لمدة 5 ثوانٍ",
		"stats": {"speed": 5, "ability": 4, "armor": 1},
		"color": Color(0.1, 0.1, 0.1),
		"icon": "🗡"
	}
]

# ============================
# NODE REFERENCES / مراجع العقد
# ============================
@onready var char_carousel: Node3D = $CharacterCarousel
@onready var char_name_label: Label = $UI/InfoPanel/NameLabel
@onready var char_ability_label: Label = $UI/InfoPanel/AbilityLabel
@onready var char_desc_label: Label = $UI/InfoPanel/DescLabel
@onready var speed_bar: ProgressBar = $UI/InfoPanel/Stats/SpeedBar
@onready var ability_bar: ProgressBar = $UI/InfoPanel/Stats/AbilityBar
@onready var armor_bar: ProgressBar = $UI/InfoPanel/Stats/ArmorBar
@onready var select_button: Button = $UI/SelectButton
@onready var prev_button: Button = $UI/PrevButton
@onready var next_button: Button = $UI/NextButton
@onready var back_button: Button = $UI/BackButton
@onready var wins_label: Label = $UI/InfoPanel/WinsLabel

# ============================
# STATE / الحالة
# ============================
var selected_index: int = 0
var character_models: Array[Node3D] = []
var carousel_rotation: float = 0.0
var target_rotation: float = 0.0

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	_create_character_models()
	_connect_buttons()
	_update_display()
	
	# استعادة الشخصية المحددة مسبقاً
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		selected_index = gm.selected_character
	
	_update_display()

func _create_character_models() -> void:
	## إنشاء نماذج الشخصيات في الدائرة
	for i in range(4):
		var model := MeshInstance3D.new()
		var capsule := CapsuleMesh.new()
		capsule.radius = 0.4
		capsule.height = 1.8
		model.mesh = capsule
		
		var mat := StandardMaterial3D.new()
		mat.albedo_color = CHARACTERS[i]["color"]
		mat.metallic = 0.5
		mat.roughness = 0.3
		model.material_override = mat
		
		# توزيع الشخصيات في دائرة
		var angle = (float(i) / 4.0) * TAU
		var radius = 3.0
		model.position = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		model.position.y = 0.9
		
		char_carousel.add_child(model)
		character_models.append(model)
		
		# إضافة ضوء فوق كل شخصية
		var light := OmniLight3D.new()
		light.light_color = CHARACTERS[i]["color"]
		light.light_energy = 2.0
		light.omni_range = 2.0
		light.position = Vector3(cos(angle) * radius, 3.0, sin(angle) * radius)
		char_carousel.add_child(light)

func _connect_buttons() -> void:
	if select_button:
		select_button.pressed.connect(_on_select_pressed)
	if prev_button:
		prev_button.pressed.connect(_on_prev)
	if next_button:
		next_button.pressed.connect(_on_next)
	if back_button:
		back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))

# ============================
# PROCESS / المعالجة
# ============================
func _process(delta: float) -> void:
	# تدوير الكاروسيل
	carousel_rotation = lerp_angle(carousel_rotation, target_rotation, delta * 6.0)
	if char_carousel:
		char_carousel.rotation.y = carousel_rotation
	
	# تنشيط الشخصية المختارة
	for i in range(character_models.size()):
		if i < character_models.size():
			var is_selected = (i == selected_index)
			var target_scale = Vector3(1.3, 1.3, 1.3) if is_selected else Vector3(1.0, 1.0, 1.0)
			character_models[i].scale = character_models[i].scale.lerp(target_scale, delta * 8.0)
			
			# تدوير الشخصية المختارة
			if is_selected:
				character_models[i].rotation.y += delta * 1.5

func _update_display() -> void:
	var char_data = CHARACTERS[selected_index]
	
	if char_name_label:
		char_name_label.text = "%s %s\n%s" % [
			char_data["icon"], char_data["name_ar"], char_data["name_en"]
		]
	
	if char_ability_label:
		char_ability_label.text = "القدرة الخاصة: " + char_data["ability_ar"]
	
	if char_desc_label:
		char_desc_label.text = char_data["desc_ar"]
	
	var stats = char_data["stats"]
	if speed_bar: speed_bar.value = stats["speed"] * 20
	if ability_bar: ability_bar.value = stats["ability"] * 20
	if armor_bar: armor_bar.value = stats["armor"] * 20
	
	# عرض إحصائيات الفوز من السجل
	var char_names := ["knight", "wizard", "princess", "thief"]
	var save_sys = get_node_or_null("/root/SaveSystem")
	if wins_label and save_sys:
		var wins = save_sys.character_stats[char_names[selected_index]].get("wins", 0)
		wins_label.text = "الانتصارات: %d" % wins
	
	# تحديث تدوير الكاروسيل لإظهار الشخصية المختارة في الأمام
	target_rotation = -(float(selected_index) / 4.0) * TAU

# ============================
# NAVIGATION / التنقل
# ============================
func _on_prev() -> void:
	selected_index = (selected_index - 1 + 4) % 4
	_update_display()

func _on_next() -> void:
	selected_index = (selected_index + 1) % 4
	_update_display()

func _on_select_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.select_character(selected_index)
		gm.go_to_stage_select()
	else:
		get_tree().change_scene_to_file("res://scenes/stage_select.tscn")

# ============================
# SWIPE INPUT / إدخال التمرير
# ============================
var swipe_start: Vector2 = Vector2.ZERO
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
	elif event is InputEventScreenDrag:
		var diff = event.position.x - swipe_start.x
		if abs(diff) > 50:
			if diff > 0:
				_on_prev()
			else:
				_on_next()
			swipe_start = event.position
