## enemy.gd
## الذكاء الاصطناعي للعدو - يدير سلوك وحركة جميع أنواع الأعداء
## Enemy AI - manages behavior and movement for all enemy types

extends CharacterBody3D

# ============================
# ENUMS / التعدادات
# ============================
enum EnemyState { PATROLLING, CHASING, ATTACKING, STUNNED }
enum EnemyType {
	WARDEN,          # الحارس الأصلي (دب/غولم)
	GIANT_BEE,       # عالم الربيع
	FIRE_WOLF,       # عالم الخريف
	ICE_BEAR,        # عالم الجليد
	GIANT_SCORPION,  # عالم الصحراء
	GHOST,           # عالم الظلام
	FIRE_DEMON,      # عالم النار
	GIANT_SHARK,     # أتلانتس
	NIGHTMARE,       # عالم الأحلام
	CHAOS_BEAST,     # عالم الفوضى
	VOID_ENTITY      # عالم الفراغ
}

# ============================
# EXPORTS / متغيرات المحرر
# ============================
@export var enemy_type: EnemyType = EnemyType.WARDEN
@export var patrol_speed: float = 3.0
@export var chase_speed: float = 6.0
@export var detection_radius: float = 5.0
@export var attack_radius: float = 1.5

# ============================
# NODE REFERENCES / مراجع العقد
# ============================
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var roar_audio: AudioStreamPlayer3D = $RoarAudio
@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio
@onready var detection_area: Area3D = $DetectionArea
@onready var glowing_eyes: OmniLight3D = $GlowingEyes
@onready var ground_shockwave: GPUParticles3D = $GroundShockwave

# ============================
# AI VARIABLES / متغيرات الذكاء الاصطناعي
# ============================
var current_state: EnemyState = EnemyState.PATROLLING
var patrol_points: Array[Vector3] = []  # 8 نقاط دوريات
var current_patrol_index: int = 0
var target_player: CharacterBody3D = null
var speed_multiplier: float = 1.0  # يتغير حسب المرحلة
var is_in_slow_time: bool = false   # تأثير قدرة الأميرة

# الإحصائيات الخاصة بكل نوع عدو
var enemy_stats: Dictionary = {}

# تاريخ الروار لمنع التكرار
var last_roar_time: float = 0.0
const ROAR_COOLDOWN := 3.0

# اهتزاز الأرض عند الخطوات
var step_timer: float = 0.0
const HEAVY_STEP_INTERVAL := 0.6

signal enemy_spotted_player
signal player_caught(player: CharacterBody3D)

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	_setup_enemy_stats()
	_setup_visual_appearance()
	_connect_signals()
	
	# ضبط NavigationAgent
	if nav_agent:
		nav_agent.path_desired_distance = 0.5
		nav_agent.target_desired_distance = 1.0
	
	print("[Enemy] Initialized: " + EnemyType.keys()[enemy_type])

func _setup_enemy_stats() -> void:
	## تحديد إحصائيات كل نوع عدو
	match enemy_type:
		EnemyType.WARDEN, EnemyType.ICE_BEAR:
			enemy_stats = {"scale": 2.0, "eye_color": Color.RED, "heavy_steps": true}
			patrol_speed = 2.5
			chase_speed = 5.5
		EnemyType.GIANT_BEE:
			enemy_stats = {"scale": 1.5, "eye_color": Color.YELLOW, "heavy_steps": false}
			patrol_speed = 4.0
			chase_speed = 7.0
			detection_radius = 7.0  # النحلة ترى أبعد
		EnemyType.FIRE_WOLF:
			enemy_stats = {"scale": 1.3, "eye_color": Color.ORANGE, "heavy_steps": false}
			patrol_speed = 5.0
			chase_speed = 8.0
		EnemyType.GIANT_SCORPION:
			enemy_stats = {"scale": 1.8, "eye_color": Color.GREEN, "heavy_steps": true}
			patrol_speed = 2.0
			chase_speed = 5.0
		EnemyType.GHOST:
			enemy_stats = {"scale": 1.2, "eye_color": Color.CYAN, "heavy_steps": false}
			patrol_speed = 3.5
			chase_speed = 6.5
			# الشبح يمر عبر الجدران
		EnemyType.FIRE_DEMON:
			enemy_stats = {"scale": 2.5, "eye_color": Color(1.0, 0.3, 0.0), "heavy_steps": true}
			patrol_speed = 2.0
			chase_speed = 6.0
		EnemyType.GIANT_SHARK:
			enemy_stats = {"scale": 3.0, "eye_color": Color.BLACK, "heavy_steps": false}
			patrol_speed = 3.0
			chase_speed = 7.5
		EnemyType.NIGHTMARE:
			enemy_stats = {"scale": 1.0, "eye_color": Color.PURPLE, "heavy_steps": false}
			patrol_speed = 4.0
			chase_speed = 8.0
			detection_radius = 8.0
		EnemyType.CHAOS_BEAST:
			enemy_stats = {"scale": randf_range(1.0, 3.0), "eye_color": Color(randf(), randf(), randf()), "heavy_steps": true}
			patrol_speed = randf_range(2.0, 5.0)
			chase_speed = randf_range(6.0, 9.0)
		EnemyType.VOID_ENTITY:
			enemy_stats = {"scale": 2.0, "eye_color": Color.WHITE, "heavy_steps": false}
			patrol_speed = 3.0
			chase_speed = 7.0
			detection_radius = 10.0  # يرى أكثر
	
	scale = Vector3.ONE * enemy_stats.get("scale", 1.5)

func _setup_visual_appearance() -> void:
	## إعداد المظهر البصري للعدو
	if mesh_instance:
		var mat = StandardMaterial3D.new()
		_apply_enemy_material(mat)
		mesh_instance.material_override = mat
	
	# إعداد العيون المضيئة
	if glowing_eyes:
		glowing_eyes.light_color = enemy_stats.get("eye_color", Color.RED)
		glowing_eyes.light_energy = 2.0
		glowing_eyes.omni_range = 1.5

func _apply_enemy_material(mat: StandardMaterial3D) -> void:
	match enemy_type:
		EnemyType.WARDEN:
			mat.albedo_color = Color(0.4, 0.3, 0.2)
			mat.roughness = 0.9
		EnemyType.GIANT_BEE:
			mat.albedo_color = Color(0.9, 0.7, 0.0)
			mat.roughness = 0.4
		EnemyType.FIRE_WOLF:
			mat.albedo_color = Color(0.8, 0.2, 0.0)
			mat.emission_enabled = true
			mat.emission = Color(1.0, 0.3, 0.0)
			mat.emission_energy_multiplier = 0.5
		EnemyType.ICE_BEAR:
			mat.albedo_color = Color(0.9, 0.95, 1.0)
			mat.metallic = 0.1
			mat.roughness = 0.2
		EnemyType.GIANT_SCORPION:
			mat.albedo_color = Color(0.7, 0.5, 0.1)
			mat.roughness = 0.7
		EnemyType.GHOST:
			mat.albedo_color = Color(0.7, 0.9, 1.0)
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = 0.6
			mat.emission_enabled = true
			mat.emission = Color(0.5, 0.8, 1.0)
			mat.emission_energy_multiplier = 1.0
		EnemyType.FIRE_DEMON:
			mat.albedo_color = Color(0.2, 0.0, 0.0)
			mat.emission_enabled = true
			mat.emission = Color(1.0, 0.2, 0.0)
			mat.emission_energy_multiplier = 2.0
		EnemyType.GIANT_SHARK:
			mat.albedo_color = Color(0.3, 0.3, 0.4)
			mat.metallic = 0.2
			mat.roughness = 0.6
		EnemyType.NIGHTMARE:
			mat.albedo_color = Color(0.1, 0.0, 0.2)
			mat.emission_enabled = true
			mat.emission = Color(0.5, 0.0, 1.0)
			mat.emission_energy_multiplier = 1.5
		EnemyType.VOID_ENTITY:
			mat.albedo_color = Color(0.0, 0.0, 0.0)
			mat.emission_enabled = true
			mat.emission = Color(1.0, 1.0, 1.0)
			mat.emission_energy_multiplier = 0.5

func _connect_signals() -> void:
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)

# ============================
# MAIN AI LOOP / حلقة الذكاء الرئيسية
# ============================
func _physics_process(delta: float) -> void:
	if is_in_slow_time:
		delta *= 0.4  # تأثير قدرة الأميرة
	
	match current_state:
		EnemyState.PATROLLING:
			_patrol_behavior(delta)
		EnemyState.CHASING:
			_chase_behavior(delta)
		EnemyState.ATTACKING:
			_attack_behavior(delta)
	
	# تطبيق الجاذبية
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	
	_handle_heavy_steps(delta)
	move_and_slide()

# ============================
# PATROL BEHAVIOR / سلوك الدوريات
# ============================
func _patrol_behavior(delta: float) -> void:
	## التحرك بين 8 نقاط دوريات بشكل عشوائي
	if patrol_points.is_empty() or not nav_agent:
		return
	
	var target = patrol_points[current_patrol_index]
	nav_agent.target_position = target
	
	if nav_agent.is_navigation_finished():
		# الانتظار قليلاً ثم الانتقال للنقطة التالية
		await get_tree().create_timer(randf_range(0.5, 2.0)).timeout
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		# أحياناً التحرك لنقطة عشوائية
		if randf() < 0.3:
			current_patrol_index = randi() % patrol_points.size()
	else:
		_move_towards_target(patrol_speed * speed_multiplier, delta)
	
	# التحقق من قرب اللاعب
	if target_player:
		var dist = global_position.distance_to(target_player.global_position)
		if dist <= detection_radius:
			_switch_to_chase()

func _switch_to_chase() -> void:
	current_state = EnemyState.CHASING
	_trigger_roar()
	emit_signal("enemy_spotted_player")

# ============================
# CHASE BEHAVIOR / سلوك المطاردة
# ============================
func _chase_behavior(delta: float) -> void:
	## مطاردة اللاعب مباشرة
	if not target_player:
		current_state = EnemyState.PATROLLING
		return
	
	var dist = global_position.distance_to(target_player.global_position)
	
	# التحقق من الخروج من مدى الاكتشاف
	if dist > detection_radius * 2.0:
		current_state = EnemyState.PATROLLING
		target_player = null
		return
	
	# التحرك نحو اللاعب
	if nav_agent:
		nav_agent.target_position = target_player.global_position
		_move_towards_target(chase_speed * speed_multiplier, delta)
	
	# التحقق من المهاجمة
	if dist <= attack_radius:
		_switch_to_attack()

func _switch_to_attack() -> void:
	current_state = EnemyState.ATTACKING

# ============================
# ATTACK BEHAVIOR / سلوك الهجوم
# ============================
func _attack_behavior(delta: float) -> void:
	if not target_player:
		current_state = EnemyState.PATROLLING
		return
	
	var dist = global_position.distance_to(target_player.global_position)
	
	if dist <= attack_radius:
		# إصابة اللاعب
		if target_player.has_method("on_enemy_hit"):
			target_player.on_enemy_hit()
		_trigger_roar()
		emit_signal("player_caught", target_player)
		current_state = EnemyState.PATROLLING
	else:
		current_state = EnemyState.CHASING

# ============================
# MOVEMENT / الحركة
# ============================
func _move_towards_target(speed: float, delta: float) -> void:
	if not nav_agent or nav_agent.is_navigation_finished():
		return
	
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	direction.y = 0.0
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	# تدوير نحو الهدف
	if direction.length() > 0.01:
		var target_rot = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot, delta * 8.0)

# ============================
# SOUND & EFFECTS / الصوت والمؤثرات
# ============================
func _trigger_roar() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_roar_time < ROAR_COOLDOWN:
		return
	
	last_roar_time = current_time
	
	if roar_audio:
		roar_audio.play()
	
	# اهتزاز الكاميرا عبر GameManager
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("shake_camera"):
		gm.shake_camera(0.5, 0.3)

func _handle_heavy_steps(delta: float) -> void:
	## تأثير اهتزاز الأرض عند الخطوات الثقيلة
	if not enemy_stats.get("heavy_steps", false):
		return
	
	step_timer -= delta
	if step_timer <= 0.0 and velocity.length() > 1.0:
		step_timer = HEAVY_STEP_INTERVAL
		
		if footstep_audio:
			footstep_audio.play()
		
		if ground_shockwave:
			ground_shockwave.restart()
		
		# اهتزاز خفيف للكاميرا
		var gm = get_node_or_null("/root/GameManager")
		if gm and gm.has_method("shake_camera"):
			gm.shake_camera(0.2, 0.1)

# ============================
# DETECTION / الكشف
# ============================
func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("on_enemy_hit"):
		target_player = body
		if current_state == EnemyState.PATROLLING:
			_switch_to_chase()

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == target_player:
		# لا نفقد اللاعب فوراً - نعطي فرصة للمطاردة
		pass

# ============================
# PATROL SETUP / إعداد الدوريات
# ============================
func setup_patrol_points(points: Array[Vector3]) -> void:
	## تعيين نقاط الدوريات من world_manager
	patrol_points = points
	if patrol_points.size() > 0:
		current_patrol_index = randi() % patrol_points.size()

func set_speed_multiplier(mult: float) -> void:
	## تعديل السرعة بناءً على الصعوبة
	speed_multiplier = mult

func set_slow_time_active(active: bool) -> void:
	## تأثير قدرة الأميرة
	is_in_slow_time = active

# ============================
# VOID ENTITY SPECIAL / قدرة عالم الفراغ الخاصة
# ============================
func _change_form_to_world(world_id: int) -> void:
	## عدو عالم الفراغ يغير شكله
	if enemy_type != EnemyType.VOID_ENTITY:
		return
	
	var mat = mesh_instance.material_override as StandardMaterial3D
	if not mat:
		return
	
	var colors := [
		Color(1.0, 0.7, 0.8),   # ربيع
		Color(1.0, 0.5, 0.1),   # خريف
		Color(0.7, 0.9, 1.0),   # جليد
		Color(1.0, 0.9, 0.3),   # صحراء
		Color(0.5, 0.0, 1.0),   # ظلام
		Color(1.0, 0.2, 0.0),   # نار
		Color(0.0, 0.8, 1.0),   # بحر
		Color(0.8, 0.0, 1.0)    # أحلام
	]
	
	var idx = clamp(world_id - 1, 0, colors.size() - 1)
	mat.emission = colors[idx]
	
	# تغيير الحجم عشوائياً
	var new_scale = randf_range(1.5, 3.0)
	scale = Vector3.ONE * new_scale
